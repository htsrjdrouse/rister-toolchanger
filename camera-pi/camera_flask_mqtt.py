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
            # Default configuration with fiducials
            tools_config = {
                "tools": [
                    {"id": 0, "name": "Camera Tool (C0)", "type": "camera", "fiducialX": 0, "fiducialY": 0, "fiducialZ": 0, "isReference": True},
                    {"id": 1, "name": "Extruder 1 (E0)", "type": "extruder", "fiducialX": 0, "fiducialY": 0, "fiducialZ": 0, "isReference": False},
                    {"id": 2, "name": "Extruder 2 (E1)", "type": "extruder", "fiducialX": 0, "fiducialY": 0, "fiducialZ": 0, "isReference": False},
                    {"id": 3, "name": "Liquid Dispenser (L0)", "type": "dispenser", "fiducialX": 0, "fiducialY": 0, "fiducialZ": 0, "isReference": False}
                ],
                "reference_tool_id": 0
            }
            save_tools_config()
    except Exception as e:
        logger.error(f"Error loading tools config: {e}")


def save_tools_config():
    """Save tools configuration to file"""
    try:
        # Check if directory exists and is writable
        config_dir = os.path.dirname(TOOLS_CONFIG_FILE)
        if not os.path.exists(config_dir):
            os.makedirs(config_dir, exist_ok=True)
            logger.info(f"Created directory: {config_dir}")
        
        # Check write permissions
        if not os.access(config_dir, os.W_OK):
            logger.error(f"No write permission for directory: {config_dir}")
            return False
        
        logger.info(f"Saving tools config to {TOOLS_CONFIG_FILE}: {tools_config}")
        
        with open(TOOLS_CONFIG_FILE, 'w') as f:
            json.dump(tools_config, f, indent=2)
        
        logger.info("Tools configuration saved successfully")
        
        # Verify the save worked
        if os.path.exists(TOOLS_CONFIG_FILE):
            with open(TOOLS_CONFIG_FILE, 'r') as f:
                saved_data = json.load(f)
            logger.info(f"Verified saved data: {saved_data}")
        else:
            logger.error(f"File was not created: {TOOLS_CONFIG_FILE}")
            return False
        
        return True
    except Exception as e:
        logger.error(f"Error saving tools config: {e}")
        return False





def calculate_tool_offsets(tool_id):
    """Calculate automatic offsets for a tool based on the reference tool or 0,0,0 if no reference"""
    try:
        reference_tool = None
        target_tool = None
        
        for tool in tools_config["tools"]:
            if tool.get("isReference", False):
                reference_tool = tool
            if tool["id"] == tool_id:
                target_tool = tool
        
        if not target_tool:
            return {"offsetX": 0, "offsetY": 0, "offsetZ": 0}
        
        # If no reference tool is set, use 0,0,0 as reference
        if not reference_tool:
            offset_x = target_tool.get("fiducialX", 0)
            offset_y = target_tool.get("fiducialY", 0)
            offset_z = target_tool.get("fiducialZ", 0)
        else:
            # Calculate offsets: target - reference
            offset_x = target_tool.get("fiducialX", 0) - reference_tool.get("fiducialX", 0)
            offset_y = target_tool.get("fiducialY", 0) - reference_tool.get("fiducialY", 0)
            offset_z = target_tool.get("fiducialZ", 0) - reference_tool.get("fiducialZ", 0)
        
        return {
            "offsetX": round(offset_x, 3),
            "offsetY": round(offset_y, 3),
            "offsetZ": round(offset_z, 3)
        }
    except Exception as e:
        logger.error(f"Error calculating tool offsets: {e}")
        return {"offsetX": 0, "offsetY": 0, "offsetZ": 0}






#Tool management functions @app.routes
#tools configuration
@app.route('/api/tools/save', methods=['POST'])
def api_save_tools():
    """Save tools configuration"""
    try:
        data = request.json
        tools_config["tools"] = data.get("tools", [])
        
        # Find and set reference tool ID
        reference_tool = None
        for tool in tools_config["tools"]:
            if tool.get("isReference", False):
                reference_tool = tool["id"]
                break
        
        tools_config["reference_tool_id"] = reference_tool
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
            "reference_tool_id": tools_config.get("reference_tool_id")
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




/* Consistent header styling */
.tool-management-container .tool-management-toggle {
    font-size: 14px;
}

.tool-selection-section h4 {
    font-size: 18px !important;
    font-weight: 600;
    color: #333;
    margin: 0 0 15px 0;
    border-bottom: 2px solid #e9ecef;
    padding-bottom: 8px;
}

.calibration-panel h2 {
    font-size: 18px;
    font-weight: 600;
    color: #333;
    margin-top: 0;
}

/* Make sure the tool management toggle button has consistent styling */
.tool-management-toggle {
    margin: 5px;
    padding: 10px 20px;
    border: none;
    border-radius: 5px;
    background-color: #4CAF50;
    color: white;
    font-weight: bold;
    cursor: pointer;
    transition: background-color 0.3s;
    /* Remove the flex properties that might be causing issues */
}

.tool-management-toggle:hover {
    background-color: #3e8e41;
}


.modal-content {
    background-color: #fefefe;
    margin: 1% auto; /* Changed from 5% to 1% for higher positioning */
    padding: 20px;
    border: 1px solid #888;
    border-radius: 10px;
    width: 80%;
    max-width: 600px;
    position: relative;
    max-height: 95vh; /* Increased max height */
    overflow-y: auto;
    box-shadow: 0 8px 32px rgba(0,0,0,0.3);
}


.modal {
    display: none;
    position: fixed;
    z-index: 2000; /* Higher than other elements */
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    overflow: auto;
    background-color: rgba(0,0,0,0.4);
}

.modal-content {
    background-color: #fefefe;
    margin: 2% auto; /* Reduced from 5% to 2% to position higher */
    padding: 20px;
    border: 1px solid #888;
    border-radius: 10px;
    width: 80%;
    max-width: 600px;
    position: relative;
    max-height: 90vh; /* Limit height to viewport */
    overflow-y: auto; /* Allow scrolling if content is too tall */
    box-shadow: 0 4px 20px rgba(0,0,0,0.3);
}

/* Ensure modal appears above everything */
.modal-content {
    z-index: 2001;
}



/* Make all section headers consistent */
.tool-management-container h4,
.calibration-panel h2 {
    font-size: 18px;
    font-weight: 600;
    color: #333;
    margin: 0 0 15px 0;
    padding: 0;
    border-bottom: 2px solid #e9ecef;
    padding-bottom: 8px;
}

.tool-selection-section h4 {
    font-size: 16px;
    font-weight: 600;
    color: #2c3e50;
    margin: 0 0 15px 0;
}



.reference-checkbox-container {
    display: flex;
    align-items: center;
    gap: 8px;
    margin: 15px 0;
    padding: 10px;
    background-color: #e8f4fd;
    border: 1px solid #bee5eb;
    border-radius: 4px;
}

.reference-checkbox-container input[type="checkbox"] {
    width: auto;
    margin: 0;
}

.reference-checkbox-container label {
    margin: 0;
    font-weight: bold;
    color: #0c5460;
}

.offset-display {
    background-color: #f8f9fa;
    border: 1px solid #dee2e6;
    border-radius: 4px;
    padding: 10px;
    margin: 10px 0;
    font-family: monospace;
    font-size: 12px;
}


.coordinate-inputs {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 20px;
    margin: 15px 0;
    padding: 15px;
    background-color: #f8f9fa;
    border: 1px solid #e9ecef;
    border-radius: 8px;
}

