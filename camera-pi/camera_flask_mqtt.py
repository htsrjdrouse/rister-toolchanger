#!/usr/bin/env python3
"""
Camera Controller with Flask and MQTT - Enhanced with Calibration Tool
Adds pixel-to-printer coordinate mapping functionality for extruder offset calibration
"""
import os
import time
import threading
import subprocess
import logging
import json
from datetime import datetime
from flask import Flask, Response, send_file, jsonify, request
import paho.mqtt.client as mqtt

# Configure logging
logging.basicConfig(
    level=logging.INFO,
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
MQTT_KLIPPER_POSITION_REQUEST = "dakash/klipper/position/request"
MQTT_KLIPPER_POSITION_RESPONSE = "dakash/klipper/position/response"
MQTT_CALIBRATION_TOPIC = "dakash/camera/calibration"

# Calibration settings
calibration_data = {
    "microns_per_pixel_x": 10.0,  # Default value, user configurable
    "microns_per_pixel_y": 10.0,  # Default value, user configurable
    "reference_points": [],       # List of {pixel_x, pixel_y, printer_x, printer_y, printer_z}
    "enabled": False
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
current_printer_position = {"x": 0, "y": 0, "z": 0}
position_request_pending = False

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
    """Request current printer position via MQTT"""
    global mqtt_client, position_request_pending
    
    if mqtt_client and mqtt_client.is_connected():
        position_request_pending = True
        mqtt_client.publish(MQTT_KLIPPER_POSITION_REQUEST, json.dumps({"request": "current_position"}))
        logger.info("Requested printer position")
        return True
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
    printer_offset_x = pixel_offset_x * calibration_data["microns_per_pixel_x"] / 1000.0  # Convert to mm
    printer_offset_y = pixel_offset_y * calibration_data["microns_per_pixel_y"] / 1000.0  # Convert to mm
    
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

# ... [Keep all existing camera functions: get_focus_info, control_autofocus, capture_frame, 
#      streaming_worker, start_stream, stop_stream, capture_image, update_camera_config] ...

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
            "calibration": calibration_data
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
        publish_status()
    else:
        logger.error(f"Failed to connect to MQTT broker, return code {rc}")

def on_message(client, userdata, msg):
    """Handle received MQTT messages"""
    global current_printer_position, position_request_pending
    
    try:
        topic = msg.topic
        payload = json.loads(msg.payload.decode())
        logger.info(f"MQTT message received: {topic} = {payload}")
        
        if topic == MQTT_COMMAND_TOPIC:
            handle_command_message(payload)
        elif topic == MQTT_CONFIG_TOPIC:
            update_camera_config(payload)
        elif topic == MQTT_KLIPPER_POSITION_RESPONSE:
            # Handle printer position response
            if "x" in payload and "y" in payload and "z" in payload:
                current_printer_position = {
                    "x": float(payload["x"]),
                    "y": float(payload["y"]),
                    "z": float(payload["z"])
                }
                position_request_pending = False
                logger.info(f"Printer position updated: {current_printer_position}")
            
    except json.JSONDecodeError:
        logger.error(f"Invalid JSON in MQTT message: {msg.payload}")
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
        
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
        mqtt_client.loop_start()
        
        logger.info(f"MQTT client initialized, connecting to {MQTT_BROKER}:{MQTT_PORT}")
        return True
    except Exception as e:
        logger.error(f"Failed to setup MQTT client: {e}")
        return False

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
            let calibrationMode = false;
            let currentImageType = 'stream'; // 'stream' or 'snapshot'
            
            window.onload = function() {
                checkStatus();
                loadCalibrationData();
                setInterval(checkStatus, 3000);
            };
            
            function checkStatus() {
                fetch('/api/status')
                    .then(response => response.json())
                    .then(data => {
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
                    .catch(error => console.error('Error checking status:', error));
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
                
                const rect = event.target.getBoundingClientRect();
                const x = Math.round(event.clientX - rect.left);
                const y = Math.round(event.clientY - rect.top);
                
                // Request current printer position
                fetch('/api/printer/position')
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'success') {
                            addReferencePoint(x, y, data.position.x, data.position.y, data.position.z);
                        } else {
                            alert('Failed to get printer position. Make sure the printer is connected.');
                        }
                    })
                    .catch(error => {
                        console.error('Error getting printer position:', error);
                        alert('Error getting printer position');
                    });
                
                // Show click coordinates temporarily
                showCoordinates(event.target, x, y);
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
                    if (result.status === 'success') {
                        loadCalibrationData();
                    }
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
            
            // Focus control functions (keeping existing functionality)
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
        </script>
    </head>
    <body>
        <div class="container">
            <h1>Rister Camera Controller with Calibration</h1>
            
            <div class="controls">
                <button onclick="startStream()">Start Stream</button>
                <button onclick="stopStream()" class="stop">Stop Stream</button>
                <button onclick="capturePhoto()" class="photo">Take Photo</button>
                <button id="calibrationToggle" onclick="toggleCalibrationMode()" class="calibration">Enable Calibration Mode</button>
            </div>
            
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
                     onclick="handleImageClick(event, 'stream')"
                     src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" 
                     alt="Live Stream">
            </div>
            
            <div id="photoContainer" class="media-container" style="display: none;">
                <h3>Latest Photo</h3>
                <img id="photoImg" class="clickable-image"
                     onclick="handleImageClick(event, 'snapshot')"
                     src="/latest_photo" 
                     alt="Latest Captured Photo">
            </div>
        </div>
    </body>
    </html>
    """
    return html

# New calibration API endpoints
@app.route('/api/printer/position')
def api_printer_position():
    """Get current printer position via MQTT"""
    global current_printer_position
    
    # Request fresh position data
    if request_printer_position():
        # Wait briefly for response
        timeout = 5
        start_time = time.time()
        while position_request_pending and (time.time() - start_time) < timeout:
            time.sleep(0.1)
        
        return jsonify({
            "status": "success",
            "position": current_printer_position
        })
    else:
        return jsonify({
            "status": "error",
            "message": "Failed to request printer position"
        })

@app.route('/api/calibration/add_point', methods=['POST'])
def api_calibration_add_point():
    """Add a reference point for calibration"""
    try:
        data = request.json
        
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
        
        result = pixel_to_printer_coordinates(
            pixel_x, pixel_y,
            current_printer_position["x"],
            current_printer_position["y"]
        )
        
        if result:
            return jsonify({"status": "success", "conversion": result})
        else:
            return jsonify({"status": "error", "message": "Calibration not available"})
            
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
    
    thread_alive = streaming_thread is not None and streaming_thread.is_alive()
    
    if STREAM_ACTIVE and not thread_alive:
        STREAM_ACTIVE = False
    
    focus_info = get_focus_info()
    
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
        "printer_position": current_printer_position
    })

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
