#!/usr/bin/env python3
"""
Camera Controller with Flask and MQTT - Stream, Capture, and Focus Slider
With improved stream handling, MQTT command interface, and direct IMX519 focusing
SAFARI COMPATIBLE VERSION with enhanced MJPEG streaming
"""
import os
import time
import threading
import subprocess
import logging
import json
from datetime import datetime
from flask import Flask, Response, send_file, jsonify
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
HTTP_PORT = 8080
STREAM_ACTIVE = False
STREAM_WIDTH = 1280
STREAM_HEIGHT = 720
CAPTURE_WIDTH = 4656
CAPTURE_HEIGHT = 3496
STREAM_QUALITY = "medium"  # low, medium, high

# Focus settings - Using direct values for libcamera-still --lens-position
FOCUS_MODE = "auto"  # auto or manual
FOCUS_POSITION = 10  # Default starting position for manual focus

# MQTT Settings
MQTT_BROKER = "192.168.1.89"  # Your Klipper Pi (MQTT broker)
MQTT_PORT = 1883
MQTT_COMMAND_TOPIC = "dakash/camera/command"
MQTT_CONFIG_TOPIC = "dakash/camera/config"
MQTT_STATUS_TOPIC = "dakash/camera/status"

# Ensure capture directory exists
os.makedirs(CAPTURE_DIR, exist_ok=True)

# Create Flask app
app = Flask(__name__)

# Global variables
streaming_thread = None
keep_streaming = False
current_frame = None
frame_lock = threading.Lock()
mqtt_client = None
frame_count = 0  # For Safari compatibility

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
            # Store auto focus mode
            FOCUS_MODE = "auto"
            FOCUS_POSITION = 10  # Default position
            return True
            
        elif mode == "manual" and position is not None:
            # Direct use of position value, ensure it's in range 0-30
            pos = max(0, min(30, float(position)))
            
            # Store manual focus mode and position
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
        # Use a temporary file
        temp_file = "/tmp/stream_frame.jpg"
        
        # Capture frame using libcamera-still with focus parameters
        cmd = [
            "libcamera-still",
            "--output", temp_file,
            "--timeout", "1",
            "--width", str(STREAM_WIDTH),
            "--height", str(STREAM_HEIGHT),
            "--immediate",
            "--nopreview",
            "--quality", "85",  # Specific quality for Safari compatibility
            "--encoding", "jpg"
        ]
        
        # Add focus parameters
        if FOCUS_MODE == "auto":
            cmd.extend(["--autofocus-mode", "auto"])
        else:  # manual
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
            # Safari-friendly frame rate (12 fps for stability)
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
    
    # Reset frame buffer and counter
    with frame_lock:
        current_frame = None
        frame_count = 0
    
    # Start streaming thread
    keep_streaming = True
    STREAM_ACTIVE = True
    streaming_thread = threading.Thread(target=streaming_worker)
    streaming_thread.daemon = True
    streaming_thread.start()
    
    logger.info("Stream started")
    # Send status update via MQTT
    publish_status()
    return True

def stop_stream():
    """Stop the streaming thread"""
    global keep_streaming, STREAM_ACTIVE, streaming_thread
    
    if not STREAM_ACTIVE:
        logger.info("No stream active")
        return True
    
    # Signal thread to stop
    keep_streaming = False
    
    # Wait for thread to finish
    if streaming_thread and streaming_thread.is_alive():
        streaming_thread.join(timeout=3)
    
    STREAM_ACTIVE = False
    streaming_thread = None
    logger.info("Stream stopped")
    # Send status update via MQTT
    publish_status()
    return True