.coordinate-inputs .input-group {
    display: flex;
    flex-direction: column;
    gap: 5px;
}

.coordinate-inputs label {
    margin: 0;
    font-weight: 600;
    color: #495057;
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.coordinate-inputs input {
    width: 100%;
    padding: 10px 12px;
    border: 2px solid #dee2e6;
    border-radius: 6px;
    font-size: 14px;
    font-family: 'Courier New', monospace;
    text-align: center;
    background-color: white;
    transition: all 0.2s ease;
    box-sizing: border-box;
}

.coordinate-inputs input:focus {
    outline: none;
    border-color: #4CAF50;
    box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
    background-color: #fafafa;
}

.coordinate-inputs input:hover {
    border-color: #adb5bd;
}

.tool-form h4 {
    margin: 20px 0 10px 0;
    color: #343a40;
    font-size: 16px;
    border-bottom: 2px solid #e9ecef;
    padding-bottom: 5px;
}

.offset-display {
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    border: 1px solid #dee2e6;
    border-radius: 8px;
    padding: 15px;
    margin: 15px 0;
    font-family: 'Courier New', monospace;
    font-size: 13px;
    box-shadow: inset 0 1px 3px rgba(0,0,0,0.1);
}

.offset-display div {
    margin: 5px 0;
    padding: 3px 0;
}

.offset-display span {
    font-weight: bold;
    color: #28a745;
}


.modal-buttons {
    margin-top: 20px;
    display: flex;
    gap: 10px;
    justify-content: flex-end;
}

.save-btn {
    background-color: #28a745;
    color: white;
}

.cancel-btn {
    background-color: #6c757d;
    color: white;
}







.coordinate-overlay {
    position: absolute;
    top: 10px;
    left: 10px;
    background-color: rgba(0, 0, 0, 0.8);
    color: white;
    padding: 8px 12px;
    border-radius: 5px;
    font-family: monospace;
    font-size: 12px;
    pointer-events: none;
    z-index: 1000;
    white-space: nowrap;
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



function updateFormFields() {
    console.log('updateFormFields called');
    
    const toolType = document.getElementById('toolType').value;
    const isReference = document.getElementById('isReference').checked;
    
    console.log('Tool type:', toolType, 'Is reference:', isReference);
    
    const programmedSection = document.getElementById('programmedSection');
    const actualSection = document.getElementById('actualSection');
    const dispenserSection = document.getElementById('dispenserSection');
    
    console.log('Sections found:', {
        programmed: !!programmedSection,
        actual: !!actualSection,
        dispenser: !!dispenserSection
    });
    
    // Show/hide sections based on tool type and reference status
    if (toolType === 'camera') {
        if (programmedSection) programmedSection.style.display = 'none';
        if (actualSection) actualSection.style.display = 'none';
        if (dispenserSection) dispenserSection.style.display = 'none';
    } else if (isReference) {
        if (programmedSection) programmedSection.style.display = 'block';
        if (actualSection) actualSection.style.display = 'none';
        if (dispenserSection) dispenserSection.style.display = toolType === 'dispenser' ? 'block' : 'none';
    } else {
        if (programmedSection) programmedSection.style.display = 'block';
        if (actualSection) actualSection.style.display = 'block';
        if (dispenserSection) dispenserSection.style.display = toolType === 'dispenser' ? 'block' : 'none';
    }
    
    updateOffsetDisplay();
}


function updateOffsetDisplay() {
    // Check if we're using the new modal structure
    const toolTypeElement = document.getElementById('toolType');
    const isReferenceElement = document.getElementById('isReference');
    
    if (!toolTypeElement || !isReferenceElement) {
        // Fall back to old fiducial system (keep existing logic)
        const fiducialX = parseFloat(document.getElementById('fiducialX')?.value) || 0;
        const fiducialY = parseFloat(document.getElementById('fiducialY')?.value) || 0;
        const fiducialZ = parseFloat(document.getElementById('fiducialZ')?.value) || 0;
        const isReference = document.getElementById('isReference')?.checked || false;
        
        if (isReference) {
            document.getElementById('calcOffsetX').textContent = '0.000';
            document.getElementById('calcOffsetY').textContent = '0.000';
            document.getElementById('calcOffsetZ').textContent = '0.000';
        } else {
            const referenceTool = tools.find(t => t.isReference === true);
            let offsetX, offsetY, offsetZ;
            
            if (referenceTool) {
                offsetX = fiducialX - (referenceTool.fiducialX || 0);
                offsetY = fiducialY - (referenceTool.fiducialY || 0);
                offsetZ = fiducialZ - (referenceTool.fiducialZ || 0);
            } else {
                offsetX = fiducialX;
                offsetY = fiducialY;
                offsetZ = fiducialZ;
            }
            
            document.getElementById('calcOffsetX').textContent = offsetX.toFixed(3);
            document.getElementById('calcOffsetY').textContent = offsetY.toFixed(3);
            document.getElementById('calcOffsetZ').textContent = offsetZ.toFixed(3);
        }
        return;
    }
    
    // New system logic
    const toolType = toolTypeElement.value;
    const isReference = isReferenceElement.checked;
    
    // Camera tools have no offsets
    if (toolType === 'camera') {
        document.getElementById('calcOffsetX').textContent = 'N/A';
        document.getElementById('calcOffsetY').textContent = 'N/A';
        document.getElementById('calcOffsetZ').textContent = 'N/A';
        return;
    }
    
    // Reference tools have no offsets
    if (isReference) {
        document.getElementById('calcOffsetX').textContent = '0.000';
        document.getElementById('calcOffsetY').textContent = '0.000';
        document.getElementById('calcOffsetZ').textContent = '0.000';
        return;
    }
    
    // For other tools, calculate X/Y offsets = actual - programmed
    // Z offset = reference_tool_programmed_Z - current_tool_programmed_Z + zOffset_input
    const programmedXElement = document.getElementById('programmedX');
    const programmedYElement = document.getElementById('programmedY');
    const programmedZElement = document.getElementById('programmedZ');
    const actualXElement = document.getElementById('actualX');
    const actualYElement = document.getElementById('actualY');
    const zOffsetElement = document.getElementById('zOffset');
    
    // Check if elements exist before accessing their values
    if (!programmedXElement || !actualXElement) {
        console.error('Required form elements not found');
        return;
    }
    
    const programmedX = parseFloat(programmedXElement.value) || 0;
    const programmedY = parseFloat(programmedYElement.value) || 0;
    const programmedZ = parseFloat(programmedZElement.value) || 0;
    
    const actualX = parseFloat(actualXElement.value) || 0;
    const actualY = parseFloat(actualYElement.value) || 0;
    const zOffsetInput = parseFloat(zOffsetElement?.value) || 0;
    
    // X and Y offsets are actual - programmed
    const offsetX = actualX - programmedX;
    const offsetY = actualY - programmedY;
    
    // Z offset calculation: reference_tool_Z - current_tool_Z + manual_Z_offset
    const referenceTool = tools.find(t => t.isReference === true);
    let offsetZ = zOffsetInput; // Start with manual Z offset
    
    if (referenceTool && referenceTool.programmedZ !== undefined) {
        offsetZ += (referenceTool.programmedZ - programmedZ);
    }
    
    document.getElementById('calcOffsetX').textContent = offsetX.toFixed(3);
    document.getElementById('calcOffsetY').textContent = offsetY.toFixed(3);
    document.getElementById('calcOffsetZ').textContent = offsetZ.toFixed(3);
}





function hideCoordinateDisplay(imageElement) {
    const overlay = imageElement.parentElement.querySelector('.coordinate-overlay');
    if (overlay) {
        overlay.style.display = 'none';
    }
}

function showCoordinateDisplay(imageElement) {
    const overlay = imageElement.parentElement.querySelector('.coordinate-overlay');
    if (overlay) {
        overlay.style.display = 'block';
    }
}





// Add these variables at the top of your script section
let imageFlipH = true;
let imageFlipV = true;

// Add these functions
function flipImageHorizontal() {
    imageFlipH = !imageFlipH;
    applyImageTransforms();
}

function flipImageVertical() {
    imageFlipV = !imageFlipV;
    applyImageTransforms();
}

function resetImageFlip() {
    imageFlipH = false;
    imageFlipV = false;
    applyImageTransforms();
}


function applyImageTransforms() {
    const images = document.querySelectorAll('.clickable-image');
    let transform = '';
    
    if (imageFlipH && imageFlipV) {
        transform = 'scaleX(-1) scaleY(-1)';
    } else if (imageFlipH) {
        transform = 'scaleX(-1)';
    } else if (imageFlipV) {
        transform = 'scaleY(-1)';
    } else {
        transform = 'none';
    }
    
    images.forEach(img => {
        img.style.transform = transform;
        img.style.transformOrigin = 'center';
    });
    
    // Update crosshair position after transform
    setTimeout(updateCrosshairPosition, 50);
}




function getCorrectCoordinates(event, imageElement) {
    const rect = imageElement.getBoundingClientRect();
    let x = Math.round(event.clientX - rect.left);
    let y = Math.round(event.clientY - rect.top);
    
    // Apply coordinate transformation based on flip state
    if (imageFlipH) {
        x = rect.width - x;
    }
    if (imageFlipV) {
        y = rect.height - y;
    }
    
    return { x, y };
}

function handleImageClick(event, imageType) {
    if (!calibrationMode) return;
    
    console.log('Image clicked in calibration mode');
    
    const coords = getCorrectCoordinates(event, event.target);
    console.log(`Corrected pixel coordinates: (${coords.x}, ${coords.y})`);
    
    showCoordinates(event.target, coords.x, coords.y);
    
    fetch('/api/printer/position')
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success' || data.status === 'timeout') {
                addReferencePoint(coords.x, coords.y, data.position.x, data.position.y, data.position.z);
            } else {
                alert('Failed to get printer position: ' + (data.message || 'Unknown error'));
            }
        })
        .catch(error => {
            console.error('Error getting printer position:', error);
            alert('Error getting printer position: ' + error);
        });
}

