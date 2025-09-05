#!/usr/bin/env python3
"""
Camera Controller with Flask and MQTT - Enhanced with Calibration Tool
FIXED: Uses the working publish_position.sh method for position reporting
"""

import requests
import os
import time
import threading
import subprocess
import logging
import json
from datetime import datetime
from flask import Flask, Response, send_file, jsonify, request
import paho.mqtt.client as mqtt


# Tool management configuration
TOOLS_CONFIG_FILE = "/home/pi/tools_config.json"
tools_config = {"tools": [], "camera_reference": None}

# Configure logging with more detailed output
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("camera_flask_mqtt")

# Camera settings
CAPTURE_DIR = "/home/pi/captures"
CALIBRATION_DIR = "/home/pi/calibration"
HTTP_PORT = 8080
STREAM_ACTIVE = False
STREAM_WIDTH = 1280
STREAM_HEIGHT = 720
CAPTURE_WIDTH = 4656
CAPTURE_HEIGHT = 3496
STREAM_QUALITY = "medium"

# Focus settings
FOCUS_MODE = "auto"
FOCUS_POSITION = 10

# MQTT Settings
MQTT_BROKER = "192.168.1.89"
MQTT_PORT = 1883
MQTT_COMMAND_TOPIC = "dakash/camera/command"
MQTT_CONFIG_TOPIC = "dakash/camera/config"
MQTT_STATUS_TOPIC = "dakash/camera/status"
MQTT_KLIPPER_GCODE_TOPIC = "dakash/klipper/gcode"
MQTT_KLIPPER_POSITION_RESPONSE = "dakash/klipper/position/response"
MQTT_CALIBRATION_TOPIC = "dakash/camera/calibration"

# Calibration settings
calibration_data = {
    "microns_per_pixel_x": 10.0,
    "microns_per_pixel_y": 10.0,
    "reference_points": [],
    "enabled": False,
    "scaler_measurements": []
}

# Ensure directories exist
os.makedirs(CAPTURE_DIR, exist_ok=True)
os.makedirs(CALIBRATION_DIR, exist_ok=True)

# Create Flask app
app = Flask(__name__)

# Global variables
streaming_thread = None
keep_streaming = False
current_frame = None
frame_lock = threading.Lock()
mqtt_client = None
frame_count = 0

# FIXED: Better position tracking with thread safety
current_printer_position = {"x": 0.0, "y": 0.0, "z": 0.0}
position_lock = threading.Lock()
position_request_pending = False
position_request_timestamp = 0

def load_calibration_data():
    """Load calibration data from file"""
    global calibration_data
    try:
        cal_file = os.path.join(CALIBRATION_DIR, "calibration.json")
        if os.path.exists(cal_file):
            with open(cal_file, 'r') as f:
                calibration_data = json.load(f)
                logger.info("Calibration data loaded")
    except Exception as e:
        logger.error(f"Failed to load calibration data: {e}")

def save_calibration_data():
    """Save calibration data to file"""
    try:
        cal_file = os.path.join(CALIBRATION_DIR, "calibration.json")
        with open(cal_file, 'w') as f:
            json.dump(calibration_data, f, indent=2)
        logger.info("Calibration data saved")
        return True
    except Exception as e:
        logger.error(f"Failed to save calibration data: {e}")
        return False

def request_printer_position():
    """Get printer position directly from Klipper API - much faster than MQTT"""
    global current_printer_position, position_request_pending
    
    logger.debug("request_printer_position() called - using direct API")
    
    try:
        # Get position directly from Klipper API
        klipper_ip = "192.168.1.89"
        url = f"http://{klipper_ip}/printer/objects/query?gcode_move"
        
        response = requests.get(url, timeout=3)
        
        if response.status_code == 200:
            data = response.json()
            gcode_pos = data['result']['status']['gcode_move']['gcode_position']
            
            with position_lock:
                current_printer_position = {
                    "x": round(float(gcode_pos[0]), 3),
                    "y": round(float(gcode_pos[1]), 3),
                    "z": round(float(gcode_pos[2]), 3)
                }
                position_request_pending = False
            
            logger.info(f"Got position from Klipper API: {current_printer_position}")
            return True
        else:
            logger.error(f"Klipper API request failed: {response.status_code}")
            return False
            
    except Exception as e:
        logger.error(f"Error getting position from Klipper API: {e}")
        with position_lock:
            position_request_pending = False
        return False



def pixel_to_printer_coordinates(pixel_x, pixel_y, reference_printer_x, reference_printer_y):
    """Convert pixel coordinates to printer coordinates using calibration"""
    if not calibration_data["enabled"] or len(calibration_data["reference_points"]) == 0:
        return None
    
    # Use the most recent reference point for simple linear conversion
    ref_point = calibration_data["reference_points"][-1]
    
    # Calculate offset in pixels from reference point
    pixel_offset_x = pixel_x - ref_point["pixel_x"]
    pixel_offset_y = pixel_y - ref_point["pixel_y"]
    
    # Convert to printer coordinates using microns per pixel
    printer_offset_x = pixel_offset_x * calibration_data["microns_per_pixel_x"] / 1000.0
    printer_offset_y = pixel_offset_y * calibration_data["microns_per_pixel_y"] / 1000.0
    
    # Calculate absolute printer coordinates
    printer_x = ref_point["printer_x"] + printer_offset_x
    printer_y = ref_point["printer_y"] - printer_offset_y  # Y axis is typically inverted
    
    return {
        "x": round(printer_x, 3),
        "y": round(printer_y, 3),
        "reference_point": ref_point,
        "pixel_offset": {"x": pixel_offset_x, "y": pixel_offset_y},
        "printer_offset": {"x": printer_offset_x, "y": printer_offset_y}
    }

def get_focus_info():
    """Get current focus mode and position"""
    global FOCUS_MODE, FOCUS_POSITION
    return {
        "mode": FOCUS_MODE,
        "position": FOCUS_POSITION
    }

def control_autofocus(mode="auto", position=None):
    """Control the autofocus of the IMX519 camera using libcamera-still parameters"""
    global FOCUS_MODE, FOCUS_POSITION
    
    try:
        logger.info(f"Setting focus: mode={mode}, position={position}")
        
        if mode == "auto":
            FOCUS_MODE = "auto"
            FOCUS_POSITION = 10
            return True
            
        elif mode == "manual" and position is not None:
            pos = max(0, min(30, float(position)))
            FOCUS_MODE = "manual"
            FOCUS_POSITION = pos
            return True
        else:
            logger.error(f"Invalid focus parameters: mode={mode}, position={position}")
            return False
    except Exception as e:
        logger.error(f"Failed to control focus: {e}")
        return False