def capture_image():
    """Capture a high-quality image and save it to disk"""
    global FOCUS_MODE, FOCUS_POSITION
    
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{CAPTURE_DIR}/capture_{timestamp}.jpg"
        
        # Capture image using libcamera-still with focus parameters
        cmd = [
            "libcamera-still",
            "--output", filename,
            "--timeout", "2000",
            "--width", str(CAPTURE_WIDTH),
            "--height", str(CAPTURE_HEIGHT),
            "--nopreview"
        ]
        
        # Add focus parameters
        if FOCUS_MODE == "auto":
            cmd.extend(["--autofocus-mode", "auto"])
        else:  # manual
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
        # Update stream dimensions if provided
        if "stream_width" in config and isinstance(config["stream_width"], int):
            STREAM_WIDTH = config["stream_width"]
        
        if "stream_height" in config and isinstance(config["stream_height"], int):
            STREAM_HEIGHT = config["stream_height"]
            
        # Update capture dimensions if provided
        if "capture_width" in config and isinstance(config["capture_width"], int):
            CAPTURE_WIDTH = config["capture_width"]
            
        if "capture_height" in config and isinstance(config["capture_height"], int):
            CAPTURE_HEIGHT = config["capture_height"]
            
        # Update stream quality if provided
        if "stream_quality" in config and config["stream_quality"] in ["low", "medium", "high"]:
            STREAM_QUALITY = config["stream_quality"]
            
        logger.info(f"Camera config updated: stream={STREAM_WIDTH}x{STREAM_HEIGHT}, "
                    f"capture={CAPTURE_WIDTH}x{CAPTURE_HEIGHT}, quality={STREAM_QUALITY}")
        
        # Send status update via MQTT
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
            "stream_quality": STREAM_QUALITY
        }
        
        mqtt_client.publish(MQTT_STATUS_TOPIC, json.dumps(status))
        logger.debug(f"Published status: {status}")
        return True
    return False

# MQTT Callback functions
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        logger.info("Connected to MQTT broker")
        # Subscribe to command and config topics
        client.subscribe(MQTT_COMMAND_TOPIC)
        client.subscribe(MQTT_CONFIG_TOPIC)
        # Publish initial status
        publish_status()
    else:
        logger.error(f"Failed to connect to MQTT broker, return code {rc}")

def on_message(client, userdata, msg):
    """Handle received MQTT messages"""
    try:
        topic = msg.topic
        payload = json.loads(msg.payload.decode())
        logger.info(f"MQTT message received: {topic} = {payload}")
        
        # Handle command messages
        if topic == MQTT_COMMAND_TOPIC:
            handle_command_message(payload)
        
        # Handle config messages
        elif topic == MQTT_CONFIG_TOPIC:
            update_camera_config(payload)
            
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
        
        # Handle stream control commands
        if command == "stream_start":
            start_stream()
            
        elif command == "stream_stop":
            stop_stream()
            
        # Handle capture command
        elif command == "capture":
            capture_image()
            
        # Handle focus commands
        elif command == "focus":
            mode = payload.get("mode", "auto")
            position = payload.get("position", 10)
            control_autofocus(mode, position)
            
        # Handle status command
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
        
        # Set callbacks
        mqtt_client.on_connect = on_connect
        mqtt_client.on_message = on_message
        
        # Connect to broker
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
        
        # Start network loop in background thread
        mqtt_client.loop_start()
        
        logger.info(f"MQTT client initialized, connecting to {MQTT_BROKER}:{MQTT_PORT}")
        return True
    except Exception as e:
        logger.error(f"Failed to setup MQTT client: {e}")
        return False