function updateCoordinateDisplay(event, imageElement) {
    let overlay = imageElement.parentElement.querySelector('.coordinate-overlay');
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.className = 'coordinate-overlay';
        imageElement.parentElement.appendChild(overlay);
    }
    
    // Get corrected coordinates
    const coords = getCorrectCoordinates(event, imageElement);
    
    const micronsPerPixelX = parseFloat(document.getElementById('micronPerPixelX').value) || 200.77730819;
    const micronsPerPixelY = parseFloat(document.getElementById('micronPerPixelY').value) || 200.77730819;
    
    // Calculate offset from center of image (489.5, 275.5)
    const centerX = 489.5;
    const centerY = 275.5;
    const pixelOffsetX = coords.x - centerX;
    const pixelOffsetY = coords.y - centerY;
    
    // Convert to mm offset - FIX THE X-AXIS DIRECTION
    const mmOffsetX = -(pixelOffsetX * micronsPerPixelX) / 1000;  // Negative sign to flip X direction
    const mmOffsetY = (pixelOffsetY * micronsPerPixelY) / 1000;   // Y direction stays the same
    
    // Get current printer position
    const currentPrinterX = debugInfo.printer_position?.x || 227.7;
    const currentPrinterY = debugInfo.printer_position?.y || 150;
    
    // Calculate target printer coordinates
    const targetX = currentPrinterX + mmOffsetX;
    const targetY = currentPrinterY + mmOffsetY;
    
    // Update overlay display
    overlay.innerHTML = `
        Pixel: (${coords.x}, ${coords.y})<br>
        Offset: (${mmOffsetX > 0 ? '+' : ''}${mmOffsetX.toFixed(2)}mm, ${mmOffsetY > 0 ? '+' : ''}${mmOffsetY.toFixed(2)}mm)
    `;
}






// Camera centering functionality
let centeringMode = false;
function addFiducialCrosshair(imageElement) {
    // Remove existing crosshair
    const existing = document.querySelector('.fiducial-crosshair-fixed');
    if (existing) existing.remove();
    
    // Get the image container position
    const rect = imageElement.getBoundingClientRect();
    
    // Create crosshair positioned absolutely to the viewport
    const crosshair = document.createElement('div');
    crosshair.className = 'fiducial-crosshair-fixed';
    crosshair.style.cssText = `
        position: fixed;
        left: ${rect.left + rect.width / 2}px;
        top: ${rect.top + rect.height / 2}px;
        transform: translate(-50%, -50%);
        pointer-events: none;
        z-index: 1000;
        color: #00ff00;
        font-size: 20px;
        font-weight: bold;
        text-shadow: 1px 1px 2px rgba(0,0,0,0.8);
    `;
    crosshair.innerHTML = '+';
    
    // Append to body (outside any transform context)
    document.body.appendChild(crosshair);
    
    return crosshair;
}


function updateCrosshairPosition() {
    const crosshair = document.querySelector('.fiducial-crosshair-fixed');
    const streamImg = document.getElementById('streamImg');
    const photoImg = document.getElementById('photoImg');
    
    if (crosshair && streamImg && streamImg.offsetParent) {
        const rect = streamImg.getBoundingClientRect();
        crosshair.style.left = (rect.left + rect.width / 2) + 'px';
        crosshair.style.top = (rect.top + rect.height / 2) + 'px';
    } else if (crosshair && photoImg && photoImg.offsetParent) {
        const rect = photoImg.getBoundingClientRect();
        crosshair.style.left = (rect.left + rect.width / 2) + 'px';
        crosshair.style.top = (rect.top + rect.height / 2) + 'px';
    }
}

// Add event listeners
window.addEventListener('resize', updateCrosshairPosition);
window.addEventListener('scroll', updateCrosshairPosition);





function debugCrosshairPosition() {
    const img = document.getElementById('streamImg');
    if (img) {
        console.log(`Image dimensions: ${img.width} x ${img.height}`);
        console.log(`Natural dimensions: ${img.naturalWidth} x ${img.naturalHeight}`);
        console.log(`Mathematical center should be: (${img.width/2}, ${img.height/2})`);
        
        // Test click at mathematical center
        const rect = img.getBoundingClientRect();
        const centerX = img.width / 2;
        const centerY = img.height / 2;
        console.log(`Click at center would give coordinates: (${centerX}, ${centerY})`);
    }
}


// Add this function to load tools from the backend
function loadToolsFromBackend() {
    fetch('/api/tools/load')
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                tools = data.tools || [];
                cameraReference = data.camera_reference;
                updateToolDropdown();
                console.log('Tools loaded from backend:', tools);
            } else {
                console.error('Failed to load tools:', data.message);
            }
        })
        .catch(error => {
            console.error('Error loading tools:', error);
        });
}