def capture_frame():
    """Capture a single frame for the stream with Safari-compatible JPEG encoding"""
    global current_frame, frame_lock, FOCUS_MODE, FOCUS_POSITION, frame_count
    
    try:
        temp_file = "/tmp/stream_frame.jpg"
        
        cmd = [
            "libcamera-still",
            "--output", temp_file,
            "--timeout", "1",
            "--width", str(STREAM_WIDTH),
            "--height", str(STREAM_HEIGHT),
            "--immediate",
            "--nopreview",
            "--quality", "85",
            "--encoding", "jpg"
        ]
        
        if FOCUS_MODE == "auto":
            cmd.extend(["--autofocus-mode", "auto"])
        else:
            cmd.extend(["--autofocus-mode", "manual", "--lens-position", str(FOCUS_POSITION)])
        
        result = subprocess.run(cmd, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        
        if result.returncode == 0 and os.path.exists(temp_file):
            with open(temp_file, 'rb') as f:
                frame_data = f.read()
                with frame_lock:
                    current_frame = frame_data
                    frame_count += 1
            return True
        else:
            logger.error(f"Failed to capture frame: {result.stderr.decode()}")
            return False
    except Exception as e:
        logger.error(f"Error capturing frame: {e}")
        return False

def streaming_worker():
    """Background thread for continuous frame capture - Safari optimized"""
    global keep_streaming, STREAM_ACTIVE
    
    logger.info("Streaming worker started")
    consecutive_failures = 0
    max_failures = 5
    
    while keep_streaming:
        if capture_frame():
            consecutive_failures = 0
            time.sleep(1/12)
        else:
            consecutive_failures += 1
            if consecutive_failures >= max_failures:
                logger.error("Too many consecutive capture failures, pausing")
                time.sleep(2)
                consecutive_failures = 0
            else:
                time.sleep(0.5)
    
    logger.info("Streaming worker stopped")
    STREAM_ACTIVE = False

def start_stream():
    """Start the streaming thread"""
    global streaming_thread, keep_streaming, STREAM_ACTIVE, current_frame, frame_count
    
    if STREAM_ACTIVE:
        logger.info("Stream already active")
        return True
    
    with frame_lock:
        current_frame = None
        frame_count = 0
    
    keep_streaming = True
    STREAM_ACTIVE = True
    streaming_thread = threading.Thread(target=streaming_worker)
    streaming_thread.daemon = True
    streaming_thread.start()
    
    logger.info("Stream started")
    publish_status()
    return True

def stop_stream():
    """Stop the streaming thread"""
    global keep_streaming, STREAM_ACTIVE, streaming_thread
    
    if not STREAM_ACTIVE:
        logger.info("No stream active")
        return True
    
    keep_streaming = False
    
    if streaming_thread and streaming_thread.is_alive():
        streaming_thread.join(timeout=3)
    
    STREAM_ACTIVE = False
    streaming_thread = None
    logger.info("Stream stopped")
    publish_status()
    return True

def capture_image():
    """Capture a high-quality image and save it to disk"""
    global FOCUS_MODE, FOCUS_POSITION
    
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{CAPTURE_DIR}/capture_{timestamp}.jpg"
        
        cmd = [
            "libcamera-still",
            "--output", filename,
            "--timeout", "2000",
            "--width", str(CAPTURE_WIDTH),
            "--height", str(CAPTURE_HEIGHT),
            "--nopreview"
        ]
        
        if FOCUS_MODE == "auto":
            cmd.extend(["--autofocus-mode", "auto"])
        else:
            cmd.extend(["--autofocus-mode", "manual", "--lens-position", str(FOCUS_POSITION)])
        
        result = subprocess.run(cmd, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        
        if result.returncode == 0:
            logger.info(f"Image captured: {filename}")
            return filename
        else:
            logger.error(f"Failed to capture image: {result.stderr.decode()}")
            return False
            
    except Exception as e:
        logger.error(f"Error in capture_image: {e}")
        return False

def update_camera_config(config):
    """Update camera configuration"""
    global STREAM_WIDTH, STREAM_HEIGHT, CAPTURE_WIDTH, CAPTURE_HEIGHT, STREAM_QUALITY
    
    try:
        if "stream_width" in config and isinstance(config["stream_width"], int):
            STREAM_WIDTH = config["stream_width"]
        
        if "stream_height" in config and isinstance(config["stream_height"], int):
            STREAM_HEIGHT = config["stream_height"]
            
        if "capture_width" in config and isinstance(config["capture_width"], int):
            CAPTURE_WIDTH = config["capture_width"]
            
        if "capture_height" in config and isinstance(config["capture_height"], int):
            CAPTURE_HEIGHT = config["capture_height"]
            
        if "stream_quality" in config and config["stream_quality"] in ["low", "medium", "high"]:
            STREAM_QUALITY = config["stream_quality"]
            
        logger.info(f"Camera config updated: stream={STREAM_WIDTH}x{STREAM_HEIGHT}, "
                    f"capture={CAPTURE_WIDTH}x{CAPTURE_HEIGHT}, quality={STREAM_QUALITY}")
        
        publish_status()
        return True
    except Exception as e:
        logger.error(f"Error updating camera config: {e}")
        return False

def publish_status():
    """Publish camera status to MQTT"""
    global mqtt_client, STREAM_ACTIVE, STREAM_WIDTH, STREAM_HEIGHT, CAPTURE_WIDTH, CAPTURE_HEIGHT
    
    if mqtt_client and mqtt_client.is_connected():
        focus_info = get_focus_info()
        
        with position_lock:
            current_pos = current_printer_position.copy()
        
        status = {
            "timestamp": datetime.now().isoformat(),
            "streaming": STREAM_ACTIVE,
            "focus_mode": focus_info.get("mode", "auto"),
            "focus_position": focus_info.get("position", 10),
            "stream_width": STREAM_WIDTH,
            "stream_height": STREAM_HEIGHT,
            "capture_width": CAPTURE_WIDTH,
            "capture_height": CAPTURE_HEIGHT,
            "stream_quality": STREAM_QUALITY,
            "calibration": calibration_data,
            "current_position": current_pos
        }
        
        mqtt_client.publish(MQTT_STATUS_TOPIC, json.dumps(status))
        logger.debug(f"Published status: {status}")
        return True
    return False

# MQTT Callback functions
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        logger.info("Connected to MQTT broker")
        client.subscribe(MQTT_COMMAND_TOPIC)
        client.subscribe(MQTT_CONFIG_TOPIC)
        client.subscribe(MQTT_KLIPPER_POSITION_RESPONSE)
        logger.info(f"Subscribed to topics: {MQTT_COMMAND_TOPIC}, {MQTT_CONFIG_TOPIC}, {MQTT_KLIPPER_POSITION_RESPONSE}")
        publish_status()
    else:
        logger.error(f"Failed to connect to MQTT broker, return code {rc}")

def on_message(client, userdata, msg):
    """FIXED: Handle received MQTT messages with better debugging"""
    global current_printer_position, position_request_pending
    
    try:
        topic = msg.topic
        payload_str = msg.payload.decode()
        logger.debug(f"Raw MQTT message: {topic} = {payload_str}")
        
        payload = json.loads(payload_str)
        logger.info(f"Parsed MQTT message: {topic} = {payload}")
        
        if topic == MQTT_COMMAND_TOPIC:
            handle_command_message(payload)
        elif topic == MQTT_CONFIG_TOPIC:
            update_camera_config(payload)
        elif topic == MQTT_KLIPPER_POSITION_RESPONSE:
            logger.info(f"Position response received: {payload}")
            # Handle printer position response from publish_position.sh
            if isinstance(payload, dict) and "x" in payload and "y" in payload and "z" in payload:
                if payload.get("status") == "success":
                    with position_lock:
                        current_printer_position = {
                            "x": float(payload["x"]),
                            "y": float(payload["y"]),
                            "z": float(payload["z"])
                        }
                        position_request_pending = False
                    logger.info(f"Printer position updated to: {current_printer_position}")
                else:
                    logger.error(f"Position request failed: {payload}")
                    with position_lock:
                        position_request_pending = False
            else:
                logger.error(f"Invalid position response format: {payload}")
            
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error in MQTT message: {e}, payload: {msg.payload}")
    except Exception as e:
        logger.error(f"Error processing MQTT message: {e}")

def handle_command_message(payload):
    """Process command messages from MQTT"""
    global STREAM_ACTIVE
    
    try:
        if "command" not in payload:
            logger.error("Missing 'command' field in MQTT message")
            return False
            
        command = payload["command"]
        logger.info(f"Processing command: {command}")
        
        if command == "stream_start":
            start_stream()
        elif command == "stream_stop":
            stop_stream()
        elif command == "capture":
            capture_image()
        elif command == "focus":
            mode = payload.get("mode", "auto")
            position = payload.get("position", 10)
            control_autofocus(mode, position)
        elif command == "status":
            publish_status()
        else:
            logger.warning(f"Unknown command: {command}")
            return False
            
        return True
    except Exception as e:
        logger.error(f"Error handling command: {e}")
        return False

def setup_mqtt_client():
    """Initialize and connect MQTT client"""
    global mqtt_client
    
    try:
        client_id = f"camera_flask_{os.getpid()}"
        mqtt_client = mqtt.Client(client_id=client_id)
        
        mqtt_client.on_connect = on_connect
        mqtt_client.on_message = on_message
        
        logger.info(f"Connecting MQTT client to {MQTT_BROKER}:{MQTT_PORT}")
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
        mqtt_client.loop_start()
        
        logger.info(f"MQTT client initialized and connecting")
        return True
    except Exception as e:
        logger.error(f"Failed to setup MQTT client: {e}")
        return False





#Tool management functions
#tools configuration
def load_tools_config():
    """Load tools configuration from file"""
    global tools_config
    try:
        if os.path.exists(TOOLS_CONFIG_FILE):
            with open(TOOLS_CONFIG_FILE, 'r') as f:
                tools_config = json.load(f)
        else:
            # Default configuration
            tools_config = {
                "tools": [
                    {"id": 0, "name": "Camera Tool (C0)", "type": "camera", "offsetX": 0, "offsetY": 0, "offsetZ": 0, "preciseX": 0, "preciseY": 0, "preciseZ": 0},
                    {"id": 1, "name": "Extruder 1 (E0)", "type": "extruder", "offsetX": 0, "offsetY": 0, "offsetZ": 0, "preciseX": 0, "preciseY": 0, "preciseZ": 0},
                    {"id": 2, "name": "Extruder 2 (E1)", "type": "extruder", "offsetX": 0, "offsetY": 0, "offsetZ": 0, "preciseX": 0, "preciseY": 0, "preciseZ": 0},
                    {"id": 3, "name": "Liquid Dispenser (L0)", "type": "dispenser", "offsetX": 0, "offsetY": 0, "offsetZ": 0, "preciseX": 0, "preciseY": 0, "preciseZ": 0}
                ],
                "camera_reference": None
            }
            save_tools_config()
    except Exception as e:
        logger.error(f"Error loading tools config: {e}")

def save_tools_config():
    """Save tools configuration to file"""
    try:
        with open(TOOLS_CONFIG_FILE, 'w') as f:
            json.dump(tools_config, f, indent=2)
        logger.info("Tools configuration saved successfully")
    except Exception as e:
        logger.error(f"Error saving tools config: {e}")



#Tool management functions @app.routes
#tools configuration
@app.route('/api/tools/save', methods=['POST'])
def api_save_tools():
    """Save tools configuration"""
    try:
        data = request.json
        tools_config["tools"] = data.get("tools", [])
        save_tools_config()
        return jsonify({"status": "success", "message": "Tools configuration saved"})
    except Exception as e:
        logger.error(f"Error saving tools: {e}")
        return jsonify({"status": "error", "message": str(e)})

@app.route('/api/tools/load', methods=['GET'])
def api_load_tools():
    """Load tools configuration"""
    try:
        load_tools_config()
        return jsonify({
            "status": "success", 
            "tools": tools_config["tools"],
            "camera_reference": tools_config["camera_reference"]
        })
    except Exception as e:
        logger.error(f"Error loading tools: {e}")
        return jsonify({"status": "error", "message": str(e)})

@app.route('/api/printer/get_position', methods=['GET'])
def api_get_printer_position():
    """Get current printer position"""
    try:
        # Send M114 command to get position
        position_response = send_gcode("M114")
        if not position_response:
            return jsonify({"status": "error", "message": "Failed to get position from printer"})
        
        # Parse position (format: "X:123.45 Y:67.89 Z:10.20 E:0.00")
        try:
            pos_parts = position_response.strip().split()
            x, y, z = None, None, None
            
            for part in pos_parts:
                if part.startswith("X:"):
                    x = float(part[2:])
                elif part.startswith("Y:"):
                    y = float(part[2:])
                elif part.startswith("Z:"):
                    z = float(part[2:])
            
            if x is None or y is None or z is None:
                return jsonify({"status": "error", "message": "Could not parse position data"})
                
            return jsonify({
                "status": "success",
                "x": round(x, 3),
                "y": round(y, 3),
                "z": round(z, 3),
                "raw_response": position_response
            })
            
        except (ValueError, IndexError) as e:
            return jsonify({"status": "error", "message": f"Error parsing position: {e}"})
            
    except Exception as e:
        logger.error(f"Error getting printer position: {e}")
        return jsonify({"status": "error", "message": str(e)})




# Enhanced Flask routes with calibration functionality
@app.route('/')
def index():
    """Enhanced camera control interface with calibration tools"""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Rister Camera Controller with Calibration</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif; 
                margin: 20px; 
                text-align: center;
                background-color: #f5f5f5;
            }
            .container {
                max-width: 1000px;
                margin: 0 auto;
                background-color: white;
                padding: 20px;
                border-radius: 10px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
            }
            h1, h2 {
                color: #333;
                margin-top: 0;
            }
            .controls {
                margin: 20px 0;
                display: flex;
                justify-content: center;
                flex-wrap: wrap;
            }


.camera-center {
    background-color: #3498db !important;  /* Blue color */
    border: 2px solid #3498db !important;
}

.camera-center:hover {
    background-color: #2980b9 !important;  /* Darker blue on hover */
    border: 2px solid #2980b9 !important;
}


.pixel-calibrate {
    background-color: #ff6b35 !important;  /* Orange color */
    border: 2px solid #ff6b35 !important;
}

.pixel-calibrate:hover {
    background-color: #e55a2b !important;  /* Darker orange on hover */
    border: 2px solid #e55a2b !important;
}

.clickable-image {
    max-width: 100%;
    max-height: 600px;
    border-radius: 5px;
    display: block;
    margin: 0 auto;
    cursor: crosshair;
    user-select: none;
    -webkit-user-select: none;
    -moz-user-select: none;
    -webkit-user-drag: none;
    -webkit-touch-callout: none;
}


            button {
                margin: 5px;
                padding: 10px 20px;
                border: none;
                border-radius: 5px;
                background-color: #4CAF50;
                color: white;
                font-weight: bold;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            button:hover { background-color: #3e8e41; }
            button.stop { background-color: #f44336; }
            button.stop:hover { background-color: #d32f2f; }
            button.photo { background-color: #2196F3; }
            button.photo:hover { background-color: #1976D2; }
            button.focus { background-color: #9C27B0; }
            button.focus:hover { background-color: #7B1FA2; }
            button.calibration { background-color: #FF9800; }
            button.calibration:hover { background-color: #F57C00; }
            
            .debug-panel {
                background-color: #f0f0f0;
                border: 1px solid #ccc;
                border-radius: 5px;
                padding: 15px;
                margin: 20px 0;
                text-align: left;
                font-family: monospace;
                font-size: 12px;
            }
            
            .calibration-panel {
                background-color: #fff3cd;
                border: 1px solid #ffeaa7;
                border-radius: 5px;
                padding: 15px;
                margin: 20px 0;
                text-align: left;
            }
            
            .input-group {
                margin: 10px 0;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            
            .input-group label {
                min-width: 150px;
                font-weight: bold;
            }
            
            .input-group input {
                padding: 5px;
                border: 1px solid #ccc;
                border-radius: 3px;
                width: 100px;
            }
            
            .media-container {
                border: 1px solid #ddd;
                padding: 10px;
                border-radius: 5px;
                margin-bottom: 20px;
                background: #000;
                position: relative;
            }
            
            .clickable-image {
                max-width: 100%;
                max-height: 600px;
                border-radius: 5px;
                display: block;
                margin: 0 auto;
                cursor: crosshair;
            }
            
            .coordinates-display {
                background-color: rgba(0, 0, 0, 0.8);
                color: white;
                padding: 5px 10px;
                border-radius: 3px;
                position: absolute;
                top: 10px;
                left: 10px;
                font-family: monospace;
                font-size: 12px;
            }
            
            .status {
                margin-top: 10px;
                font-style: italic;
                color: #666;
            }
            
            .reference-points {
                max-height: 200px;
                overflow-y: auto;
                background-color: #f8f9fa;
                border: 1px solid #dee2e6;
                border-radius: 3px;
                padding: 10px;
                margin: 10px 0;
            }
            
            .reference-point {
                background-color: white;
                border: 1px solid #ccc;
                border-radius: 3px;
                padding: 5px;
                margin: 5px 0;
                font-family: monospace;
                font-size: 12px;
            }
        </style>
        <script>


// Camera centering functionality
let centeringMode = false;

function startCameraCentering() {
    centeringMode = true;
    measuringLine = false; // Disable line measurement
    console.log('Camera centering mode enabled');
    alert('Click on a marking and the camera will move to center it in the view.');
}

function centerCameraClick(event) {
    if (!centeringMode) return;
    
    const rect = event.target.getBoundingClientRect();
    const clickX = event.clientX - rect.left;
    const clickY = event.clientY - rect.top;
    
    // Get image dimensions
    const imageWidth = event.target.naturalWidth || event.target.width;
    const imageHeight = event.target.naturalHeight || event.target.height;
    
    // Calculate offset from center (in pixels)
    const centerX = imageWidth / 2;
    const centerY = imageHeight / 2;
    const offsetX = clickX - centerX;
    const offsetY = clickY - centerY;
    
    console.log(`Clicked at (${clickX}, ${clickY}), center is (${centerX}, ${centerY}), offset: (${offsetX}, ${offsetY})`);
    
    // Convert pixel offset to real-world coordinates using calibration
    moveCameraToCenter(offsetX, offsetY);
}

function moveCameraToCenter(pixelOffsetX, pixelOffsetY) {
    // Get current calibration data
    fetch('/api/calibration/info')
        .then(response => response.json())
        .then(calibration => {
            if (!calibration.microns_per_pixel_x || !calibration.microns_per_pixel_y) {
                alert('Camera calibration required! Please calibrate pixel size first.');
                centeringMode = false;
                return;
            }
            
            // Convert pixel offset to mm
            const offsetMmX = (pixelOffsetX * calibration.microns_per_pixel_x) / 1000;
            const offsetMmY = -(pixelOffsetY * calibration.microns_per_pixel_y) / 1000; // Y axis inverted
            
            console.log(`Moving camera by offset: X=${offsetMmX.toFixed(3)}mm, Y=${offsetMmY.toFixed(3)}mm`);
            
            // Send move command to move camera tool
            fetch('/api/printer/move_camera', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    offset_x: offsetMmX,
                    offset_y: offsetMmY
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    alert(`Camera moved to center the marking!\nOffset: X=${offsetMmX.toFixed(3)}mm, Y=${offsetMmY.toFixed(3)}mm`);
                } else {
                    alert('Failed to move camera: ' + (data.message || 'Unknown error'));
                }
                centeringMode = false;
            })
            .catch(error => {
                console.error('Error moving camera:', error);
                alert('Error moving camera: ' + error);
                centeringMode = false;
            });
        })
        .catch(error => {
            console.error('Error getting calibration:', error);
            alert('Error getting calibration data');
            centeringMode = false;
        });
}

// Add fiducial crosshair overlay
function addFiducialCrosshair(imageElement) {
    // Remove existing crosshair
    const existing = imageElement.parentElement.querySelector('.fiducial-crosshair');
    if (existing) existing.remove();
    
    // Create crosshair container
    const crosshair = document.createElement('div');
    crosshair.className = 'fiducial-crosshair';
    crosshair.style.position = 'absolute';
    crosshair.style.top = '50%';
    crosshair.style.left = '50%';
    crosshair.style.transform = 'translate(-50%, -50%)';
    crosshair.style.pointerEvents = 'none';
    crosshair.style.zIndex = '500';
    
    // Create circle
    const circle = document.createElement('div');
    circle.style.width = '40px';
    circle.style.height = '40px';
    circle.style.border = '2px solid #00ff00';
    circle.style.borderRadius = '50%';
    circle.style.position = 'relative';
    
    // Create horizontal line
    const hLine = document.createElement('div');
    hLine.style.position = 'absolute';
    hLine.style.top = '50%';
    hLine.style.left = '10%';
    hLine.style.right = '10%';
    hLine.style.height = '2px';
    hLine.style.backgroundColor = '#00ff00';
    hLine.style.transform = 'translateY(-50%)';
    
    // Create vertical line
    const vLine = document.createElement('div');
    vLine.style.position = 'absolute';
    vLine.style.left = '50%';
    vLine.style.top = '10%';
    vLine.style.bottom = '10%';
    vLine.style.width = '2px';
    vLine.style.backgroundColor = '#00ff00';
    vLine.style.transform = 'translateX(-50%)';
    
    circle.appendChild(hLine);
    circle.appendChild(vLine);
    crosshair.appendChild(circle);
    
    // Ensure parent container is positioned
    imageElement.parentElement.style.position = 'relative';
    imageElement.parentElement.appendChild(crosshair);
}

// Initialize fiducial on page load
document.addEventListener('DOMContentLoaded', function() {
    // Add crosshairs to both stream and photo images
    const streamImg = document.getElementById('streamImg');
    const photoImg = document.getElementById('photoImg');
    
    if (streamImg) {
        streamImg.addEventListener('load', () => addFiducialCrosshair(streamImg));
        addFiducialCrosshair(streamImg); // Add immediately if already loaded
    }
    
    if (photoImg) {
        photoImg.addEventListener('load', () => addFiducialCrosshair(photoImg));
        addFiducialCrosshair(photoImg); // Add immediately if already loaded
    }
});









            let calibrationMode = false;
            let currentImageType = 'stream';
            let debugInfo = {};
            
            window.onload = function() {
                checkStatus();
                loadCalibrationData();
                setInterval(checkStatus, 3000);
            };
            
            function checkStatus() {
                fetch('/api/status')
                    .then(response => response.json())
                    .then(data => {
                        debugInfo = data;
                        updateDebugPanel();
                        
                        if (data.streaming) {
                            document.getElementById('streamContainer').style.display = 'block';
                            document.getElementById('focusControls').style.display = 'flex';
                            refreshStreamImage();
                        } else {
                            document.getElementById('streamContainer').style.display = 'none';
                            document.getElementById('focusControls').style.display = 'none';
                        }
                        
                        // Update calibration status
                        if (data.calibration) {
                            document.getElementById('micronPerPixelX').value = data.calibration.microns_per_pixel_x || 10;
                            document.getElementById('micronPerPixelY').value = data.calibration.microns_per_pixel_y || 10;
                            updateCalibrationStatus(data.calibration.enabled);
                        }
                    })
                    .catch(error => {
                        console.error('Error checking status:', error);
                        updateDebugPanel('Error: ' + error);
                    });
            }
            
            function updateDebugPanel(error = null) {
                const panel = document.getElementById('debugPanel');
                if (error) {
                    panel.innerHTML = '<strong>Error:</strong> ' + error;
                } else {
                    panel.innerHTML = `
                        <strong>Debug Info:</strong><br>
                        Current Position: X${debugInfo.printer_position?.x || 0} Y${debugInfo.printer_position?.y || 0} Z${debugInfo.printer_position?.z || 0}<br>
                        Streaming: ${debugInfo.streaming || false}<br>
                        Calibration Enabled: ${debugInfo.calibration?.enabled || false}<br>
                        Reference Points: ${debugInfo.calibration?.reference_points?.length || 0}<br>
                        Last Update: ${new Date().toLocaleTimeString()}
                    `;
                }
            }
            
            function refreshStreamImage() {
                const img = document.getElementById('streamImg');
                img.src = '/stream?t=' + new Date().getTime();
            }
            
            function startStream() {
                fetch('/api/stream/start')
                    .then(response => response.json())
                    .then(data => {
                        if (data.streaming) {
                            document.getElementById('streamContainer').style.display = 'block';
                            document.getElementById('focusControls').style.display = 'flex';
                            setTimeout(refreshStreamImage, 1000);
                        }
                    });
            }
            
            function stopStream() {
                fetch('/api/stream/stop')
                    .then(response => response.json())
                    .then(data => {
                        document.getElementById('streamContainer').style.display = 'none';
                        document.getElementById('focusControls').style.display = 'none';
                    });
            }
            
            function capturePhoto() {
                fetch('/api/capture')
                    .then(response => response.json())
                    .then(data => {
                        document.getElementById('photoContainer').style.display = 'block';
                        document.getElementById('photoImg').src = '/latest_photo?t=' + new Date().getTime();
                        currentImageType = 'snapshot';
                    });
            }
            
            function toggleCalibrationMode() {
                calibrationMode = !calibrationMode;
                document.getElementById('calibrationToggle').textContent = 
                    calibrationMode ? 'Disable Calibration Mode' : 'Enable Calibration Mode';
                document.getElementById('calibrationPanel').style.display = 
                    calibrationMode ? 'block' : 'none';
                    
                // Update cursor style
                const images = document.querySelectorAll('.clickable-image');
                images.forEach(img => {
                    img.style.cursor = calibrationMode ? 'crosshair' : 'default';
                });
            }
            
            function handleImageClick(event, imageType) {
                if (!calibrationMode) return;
                
                console.log('Image clicked in calibration mode');
                
                const rect = event.target.getBoundingClientRect();
                const x = Math.round(event.clientX - rect.left);
                const y = Math.round(event.clientY - rect.top);
                
                console.log(`Pixel coordinates: (${x}, ${y})`);
                
                // Show click coordinates immediately
                showCoordinates(event.target, x, y);
                
                // Request current printer position with detailed logging
                console.log('Requesting printer position...');
                fetch('/api/printer/position')
                    .then(response => {
                        console.log('Position request response received:', response);
                        return response.json();
                    })
                    .then(data => {
                        console.log('Position data:', data);
                        if (data.status === 'success' || data.status === 'timeout') {
                            console.log(`Printer position: X${data.position.x} Y${data.position.y} Z${data.position.z}`);
                            addReferencePoint(x, y, data.position.x, data.position.y, data.position.z);
                        } else {
                            console.error('Failed to get printer position:', data);
                            alert('Failed to get printer position: ' + (data.message || 'Unknown error'));
                        }
                    })
                    .catch(error => {
                        console.error('Error getting printer position:', error);
                        alert('Error getting printer position: ' + error);
                    });
            }
            
            function showCoordinates(imgElement, x, y) {
                // Remove existing coordinate display
                const existing = imgElement.parentElement.querySelector('.coordinates-display');
                if (existing) existing.remove();
                
                // Create new coordinate display
                const coordDiv = document.createElement('div');
                coordDiv.className = 'coordinates-display';
                coordDiv.textContent = `Pixel: (${x}, ${y})`;
                imgElement.parentElement.appendChild(coordDiv);
                
                // Remove after 3 seconds
                setTimeout(() => {
                    if (coordDiv.parentElement) {
                        coordDiv.remove();
                    }
                }, 3000);
            }
            
            function addReferencePoint(pixelX, pixelY, printerX, printerY, printerZ) {
                console.log(`Adding reference point: Pixel(${pixelX}, ${pixelY}) -> Printer(${printerX}, ${printerY}, ${printerZ})`);
                
                const data = {
                    pixel_x: pixelX,
                    pixel_y: pixelY,
                    printer_x: printerX,
                    printer_y: printerY,
                    printer_z: printerZ
                };
                
                fetch('/api/calibration/add_point', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(data)
                })
                .then(response => response.json())
                .then(result => {
                    console.log('Add point result:', result);
                    if (result.status === 'success') {
                        loadCalibrationData();
                        alert(`Reference point added successfully!\\nPixel: (${pixelX}, ${pixelY})\\nPrinter: X${printerX} Y${printerY} Z${printerZ}`);
                    } else {
                        alert('Failed to add reference point: ' + (result.message || 'Unknown error'));
                    }
                })
                .catch(error => {
                    console.error('Error adding reference point:', error);
                    alert('Error adding reference point: ' + error);
                });
            }
            
            function updateMicronsPerPixel() {
                const x = parseFloat(document.getElementById('micronPerPixelX').value);
                const y = parseFloat(document.getElementById('micronPerPixelY').value);
                
                fetch('/api/calibration/set_microns', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({microns_per_pixel_x: x, microns_per_pixel_y: y})
                })
                .then(response => response.json())
                .then(result => {
                    if (result.status === 'success') {
                        alert('Microns per pixel updated');
                    }
                });
            }
            
            function enableCalibration() {
                fetch('/api/calibration/enable', {method: 'POST'})
                    .then(response => response.json())
                    .then(result => {
                        if (result.status === 'success') {
                            updateCalibrationStatus(true);
                        }
                    });
            }
            
            function disableCalibration() {
                fetch('/api/calibration/disable', {method: 'POST'})
                    .then(response => response.json())
                    .then(result => {
                        if (result.status === 'success') {
                            updateCalibrationStatus(false);
                        }
                    });
            }
            
            function clearCalibration() {
                if (confirm('Clear all calibration data?')) {
                    fetch('/api/calibration/clear', {method: 'POST'})
                        .then(response => response.json())
                        .then(result => {
                            if (result.status === 'success') {
                                loadCalibrationData();
                            }
                        });
                }
            }
            
            function loadCalibrationData() {
                fetch('/api/calibration/data')
                    .then(response => response.json())
                    .then(data => {
                        const container = document.getElementById('referencePoints');
                        container.innerHTML = '';
                        
                        if (data.reference_points && data.reference_points.length > 0) {
                            data.reference_points.forEach((point, index) => {
                                const div = document.createElement('div');
                                div.className = 'reference-point';
                                div.innerHTML = `
                                    <strong>Point ${index + 1}:</strong><br>
                                    Pixel: (${point.pixel_x}, ${point.pixel_y})<br>
                                    Printer: X${point.printer_x} Y${point.printer_y} Z${point.printer_z}
                                `;
                                container.appendChild(div);
                            });
                        } else {
                            container.innerHTML = '<div class="reference-point">No reference points set</div>';
                        }
                        
                        updateCalibrationStatus(data.enabled);
                    });
            }
            
            function updateCalibrationStatus(enabled) {
                const statusElement = document.getElementById('calibrationStatus');
                statusElement.textContent = enabled ? 'ENABLED' : 'DISABLED';
                statusElement.style.color = enabled ? 'green' : 'red';
            }
            
            // Focus control functions
            function updateFocusValue(value) {
                document.getElementById('focusValue').textContent = value;
            }
            
            function setFocusAuto() {
                fetch('/api/focus/auto')
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'success') {
                            document.getElementById('focusSlider').value = 10;
                            document.getElementById('focusValue').textContent = 10;
                            alert('Auto focus enabled');
                        }
                    });
            }
            
            function setFocusManual(position) {
                fetch('/api/focus/manual/' + position)
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'success') {
                            const focusValue = document.getElementById('focusValue');
                            const originalColor = focusValue.style.color;
                            focusValue.style.color = '#4CAF50';
                            setTimeout(() => {
                                focusValue.style.color = originalColor;
                            }, 500);
                        }
                    });
            }


let measuringLine = false;
let lineStart = null;
let currentLine = null;
let isDrawingLine = false;



function startLineMeasurement() {
    measuringLine = true;
    lineStart = null;
    isDrawingLine = false;
    currentLine = null;
    console.log('Line measurement mode enabled');
    alert('Click and drag to draw a measurement line on the image.');
}


function measureClick(event) {
    if (!measuringLine) return;
    
    if (event.type === 'mousedown') {
        startDrawingLine(event);
    } else if (event.type === 'mousemove' && isDrawingLine) {
        updateLine(event);
    } else if (event.type === 'mouseup' && isDrawingLine) {
        finishLine(event);
    }
}

function startDrawingLine(event) {
    event.preventDefault();
    const rect = event.target.getBoundingClientRect();
    lineStart = {
        x: event.clientX - rect.left,
        y: event.clientY - rect.top
    };
    
    isDrawingLine = true;
    
    // Create line element positioned absolutely on the page
    currentLine = document.createElement('div');
    currentLine.style.position = 'fixed'; // Use fixed positioning
    currentLine.style.backgroundColor = '#ff4444';
    currentLine.style.height = '2px';
    currentLine.style.transformOrigin = '0 0';
    currentLine.style.pointerEvents = 'none';
    currentLine.style.zIndex = '1000';
    currentLine.style.left = (rect.left + lineStart.x) + 'px';
    currentLine.style.top = (rect.top + lineStart.y) + 'px';
    
    // Add to body for fixed positioning
    document.body.appendChild(currentLine);
}

function updateLine(event) {
    if (!isDrawingLine || !currentLine || !lineStart) return;
    
    const rect = event.target.getBoundingClientRect();
    const currentX = event.clientX - rect.left;
    const currentY = event.clientY - rect.top;
    
    const deltaX = currentX - lineStart.x;
    const deltaY = currentY - lineStart.y;
    const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
    const angle = Math.atan2(deltaY, deltaX) * 180 / Math.PI;
    
    // Update line width and rotation only - position is set in startDrawingLine
    currentLine.style.width = distance + 'px';
    currentLine.style.transform = 'rotate(' + angle + 'deg)';
}


function finishLine(event) {
    if (!isDrawingLine || !currentLine || !lineStart) return;
    
    const rect = event.target.getBoundingClientRect();
    const endX = event.clientX - rect.left;
    const endY = event.clientY - rect.top;
    
    const deltaX = endX - lineStart.x;
    const deltaY = endY - lineStart.y;
    const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
    
    if (distance < 10) {
        // Line too short, remove it
        currentLine.remove();
        isDrawingLine = false;
        return;
    }
    
    const actualMM = prompt('Line is ' + Math.round(distance) + ' pixels long.\\nWhat is the actual length in mm?');
    
    if (actualMM && !isNaN(actualMM)) {
        const micronsPerPixel = (parseFloat(actualMM) * 1000) / distance;
        
        fetch('/api/scaler/calculate', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                width_mm: actualMM,
                height_mm: actualMM,
                pixel_width: distance,
                pixel_height: distance
            })
        }).then(() => {
            alert('Calculated: ' + micronsPerPixel.toFixed(2) + ' μm/pixel\\nCalibration updated!');
            location.reload();
        });
    }
    
    // Clean up
    currentLine.remove();
    measuringLine = false;
    lineStart = null;
    isDrawingLine = false;
}