# Flask routes
@app.route('/')
def index():
    """Safari-enhanced camera control interface with focus slider"""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Rister Camera Controller</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif; 
                margin: 20px; 
                text-align: center;
                background-color: #f5f5f5;
            }
            .container {
                max-width: 800px;
                margin: 0 auto;
                background-color: white;
                padding: 20px;
                border-radius: 10px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
            }
            h1 {
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
                -webkit-appearance: none;
                appearance: none;
            }
            button:hover {
                background-color: #3e8e41;
            }
            button.stop {
                background-color: #f44336;
            }
            button.stop:hover {
                background-color: #d32f2f;
            }
            button.photo {
                background-color: #2196F3;
            }
            button.photo:hover {
                background-color: #1976D2;
            }
            button.focus {
                background-color: #9C27B0;
            }
            button.focus:hover {
                background-color: #7B1FA2;
            }
            .slider-container {
                display: flex;
                flex-direction: column;
                align-items: center;
                margin: 0 10px;
                min-width: 250px;
            }
            .slider {
                width: 100%;
                height: 25px;
                background: #d3d3d3;
                outline: none;
                opacity: 0.7;
                -webkit-transition: .2s;
                transition: opacity .2s;
                border-radius: 5px;
                margin-top: 5px;
                -webkit-appearance: none;
                appearance: none;
            }
            .slider:hover {
                opacity: 1;
            }
            .slider::-webkit-slider-thumb {
                -webkit-appearance: none;
                appearance: none;
                width: 25px;
                height: 25px;
                border-radius: 50%;
                background: #9C27B0;
                cursor: pointer;
            }
            .slider::-moz-range-thumb {
                width: 25px;
                height: 25px;
                border-radius: 50%;
                background: #9C27B0;
                cursor: pointer;
                border: none;
            }
            #streamContainer, #photoContainer {
                display: none;
                margin-top: 20px;
            }
            .media-container {
                border: 1px solid #ddd;
                padding: 10px;
                border-radius: 5px;
                margin-bottom: 20px;
                background: #000;
                position: relative;
            }
            #streamImg {
                max-width: 100%;
                max-height: 480px;
                border-radius: 5px;
                display: block;
                margin: 0 auto;
            }
            img {
                max-width: 100%;
                max-height: 480px;
                border-radius: 5px;
            }
            .status {
                margin-top: 10px;
                font-style: italic;
                color: #666;
            }
            .focus-info {
                margin-top: 5px;
                font-size: 12px;
                color: #666;
            }
            .loading {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                color: white;
                font-size: 16px;
                display: none;
            }
            .spinner {
                display: inline-block;
                width: 20px;
                height: 20px;
                border: 3px solid #f3f3f3;
                border-top: 3px solid #007AFF;
                border-radius: 50%;
                animation: spin 1s linear infinite;
                margin-right: 10px;
            }
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
        </style>
        <script>
            // Track whether user has adjusted focus
            window.userAdjustedFocus = false;
            window.streamRefreshInterval = null;
            
            // Check streaming status when page loads
            window.onload = function() {
                checkStatus();
                // Check every 3 seconds
                setInterval(checkStatus, 3000);
            };
            
            function checkStatus() {
                fetch('/api/status')
                    .then(response => response.json())
                    .then(data => {
                        console.log('Status:', data);
                        // Update stream container visibility
                        if (data.streaming) {
                            document.getElementById('streamContainer').style.display = 'block';
                            document.getElementById('focusControls').style.display = 'flex';
                            
                            // Safari-specific: refresh stream periodically to prevent freezing
                            if (navigator.userAgent.includes('Safari') && !navigator.userAgent.includes('Chrome')) {
                                if (!window.streamRefreshInterval) {
                                    refreshStreamImage();
                                    window.streamRefreshInterval = setInterval(refreshStreamImage, 30000);
                                }
                            } else {
                                refreshStreamImage();
                            }
                            
                            // Only update the focus slider if we're in auto mode or it's the first load
                            if (data.focus_mode === "auto") {
                                document.getElementById('focusSlider').value = 10;
                                document.getElementById('focusValue').textContent = 10;
                            } else if (data.focus_mode === "manual" && !window.userAdjustedFocus) {
                                document.getElementById('focusSlider').value = data.focus_position;
                                document.getElementById('focusValue').textContent = data.focus_position;
                            }
                        } else {
                            document.getElementById('streamContainer').style.display = 'none';
                            document.getElementById('focusControls').style.display = 'none';
                            
                            // Clear stream refresh interval
                            if (window.streamRefreshInterval) {
                                clearInterval(window.streamRefreshInterval);
                                window.streamRefreshInterval = null;
                            }
                            
                            // Clear the stream image
                            const img = document.getElementById('streamImg');
                            img.src = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==';
                            
                            // Reset focus adjustment tracking
                            window.userAdjustedFocus = false;
                        }
                    })
                    .catch(error => console.error('Error checking status:', error));
            }
            
            function refreshStreamImage() {
                const img = document.getElementById('streamImg');
                const loading = document.getElementById('loading');
                
                // Show loading indicator
                loading.style.display = 'block';
                
                // Create new image with cache-busting timestamp
                const newSrc = '/stream?t=' + new Date().getTime();
                
                // Handle image load success
                img.onload = function() {
                    loading.style.display = 'none';
                };
                
                // Handle image load error
                img.onerror = function() {
                    loading.style.display = 'none';
                    console.warn('Stream image failed to load');
                };
                
                img.src = newSrc;
            }
            
            function startStream() {
                fetch('/api/stream/start')
                    .then(response => response.json())
                    .then(data => {
                        console.log('Start stream response:', data);
                        if (data.streaming) {
                            document.getElementById('streamContainer').style.display = 'block';
                            document.getElementById('focusControls').style.display = 'flex';
                            
                            // Wait a moment for stream to initialize, then refresh
                            setTimeout(refreshStreamImage, 1000);
                        }
                    })
                    .catch(error => console.error('Error starting stream:', error));
            }
            
            function stopStream() {
                fetch('/api/stream/stop')
                    .then(response => response.json())
                    .then(data => {
                        console.log('Stop stream response:', data);
                        document.getElementById('streamContainer').style.display = 'none';
                        document.getElementById('focusControls').style.display = 'none';
                        
                        // Clear refresh interval
                        if (window.streamRefreshInterval) {
                            clearInterval(window.streamRefreshInterval);
                            window.streamRefreshInterval = null;
                        }
                        
                        // Clear the stream image
                        const img = document.getElementById('streamImg');
                        img.src = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==';
                    })
                    .catch(error => console.error('Error stopping stream:', error));
            }
            
            function capturePhoto() {
                fetch('/api/capture')
                    .then(response => response.json())
                    .then(data => {
                        console.log('Capture response:', data);
                        document.getElementById('photoContainer').style.display = 'block';
                        // Update the photo with cache-busting
                        document.getElementById('photoImg').src = '/latest_photo?t=' + new Date().getTime();
                    })
                    .catch(error => console.error('Error capturing photo:', error));
            }
            
            function updateFocusValue(value) {
                // Update the displayed focus value as the slider moves
                document.getElementById('focusValue').textContent = value;
            }
            
            function setFocusAuto() {
                // Reset focus adjustment tracking
                window.userAdjustedFocus = false;
                
                fetch('/api/focus/auto')
                    .then(response => response.json())
                    .then(data => {
                        console.log('Focus response:', data);
                        if (data.status === 'success') {
                            // Reset slider to default position
                            document.getElementById('focusSlider').value = 10;
                            document.getElementById('focusValue').textContent = 10;
                            alert('Auto focus enabled');
                        }
                    })
                    .catch(error => console.error('Error setting focus:', error));
            }
            
            function setFocusManual(position) {
                // Track that user has adjusted the focus
                window.userAdjustedFocus = true;
                
                fetch('/api/focus/manual/' + position)
                    .then(response => response.json())
                    .then(data => {
                        console.log('Focus response:', data);
                        if (data.status === 'success') {
                            // Show a brief visual confirmation
                            const focusValue = document.getElementById('focusValue');
                            const originalColor = focusValue.style.color;
                            focusValue.style.color = '#4CAF50';
                            setTimeout(() => {
                                focusValue.style.color = originalColor;
                            }, 500);
                        }
                    })
                    .catch(error => console.error('Error setting focus:', error));
            }
            
            // Clean up on page unload
            window.addEventListener('beforeunload', function() {
                if (window.streamRefreshInterval) {
                    clearInterval(window.streamRefreshInterval);
                }
            });
        </script>
    </head>
    <body>
        <div class="container">
            <h1>Rister Camera Controller</h1>
            
            <div class="controls">
                <button onclick="startStream()">Start Stream</button>
                <button onclick="stopStream()" class="stop">Stop Stream</button>
                <button onclick="capturePhoto()" class="photo">Take Photo</button>
            </div>
            
            <div id="focusControls" class="controls" style="display: none;">
                <button onclick="setFocusAuto()" class="focus">Auto Focus</button>
                <div class="slider-container">
                    <label for="focusSlider">Manual Focus: <span id="focusValue">10</span></label>
                    <input type="range" min="0" max="30" value="10" step="0.5" class="slider" id="focusSlider" oninput="updateFocusValue(this.value)" onchange="setFocusManual(this.value)">
                    <div class="focus-info">
                        <small>0 = Near, 30 = Far</small><br>
                        <small>For IMX519: useful range typically 10-20</small>
                    </div>
                </div>
            </div>
            
            <div id="streamContainer" class="media-container" style="display: none;">
                <h3>Live Stream</h3>
                <div id="loading" class="loading">
                    <div class="spinner"></div>
                    Loading stream...
                </div>
                <img id="streamImg" src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==" alt="Live Stream">
            </div>
            
            <div id="photoContainer" class="media-container" style="display: none;">
                <h3>Latest Photo</h3>
                <img id="photoImg" src="/latest_photo" alt="Latest Captured Photo">
            </div>
        </div>
    </body>
    </html>
    """
    return html

@app.route('/stream')
def stream():
    """Safari-compatible MJPEG stream endpoint"""
    global STREAM_ACTIVE, current_frame, frame_count
    
    # If not streaming, return a blank image
    if not STREAM_ACTIVE:
        # Create a 1x1 transparent GIF
        blank_gif = b'GIF89a\x01\x00\x01\x00\x80\x00\x00\xff\xff\xff\x00\x00\x00!\xf9\x04\x01\x00\x00\x00\x00,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x02D\x01\x00;'
        return Response(blank_gif, mimetype='image/gif')
    
    def generate_frames():
        global STREAM_ACTIVE, current_frame, frame_count
        last_frame_count = 0
        
        # Exit if streaming stops while generating
        if not STREAM_ACTIVE:
            return
        
        # Initial wait for first frame
        attempts = 0
        while current_frame is None and STREAM_ACTIVE and attempts < 20:
            time.sleep(0.1)
            attempts += 1
        
        # Main streaming loop - Safari optimized
        while STREAM_ACTIVE:
            with frame_lock:
                frame = current_frame
                current_count = frame_count
            
            # Only yield new frames to prevent duplicates in Safari
            if frame and current_count > last_frame_count:
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n'
                       b'Content-Length: ' + str(len(frame)).encode() + b'\r\n'
                       b'Cache-Control: no-cache, no-store, must-revalidate\r\n'
                       b'Pragma: no-cache\r\n'
                       b'Expires: 0\r\n'
                       b'\r\n' + frame + b'\r\n')
                
                last_frame_count = current_count
                
                # Safari-friendly delay between frames
                time.sleep(1/12)  # 12 fps for stability
            else:
                # No new frame, wait a bit
                time.sleep(0.05)
    
    # Safari-specific headers for better compatibility
    response = Response(
        generate_frames(),
        mimetype='multipart/x-mixed-replace; boundary=frame',
        headers={
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
            'Connection': 'close',
            'X-Accel-Buffering': 'no'  # Disable nginx buffering if present
        }
    )
    return response

@app.route('/latest_photo')
def latest_photo():
    """Serve the most recently captured photo"""
    try:
        # Find the most recent photo in the capture directory
        photos = [os.path.join(CAPTURE_DIR, f) for f in os.listdir(CAPTURE_DIR) 
                 if f.startswith("capture_") and f.endswith(".jpg")]
        
        if not photos:
            # If no photos, return a simple message
            return "No photos available", 404
        
        # Sort by modification time (newest first)
        photos.sort(key=lambda x: os.path.getmtime(x), reverse=True)
        latest = photos[0]
        
        # Send the file
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
    """Set camera to auto focus mode"""
    result = control_autofocus("auto")
    return jsonify({"status": "success" if result else "error", "mode": "auto"})

@app.route('/api/focus/manual/<position>')
def api_focus_manual(position):
    """Set camera to manual focus with specific position (0-30)"""
    # Position directly used for libcamera-still --lens-position
    try:
        pos_float = float(position)
        result = control_autofocus("manual", pos_float)
        return jsonify({"status": "success" if result else "error", "mode": "manual", "position": pos_float})
    except ValueError:
        return jsonify({"status": "error", "message": "Invalid position value"})

@app.route('/api/status')
def api_status():
    """API endpoint to get camera status with more detailed info"""
    global STREAM_ACTIVE, streaming_thread
    
    # Check if streaming thread is actually running
    thread_alive = streaming_thread is not None and streaming_thread.is_alive()
    
    # If thread is dead but flag is still set, fix the inconsistency
    if STREAM_ACTIVE and not thread_alive:
        STREAM_ACTIVE = False
    
    # Get current focus mode and position
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
        "frame_count": frame_count  # Added for debugging
    })

if __name__ == '__main__':
    try:
        # Setup MQTT client
        setup_mqtt_client()
        
        # Start the Flask application
        logger.info(f"Starting Flask server on port {HTTP_PORT}")
        app.run(host='0.0.0.0', port=HTTP_PORT, threaded=True)
    except KeyboardInterrupt:
        logger.info("Application stopping due to keyboard interrupt")
        # Clean shutdown
        stop_stream()
        if mqtt_client:
            mqtt_client.loop_stop()
            mqtt_client.disconnect()
    except Exception as e:
        logger.error(f"Application error: {e}")
        # Clean shutdown
        stop_stream()
        if mqtt_client:
            mqtt_client.loop_stop()
            mqtt_client.disconnect()