// Update the existing DOMContentLoaded event listener
document.addEventListener('DOMContentLoaded', function() {
    // Hide photo container on page load
    document.getElementById('photoContainer').style.display = 'none';
    
    // Apply default flips immediately
    applyImageTransforms();
    
    // Load tools from backend instead of just rendering the default list
    loadToolsFromBackend();
    
    // Initialize crosshair when images load
    const streamImg = document.getElementById('streamImg');
    const photoImg = document.getElementById('photoImg');
    
    if (streamImg) {
        streamImg.addEventListener('load', () => {
            if (document.getElementById('streamContainer').style.display !== 'none') {
                applyImageTransforms();
                setTimeout(() => {
                    addFiducialCrosshair(streamImg);
                    updateCrosshairPosition();
                }, 100);
            }
        });
    }
    
    if (photoImg) {
        photoImg.addEventListener('load', () => {
            if (document.getElementById('photoContainer').style.display !== 'none') {
                applyImageTransforms();
                setTimeout(() => {
                    addFiducialCrosshair(photoImg);
                    updateCrosshairPosition();
                }, 100);
            }
        });
    }

    // Add event listeners for fiducial inputs to update offset display
    const fiducialInputs = ['fiducialX', 'fiducialY', 'fiducialZ', 'isReference'];
    fiducialInputs.forEach(id => {
        const element = document.getElementById(id);
        if (element) {
            element.addEventListener('input', updateOffsetDisplay);
            element.addEventListener('change', updateOffsetDisplay);
        }
    });

    // ADD THIS: Event listeners for the new position inputs
    // Event listeners for the new position inputs
const positionInputs = ['programmedX', 'programmedY', 'programmedZ', 'actualX', 'actualY', 'zOffset'];
    positionInputs.forEach(id => {
        const element = document.getElementById(id);
        if (element) {
            element.addEventListener('input', updateOffsetDisplay);
            element.addEventListener('change', updateOffsetDisplay);
        }
    });



});








            let calibrationMode = false;
            let currentImageType = 'stream';
            let debugInfo = {};
            
            window.onload = function() {
                checkStatus();
                loadCalibrationData();
                setInterval(checkStatus, 3000);
            };
            


let consecutiveErrors = 0;