//Tool management javascript
// Tool management state
let tools = [
    {id: 0, name: "Camera Tool (C0)", type: "camera", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0},
    {id: 1, name: "Extruder 1 (E0)", type: "extruder", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0},
    {id: 2, name: "Extruder 2 (E1)", type: "extruder", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0},
    {id: 3, name: "Liquid Dispenser (L0)", type: "dispenser", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0}
];

let cameraReference = null;
let currentEditingTool = null;

function toggleToolManagement() {
    const content = document.getElementById('tool-management-content');
    const arrow = document.getElementById('tool-arrow');
    
    if (content.style.display === 'none') {
        content.style.display = 'block';
        arrow.classList.add('tool-arrow-up');
    } else {
        content.style.display = 'none';
        arrow.classList.remove('tool-arrow-up');
    }
}

function renderToolList() {
    const toolList = document.getElementById('toolList');
    toolList.innerHTML = '';
    
    tools.forEach(tool => {
        const toolItem = document.createElement('div');
        toolItem.className = 'tool-item';
        
        let offsetDisplay = '';
        if (tool.type === 'camera') {
            offsetDisplay = 'Reference Tool (No Offsets)';
        } else {
            offsetDisplay = `Offset: X${tool.offsetX} Y${tool.offsetY} Z${tool.offsetZ} | Precise: X${tool.preciseX} Y${tool.preciseY} Z${tool.preciseZ}`;
        }
        
        toolItem.innerHTML = `
            <div class="tool-info">
                <div class="tool-name">${tool.name}</div>
                <div class="tool-details">Type: ${tool.type} | ${offsetDisplay}</div>
            </div>
            <div class="tool-actions">
                <button class="edit-btn" onclick="editTool(${tool.id})">Edit</button>
                ${tool.type === 'camera' ? '' : '<button class="delete-btn" onclick="deleteTool(' + tool.id + ')">Delete</button>'}
            </div>
        `;
        toolList.appendChild(toolItem);
    });
    
    renderCalibrationButtons();
}

