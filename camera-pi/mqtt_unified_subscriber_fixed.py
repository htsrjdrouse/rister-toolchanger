#!/usr/bin/env python3
"""
Unified MQTT Client for Dakash Toolchanger - Handles both camera and GPIO
Uses gpiod library for Raspberry Pi 5 compatibility
"""

import json
import time
import paho.mqtt.client as mqtt
import os
import subprocess
from datetime import datetime
import sys
import subprocess

# MQTT Settings
MQTT_BROKER = "192.168.1.89"  # klipperPi IP
MQTT_PORT = 1883
MQTT_USER = ""                # Set if your broker requires authentication
MQTT_PASSWORD = ""            # Set if your broker requires authentication
MQTT_CLIENT_ID = "camerapi_unified"

# MQTT Topics
# Camera topics
MQTT_TOPIC_CAMERA_COMMAND = "dakash/camera/command"
MQTT_TOPIC_CAMERA_STATUS = "dakash/camera/status"
# GPIO topics
MQTT_TOPIC_LED_RED = "dakash/gpio/led/red"
MQTT_TOPIC_LED_GREEN = "dakash/gpio/led/green"
MQTT_TOPIC_LED_BLUE = "dakash/gpio/led/blue"
MQTT_TOPIC_SENSORS_REQUEST = "dakash/gpio/sensors/request"
MQTT_TOPIC_SENSORS_STATUS = "dakash/gpio/sensors/status"

MQTT_RETRY_INTERVAL = 10      # Seconds between connection attempts

# Camera settings
CAPTURE_DIR = "/home/pi/captures"
STREAM_PORT = 8080

# GPIO pin definitions
PIN_DOCK_SENSOR = 24
PIN_CARRIAGE_SENSOR = 23
PIN_RED_LED = 17
PIN_GREEN_LED = 27
PIN_BLUE_LED = 22

# Ensure capture directory exists
os.makedirs(CAPTURE_DIR, exist_ok=True)

# Global variables
streaming = False
stream_process = None
mqtt_client = None
mqtt_connected = False
camera_ready = False
gpio_available = False

# GPIO objects
gpio_chip = None
red_led = None
green_led = None
blue_led = None
dock_sensor = None
carriage_sensor = None

# LED values (0.0-1.0)
led_values = {
    "red": 0,
    "green": 0,
    "blue": 0
}

# Sensor values
sensor_values = {
    "dock_sensor": False,
    "carriage_sensor": False
}

# Try to detect if we're using a command-line fallback
use_cmdline_gpio = False