function checkStatus() {
    fetch('/api/status')
        .then(response => response.json())
        .then(data => {
            consecutiveErrors = 0; // Reset error counter on success
            debugInfo = data;
            updateDebugPanel();
            
            if (data.streaming) {
                document.getElementById('streamContainer').style.display = 'block';
                document.getElementById('focusControls').style.display = 'flex';
                refreshStreamImage();
                setTimeout(() => {
                    const streamImg = document.getElementById('streamImg');
                    if (streamImg.complete) {
                        addFiducialCrosshair(streamImg);
                        updateCrosshairPosition();
                    }
                }, 100);
            } else {
                document.getElementById('streamContainer').style.display = 'none';
                document.getElementById('focusControls').style.display = 'none';
            }
            
            if (data.calibration) {
                document.getElementById('micronPerPixelX').value = data.calibration.microns_per_pixel_x || 10;
                document.getElementById('micronPerPixelY').value = data.calibration.microns_per_pixel_y || 10;
                updateCalibrationStatus(data.calibration.enabled);
            }
        })
        .catch(error => {
            consecutiveErrors++;
            // Only log every 10th error to reduce console spam
            if (consecutiveErrors % 10 === 1) {
                console.error('Connection error (logging every 10th occurrence):', error);
            }
            updateDebugPanel('Server connection lost');
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
                // Make sure photo container is hidden when starting stream
                document.getElementById('photoContainer').style.display = 'none';
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
    // Hide stream container when taking photo
    document.getElementById('streamContainer').style.display = 'none';
    
    fetch('/api/capture')
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                document.getElementById('photoContainer').style.display = 'block';
                document.getElementById('photoImg').src = '/latest_photo?t=' + new Date().getTime();
                currentImageType = 'snapshot';
                
                // Add crosshair to photo after it loads
                const photoImg = document.getElementById('photoImg');
                photoImg.onload = function() {
                    addFiducialCrosshair(photoImg);
                };
            }
        })
        .catch(error => {
            console.error('Error capturing photo:', error);
        });
}



            function toggleCalibrationMode() {
                calibrationMode = !calibrationMode;
                document.getElementById('calibrationToggle').textContent = 
                    calibrationMode ? 'Disable Image Mapper' : 'Enable Image Mapper';
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





//For testing
function testModal() {
    const modal = document.getElementById('toolModal');
    console.log('Modal element:', modal);
    if (modal) {
        modal.style.display = 'block';
        console.log('Modal should be visible now');
    } else {
        console.log('Modal element not found!');
    }
}

//For testing
function debugTools() {
    console.log('Tools array:', tools);
    console.log('Tools length:', tools.length);
    console.log('Current tool value:', document.getElementById('currentTool').value);
}

function editTool(toolId) {
    console.log('editTool called with toolId:', toolId);
    
    const tool = tools.find(t => t.id === toolId);
    console.log('Found tool:', tool);
    
    if (!tool) {
        console.log('Tool not found!');
        return;
    }
    
    const modal = document.getElementById('toolModal');
    console.log('Modal element:', modal);
    
    if (!modal) {
        console.log('Modal element not found!');
        return;
    }
    
    currentEditingTool = toolId;
    document.getElementById('modalTitle').textContent = 'Edit Tool';
    document.getElementById('toolName').value = tool.name;
    document.getElementById('toolId').value = tool.id;
    document.getElementById('toolType').value = tool.type;
    document.getElementById('isReference').checked = tool.isReference || false;
    
    // Check if the new form elements exist
    const programmedX = document.getElementById('programmedX');
    const actualX = document.getElementById('actualX');
    console.log('programmedX element:', programmedX);
    console.log('actualX element:', actualX);
    
    // Load position data with fallback to old property names
    if (programmedX) programmedX.value = tool.programmedX || tool.fiducialX || 0;
    if (document.getElementById('programmedY')) document.getElementById('programmedY').value = tool.programmedY || tool.fiducialY || 0;
    if (document.getElementById('programmedZ')) document.getElementById('programmedZ').value = tool.programmedZ || tool.fiducialZ || 0;
    
    if (actualX) actualX.value = tool.actualX || 0;
    if (document.getElementById('actualY')) document.getElementById('actualY').value = tool.actualY || 0;

    // Load Z offset
    const zOffset = document.getElementById('zOffset');
    if (zOffset) zOffset.value = tool.zOffset || 0;

    
    // Load dispenser-specific data
    const linearActuator = document.getElementById('linearActuator');
    if (linearActuator) linearActuator.value = tool.linearActuator || 0;
    
    console.log('About to call updateFormFields');
    updateFormFields();
    
    console.log('About to show modal');
    modal.style.display = 'block';
    console.log('Modal display style set to block');
}



function saveTool() {
    const toolData = {
        id: parseInt(document.getElementById('toolId').value),
        name: document.getElementById('toolName').value,
        type: document.getElementById('toolType').value,
        isReference: document.getElementById('isReference').checked
    };
    
    console.log('Saving tool data:', toolData); // Debug
    
    // Validate required fields
    if (!toolData.name || toolData.name.trim() === '') {
        alert('Please enter a tool name');
        return;
    }
    
    // Add position data for non-camera tools
    if (toolData.type !== 'camera') {
        const programmedX = document.getElementById('programmedX');
        const programmedY = document.getElementById('programmedY');
        const programmedZ = document.getElementById('programmedZ');
        
        if (programmedX) toolData.programmedX = parseFloat(programmedX.value) || 0;
        if (programmedY) toolData.programmedY = parseFloat(programmedY.value) || 0;
        if (programmedZ) toolData.programmedZ = parseFloat(programmedZ.value) || 0;

// Add actual position data for non-reference tools
if (!toolData.isReference) {
    const actualElements = ['actualX', 'actualY'];
    for (let elementId of actualElements) {
        const element = document.getElementById(elementId);
        if (element) {
            toolData[elementId] = parseFloat(element.value) || 0;
            console.log(`Set ${elementId} to:`, toolData[elementId]);
        } else {
            console.warn(`Element ${elementId} not found`);
        }
    }
    
    // Handle Z offset separately
    const zOffsetElement = document.getElementById('zOffset');
    if (zOffsetElement) {
        toolData.zOffset = parseFloat(zOffsetElement.value) || 0;
        console.log('Set zOffset to:', toolData.zOffset);
    }
}

    }
    
    // Add dispenser-specific data
    if (toolData.type === 'dispenser') {
        const linearActuator = document.getElementById('linearActuator');
        if (linearActuator) {
          toolData.linearActuator = parseFloat(linearActuator.value) || 0;
          console.log('Set linearActuator to:', toolData.linearActuator);
      }    
    }
    
    // If this tool is set as reference, unset all others
    if (toolData.isReference) {
        tools.forEach(tool => {
            if (tool.id !== toolData.id) {
                tool.isReference = false;
            }
        });
    }
    
    // Update tools array
    if (currentEditingTool !== null) {
        const index = tools.findIndex(t => t.id === currentEditingTool);
        if (index !== -1) {
            tools[index] = toolData;
        }
    } else {
        const existingIndex = tools.findIndex(t => t.id === toolData.id);
        if (existingIndex !== -1) {
            tools[existingIndex] = toolData;
        } else {
            tools.push(toolData);
        }
    }
    
    console.log('Updated tools array:', tools); // Debug
    
    updateToolDropdown();
    closeToolModal();
    
    // Save to backend
    fetch('/api/tools/save', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({tools: tools})
    })
    .then(response => response.json())
    .then(data => {
        console.log('Backend save response:', data);
        if (data.status === 'success') {
            console.log('Tools saved successfully');
            loadToolsFromBackend();
        } else {
            alert('Error saving tools: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error saving tools:', error);
        alert('Error saving tools: ' + error);
    });
}





// Enhanced loadToolsFromBackend function
function loadToolsFromBackend() {
    console.log('Loading tools from backend...');
    
    fetch('/api/tools/load')
        .then(response => {
            console.log('Backend response status:', response.status);
            return response.json();
        })
        .then(data => {
            console.log('Backend response data:', data);
            
            if (data.status === 'success') {
                tools = data.tools || [];
                cameraReference = data.camera_reference;
                console.log('Tools loaded from backend:', tools);
                updateToolDropdown();
                // Update current tool dropdown
                const currentToolSelect = document.getElementById('currentTool');
                if (currentToolSelect) {
                    const currentValue = currentToolSelect.value;
                    currentToolSelect.innerHTML = '';
                    
                    tools.forEach(tool => {
                        const option = document.createElement('option');
                        option.value = tool.id;
                        option.textContent = tool.name;
                        currentToolSelect.appendChild(option);
                    });
                    
                    // Restore previous selection if still valid
                    if (Array.from(currentToolSelect.options).some(opt => opt.value === currentValue)) {
                        currentToolSelect.value = currentValue;
                    }
                }
            } else {
                console.error('Failed to load tools:', data.message);
                // Use default tools if backend fails
                tools = [
                    {id: 0, name: "Camera Tool (C0)", type: "camera", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0},
                    {id: 1, name: "Extruder 1 (E0)", type: "extruder", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0},
                    {id: 2, name: "Extruder 2 (E1)", type: "extruder", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0},
                    {id: 3, name: "Liquid Dispenser (L0)", type: "dispenser", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0}
                ];
                updateToolDropdown();
            }
        })
        .catch(error => {
            console.error('Error loading tools:', error);
            // Use default tools if request fails
            tools = [
                {id: 0, name: "Camera Tool (C0)", type: "camera", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0},
                {id: 1, name: "Extruder 1 (E0)", type: "extruder", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0},
                {id: 2, name: "Extruder 2 (E1)", type: "extruder", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0},
                {id: 3, name: "Liquid Dispenser (L0)", type: "dispenser", offsetX: 0, offsetY: 0, offsetZ: 0, preciseX: 0, preciseY: 0, preciseZ: 0}
            ];
            updateToolDropdown();
        });
}



// Test function to debug tool list
function debugToolList() {
    console.log('=== TOOL DEBUG INFO ===');
    console.log('Current tools array:', tools);
    console.log('Tools array length:', tools.length);
    console.log('Tools array type:', typeof tools);
    console.log('Is tools an array?', Array.isArray(tools));
    
    const toolListElement = document.getElementById('toolList');
    console.log('Tool list element exists?', !!toolListElement);
    console.log('Tool list innerHTML:', toolListElement ? toolListElement.innerHTML : 'N/A');
    
    tools.forEach((tool, index) => {
        console.log(`Tool ${index}:`, tool);
    });
    console.log('=== END DEBUG INFO ===');
}




function deleteTool(toolId) {
    if (confirm('Are you sure you want to delete this tool?')) {
        tools = tools.filter(t => t.id !== toolId);
        updateToolDropdown();

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
    
    // Clear form fields
    document.getElementById('toolName').value = '';
    document.getElementById('toolId').value = '';
    document.getElementById('toolType').value = 'extruder';
    document.getElementById('isReference').checked = false;
    document.getElementById('fiducialX').value = '0';
    document.getElementById('fiducialY').value = '0';
    document.getElementById('fiducialZ').value = '0';
    
    // Reset offset display
    document.getElementById('calcOffsetX').textContent = '0.000';
    document.getElementById('calcOffsetY').textContent = '0.000';
    document.getElementById('calcOffsetZ').textContent = '0.000';
}



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
                <!--<button onclick="startCameraCentering()" class="calibration camera-center">Center Camera</button>-->
                <button id="calibrationToggle" onclick="toggleCalibrationMode()" class="calibration">Image Mapper</button>
                <button onclick="flipImageHorizontal()" class="calibration">Flip Horizontal</button>
                <button onclick="flipImageVertical()" class="calibration">Flip Vertical</button>
                <button onclick="resetImageFlip()" class="calibration">Reset Flip</button>
            </div>
           



<!-- Camera Calibration Tutorial Dropdown -->
<!-- Camera Calibration Tutorial Dropdown -->
<div class="tutorial-container">
    <button onclick="toggleTutorial()" class="tutorial-toggle">
        📖 Image Mapper Tutorial
        <span id="tutorial-arrow">▼</span>
    </button>
    
    <div id="tutorial-content" class="tutorial-content" style="display: none;">
        <div class="tutorial-steps">
            <h3>🎯 Image Mapper Process</h3>
            <p>Follow these steps to map pixel coordinates to real printer positions:</p>
            
            <div class="step-section">
                <h4>Step 1: Print & Place Calibration Target</h4>
                <ul>
                    <li><strong>Copy the calibration target code below:</strong></li>
                    <li>Save it as <code>calibration_target.svg</code> on your computer</li>
                    <li>Open the SVG file and print at <strong>100% scale</strong> - Do not scale to fit page!</li>
                    <li>Verify the 50mm scale bar measures exactly 50mm with a ruler</li>
                    <li>Place the printed target on your print bed within camera view</li>
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
    &lt;text x="0" y="32"&gt;4. Use "Image Mapper" - click on targets to map coordinates&lt;/text&gt;
    &lt;text x="0" y="40"&gt;5. Use coordinates to manually center camera and add reference points&lt;/text&gt;
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
                <h4>Step 2: Calibrate Pixel Scale</h4>
                <ul>
                    <li>Click the <strong style="color: #ff6b35;">Calibrate Pixel Size</strong> button</li>
                    <li>Click and drag to draw a line across a known dimension (like the 50mm crosshair)</li>
                    <li>Enter the actual measurement in millimeters when prompted</li>
                    <li>The system calculates microns per pixel automatically</li>
                </ul>
            </div>
            
            <div class="step-section">
                <h4>Step 3: Use Image Mapper</h4>
                <ul>
                    <li>Click the <strong style="color: #FF9800;">Image Mapper</strong> button</li>
                    <li>Click on specific features in the image (center dot, corner targets)</li>
                    <li>Each click shows you both pixel coordinates and current printer position</li>
                    <li>Use this information to manually move your printer/camera to center targets</li>
                    <li>Add multiple reference points for better coordinate mapping accuracy</li>
                </ul>
            </div>
            
            <div class="step-section">
                <h4>Step 4: Manual Camera Positioning</h4>
                <ul>
                    <li>Use the coordinate information from Image Mapper clicks</li>
                    <li>Manually move your printer to center the camera on targets</li>
                    <li>Build up reference points at different locations for full-bed accuracy</li>
                    <li>Use flip buttons if your camera image appears inverted</li>
                </ul>
            </div>
            
            <div class="step-section success-box">
                <h4>✅ Mapping Complete!</h4>
                <p>Your camera coordinates are now mapped. You can:</p>
                <ul>
                    <li>Click anywhere in the image to get precise printer coordinates</li>
                    <li>Use the coordinate data to manually position your camera</li>
                    <li>Build reference points for accurate coordinate conversion across the bed</li>
                    <li>Measure distances and positions accurately in your images</li>
                </ul>
            </div>
            
            <div class="tips-section">
                <h4>💡 Pro Tips</h4>
                <ul>
                    <li><strong>Start with the center target</strong> for initial reference point</li>
                    <li><strong>Add corner targets</strong> for full-bed coordinate accuracy</li>
                    <li><strong>Use the flip buttons</strong> if your camera view is inverted</li>
                    <li><strong>Recalibrate pixel size</strong> if you change camera height or focus</li>
                    <li><strong>The green crosshair</strong> shows the exact center of your camera view</li>
                    <li><strong>Manual positioning</strong> gives you full control over camera movement</li>
                </ul>
            </div>
        </div>
    </div>
</div>













<!--Tool management html -->
<!-- Tool Management Interface -->
<div class="tool-management-container">
    <button onclick="toggleToolManagement()" class="tool-management-toggle">
        🔧 Tool Management
        <span id="tool-arrow">▼</span>
    </button>
    
    <div id="tool-management-content" class="tool-management-content" style="display: none;">
        <!-- Tool Selection and Management -->
        <div class="tool-selection-section">
            <h4>Tool Management</h4>
            <div class="tool-controls">
                <label for="currentTool">Select Tool:</label>
                <select id="currentTool">
                    <option value="0">Camera Tool (C0)</option>
                </select>
                
                <div class="tool-action-buttons">
                    <button onclick="editSelectedTool()" class="edit-tool-btn">Edit</button>
                    <button onclick="deleteSelectedTool()" class="delete-tool-btn">Delete</button>
                    <button onclick="addNewTool()" class="add-tool-btn">+ Add New</button>
                </div>
            </div>
            
            <!-- Selected Tool Info Display -->
            <div id="selectedToolInfo" class="selected-tool-info">
                <p><strong>Selected:</strong> <span id="selectedToolName">Camera Tool (C0)</span></p>
                <p><strong>Type:</strong> <span id="selectedToolType">camera</span></p>
                <p><strong>Offsets:</strong> <span id="selectedToolOffsets">Reference Tool (No Offsets)</span></p>
            </div>
        </div>
    </div>
</div>






<style>
.tool-selection-section {
    margin-bottom: 20px;
    padding: 15px;
    background-color: white;
    border-radius: 5px;
    border: 1px solid #e0e0e0;
}

.tool-controls {
    display: flex;
    flex-direction: column;
    gap: 15px;
}

.tool-controls label {
    font-weight: bold;
    color: #2c3e50;
}

.tool-controls select {
    padding: 8px 12px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 14px;
    min-width: 200px;
}

.tool-action-buttons {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}

.tool-action-buttons button {
    padding: 8px 16px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    font-weight: bold;
}

.select-tool-btn {
    background-color: #007bff;
    color: white;
}

.select-tool-btn:hover {
    background-color: #0056b3;
}

.edit-tool-btn {
    background-color: #ffc107;
    color: black;
}

.edit-tool-btn:hover {
    background-color: #e0a800;
}

.delete-tool-btn {
    background-color: #dc3545;
    color: white;
}

.delete-tool-btn:hover {
    background-color: #c82333;
}

.add-tool-btn {
    background-color: #28a745;
    color: white;
}

.add-tool-btn:hover {
    background-color: #218838;
}

.selected-tool-info {
    margin-top: 15px;
    padding: 10px;
    background-color: #f8f9fa;
    border: 1px solid #dee2e6;
    border-radius: 4px;
    font-size: 14px;
}

.selected-tool-info p {
    margin: 5px 0;
}

.selected-tool-info span {
    font-family: monospace;
    color: #495057;
}
.tool-selection-section {
    margin-bottom: 20px;
    padding: 15px;
    background-color: white;
    border-radius: 5px;
    border: 1px solid #e0e0e0;
}

.tool-controls {
    display: flex;
    flex-direction: column;
    gap: 15px;
}

.tool-action-buttons {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}

.edit-tool-btn {
    background-color: #ffc107;
    color: black;
    padding: 8px 16px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

.delete-tool-btn {
    background-color: #dc3545;
    color: white;
    padding: 8px 16px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

.selected-tool-info {
    margin-top: 15px;
    padding: 10px;
    background-color: #f8f9fa;
    border: 1px solid #dee2e6;
    border-radius: 4px;
    font-size: 14px;
}
</style>

<script>
// Updated JavaScript functions for simplified tool management

function editSelectedTool() {
    const selectedId = parseInt(document.getElementById('currentTool').value);
    editTool(selectedId);
}

function addNewTool() {
    currentEditingTool = null;
    document.getElementById('modalTitle').textContent = 'Add New Tool';
    document.getElementById('toolName').value = '';
    
    // Find next available ID
    const existingIds = tools.map(t => t.id);
    let nextId = 0;
    while (existingIds.includes(nextId)) {
        nextId++;
    }
    
    document.getElementById('toolId').value = nextId;
    document.getElementById('toolType').value = 'extruder';
    document.getElementById('isReference').checked = false;
    document.getElementById('fiducialX').value = '0';
    document.getElementById('fiducialY').value = '0';
    document.getElementById('fiducialZ').value = '0';
    
    updateOffsetDisplay();
    document.getElementById('toolModal').style.display = 'block';
}


function updateSelectedToolInfo() {
    const currentToolSelect = document.getElementById('currentTool');
    if (!currentToolSelect) {
        console.error('currentTool select element not found');
        return;
    }
    
    const selectedId = parseInt(currentToolSelect.value);
    const selectedTool = tools.find(t => t.id === selectedId);
    
    if (selectedTool) {
        const nameElement = document.getElementById('selectedToolName');
        const typeElement = document.getElementById('selectedToolType');
        const offsetsElement = document.getElementById('selectedToolOffsets');
        
        if (nameElement) nameElement.textContent = selectedTool.name;
        if (typeElement) typeElement.textContent = selectedTool.type;
        
        if (offsetsElement) {
            if (selectedTool.type === 'camera') {
                offsetsElement.textContent = 'Imaging Tool (No Positions)';
            } else if (selectedTool.isReference) {
                offsetsElement.textContent = 'Reference Tool (No Offsets)';
            } else {
                // Calculate offsets using the new logic
                const programmedX = selectedTool.programmedX || selectedTool.fiducialX || 0;
                const programmedY = selectedTool.programmedY || selectedTool.fiducialY || 0;
                const programmedZ = selectedTool.programmedZ || selectedTool.fiducialZ || 0;
                
                const actualX = selectedTool.actualX || 0;
                const actualY = selectedTool.actualY || 0;
                const zOffsetInput = selectedTool.zOffset || 0;
                
                // X and Y offsets = actual - programmed
                const offsetX = actualX - programmedX;
                const offsetY = actualY - programmedY;
                
                // Z offset = reference_tool_Z - current_tool_Z + manual_Z_offset
                const referenceTool = tools.find(t => t.isReference === true);
                let offsetZ = zOffsetInput; // Start with manual Z offset
                
                if (referenceTool && (referenceTool.programmedZ !== undefined || referenceTool.fiducialZ !== undefined)) {
                    const referenceZ = referenceTool.programmedZ || referenceTool.fiducialZ || 0;
                    offsetZ += (referenceZ - programmedZ);
                }
                
                offsetsElement.textContent = 
                    `X${offsetX.toFixed(3)} Y${offsetY.toFixed(3)} Z${offsetZ.toFixed(3)}`;
            }
        }
        
        // Disable edit and delete buttons for camera tools
        const editBtn = document.querySelector('.edit-tool-btn');
        const deleteBtn = document.querySelector('.delete-tool-btn');
        
        if (editBtn) {
            editBtn.disabled = selectedTool.type === 'camera';
            editBtn.style.opacity = selectedTool.type === 'camera' ? '0.5' : '1';
        }
        
        if (deleteBtn) {
            deleteBtn.disabled = selectedTool.type === 'camera' || selectedTool.isReference;
            deleteBtn.style.opacity = (selectedTool.type === 'camera' || selectedTool.isReference) ? '0.5' : '1';
        }
    }
}


function deleteSelectedTool() {
    const selectedId = parseInt(document.getElementById('currentTool').value);
    const selectedTool = tools.find(t => t.id === selectedId);
    
    if (selectedTool && selectedTool.type === 'camera') {
        alert('Cannot delete the camera tool - it is the reference tool.');
        return;
    }
    
    if (confirm(`Are you sure you want to delete "${selectedTool.name}"?`)) {
        deleteTool(selectedId);
    }
}


function updateToolDropdown() {
    const currentToolSelect = document.getElementById('currentTool');
    if (!currentToolSelect) return;
    
    const currentValue = currentToolSelect.value;
    currentToolSelect.innerHTML = '';
    
    tools.forEach(tool => {
        const option = document.createElement('option');
        option.value = tool.id;
        option.textContent = tool.name;
        currentToolSelect.appendChild(option);
    });
    
    if (Array.from(currentToolSelect.options).some(opt => opt.value === currentValue)) {
        currentToolSelect.value = currentValue;
    }
    
    updateSelectedToolInfo();
    
    currentToolSelect.onchange = function() {
        updateSelectedToolInfo();
    };
}


function saveTool() {
    console.log('saveTool called');
    
    // Check if required elements exist first
    const requiredElements = ['toolId', 'toolName', 'toolType', 'isReference'];
    for (let elementId of requiredElements) {
        const element = document.getElementById(elementId);
        if (!element) {
            console.error(`Required element missing: ${elementId}`);
            alert(`Form error: ${elementId} element not found`);
            return;
        }
    }
    
    const toolData = {
        id: parseInt(document.getElementById('toolId').value),
        name: document.getElementById('toolName').value,
        type: document.getElementById('toolType').value,
        isReference: document.getElementById('isReference').checked
    };
    
    console.log('Basic tool data:', toolData);
    
    // Validate required fields
    if (!toolData.name || toolData.name.trim() === '') {
        alert('Please enter a tool name');
        return;
    }
    
    // Add position data for non-camera tools
    if (toolData.type !== 'camera') {
        // Check for programmed position elements
        const programmedElements = ['programmedX', 'programmedY', 'programmedZ'];
        for (let elementId of programmedElements) {
            const element = document.getElementById(elementId);
            if (element) {
                toolData[elementId] = parseFloat(element.value) || 0;
                console.log(`Set ${elementId} to:`, toolData[elementId]);
            } else {
                console.warn(`Element ${elementId} not found`);
            }
        }
        
        // Add actual position data for non-reference tools
        if (!toolData.isReference) {
            const actualElements = ['actualX', 'actualY', 'actualZ'];
            for (let elementId of actualElements) {
                const element = document.getElementById(elementId);
                if (element) {
                    toolData[elementId] = parseFloat(element.value) || 0;
                    console.log(`Set ${elementId} to:`, toolData[elementId]);
                } else {
                    console.warn(`Element ${elementId} not found`);
                }
            }
        }
    }
    
    // Add dispenser-specific data
    if (toolData.type === 'dispenser') {
        const linearActuator = document.getElementById('linearActuator');
        const pipetteHeight = document.getElementById('pipetteHeight');
        
        if (linearActuator) {
            toolData.linearActuator = parseFloat(linearActuator.value) || 0;
            console.log('Set linearActuator to:', toolData.linearActuator);
        }
        
        if (pipetteHeight) {
            toolData.pipetteHeight = parseInt(pipetteHeight.value) || 90;
            console.log('Set pipetteHeight to:', toolData.pipetteHeight);
        }
    }
    
    console.log('Final tool data before saving:', toolData);
    
    // If this tool is set as reference, unset all others
    if (toolData.isReference) {
        tools.forEach(tool => {
            if (tool.id !== toolData.id) {
                tool.isReference = false;
            }
        });
    }
    
    // Update tools array
    if (currentEditingTool !== null) {
        const index = tools.findIndex(t => t.id === currentEditingTool);
        if (index !== -1) {
            tools[index] = toolData;
            console.log('Updated existing tool at index:', index);
        }
    } else {
        const existingIndex = tools.findIndex(t => t.id === toolData.id);
        if (existingIndex !== -1) {
            tools[existingIndex] = toolData;
            console.log('Replaced tool at index:', existingIndex);
        } else {
            tools.push(toolData);
            console.log('Added new tool');
        }
    }
    
    console.log('Updated tools array:', tools);
    
    updateToolDropdown();
    closeToolModal();
    
    // Save to backend
    fetch('/api/tools/save', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({tools: tools})
    })
    .then(response => response.json())
    .then(data => {
        console.log('Backend save response:', data);
        if (data.status === 'success') {
            console.log('Tools saved successfully');
            loadToolsFromBackend();
        } else {
            alert('Error saving tools: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error saving tools:', error);
        alert('Error saving tools: ' + error);
    });
}


// Updated deleteTool function
function deleteTool(toolId) {
    const tool = tools.find(t => t.id === toolId);
    if (tool && tool.type === 'camera') {
        alert('Cannot delete the camera tool - it is the reference tool.');
        return;
    }
    
    tools = tools.filter(t => t.id !== toolId);
    updateToolDropdown();
    
    // Save to backend
    fetch('/api/tools/save', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({tools: tools})
    });
}

// Updated loadToolsFromBackend function


function loadToolsFromBackend() {
    fetch('/api/tools/load')
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                tools = data.tools || [];
                updateToolDropdown();
            } else {
                // Use default tools with fiducial structure if backend fails
                tools = [
                    {id: 0, name: "Camera Tool (C0)", type: "camera", fiducialX: 0, fiducialY: 0, fiducialZ: 0, isReference: true},
                    {id: 1, name: "Extruder 1 (E0)", type: "extruder", fiducialX: 0, fiducialY: 0, fiducialZ: 0, isReference: false},
                    {id: 2, name: "Extruder 2 (E1)", type: "extruder", fiducialX: 0, fiducialY: 0, fiducialZ: 0, isReference: false},
                    {id: 3, name: "Liquid Dispenser (L0)", type: "dispenser", fiducialX: 0, fiducialY: 0, fiducialZ: 0, isReference: false}
                ];
                updateToolDropdown();
            }
        })
        .catch(error => {
            console.error('Error loading tools:', error);
            // Use default tools with fiducial structure if request fails
            tools = [
                {id: 0, name: "Camera Tool (C0)", type: "camera", fiducialX: 0, fiducialY: 0, fiducialZ: 0, isReference: true},
                {id: 1, name: "Extruder 1 (E0)", type: "extruder", fiducialX: 0, fiducialY: 0, fiducialZ: 0, isReference: false},
                {id: 2, name: "Extruder 2 (E1)", type: "extruder", fiducialX: 0, fiducialY: 0, fiducialZ: 0, isReference: false},
                {id: 3, name: "Liquid Dispenser (L0)", type: "dispenser", fiducialX: 0, fiducialY: 0, fiducialZ: 0, isReference: false}
            ];
            updateToolDropdown();
        });
}