function renderCalibrationButtons() {
    const approxDiv = document.getElementById('approximateCalibration');
    approxDiv.innerHTML = '';
    
    tools.filter(t => t.type !== 'camera').forEach(tool => {
        const btn = document.createElement('button');
        btn.className = 'workflow-btn';
        btn.textContent = `Record ${tool.name} Position`;
        btn.onclick = () => recordApproximatePosition(tool.id);
        approxDiv.appendChild(btn);
    });
    
    const precisionDiv = document.getElementById('precisionCalibration');
    precisionDiv.innerHTML = '';
    
    tools.filter(t => t.type !== 'camera').forEach(tool => {
        const btn = document.createElement('button');
        btn.className = 'workflow-btn';
        btn.textContent = `Calibrate ${tool.name} Precisely`;
        btn.onclick = () => startPrecisionCalibration(tool.id);
        precisionDiv.appendChild(btn);
    });
}

function selectTool() {
    const toolId = document.getElementById('currentTool').value;
    let toolCommand;
    
    switch(toolId) {
        case '0': toolCommand = 'C0'; break;
        case '1': toolCommand = 'E0'; break;
        case '2': toolCommand = 'E1'; break;
        case '3': toolCommand = 'L0'; break;
        default: toolCommand = 'C0';
    }
    
    fetch('/api/printer/select_tool', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({tool_command: toolCommand})
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            alert(`Tool ${toolCommand} selected`);
        } else {
            alert('Failed to select tool: ' + data.message);
        }
    });
}