# GPIO setup
def setup_gpio():
    """Initialize GPIO using gpiod"""
    global gpio_available, gpio_chip
    global red_led, green_led, blue_led, dock_sensor, carriage_sensor
    global use_cmdline_gpio
    
    # First try to import gpiod
    try:
        import gpiod
        
        # First, detect available GPIO chips
        try:
            # Use gpiodetect to find chips with pinctrl-rp1 label (Raspberry Pi 5)
            detect_result = subprocess.run(["gpiodetect"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if detect_result.returncode == 0:
                output = detect_result.stdout.decode('utf-8')
                
                # Find the chip with pinctrl-rp1 label first (Pi 5)
                chip_name = None
                for line in output.splitlines():
                    if "pinctrl-rp1" in line:
                        chip_name = line.split()[0]
                        break
                
                # Fallback to gpiochip0 if no specific label found
                if not chip_name and "gpiochip0" in output:
                    chip_name = "gpiochip0"
            else:
                # Default fallback
                chip_name = "gpiochip0"
        except Exception as e:
            # If gpiodetect fails, just try gpiochip0
            chip_name = "gpiochip0"
        
        # Open the GPIO chip
        try:
            gpio_chip = gpiod.Chip(chip_name)
        except Exception as e:
            return False
            
        # Configure LED lines
        try:
            red_led = gpio_chip.get_line(PIN_RED_LED)
            green_led = gpio_chip.get_line(PIN_GREEN_LED)
            blue_led = gpio_chip.get_line(PIN_BLUE_LED)
            
            # Request lines as output
            red_led.request(consumer="dakash_red_led", type=gpiod.LINE_REQ_DIR_OUT)
            green_led.request(consumer="dakash_green_led", type=gpiod.LINE_REQ_DIR_OUT)
            blue_led.request(consumer="dakash_blue_led", type=gpiod.LINE_REQ_DIR_OUT)
            
            # Set initial values
            red_led.set_value(0)
            green_led.set_value(0)
            blue_led.set_value(0)
        except Exception as e:
            return False
            
        # Configure sensor lines
        try:
            dock_sensor = gpio_chip.get_line(PIN_DOCK_SENSOR)
            carriage_sensor = gpio_chip.get_line(PIN_CARRIAGE_SENSOR)
            
            # Request lines as input with active low (since we want pull-up)
            # Use different consumer names to avoid conflicts
            dock_sensor.request(consumer="dakash_dock_sensor", type=gpiod.LINE_REQ_DIR_IN, flags=gpiod.LINE_REQ_FLAG_ACTIVE_LOW)
            carriage_sensor.request(consumer="dakash_carriage_sensor", type=gpiod.LINE_REQ_DIR_IN, flags=gpiod.LINE_REQ_FLAG_ACTIVE_LOW)
        except Exception as e:
            # Continue even if sensors fail, as LEDs might still work
            pass
            
        gpio_available = True
        return True
        
    except (ImportError, ModuleNotFoundError):
        # If we can't import gpiod, try command-line fallback
        
        # Check if command-line tools are available
        try:
            result = subprocess.run(["gpiodetect"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if result.returncode == 0:
                use_cmdline_gpio = True
                gpio_available = True
                return True
            else:
                return False
        except Exception as e:
            return False
    except Exception as e:
        return False

def setup_camera():
    """Initialize the camera using subprocess approach for Pi 5"""
    try:
        # Check if camera is accessible
        result = subprocess.run(["libcamera-still", "--timeout", "1", "-n", "--output", "/dev/null"], 
                              stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        
        if result.returncode == 0:
            return True
        else:
            # List available cameras
            cameras_cmd = "libcamera-hello --list-cameras"
            cameras_result = subprocess.run(cameras_cmd, shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            return False
            
    except Exception as e:
        return False

def control_autofocus(mode="auto", position=None):
    """Control the autofocus of the IMX519 camera"""
    try:
        if mode == "auto":
            # Set to auto focus mode
            subprocess.run(["v4l2-ctl", "-d", "/dev/v4l-subdev0", "-c", "focus_auto=1"], 
                          stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            return True
        elif mode == "manual" and position is not None:
            # Set manual focus position (value between 0-1023)
            pos = max(0, min(1023, int(position)))
            subprocess.run(["v4l2-ctl", "-d", "/dev/v4l-subdev0", "-c", f"focus_absolute={pos}"],
                          stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            return True
        else:
            return False
    except Exception as e:
        return False

def capture_image(focus_mode="auto", focus_position=None):
    """Capture an image and save it to disk using libcamera-still command"""
    try:
        # Set focus if requested
        if focus_mode != "auto" and focus_position is not None:
            control_autofocus("manual", focus_position)
        elif focus_mode == "auto":
            control_autofocus("auto")
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{CAPTURE_DIR}/capture_{timestamp}.jpg"
        
        # Capture image using subprocess with proper parameters for IMX519
        cmd = [
            "libcamera-still",
            "--output", filename,
            "--timeout", "2000",
            "--width", "4656",
            "--height", "3496",
            "--nopreview"
        ]
        
        result = subprocess.run(cmd, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        
        if result.returncode == 0:
            return filename
        else:
            return False
            
    except Exception as e:
        return False

def start_stream():
    """Start a video stream using libcamera-vid"""
    global streaming, stream_process
    
    if streaming:
        return True
    
    try:
        # Use libcamera-vid to stream
        cmd = [
            "libcamera-vid",
            "-t", "0",           # Run indefinitely
            "--width", "1920",
            "--height", "1080",
            "--framerate", "30",
            "--inline",
            "--listen", "-o", f"tcp://0.0.0.0:{STREAM_PORT}"
        ]
        
        stream_process = subprocess.Popen(cmd)
        time.sleep(2)  # Give time to start
        
        # Check if process is still running
        if stream_process.poll() is None:
            streaming = True
            return True
        else:
            return False
            
    except Exception as e:
        return False

def stop_stream():
    """Stop video streaming"""
    global streaming, stream_process
    
    if not streaming:
        return True
    
    try:
        if stream_process:
            stream_process.terminate()
            stream_process = None
        
        streaming = False
        return True
    except Exception as e:
        return False

def set_led(color, value_float):
    """Set the LED color value (0.0-1.0) using PWM simulation"""
    global use_cmdline_gpio
    
    if not gpio_available:
        return False
    
    try:
        # Ensure value is float and in range 0.0-1.0
        value_float = float(value_float)
        value_float = max(0.0, min(1.0, value_float))
        
        # Store the value
        led_values[color] = value_float
        
        # For simplicity, we just use 0 or 1 for now
        # For true PWM, you'd need a separate thread
        binary_value = 1 if value_float > 0.5 else 0
        
        if use_cmdline_gpio:
            # Use command-line tools if Python module not available
            pin_map = {"red": PIN_RED_LED, "green": PIN_GREEN_LED, "blue": PIN_BLUE_LED}
            pin = pin_map.get(color)
            
            if pin is not None:
                # Find the chip with pinctrl-rp1 label
                chip_to_use = "gpiochip0"  # Default
                
                # Use gpiodetect to find the right chip (only once)
                if not hasattr(set_led, "chip_detected"):
                    try:
                        detect_result = subprocess.run(["gpiodetect"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                        if detect_result.returncode == 0:
                            output = detect_result.stdout.decode('utf-8')
                            for line in output.splitlines():
                                if "pinctrl-rp1" in line:
                                    chip_to_use = line.split()[0]
                                    break
                    except Exception:
                        pass
                    
                    # Cache the result
                    set_led.chip_detected = True
                    set_led.chip_to_use = chip_to_use
                else:
                    chip_to_use = getattr(set_led, "chip_to_use", "gpiochip0")
                
                # Set the GPIO pin value
                cmd = ["gpioset", chip_to_use, f"{pin}={binary_value}"]
                subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                return True
        else:
            # Use Python gpiod module
            if color == "red" and red_led:
                red_led.set_value(binary_value)
            elif color == "green" and green_led:
                green_led.set_value(binary_value)
            elif color == "blue" and blue_led:
                blue_led.set_value(binary_value)
            
            return True
            
        return False
    except Exception as e:
        return False

def read_sensors():
    """Read the current state of sensors"""
    global use_cmdline_gpio
    
    if not gpio_available:
        return {"dock_sensor": None, "carriage_sensor": None, "error": "GPIO not available"}
    
    try:
        if use_cmdline_gpio:
            # Use command-line tools as fallback
            
            # Find the chip with pinctrl-rp1 label
            chip_to_use = "gpiochip0"  # Default
            
            # Use gpiodetect to find the right chip (only once)
            if not hasattr(read_sensors, "chip_detected"):
                try:
                    detect_result = subprocess.run(["gpiodetect"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                    if detect_result.returncode == 0:
                        output = detect_result.stdout.decode('utf-8')
                        for line in output.splitlines():
                            if "pinctrl-rp1" in line:
                                chip_to_use = line.split()[0]
                                break
                except Exception:
                    pass
                
                # Cache the result
                read_sensors.chip_detected = True
                read_sensors.chip_to_use = chip_to_use
            else:
                chip_to_use = getattr(read_sensors, "chip_to_use", "gpiochip0")
            
            # Read dock sensor
            dock_cmd = ["gpioget", chip_to_use, str(PIN_DOCK_SENSOR)]
            dock_result = subprocess.run(dock_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            
            # Read carriage sensor
            carriage_cmd = ["gpioget", chip_to_use, str(PIN_CARRIAGE_SENSOR)]
            carriage_result = subprocess.run(carriage_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            
            # Process results
            if dock_result.returncode == 0 and carriage_result.returncode == 0:
                dock_raw = int(dock_result.stdout.decode('utf-8').strip())
                carriage_raw = int(carriage_result.stdout.decode('utf-8').strip())
                
                # COMPLETELY INVERTED LOGIC based on user feedback:
                # Raw values from hardware:
                # dock_sensor: 1 when NOT pressed, 0 when pressed
                # carriage_sensor: 0 when NOT pressed, 1 when pressed
                
                # For MQTT reporting we now need to INVERT the logic:
                # dock_sensor: true when NOT pressed, false when pressed
                # carriage_sensor: true when NOT pressed, false when pressed
                
                dock_value = dock_raw != 0  # Convert 1→true (NOT pressed), 0→false (pressed)
                carriage_value = carriage_raw != 1  # Convert 0→true (NOT pressed), 1→false (pressed)
                
                # Update stored values
                sensor_values["dock_sensor"] = dock_value
                sensor_values["carriage_sensor"] = carriage_value
                
                # Return the correctly mapped values
                return {
                    "dock_sensor": dock_value,
                    "carriage_sensor": carriage_value
                }
            else:
                error_msg = f"Error reading sensors"
                return {"dock_sensor": None, "carriage_sensor": None, "error": error_msg}
        else:
            # Use Python gpiod module
            # Read the current values
            dock_value = dock_sensor.get_value() if dock_sensor else None
            carriage_value = carriage_sensor.get_value() if carriage_sensor else None
            
            # COMPLETELY INVERTED LOGIC based on user feedback:
            # Using gpiod with LINE_REQ_FLAG_ACTIVE_LOW for dock_sensor:
            # - dock_value will be 1 when pressed, 0 when not pressed
            # For carriage_sensor (without FLAG_ACTIVE_LOW):
            # - carriage_value will be 1 when pressed, 0 when not pressed
            
            # For MQTT reporting we now need to INVERT the logic:
            # - dock_sensor: true when NOT pressed, false when pressed  
            # - carriage_sensor: true when NOT pressed, false when pressed
            
            dock_value_bool = not bool(dock_value)  # Invert: 1→false (pressed), 0→true (NOT pressed)
            carriage_value_bool = not bool(carriage_value)  # Invert: 1→false (pressed), 0→true (NOT pressed)
            
            # Update stored values
            sensor_values["dock_sensor"] = dock_value_bool
            sensor_values["carriage_sensor"] = carriage_value_bool
            
            # Return the correctly mapped values
            return {
                "dock_sensor": dock_value_bool,
                "carriage_sensor": carriage_value_bool
            }
    except Exception as e:
        return {"dock_sensor": None, "carriage_sensor": None, "error": str(e)}

def publish_sensor_status():
    """Publish sensor status information via MQTT"""
    if not mqtt_connected or not mqtt_client:
        return
    
    status = read_sensors()
    status["timestamp"] = time.time()
    
    try:
        mqtt_client.publish(MQTT_TOPIC_SENSORS_STATUS, json.dumps(status))
    except Exception as e:
        pass

def publish_camera_status(status_data):
    """Publish camera status information via MQTT"""
    if not mqtt_connected or not mqtt_client:
        return
        
    # Add timestamp
    status_data["timestamp"] = time.time()
    
    # Publish
    try:
        mqtt_client.publish(MQTT_TOPIC_CAMERA_STATUS, json.dumps(status_data))
    except Exception as e:
        pass

# MQTT Callbacks
def on_connect(client, userdata, flags, rc):
    global mqtt_connected
    # Handle MQTT v3 callbacks
    if rc == 0:
        mqtt_connected = True
        
        # Subscribe to all relevant topics
        client.subscribe(MQTT_TOPIC_CAMERA_COMMAND)
        client.subscribe(MQTT_TOPIC_LED_RED)
        client.subscribe(MQTT_TOPIC_LED_GREEN)
        client.subscribe(MQTT_TOPIC_LED_BLUE)
        client.subscribe(MQTT_TOPIC_SENSORS_REQUEST)
        
        # Publish initial status
        publish_camera_status({
            "status": "online", 
            "streaming": streaming,
            "gpio_available": gpio_available
        })
        
        if gpio_available:
            publish_sensor_status()
    else:
        mqtt_connected = False

def on_disconnect(client, userdata, rc):
    global mqtt_connected
    mqtt_connected = False

def on_message(client, userdata, msg):
    """Handle incoming MQTT messages"""
    topic = msg.topic
    try:
        # Handle LED control messages (simple values)
        if topic == MQTT_TOPIC_LED_RED:
            set_led("red", msg.payload.decode())
        elif topic == MQTT_TOPIC_LED_GREEN:
            set_led("green", msg.payload.decode())
        elif topic == MQTT_TOPIC_LED_BLUE:
            set_led("blue", msg.payload.decode())
        elif topic == MQTT_TOPIC_SENSORS_REQUEST:
            if msg.payload.decode() == "status":
                publish_sensor_status()
        # Handle camera commands (JSON)
        elif topic == MQTT_TOPIC_CAMERA_COMMAND:
            payload = json.loads(msg.payload)
            
            command = payload.get("command", "")
            status_data = {"status": "error", "command": command}
            
            if command == "capture":
                focus_mode = payload.get("focus_mode", "auto")
                focus_position = payload.get("focus_position", None)
                result = capture_image(focus_mode, focus_position)
                status_data = {
                    "status": "success" if result else "error",
                    "command": command,
                    "result": result
                }
                
            elif command == "stream_start":
                result = start_stream()
                status_data = {
                    "status": "success" if result else "error",
                    "command": command,
                    "streaming": streaming
                }
                
            elif command == "stream_stop":
                result = stop_stream()
                status_data = {
                    "status": "success" if result else "error",
                    "command": command,
                    "streaming": streaming
                }
                
            elif command == "focus":
                mode = payload.get("mode", "auto")
                position = payload.get("position", None)
                result = control_autofocus(mode, position)
                status_data = {
                    "status": "success" if result else "error",
                    "command": command,
                    "mode": mode,
                    "position": position
                }
                
            elif command == "status":
                status_data = {
                    "status": "online",
                    "streaming": streaming,
                    "gpio_available": gpio_available,
                    "led_values": led_values,
                    "sensors": read_sensors() if gpio_available else {"error": "GPIO not available"}
                }
            
            else:
                status_data = {
                    "status": "error",
                    "command": command,
                    "message": "Unknown command"
                }
            
            # Publish status response
            publish_camera_status(status_data)
    except json.JSONDecodeError:
        pass
    except Exception as e:
        pass

def setup_mqtt_client():
    """Initialize and connect MQTT client"""
    # Use MQTT v3.1.1 for better compatibility
    client = mqtt.Client(MQTT_CLIENT_ID)
    
    # Set callbacks
    client.on_connect = on_connect
    client.on_message = on_message
    client.on_disconnect = on_disconnect
    
    # Set authentication if needed
    if MQTT_USER and MQTT_PASSWORD:
        client.username_pw_set(MQTT_USER, MQTT_PASSWORD)
    
    # Set last will message before connecting
    client.will_set(MQTT_TOPIC_CAMERA_STATUS, json.dumps({"status": "offline"}), qos=1, retain=True)
    
    # Try to connect
    try:
        client.connect_async(MQTT_BROKER, MQTT_PORT, 60)
    except Exception as e:
        pass
        
    return client

# Thread for sensor polling (since we don't have interrupts in gpiod)
def sensor_polling_thread():
    """Thread to poll sensors periodically and detect changes"""
    global sensor_values
    
    last_values = sensor_values.copy()
    last_update_time = 0
    blink_state = False
    last_blink_time = 0
    
    while True:
        if not gpio_available:
            time.sleep(1)
            continue
            
        try:
            current_time = time.time()
            
            # Read current sensor values
            current = read_sensors()
            
            # Update on change or periodically
            update_needed = (
                current["dock_sensor"] != last_values["dock_sensor"] or 
                current["carriage_sensor"] != last_values["carriage_sensor"] or
                current_time - last_update_time > 30
            )
            
            # Handle LED control based on sensor states
            try:
                # Keep LED logic the same since it's working correctly
                if current["dock_sensor"] and not current["carriage_sensor"]:
                    # Dock sensor pressed, carriage sensor not pressed - WHITE
                    set_led("red", 1.0)
                    set_led("green", 1.0)
                    set_led("blue", 1.0)
                    #print("dock sensor pressed, carriage sensor not pressed")
                
                elif current["carriage_sensor"] and not current["dock_sensor"]:
                    # Carriage sensor pressed, dock sensor not pressed - BLUE
                    set_led("red", 0.0)
                    set_led("green", 0.0)
                    set_led("blue", 1.0)
                    #print("dock sensor not pressed, carriage sensor pressed")
                
                elif not current["dock_sensor"] and not current["carriage_sensor"]:
                    # Neither sensor pressed - RED BLINKING
                    # Blink every 500ms
                    if current_time - last_blink_time > 0.5:
                        blink_state = not blink_state
                        set_led("red", 1.0 if blink_state else 0.0)
                        set_led("green", 0.0)
                        set_led("blue", 0.0)
                        last_blink_time = current_time
                        #print("dock sensor not pressed, carriage sensor not pressed")
                
                else:  # Both sensors pressed
                    # Both sensors pressed - RED BLINKING (same as neither pressed)
                    # Blink every 500ms
                    if current_time - last_blink_time > 0.5:
                        blink_state = not blink_state
                        set_led("red", 1.0 if blink_state else 0.0)
                        set_led("green", 0.0)
                        set_led("blue", 0.0)
                        last_blink_time = current_time
                        #print("dock sensor pressed, carriage sensor pressed")
                
                # Values changed or periodic update, publish update
                if update_needed:
                    publish_sensor_status()
                    last_values = current.copy()
                    last_update_time = current_time
                
            except Exception as e:
                pass
                
        except Exception as e:
            pass
            
        time.sleep(0.1)  # Poll every 100ms

def main():
    global mqtt_client, mqtt_connected, camera_ready, gpio_available
    
    # Initialize hardware
    gpio_available = setup_gpio()
    camera_ready = setup_camera()
    
    # Main loop with reconnection logic
    last_camera_attempt = 0
    last_mqtt_attempt = 0
    last_gpio_attempt = 0
    
    try:
        # Start sensor polling in a separate thread
        import threading
        sensor_thread = threading.Thread(target=sensor_polling_thread, daemon=True)
        sensor_thread.start()
        
        # Set up MQTT client
        mqtt_client = setup_mqtt_client()
        mqtt_client.loop_start()
        
        while True:
            current_time = time.time()
            
            # Try to initialize camera if needed
            if not camera_ready and (current_time - last_camera_attempt > 60):  # Retry every minute
                camera_ready = setup_camera()
                last_camera_attempt = current_time
            
            # Try to reconnect GPIO if needed (every 5 minutes)
            if not gpio_available and (current_time - last_gpio_attempt > 300):
                gpio_available = setup_gpio()
                last_gpio_attempt = current_time
            
            # Try to reconnect MQTT if needed
            if not mqtt_connected and (current_time - last_mqtt_attempt > MQTT_RETRY_INTERVAL):
                # Clean up old client
                try:
                    mqtt_client.loop_stop()
                except:
                    pass
                
                # Create new client
                mqtt_client = setup_mqtt_client()
                mqtt_client.loop_start()
                last_mqtt_attempt = current_time
            
            # Periodic status updates (every 60 seconds)
            if mqtt_connected and current_time % 60 < 1:
                try:
                    # Combined status
                    publish_camera_status({
                        "status": "online", 
                        "streaming": streaming,
                        "gpio_available": gpio_available,
                        "camera_ready": camera_ready,
                        "led_values": led_values
                    })
                    
                    # Sensor status if available
                    if gpio_available:
                        publish_sensor_status()
                except Exception as e:
                    mqtt_connected = False
            
            # Sleep for a bit
            time.sleep(1)
            
    except KeyboardInterrupt:
        pass
    except Exception as e:
        pass
    finally:
        # Cleanup
        if streaming:
            stop_stream()
        
        if mqtt_client:
            try:
                mqtt_client.loop_stop()
                mqtt_client.disconnect()
            except:
                pass
        
        # GPIO cleanup
        if gpio_available and not use_cmdline_gpio:
            try:
                # Release all GPIO lines
                if red_led:
                    red_led.release()
                if green_led:
                    green_led.release()
                if blue_led:
                    blue_led.release()
                if dock_sensor:
                    dock_sensor.release()
                if carriage_sensor:
                    carriage_sensor.release()
            except Exception as e:
                pass

if __name__ == "__main__":
    main()