</script>









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
                <h2>Image Mapper - Pixel-to-Printer Coordinate Mapping</h2>
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
                    <li>1. Use "Image Mapper" to click on features in the image</li>
                    <li>2. Each click records pixel coordinates and current printer position</li>
                    <li>3. Use the coordinate information to manually position your camera/printer</li>
                    <li>4. Use flip buttons if your camera image is inverted</li>
                    <li>5. Build reference points for accurate coordinate mapping</li>
                </ul>
            </div>
            
            <div id="streamContainer" class="media-container" style="display: none;">
                <h3>Live Stream</h3>

<img id="streamImg" class="clickable-image" 
     onmousedown="measureClick(event)" 
     onmousemove="measureClick(event); updateCoordinateDisplay(event, this)" 
     onmouseup="measureClick(event)"
     onmouseenter="showCoordinateDisplay(this)"
     onmouseleave="hideCoordinateDisplay(this)"
     onclick="handleImageClick(event, 'stream'); measureClick(event);"
     src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" 
     alt="Live Stream">


            </div>




            <div id="photoContainer" class="media-container" style="display: none;">
                <h3>Latest Photo</h3>

<img id="photoImg" class="clickable-image"
     onmousedown="measureClick(event)" 
     onmousemove="measureClick(event); updateCoordinateDisplay(event, this)" 
     onmouseup="measureClick(event)"
     onmouseenter="showCoordinateDisplay(this)"
     onmouseleave="hideCoordinateDisplay(this)"
     onclick="handleImageClick(event, 'snapshot'); measureClick(event);"
     src="/latest_photo" 
     alt="Latest Captured Photo">

            </div>



        </div>