function getCurrentPosition() {
    fetch('/api/printer/get_position')
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            alert(`Current Position: X${data.x} Y${data.y} Z${data.z}`);
        } else {
            alert('Failed to get position: ' + data.message);
        }
    });
}

function setCameraReference() {
    const toolId = document.getElementById('currentTool').value;
    if (toolId !== '0') {
        alert('Please select Camera Tool (C0) first');
        return;
    }
    
    fetch('/api/printer/get_position')
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            cameraReference = {x: data.x, y: data.y, z: data.z};
            document.getElementById('cameraRefStatus').textContent = `Set: X${data.x} Y${data.y} Z${data.z}`;
            document.getElementById('cameraRefStatus').className = 'status-indicator set';
            alert('Camera reference position recorded!');
        }
    });
}

function recordApproximatePosition(toolId) {
    if (!cameraReference) {
        alert('Please set camera reference position first');
        return;
    }
    
    fetch('/api/printer/get_position')
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            const tool = tools.find(t => t.id === toolId);
            tool.offsetX = (data.x - cameraReference.x).toFixed(1);
            tool.offsetY = (data.y - cameraReference.y).toFixed(1);
            tool.offsetZ = (data.z - cameraReference.z).toFixed(1);
            renderToolList();
            alert(`Approximate offset recorded for ${tool.name}`);
        }
    });
}

function startPrecisionCalibration(toolId) {
    const tool = tools.find(t => t.id === toolId);
    alert(`1. Dispense material with ${tool.name}\\n2. Switch to camera tool (C0)\\n3. Click on dispensed material in image`);
    window.precisionCalibrationMode = toolId;
}

function addNewTool() {
    currentEditingTool = null;
    document.getElementById('modalTitle').textContent = 'Add New Tool';
    document.getElementById('toolName').value = '';
    document.getElementById('toolId').value = tools.length;
    document.getElementById('toolType').value = 'extruder';
    document.getElementById('offsetX').value = '0';
    document.getElementById('offsetY').value = '0';
    document.getElementById('offsetZ').value = '0';
    document.getElementById('preciseX').value = '0';
    document.getElementById('preciseY').value = '0';
    document.getElementById('preciseZ').value = '0';
    document.getElementById('toolModal').style.display = 'block';
}

function editTool(toolId) {
    const tool = tools.find(t => t.id === toolId);
    currentEditingTool = toolId;
    document.getElementById('modalTitle').textContent = 'Edit Tool';
    document.getElementById('toolName').value = tool.name;
    document.getElementById('toolId').value = tool.id;
    document.getElementById('toolType').value = tool.type;
    
    const isCamera = tool.type === 'camera';
    document.getElementById('offsetX').value = isCamera ? '0' : tool.offsetX;
    document.getElementById('offsetY').value = isCamera ? '0' : tool.offsetY;
    document.getElementById('offsetZ').value = isCamera ? '0' : tool.offsetZ;
    document.getElementById('preciseX').value = isCamera ? '0' : tool.preciseX;
    document.getElementById('preciseY').value = isCamera ? '0' : tool.preciseY;
    document.getElementById('preciseZ').value = isCamera ? '0' : tool.preciseZ;
    
    document.getElementById('offsetX').disabled = isCamera;
    document.getElementById('offsetY').disabled = isCamera;
    document.getElementById('offsetZ').disabled = isCamera;
    document.getElementById('preciseX').disabled = isCamera;
    document.getElementById('preciseY').disabled = isCamera;
    document.getElementById('preciseZ').disabled = isCamera;
    
    document.getElementById('toolModal').style.display = 'block';
}

function saveTool() {
    const toolData = {
        id: parseInt(document.getElementById('toolId').value),
        name: document.getElementById('toolName').value,
        type: document.getElementById('toolType').value,
        offsetX: parseFloat(document.getElementById('offsetX').value) || 0,
        offsetY: parseFloat(document.getElementById('offsetY').value) || 0,
        offsetZ: parseFloat(document.getElementById('offsetZ').value) || 0,
        preciseX: parseFloat(document.getElementById('preciseX').value) || 0,
        preciseY: parseFloat(document.getElementById('preciseY').value) || 0,
        preciseZ: parseFloat(document.getElementById('preciseZ').value) || 0
    };
    
    if (toolData.type === 'camera') {
        toolData.offsetX = 0;
        toolData.offsetY = 0;
        toolData.offsetZ = 0;
        toolData.preciseX = 0;
        toolData.preciseY = 0;
        toolData.preciseZ = 0;
    }
    
    if (currentEditingTool !== null) {
        const index = tools.findIndex(t => t.id === currentEditingTool);
        tools[index] = toolData;
    } else {
        tools.push(toolData);
    }
    
    renderToolList();
    closeToolModal();
    
    fetch('/api/tools/save', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({tools: tools})
    });
}

function deleteTool(toolId) {
    if (confirm('Are you sure you want to delete this tool?')) {
        tools = tools.filter(t => t.id !== toolId);
        renderToolList();
        
        fetch('/api/tools/save', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({tools: tools})
        });
    }
}

function closeToolModal() {
    document.getElementById('toolModal').style.display = 'none';
    currentEditingTool = null;
    
    document.getElementById('offsetX').disabled = false;
    document.getElementById('offsetY').disabled = false;
    document.getElementById('offsetZ').disabled = false;
    document.getElementById('preciseX').disabled = false;
    document.getElementById('preciseY').disabled = false;
    document.getElementById('preciseZ').disabled = false;
}

// Initialize tool list when page loads
document.addEventListener('DOMContentLoaded', function() {
    renderToolList();
});




        </script>
    </head>
    <body>
        <div class="container">
            <h1>Rister Camera Controller with Calibration</h1>
            
            <!-- Debug Panel -->
            <div id="debugPanel" class="debug-panel">
                Loading debug info...
            </div>
            
            <div class="controls">
                <button onclick="startStream()">Start Stream</button>
                <button onclick="stopStream()" class="stop">Stop Stream</button>
                <button onclick="capturePhoto()" class="photo">Take Photo</button>
                <button onclick="startLineMeasurement()" class="calibration pixel-calibrate">Calibrate Pixel Size</button>
                <button onclick="startCameraCentering()" class="calibration camera-center">Center Camera</button>
                <button id="calibrationToggle" onclick="toggleCalibrationMode()" class="calibration">Enable Calibration Mode</button>
            </div>
           



<!-- Camera Calibration Tutorial Dropdown -->
<div class="tutorial-container">
    <button onclick="toggleTutorial()" class="tutorial-toggle">
        📖 Camera Calibration Tutorial
        <span id="tutorial-arrow">▼</span>
    </button>
    
    <div id="tutorial-content" class="tutorial-content" style="display: none;">
        <div class="tutorial-steps">
            <h3>🎯 Camera Calibration Process</h3>
            <p>Follow these steps to calibrate your camera for precise positioning:</p>
            
            <div class="step-section">
                <h4>Step 1: Print & Place Calibration Target</h4>
                <ul>
                    <li><strong>Copy the calibration target code below:</strong></li>
                    <li>Save it as <code>calibration_target.svg</code> on your computer</li>
                    <li>Open the SVG file and print at <strong>100% scale</strong> - Do not scale to fit page!</li>
                    <li>Verify the 50mm scale bar measures exactly 50mm with a ruler</li>
                    <li>Place the printed target on your print bed within camera view</li>
                    <li>Target doesn't need to be perfectly centered initially</li>
                </ul>
                
                <div class="svg-code-container">
                    <h5>Calibration Target SVG Code:</h5>
                    <textarea readonly style="width: 100%; height: 100px; font-family: monospace; font-size: 12px; resize: vertical;" onclick="this.select()">
&lt;svg width="210mm" height="297mm" viewBox="0 0 210 297" xmlns="http://www.w3.org/2000/svg"&gt;
  &lt;text x="105" y="25" text-anchor="middle" font-family="Arial" font-size="6" font-weight="bold"&gt;CAMERA CALIBRATION TARGET&lt;/text&gt;
  &lt;text x="105" y="32" text-anchor="middle" font-family="Arial" font-size="4"&gt;Print at 100% scale - Do not scale to fit&lt;/text&gt;
  &lt;g transform="translate(105, 150)"&gt;
    &lt;g stroke="black" stroke-width="0.3" fill="none"&gt;
      &lt;line x1="-25" y1="0" x2="25" y2="0"/&gt;
      &lt;line x1="0" y1="-25" x2="0" y2="25"/&gt;
      &lt;line x1="-20" y1="-2" x2="-20" y2="2"/&gt;
      &lt;line x1="-10" y1="-2" x2="-10" y2="2"/&gt;
      &lt;line x1="10" y1="-2" x2="10" y2="2"/&gt;
      &lt;line x1="20" y1="-2" x2="20" y2="2"/&gt;
      &lt;line x1="-2" y1="-20" x2="2" y2="-20"/&gt;
      &lt;line x1="-2" y1="-10" x2="2" y2="-10"/&gt;
      &lt;line x1="-2" y1="10" x2="2" y2="10"/&gt;
      &lt;line x1="-2" y1="20" x2="2" y2="20"/&gt;
    &lt;/g&gt;
    &lt;circle cx="0" cy="0" r="2" fill="none" stroke="black" stroke-width="0.3"/&gt;
    &lt;circle cx="0" cy="0" r="1" fill="black"/&gt;
    &lt;g fill="black" stroke="black" stroke-width="0.2"&gt;
      &lt;g transform="translate(-40, -40)"&gt;
        &lt;circle cx="0" cy="0" r="1.5" fill="none" stroke="black" stroke-width="0.3"/&gt;
        &lt;circle cx="0" cy="0" r="0.5" fill="black"/&gt;
        &lt;text x="0" y="-5" text-anchor="middle" font-family="Arial" font-size="3"&gt;TL&lt;/text&gt;
      &lt;/g&gt;
      &lt;g transform="translate(40, -40)"&gt;
        &lt;circle cx="0" cy="0" r="1.5" fill="none" stroke="black" stroke-width="0.3"/&gt;
        &lt;circle cx="0" cy="0" r="0.5" fill="black"/&gt;
        &lt;text x="0" y="-5" text-anchor="middle" font-family="Arial" font-size="3"&gt;TR&lt;/text&gt;
      &lt;/g&gt;
      &lt;g transform="translate(-40, 40)"&gt;
        &lt;circle cx="0" cy="0" r="1.5" fill="none" stroke="black" stroke-width="0.3"/&gt;
        &lt;circle cx="0" cy="0" r="0.5" fill="black"/&gt;
        &lt;text x="0" y="8" text-anchor="middle" font-family="Arial" font-size="3"&gt;BL&lt;/text&gt;
      &lt;/g&gt;
      &lt;g transform="translate(40, 40)"&gt;
        &lt;circle cx="0" cy="0" r="1.5" fill="none" stroke="black" stroke-width="0.3"/&gt;
        &lt;circle cx="0" cy="0" r="0.5" fill="black"/&gt;
        &lt;text x="0" y="8" text-anchor="middle" font-family="Arial" font-size="3"&gt;BR&lt;/text&gt;
      &lt;/g&gt;
    &lt;/g&gt;
    &lt;g font-family="Arial" font-size="3" fill="black"&gt;
      &lt;text x="-15" y="-6" text-anchor="middle"&gt;10mm&lt;/text&gt;
      &lt;text x="-5" y="-6" text-anchor="middle"&gt;10mm&lt;/text&gt;
      &lt;text x="5" y="-6" text-anchor="middle"&gt;10mm&lt;/text&gt;
      &lt;text x="15" y="-6" text-anchor="middle"&gt;10mm&lt;/text&gt;
      &lt;text x="0" y="-32" text-anchor="middle" font-weight="bold"&gt;50mm&lt;/text&gt;
      &lt;text x="32" y="2" text-anchor="middle" font-weight="bold" transform="rotate(-90, 32, 2)"&gt;50mm&lt;/text&gt;
    &lt;/g&gt;
  &lt;/g&gt;
  &lt;g transform="translate(20, 250)" font-family="Arial" font-size="4" fill="black"&gt;
    &lt;text x="0" y="0" font-weight="bold"&gt;CALIBRATION INSTRUCTIONS:&lt;/text&gt;
    &lt;text x="0" y="8"&gt;1. Print this page at 100% scale (no scaling!)&lt;/text&gt;
    &lt;text x="0" y="16"&gt;2. Place on printer bed within camera view&lt;/text&gt;
    &lt;text x="0" y="24"&gt;3. Use "Calibrate Pixel Size" - draw 50mm line across center crosshair&lt;/text&gt;
    &lt;text x="0" y="32"&gt;4. Use "Center Camera" - click on center dot to auto-center&lt;/text&gt;
    &lt;text x="0" y="40"&gt;5. Add reference points by clicking corner targets (TL, TR, BL, BR)&lt;/text&gt;
  &lt;/g&gt;
  &lt;g transform="translate(130, 250)" stroke="black" stroke-width="0.3" fill="black"&gt;
    &lt;line x1="0" y1="0" x2="50" y2="0"/&gt;
    &lt;line x1="0" y1="-2" x2="0" y2="2"/&gt;
    &lt;line x1="50" y1="-2" x2="50" y2="2"/&gt;
    &lt;text x="25" y="-4" text-anchor="middle" font-family="Arial" font-size="3"&gt;50mm Scale Check&lt;/text&gt;
    &lt;text x="25" y="8" text-anchor="middle" font-family="Arial" font-size="3"&gt;Measure with ruler to verify&lt;/text&gt;
    &lt;text x="25" y="16" text-anchor="middle" font-family="Arial" font-size="3"&gt;correct print scale&lt;/text&gt;
  &lt;/g&gt;