<!-- Tool Details Modal - ADD THIS if it's missing -->
<!-- Tool Details Modal -->
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
            <select id="toolType" onchange="updateFormFields()">
                <option value="camera">Camera</option>
                <option value="extruder">Extruder</option>
                <option value="dispenser">Liquid Dispenser</option>
                <option value="probe">Probe</option>
                <option value="other">Other</option>
            </select>
            
            <div class="reference-checkbox-container">
                <input type="checkbox" id="isReference" onchange="updateFormFields()">
                <label for="isReference">Set as Reference Tool</label>
            </div>
            
            <!-- Programmed Position Section -->
            <div id="programmedSection">
                <h4>Programmed Position (mm)</h4>
                <div class="coordinate-inputs">
                    <div class="input-group">
                        <label>Programmed X</label>
                        <input type="number" id="programmedX" step="0.001" placeholder="0.000">
                    </div>
                    
                    <div class="input-group">
                        <label>Programmed Y</label>
                        <input type="number" id="programmedY" step="0.001" placeholder="0.000">
                    </div>
                    
                    <div class="input-group">
                        <label>Programmed Z</label>
                        <input type="number" id="programmedZ" step="0.001" placeholder="0.000">
                    </div>
                </div>
            </div>
            



<!-- Actual Position Section (hidden for camera and reference tools) -->
<div id="actualSection">
    <h4>Actual Position (mm)</h4>
    <p style="font-size: 12px; color: #666; margin: 5px 0 15px 0;">X and Y positions measured using camera system. Z offset calculated from reference tool.</p>
    <div class="coordinate-inputs">
        <div class="input-group">
            <label>Actual X</label>
            <input type="number" id="actualX" step="0.001" placeholder="0.000">
        </div>
        
        <div class="input-group">
            <label>Actual Y</label>
            <input type="number" id="actualY" step="0.001" placeholder="0.000">
        </div>
        
        <div class="input-group">
            <label>Z Offset</label>
            <input type="number" id="zOffset" step="0.001" placeholder="0.000" 
                   title="Z offset relative to reference tool">
        </div>
    </div>