&lt;/svg&gt;
</textarea>
                    <p style="font-size: 12px; color: #666; margin-top: 5px;">
                        <strong>Instructions:</strong> Select all text above (click in box, then Ctrl+A), copy it (Ctrl+C), 
                        paste into a text editor, and save as "calibration_target.svg"
                    </p>
                </div>
            </div>
            
            <div class="step-section">
                <h4>Step 2: Calibrate Pixel Scale (Required First!)</h4>
                <ul>
                    <li>Click the <strong style="color: #ff6b35;">Calibrate Pixel Size</strong> button</li>
                    <li>Click and drag to draw a line across a known dimension of your object</li>
                    <li>Enter the actual measurement in millimeters when prompted</li>
                    <li>The system will calculate microns per pixel automatically</li>
                    <li><strong>⚠️ This must be done before using Center Camera!</strong></li>
                </ul>
            </div>
            
            <div class="step-section">
                <h4>Step 3: Center the Reference Object</h4>
                <ul>
                    <li>Click the <strong style="color: #3498db;">Center Camera</strong> button</li>
                    <li>Click directly on your reference object in the image</li>
                    <li>The camera will automatically move to center the object under the green crosshair</li>
                    <li>Repeat if needed for fine adjustment</li>
                </ul>
            </div>
            
            <div class="step-section">
                <h4>Step 4: Add Reference Points</h4>
                <ul>
                    <li>Click on specific features in the image to add calibration points</li>
                    <li>Each click records the pixel position and current printer coordinates</li>
                    <li><strong>Minimum:</strong> One reference point for basic functionality</li>
                    <li><strong>Recommended:</strong> 3-4 points near bed corners for higher precision</li>
                </ul>
                <div class="reference-points-explanation">
                    <h5>Why Multiple Points?</h5>
                    <ul>
                        <li><strong>Single Point:</strong> Good accuracy near reference, ±2-5mm error at bed edges</li>
                        <li><strong>Multiple Points:</strong> Corrects camera distortion, bed rotation, and perspective effects</li>
                        <li><strong>Best for Multi-Tool:</strong> Essential for accurate tool switching across the bed</li>
                    </ul>
                </div>
            </div>
            
            <div class="step-section success-box">
                <h4>✅ Calibration Complete!</h4>
                <p>Your camera is now calibrated. You can:</p>
                <ul>
                    <li>Click anywhere in the image to get precise printer coordinates</li>
                    <li>Use the tools to measure distances and positions accurately</li>
                    <li>Switch between different tools with known positional relationships</li>
                </ul>
            </div>
            
            <div class="tips-section">
                <h4>💡 Pro Tips</h4>
                <ul>
                    <li><strong>Use a ruler or grid pattern</strong> for the most accurate calibration</li>
                    <li><strong>Start with one reference point</strong> for quick testing, add more for precision</li>
                    <li><strong>Place additional points near bed corners</strong> for full-bed accuracy</li>
                    <li><strong>Recalibrate</strong> if you change camera height or focus</li>
                    <li><strong>The green crosshair</strong> shows the exact center of your camera view</li>
                </ul>
            </div>
        </div>
    </div>
</div>

<style>
.tutorial-container {
    margin: 10px 0;
    border: 1px solid #ddd;
    border-radius: 5px;
    background-color: #f9f9f9;
}

.tutorial-toggle {
    width: 100%;
    padding: 12px 15px;
    background-color: #f1f1f1;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 16px;
    font-weight: bold;
    text-align: left;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: #3498db !important;  /* Blue hyperlink color */
    text-decoration: none;
}

.tutorial-toggle:hover {
    background-color: #e8e8e8;
}

.tutorial-content {
    padding: 20px;
    background-color: white;
    border-top: 1px solid #ddd;
}

.tutorial-steps h3 {
    color: #2c3e50;
    margin-top: 0;
    margin-bottom: 15px;
}

.step-section {
    margin-bottom: 20px;
    padding: 15px;
    border-left: 4px solid #3498db;
    background-color: #f8f9fa;
}

.step-section h4 {
    color: #2c3e50;
    margin-top: 0;
    margin-bottom: 10px;
}

.step-section ul {
    margin: 10px 0;
    padding-left: 20px;
}

.step-section li {
    margin-bottom: 8px;
    line-height: 1.4;
}

.success-box {
    border-left-color: #27ae60;
    background-color: #d5f4e6;
}

.tips-section {
    border-left-color: #f39c12;
    background-color: #fef9e7;
}

.svg-code-container {
    margin: 15px 0;
    padding: 15px;
    background-color: #f8f9fa;
    border: 1px solid #dee2e6;
    border-radius: 4px;
}

.svg-code-container h5 {
    margin-top: 0;
    margin-bottom: 10px;
    color: #2c3e50;
    font-size: 14px;
}

.svg-code-container textarea {
    border: 1px solid #ccc;
    border-radius: 4px;
    padding: 10px;
}

.svg-code-container p {
    margin-bottom: 0;
}

.reference-points-explanation {
    margin-top: 15px;
    padding: 10px;
    background-color: #e8f4fd;
    border: 1px solid #3498db;
    border-radius: 4px;
}

.reference-points-explanation h5 {
    margin-top: 0;
    margin-bottom: 8px;
    color: #2c3e50;
    font-size: 14px;
}

.reference-points-explanation ul {
    margin-bottom: 5px;
    font-size: 13px;
}

.reference-points-explanation li {
    margin-bottom: 4px;
}

.tutorial-content p {
    margin-bottom: 15px;
    line-height: 1.5;
}

#tutorial-arrow {
    transition: transform 0.3s ease;
}

.tutorial-arrow-up {
    transform: rotate(180deg);
}
</style>



<!--Tool management html -->
<!-- Tool Management Interface -->
<!-- Tool Management Interface (Dropdown Version) -->
<div class="tool-management-container">
    <button onclick="toggleToolManagement()" class="tool-management-toggle">
        🔧 Tool Management & Calibration
        <span id="tool-arrow">▼</span>
    </button>
    
    <div id="tool-management-content" class="tool-management-content" style="display: none;">
        <!-- Current Active Tool -->
        <div class="current-tool-section">
            <h4>Current Active Tool</h4>
            <select id="currentTool" onchange="selectTool()">
                <option value="0">Camera Tool (C0)</option>
                <option value="1">Extruder 1 (E0)</option>
                <option value="2">Extruder 2 (E1)</option>
                <option value="3">Liquid Dispenser (L0)</option>
            </select>
            <button onclick="getCurrentPosition()" class="get-position-btn">Get Current Position</button>
        </div>

        <!-- Tool List -->
        <div class="tool-list-section">
            <h4>Registered Tools</h4>
            <div id="toolList" class="tool-list">
                <!-- Tools will be populated here -->
            </div>
            <button onclick="addNewTool()" class="add-tool-btn">+ Add New Tool</button>
        </div>

        <!-- Calibration Workflow -->
        <div class="calibration-workflow">
            <h4>📐 Calibration Workflow</h4>
            
            <div class="workflow-step">
                <h5>Step 1: Set Camera Reference Point</h5>
                <p>Center camera (C0) on fiducial target, then click:</p>
                <button onclick="setCameraReference()" class="workflow-btn">Set Camera Reference</button>
                <span id="cameraRefStatus" class="status-indicator">Not Set</span>
                <p><em>Note: Camera tool (C0) has no offsets - it's the reference point for all other tools.</em></p>
            </div>

            <div class="workflow-step">
                <h5>Step 2: Record Approximate Tool Positions</h5>
                <p>For each tool (E0, E1, L0), manually move to reference location:</p>
                <div id="approximateCalibration">
                    <!-- Approximate calibration buttons will be populated here -->
                </div>
            </div>

            <div class="workflow-step">
                <h5>Step 3: Precision Calibration</h5>
                <p>Dispense material with each tool, then use camera to find exact location:</p>
                <div id="precisionCalibration">
                    <!-- Precision calibration buttons will be populated here -->
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Tool Details Modal -->
<div id="toolModal" class="modal" style="display: none;">
    <div class="modal-content">
        <span class="close" onclick="closeToolModal()">&times;</span>
        <h3 id="modalTitle">Tool Configuration</h3>
        
        <div class="tool-form">
            <label>Tool Name:</label>
            <input type="text" id="toolName" placeholder="e.g., Extruder 1 (E0)">
            
            <label>Tool ID:</label>
            <input type="number" id="toolId" placeholder="1" min="0" max="99">
            
            <label>Tool Type:</label>
            <select id="toolType">
                <option value="camera">Camera</option>
                <option value="extruder">Extruder</option>
                <option value="dispenser">Liquid Dispenser</option>
                <option value="probe">Probe</option>
                <option value="other">Other</option>
            </select>
            
            <h4>Approximate Offsets (mm)</h4>
            <p style="font-size: 12px; color: #666; margin-bottom: 10px;">
                <em>Note: Camera Tool (C0) has no offsets - it's the reference point.</em>
            </p>
            <div class="coordinate-inputs">
                <label>X Offset:</label>
                <input type="number" id="offsetX" step="0.1" placeholder="0.0">
                
                <label>Y Offset:</label>
                <input type="number" id="offsetY" step="0.1" placeholder="0.0">
                
                <label>Z Offset:</label>
                <input type="number" id="offsetZ" step="0.1" placeholder="0.0">
            </div>
            
            <h4>Precision Offsets (mm)</h4>
            <p style="font-size: 12px; color: #666; margin-bottom: 10px;">
                <em>Calculated automatically from camera clicks on dispensed material.</em>
            </p>
            <div class="coordinate-inputs">
                <label>Precise X:</label>
                <input type="number" id="preciseX" step="0.01" placeholder="0.00">
                
                <label>Precise Y:</label>
                <input type="number" id="preciseY" step="0.01" placeholder="0.00">
                
                <label>Precise Z:</label>
                <input type="number" id="preciseZ" step="0.01" placeholder="0.00">
            </div>
            
            <div class="modal-buttons">
                <button onclick="saveTool()" class="save-btn">Save Tool</button>
                <button onclick="closeToolModal()" class="cancel-btn">Cancel</button>
            </div>
        </div>
    </div>
</div>

<style>
.tool-management-container {
    margin: 10px 0;
    border: 1px solid #ddd;
    border-radius: 5px;
    background-color: #f9f9f9;
}

.tool-management-toggle {
    width: 100%;
    padding: 12px 15px;
    background-color: #f1f1f1;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 16px;
    font-weight: bold;
    text-align: left;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: #2c3e50 !important;
    text-decoration: none;
}

.tool-management-toggle:hover {
    background-color: #e8e8e8;
    text-decoration: underline;
}

.tool-management-content {
    padding: 20px;
    background-color: white;
    border-top: 1px solid #ddd;
}

.current-tool-section {
    margin-bottom: 20px;
    padding: 15px;
    background-color: white;
    border-radius: 5px;
    border: 1px solid #e0e0e0;
}

.current-tool-section select {
    padding: 8px 12px;
    margin-right: 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 14px;
}

.get-position-btn {
    padding: 8px 16px;
    background-color: #17a2b8;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

.get-position-btn:hover {
    background-color: #138496;
}

.tool-list {
    margin: 10px 0;
    max-height: 200px;
    overflow-y: auto;
}

.tool-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px;
    margin: 5px 0;
    background-color: white;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
}

.tool-info {
    flex-grow: 1;
}

.tool-name {
    font-weight: bold;
    color: #2c3e50;
}

.tool-details {
    font-size: 12px;
    color: #666;
    margin-top: 2px;
}

.tool-actions {
    display: flex;
    gap: 5px;
}

.tool-actions button {
    padding: 4px 8px;
    border: none;
    border-radius: 3px;
    cursor: pointer;
    font-size: 12px;
}

.edit-btn {
    background-color: #ffc107;
    color: black;
}

.delete-btn {
    background-color: #dc3545;
    color: white;
}

.add-tool-btn {
    padding: 10px 20px;
    background-color: #28a745;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-weight: bold;
}

.add-tool-btn:hover {
    background-color: #218838;
}

.workflow-step {
    margin: 15px 0;
    padding: 15px;
    background-color: white;
    border-radius: 5px;
    border-left: 4px solid #007bff;
}

.workflow-step h5 {
    margin-top: 0;
    color: #2c3e50;
}

.workflow-btn {
    padding: 8px 16px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    margin-right: 10px;
}

.workflow-btn:hover {
    background-color: #0056b3;
}

.status-indicator {
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: bold;
}

.status-indicator.not-set {
    background-color: #ffc107;
    color: black;
}

.status-indicator.set {
    background-color: #28a745;
    color: white;
}

#tool-arrow {
    transition: transform 0.3s ease;
}

.tool-arrow-up {
    transform: rotate(180deg);
}

/* Modal Styles */
.modal {
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5);
}

.modal-content {
    background-color: white;
    margin: 5% auto;
    padding: 20px;
    border-radius: 8px;
    width: 90%;
    max-width: 500px;
    max-height: 80vh;
    overflow-y: auto;
}

.close {
    color: #aaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
    cursor: pointer;
}

.close:hover {
    color: black;
}

.tool-form label {
    display: block;
    margin-top: 10px;
    margin-bottom: 5px;
    font-weight: bold;
    color: #2c3e50;
}

.tool-form input, .tool-form select {
    width: 100%;
    padding: 8px 12px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
    box-sizing: border-box;
}

.coordinate-inputs {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: 10px;
    align-items: center;
    margin: 10px 0;
}

.coordinate-inputs label {
    margin: 0;
}

.coordinate-inputs input {
    margin: 0;
}

.modal-buttons {
    display: flex;
    gap: 10px;
    margin-top: 20px;
    justify-content: flex-end;
}