</div>





<!-- Liquid Dispenser Specific Fields -->
<div id="dispenserSection" style="display: none;">
    <h4>Dispenser Settings</h4>
    <div class="coordinate-inputs">
        <div class="input-group">
            <label>Linear Actuator</label>
            <input type="number" id="linearActuator" step="0.1" placeholder="0.0" min="0" max="100">
        </div>
    </div>
</div>




            <h4>Calculated Offsets</h4>
            <div id="offsetDisplay" class="offset-display">
                <div>X Offset: <span id="calcOffsetX">0.000</span>mm</div>
                <div>Y Offset: <span id="calcOffsetY">0.000</span>mm</div>
                <div>Z Offset: <span id="calcOffsetZ">0.000</span>mm</div>
            </div>
            
            <div class="modal-buttons">
                <button onclick="saveTool()" class="save-btn">Save Tool</button>
                <button onclick="closeToolModal()" class="cancel-btn">Cancel</button>
            </div>
        </div>
    </div>
</div>








   </body>
    </html>
    """
    return html




# Add this to your Flask application

@app.route('/api/calibration/info')
def api_calibration_info():
    """Get calibration info (alias for data endpoint)"""
    return jsonify({
        "microns_per_pixel_x": calibration_data["microns_per_pixel_x"],
        "microns_per_pixel_y": calibration_data["microns_per_pixel_y"],
        "reference_points": calibration_data["reference_points"],
        "enabled": calibration_data["enabled"]
    })




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
    """Get calibration data in expected format"""
    return jsonify({
        "microns_per_pixel_x": calibration_data["microns_per_pixel_x"],
        "microns_per_pixel_y": calibration_data["microns_per_pixel_y"], 
        "reference_points": calibration_data["reference_points"],
        "enabled": calibration_data["enabled"]
    })


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