.save-btn {
    padding: 10px 20px;
    background-color: #28a745;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

.cancel-btn {
    padding: 10px 20px;
    background-color: #6c757d;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}
</style>















<script>
function toggleTutorial() {
    const content = document.getElementById('tutorial-content');
    const arrow = document.getElementById('tutorial-arrow');
    
    if (content.style.display === 'none') {
        content.style.display = 'block';
        arrow.classList.add('tutorial-arrow-up');
    } else {
        content.style.display = 'none';
        arrow.classList.remove('tutorial-arrow-up');
    }
}
</script>










            <div id="focusControls" class="controls" style="display: none;">
                <button onclick="setFocusAuto()" class="focus">Auto Focus</button>
                <div class="slider-container">
                    <label for="focusSlider">Manual Focus: <span id="focusValue">10</span></label>
                    <input type="range" min="0" max="30" value="10" step="0.5" class="slider" id="focusSlider" 
                           oninput="updateFocusValue(this.value)" onchange="setFocusManual(this.value)">
                </div>
            </div>
            
            <div id="calibrationPanel" class="calibration-panel" style="display: none;">
                <h2>Pixel-to-Printer Coordinate Calibration</h2>
                <p><strong>Status:</strong> <span id="calibrationStatus">DISABLED</span></p>
                
                <div class="input-group">
                    <label>Microns per pixel X:</label>
                    <input type="number" id="micronPerPixelX" value="10" step="0.1" min="0.1" max="1000">
                    <label>Microns per pixel Y:</label>
                    <input type="number" id="micronPerPixelY" value="10" step="0.1" min="0.1" max="1000">
                    <button onclick="updateMicronsPerPixel()">Update</button>
                </div>
                
                <div class="controls">
                    <button onclick="enableCalibration()" class="calibration">Enable Calibration</button>
                    <button onclick="disableCalibration()" class="stop">Disable Calibration</button>
                    <button onclick="clearCalibration()" class="stop">Clear All Points</button>
                </div>
                
                <h3>Reference Points</h3>
                <div id="referencePoints" class="reference-points">
                    <div class="reference-point">No reference points set</div>
                </div>
                
                <p><strong>Instructions:</strong></p>
                <ul style="text-align: left;">
                    <li>1. Measure your calibration object (ruler, etc.) and calculate microns per pixel</li>
                    <li>2. Move printer to a known position</li>
                    <li>3. Click on the corresponding point in the image</li>
                    <li>4. Repeat for multiple reference points for better accuracy</li>
                    <li>5. Enable calibration to start using pixel-to-printer coordinate conversion</li>
                </ul>
            </div>
            
            <div id="streamContainer" class="media-container" style="display: none;">
                <h3>Live Stream</h3>
                <img id="streamImg" class="clickable-image" 

<img id="streamImg" class="clickable-image" 
     onmousedown="measureClick(event)" 
     onmousemove="measureClick(event)" 
     onmouseup="measureClick(event)"
     onclick="handleImageClick(event, 'stream'); measureClick(event); centerCameraClick(event);"
     src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" 
     alt="Live Stream">

            </div>





            <div id="photoContainer" class="media-container" style="display: none;">
                <h3>Latest Photo</h3>

<img id="photoImg" class="clickable-image"
     onmousedown="measureClick(event)" 
     onmousemove="measureClick(event)" 
     onmouseup="measureClick(event)"
     onclick="handleImageClick(event, 'snapshot'); measureClick(event); centerCameraClick(event);"
     src="/latest_photo" 
     alt="Latest Captured Photo">

            </div>



        </div>
    </body>
    </html>
    """
    return html




# Add this to your Flask application

@app.route('/api/printer/move_camera', methods=['POST'])
def api_move_camera():
    """Move the camera tool by a relative offset"""
    try:
        data = request.json
        offset_x = float(data.get("offset_x", 0))
        offset_y = float(data.get("offset_y", 0))
        
        logger.info(f"Moving camera tool by offset: X={offset_x:.3f}mm, Y={offset_y:.3f}mm")
        
        # Get current position
        current_pos = send_gcode("M114")
        if not current_pos:
            return jsonify({"status": "error", "message": "Failed to get current position"})
        
        # Parse current position (format: "X:123.45 Y:67.89 Z:...")
        try:
            pos_parts = current_pos.strip().split()
            current_x = None
            current_y = None
            
            for part in pos_parts:
                if part.startswith("X:"):
                    current_x = float(part[2:])
                elif part.startswith("Y:"):
                    current_y = float(part[2:])
            
            if current_x is None or current_y is None:
                return jsonify({"status": "error", "message": "Could not parse current position"})
                
        except (ValueError, IndexError):
            return jsonify({"status": "error", "message": "Invalid position format from printer"})
        
        # Calculate new position
        new_x = current_x + offset_x
        new_y = current_y + offset_y
        
        # Ensure camera tool is selected (T0 assuming camera is tool 0)
        tool_result = send_gcode("T0")  # Select camera tool
        if not tool_result:
            logger.warning("Failed to select camera tool, continuing anyway")
        
        # Move to new position
        move_command = f"G1 X{new_x:.3f} Y{new_y:.3f} F3000"
        move_result = send_gcode(move_command)
        
        if move_result:
            logger.info(f"Camera moved from ({current_x:.3f}, {current_y:.3f}) to ({new_x:.3f}, {new_y:.3f})")
            return jsonify({
                "status": "success", 
                "message": f"Camera moved to X{new_x:.3f} Y{new_y:.3f}",
                "old_position": {"x": current_x, "y": current_y},
                "new_position": {"x": new_x, "y": new_y},
                "offset": {"x": offset_x, "y": offset_y}
            })
        else:
            return jsonify({"status": "error", "message": "Failed to move camera"})
            
    except Exception as e:
        logger.error(f"Error moving camera: {e}")
        return jsonify({"status": "error", "message": str(e)})



@app.route('/api/printer/select_tool', methods=['POST'])
def api_select_tool():
    """Select a specific tool using correct commands"""
    try:
        data = request.json
        tool_command = data.get("tool_command", "C0")
        
        logger.info(f"Selecting tool {tool_command}")
        
        # Send tool selection command (C0, E0, E1, L0)
        result = send_gcode(tool_command)
        
        if result:
            return jsonify({
                "status": "success", 
                "message": f"Tool {tool_command} selected",
                "tool_command": tool_command
            })
        else:
            return jsonify({"status": "error", "message": f"Failed to select tool {tool_command}"})
            
    except Exception as e:
        logger.error(f"Error selecting tool: {e}")
        return jsonify({"status": "error", "message": str(e)})



# Add to existing send_gcode function or modify if needed
def send_gcode(command):
    """Send G-code command to printer via MQTT"""
    try:
        logger.info(f"Sending G-code: {command}")
        
        # Clear any previous response
        global gcode_response
        gcode_response = None
        
        # Publish G-code command
        mqtt_client.publish("printer/gcode", command)
        
        # Wait for response (with timeout)
        start_time = time.time()
        while gcode_response is None and (time.time() - start_time) < 10:  # 10 second timeout
            time.sleep(0.1)
        
        if gcode_response:
            logger.info(f"G-code response: {gcode_response}")
            return gcode_response
        else:
            logger.error(f"G-code timeout for command: {command}")
            return None
            
    except Exception as e:
        logger.error(f"Error sending G-code: {e}")
        return None

# Global variable to store G-code responses
gcode_response = None

def on_gcode_response(client, userdata, message):
    """Handle G-code response from printer"""
    global gcode_response
    try:
        gcode_response = message.payload.decode('utf-8')
        logger.info(f"Received G-code response: {gcode_response}")
    except Exception as e:
        logger.error(f"Error processing G-code response: {e}")

# Subscribe to G-code response topic (add this to your MQTT setup)
# mqtt_client.subscribe("printer/gcode/response")
# mqtt_client.message_callback_add("printer/gcode/response", on_gcode_response)






# Enhanced printer position API endpoint with better error handling
@app.route('/api/printer/position')
def api_printer_position():
    """FIXED: Get current printer position via MQTT with better debugging"""
    global current_printer_position, position_request_pending
    
    logger.info("API: Printer position requested")
    
    # First check if we already have a recent position
    with position_lock:
        current_pos = current_printer_position.copy()
        is_pending = position_request_pending
    
    logger.info(f"Current cached position: {current_pos}")
    
    # Try to get fresh position
    if request_printer_position():
        logger.info("Position request sent, waiting for response...")
        
        # Wait for response with timeout
        timeout = 10  # Increased timeout for debugging
        start_time = time.time()
        
        while True:
            with position_lock:
                is_pending = position_request_pending
                current_pos = current_printer_position.copy()
            
            if not is_pending:
                logger.info(f"Position response received: {current_pos}")
                return jsonify({
                    "status": "success",
                    "position": current_pos,
                    "wait_time": round(time.time() - start_time, 2)
                })
            
            if (time.time() - start_time) > timeout:
                logger.warning(f"Position request timeout after {timeout}s, using cached position")
                break
                
            time.sleep(0.1)
        
        # Timeout - return cached position with warning
        return jsonify({
            "status": "timeout",
            "position": current_pos,
            "message": f"Position request timed out after {timeout}s, using cached position",
            "wait_time": timeout
        })
    else:
        logger.error("Failed to send position request")
        return jsonify({
            "status": "error",
            "position": current_pos,
            "message": "Failed to request printer position - MQTT not connected"
        })

@app.route('/api/calibration/add_point', methods=['POST'])
def api_calibration_add_point():
    """Add a reference point for calibration"""
    try:
        data = request.json
        logger.info(f"Adding calibration point: {data}")
        
        point = {
            "pixel_x": int(data["pixel_x"]),
            "pixel_y": int(data["pixel_y"]),
            "printer_x": float(data["printer_x"]),
            "printer_y": float(data["printer_y"]),
            "printer_z": float(data["printer_z"]),
            "timestamp": datetime.now().isoformat()
        }
        
        calibration_data["reference_points"].append(point)
        save_calibration_data()
        
        logger.info(f"Added calibration point: {point}")
        
        return jsonify({"status": "success", "point": point})
    except Exception as e:
        logger.error(f"Error adding calibration point: {e}")
        return jsonify({"status": "error", "message": str(e)})

@app.route('/api/calibration/set_microns', methods=['POST'])
def api_calibration_set_microns():
    """Set microns per pixel values"""
    try:
        data = request.json
        calibration_data["microns_per_pixel_x"] = float(data["microns_per_pixel_x"])
        calibration_data["microns_per_pixel_y"] = float(data["microns_per_pixel_y"])
        save_calibration_data()
        
        return jsonify({"status": "success"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

@app.route('/api/calibration/enable', methods=['POST'])
def api_calibration_enable():
    """Enable calibration"""
    calibration_data["enabled"] = True
    save_calibration_data()
    return jsonify({"status": "success"})

@app.route('/api/calibration/disable', methods=['POST'])
def api_calibration_disable():
    """Disable calibration"""
    calibration_data["enabled"] = False
    save_calibration_data()
    return jsonify({"status": "success"})

@app.route('/api/calibration/clear', methods=['POST'])
def api_calibration_clear():
    """Clear all calibration data"""
    calibration_data["reference_points"] = []
    calibration_data["enabled"] = False
    save_calibration_data()
    return jsonify({"status": "success"})

@app.route('/api/calibration/data')
def api_calibration_data():
    """Get calibration data"""
    return jsonify(calibration_data)

@app.route('/api/calibration/convert', methods=['POST'])
def api_calibration_convert():
    """Convert pixel coordinates to printer coordinates"""
    try:
        data = request.json
        pixel_x = int(data["pixel_x"])
        pixel_y = int(data["pixel_y"])
        
        with position_lock:
            current_pos = current_printer_position.copy()
        
        result = pixel_to_printer_coordinates(
            pixel_x, pixel_y,
            current_pos["x"],
            current_pos["y"]
        )
        
        if result:
            return jsonify({"status": "success", "conversion": result})
        else:
            return jsonify({"status": "error", "message": "Calibration not available"})
            
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})



@app.route('/api/scaler/calculate', methods=['POST'])
def api_scaler_calculate():
    try:
        data = request.json
        width_mm = float(data["width_mm"])
        height_mm = float(data["height_mm"])
        pixel_width = float(data["pixel_width"])
        pixel_height = float(data["pixel_height"])
        
        microns_x = (width_mm * 1000) / pixel_width
        microns_y = (height_mm * 1000) / pixel_height
        
        # Update calibration data
        calibration_data["microns_per_pixel_x"] = microns_x
        calibration_data["microns_per_pixel_y"] = microns_y
        save_calibration_data()
        
        return jsonify({
            "status": "success",
            "microns_per_pixel_x": microns_x,
            "microns_per_pixel_y": microns_y
        })
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})





# Keep all existing routes
@app.route('/stream')
def stream():
    """Safari-compatible MJPEG stream endpoint"""
    global STREAM_ACTIVE, current_frame, frame_count
    
    if not STREAM_ACTIVE:
        blank_gif = b'GIF89a\x01\x00\x01\x00\x80\x00\x00\xff\xff\xff\x00\x00\x00!\xf9\x04\x01\x00\x00\x00\x00,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x02D\x01\x00;'
        return Response(blank_gif, mimetype='image/gif')
    
    def generate_frames():
        global STREAM_ACTIVE, current_frame, frame_count
        last_frame_count = 0
        
        if not STREAM_ACTIVE:
            return
        
        attempts = 0
        while current_frame is None and STREAM_ACTIVE and attempts < 20:
            time.sleep(0.1)
            attempts += 1
        
        while STREAM_ACTIVE:
            with frame_lock:
                frame = current_frame
                current_count = frame_count
            
            if frame and current_count > last_frame_count:
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n'
                       b'Content-Length: ' + str(len(frame)).encode() + b'\r\n'
                       b'Cache-Control: no-cache, no-store, must-revalidate\r\n'
                       b'Pragma: no-cache\r\n'
                       b'Expires: 0\r\n'
                       b'\r\n' + frame + b'\r\n')
                
                last_frame_count = current_count
                time.sleep(1/12)
            else:
                time.sleep(0.05)
    
    response = Response(
        generate_frames(),
        mimetype='multipart/x-mixed-replace; boundary=frame',
        headers={
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
            'Connection': 'close',
            'X-Accel-Buffering': 'no'
        }
    )
    return response

@app.route('/latest_photo')
def latest_photo():
    """Serve the most recently captured photo"""
    try:
        photos = [os.path.join(CAPTURE_DIR, f) for f in os.listdir(CAPTURE_DIR) 
                 if f.startswith("capture_") and f.endswith(".jpg")]
        
        if not photos:
            return "No photos available", 404
        
        photos.sort(key=lambda x: os.path.getmtime(x), reverse=True)
        latest = photos[0]
        
        return send_file(latest, mimetype='image/jpeg')
    except Exception as e:
        logger.error(f"Error serving latest photo: {e}")
        return "Error retrieving photo", 500

@app.route('/api/stream/start')
def api_stream_start():
    result = start_stream()
    return jsonify({"status": "success", "streaming": STREAM_ACTIVE})

@app.route('/api/stream/stop')
def api_stream_stop():
    result = stop_stream()
    return jsonify({"status": "success", "streaming": STREAM_ACTIVE})

@app.route('/api/capture')
def api_capture():
    result = capture_image()
    return jsonify({"status": "success" if result else "error", "result": result})

@app.route('/api/focus/auto')
def api_focus_auto():
    result = control_autofocus("auto")
    return jsonify({"status": "success" if result else "error", "mode": "auto"})

@app.route('/api/focus/manual/<position>')
def api_focus_manual(position):
    try:
        pos_float = float(position)
        result = control_autofocus("manual", pos_float)
        return jsonify({"status": "success" if result else "error", "mode": "manual", "position": pos_float})
    except ValueError:
        return jsonify({"status": "error", "message": "Invalid position value"})

@app.route('/api/status')
def api_status():
    """API endpoint to get camera status with calibration info"""
    global STREAM_ACTIVE, streaming_thread
    
    thread_alive = streaming_thread is not None and threading.active_count()
    
    if STREAM_ACTIVE and not thread_alive:
        STREAM_ACTIVE = False
    
    focus_info = get_focus_info()
    
    with position_lock:
        current_pos = current_printer_position.copy()
    
    return jsonify({
        "streaming": STREAM_ACTIVE,
        "camera_ready": True,
        "stream_active": STREAM_ACTIVE and thread_alive,
        "focus_mode": focus_info.get("mode", "auto"),
        "focus_position": focus_info.get("position", 10),
        "stream_width": STREAM_WIDTH,
        "stream_height": STREAM_HEIGHT,
        "capture_width": CAPTURE_WIDTH,
        "capture_height": CAPTURE_HEIGHT,
        "stream_quality": STREAM_QUALITY,
        "frame_count": frame_count,
        "calibration": calibration_data,
        "printer_position": current_pos
    })

# Initialize tools configuration on startup
load_tools_config()


if __name__ == '__main__':
    try:
        # Load calibration data on startup
        load_calibration_data()
        
        # Setup MQTT client
        setup_mqtt_client()
        
        # Start the Flask application
        logger.info(f"Starting Flask server on port {HTTP_PORT}")
        app.run(host='0.0.0.0', port=HTTP_PORT, threaded=True)
    except KeyboardInterrupt:
        logger.info("Application stopping due to keyboard interrupt")
        stop_stream()
        if mqtt_client:
            mqtt_client.loop_stop()
            mqtt_client.disconnect()
    except Exception as e:
        logger.error(f"Application error: {e}")
        stop_stream()
        if mqtt_client:
            mqtt_client.loop_stop()
            mqtt_client.disconnect()
