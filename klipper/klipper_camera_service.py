#!/usr/bin/env python3
"""
Klipper Position and Camera Sensor Service
Runs on the Klipper Pi to handle:
- Position requests from the camera for calibration
- Camera sensor monitoring for toolchanger verification
Fixed version that doesn't send empty MQTT messages
"""
import json
import time
import socket
import logging
import threading
import subprocess
import os
import paho.mqtt.client as mqtt

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("klipper_camera_service")

# Configuration
MQTT_BROKER = "192.168.1.89"
MQTT_PORT = 1883

# Position service topics
POSITION_REQUEST_TOPIC = "dakash/klipper/position/request"
POSITION_RESPONSE_TOPIC = "dakash/klipper/position/response"

# Camera sensor topics
SENSOR_REQUEST_TOPIC = "dakash/gpio/sensors/request"
SENSOR_RESPONSE_TOPIC = "dakash/gpio/sensors/status"

# Klipper communication
KLIPPER_UDS_PATH = "/tmp/klippy_uds"
KLIPPY_SERIAL_PATH = "/tmp/klippy_serial"

class KlipperCameraService:
    def __init__(self):
        self.mqtt_client = None
        self.running = False
        self.sensor_cache = {}
        self.sensor_cache_timeout = 5
        
    def connect_to_klipper(self):
        """Connect to Klipper via Unix Domain Socket"""
        try:
            sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            sock.connect(KLIPPER_UDS_PATH)
            return sock
        except Exception as e:
            logger.error(f"Failed to connect to Klipper: {e}")
            return None
    
    def send_klipper_command(self, command):
        """Send G-code command to Klipper via serial interface"""
        try:
            with open(KLIPPY_SERIAL_PATH, 'w') as f:
                f.write(command + '\n')
            logger.info(f"Sent command to Klipper: {command}")
            return True
        except Exception as e:
            logger.error(f"Failed to send command to Klipper: {e}")
            return False
    
    def pause_print_with_error(self, error_message):
        """Pause print and set error state"""
        logger.error(f"Pausing print: {error_message}")
        commands = [
            "SET_GCODE_VARIABLE MACRO=VARIABLES_LIST VARIABLE=tc_state VALUE=-1",
            "SET_GCODE_VARIABLE MACRO=VARIABLES_LIST VARIABLE=tc_error_code VALUE=7",
            "SET_GCODE_VARIABLE MACRO=VARIABLES_LIST VARIABLE=error_tools VALUE=\"['camera']\"",
            "PAUSE_AND_ALERT"
        ]
        
        for cmd in commands:
            self.send_klipper_command(cmd)
            time.sleep(0.1)
    
    def get_printer_position(self):
        """Get current printer position from Klipper using file-based approach"""
        try:
            # Method 1: Try to read from a position file (we'll create this)
            position_file = "/tmp/klipper_position.json"
            if os.path.exists(position_file):
                try:
                    with open(position_file, 'r') as f:
                        data = json.load(f)
                    # Check if data is recent (within 30 seconds)
                    if time.time() - data.get('timestamp', 0) < 30:
                        return {
                            "x": round(data['x'], 3),
                            "y": round(data['y'], 3),
                            "z": round(data['z'], 3)
                        }
                except Exception as e:
                    logger.debug(f"Position file read error: {e}")
            
            # Method 2: Request position via G-code and read from file
            self.send_klipper_command("_WRITE_POSITION_TO_FILE")
            time.sleep(0.5)  # Wait for file write
            
            if os.path.exists(position_file):
                try:
                    with open(position_file, 'r') as f:
                        data = json.load(f)
                    return {
                        "x": round(data['x'], 3),
                        "y": round(data['y'], 3),
                        "z": round(data['z'], 3)
                    }
                except Exception as e:
                    logger.error(f"Position file read error after write: {e}")
            
            # Method 3: Try Unix Domain Socket as fallback
            sock = self.connect_to_klipper()
            if sock:
                command = {
                    "id": int(time.time()),
                    "method": "objects/query",
                    "params": {
                        "objects": {
                            "toolhead": ["position"]
                        }
                    }
                }
                
                sock.send((json.dumps(command) + "\n").encode())
                response = sock.recv(4096).decode().strip()
                sock.close()
                
                data = json.loads(response)
                if "result" in data and "status" in data["result"]:
                    position = data["result"]["status"]["toolhead"]["position"]
                    return {
                        "x": round(position[0], 3),
                        "y": round(position[1], 3),
                        "z": round(position[2], 3)
                    }
                        
        except Exception as e:
            logger.error(f"Error getting printer position: {e}")
        
        logger.error("All position methods failed")
        return None
    
    def query_camera_sensors(self):
        """Query camera sensor states - returns consistent valid JSON"""
        try:
            # For now, return mock sensor data since we don't have direct GPIO access
            # Replace this with actual sensor reading logic for your hardware
            
            # Based on your MQTT output, this represents:
            # dock_sensor: true = NOT pressed (camera not in dock)
            # carriage_sensor: false = PRESSED (camera is on carriage)
            
            sensors = {
                "dock_sensor": True,      # true = not pressed, false = pressed
                "carriage_sensor": False, # true = not pressed, false = pressed
                "timestamp": time.time(),
                "status": "active"
            }
            
            logger.debug(f"Sensor query result: {sensors}")
            return sensors
            
        except Exception as e:
            logger.error(f"Error querying sensors: {e}")
            # Return a valid error response instead of None
            return {
                "dock_sensor": None,
                "carriage_sensor": None,
                "timestamp": time.time(),
                "status": "error",
                "error": str(e)
            }
    
    def verify_camera_state(self, expected_state):
        """Verify camera is in expected state and pause print if not"""
        sensors = self.query_camera_sensors()
        if not sensors or sensors.get("status") == "error":
            self.pause_print_with_error("Failed to read camera sensors")
            return False
        
        dock_value = sensors.get("dock_sensor")
        carriage_value = sensors.get("carriage_sensor")
        
        if expected_state == "docked":
            # Camera properly docked: dock NOT pressed (True), carriage pressed (False)
            if dock_value == True and carriage_value == False:
                logger.info("✅ Camera properly docked")
                return True
            else:
                error_msg = f"Camera not properly docked. Expected: Dock NOT PRESSED, Carriage PRESSED. " \
                           f"Actual: Dock {'NOT PRESSED' if dock_value else 'PRESSED'}, " \
                           f"Carriage {'NOT PRESSED' if carriage_value else 'PRESSED'}"
                self.pause_print_with_error(error_msg)
                return False
                
        elif expected_state == "picked":
            # Camera on carriage: dock pressed (False), carriage NOT pressed (True)
            if dock_value == False and carriage_value == True:
                logger.info("✅ Camera properly on carriage")
                return True
            else:
                error_msg = f"Camera not properly on carriage. Expected: Dock PRESSED, Carriage NOT PRESSED. " \
                           f"Actual: Dock {'NOT PRESSED' if dock_value else 'PRESSED'}, " \
                           f"Carriage {'NOT PRESSED' if carriage_value else 'PRESSED'}"
                self.pause_print_with_error(error_msg)
                return False
        
        return False
    
    def check_camera_state(self):
        """Check for impossible or error camera states"""
        sensors = self.query_camera_sensors()
        if not sensors or sensors.get("status") == "error":
            self.pause_print_with_error("Failed to read camera sensors")
            return False
        
        dock_value = sensors.get("dock_sensor")
        carriage_value = sensors.get("carriage_sensor")
        
        # Check for impossible states
        if dock_value == True and carriage_value == True:
            # Both NOT PRESSED - camera detached
            self.pause_print_with_error("Camera detached - not detected in dock or on carriage")
            return False
        elif dock_value == False and carriage_value == False:
            # Both PRESSED - impossible state
            self.pause_print_with_error("Impossible sensor state - camera detected in both dock and carriage")
            return False
        else:
            # Normal state
            if dock_value == True and carriage_value == False:
                logger.info("✅ Camera tool status: IN DOCK")
            elif dock_value == False and carriage_value == True:
                logger.info("✅ Camera tool status: ON CARRIAGE")
            return True
    
    def on_connect(self, client, userdata, flags, rc):
        """MQTT connection callback"""
        if rc == 0:
            logger.info("Connected to MQTT broker")
            client.subscribe(POSITION_REQUEST_TOPIC)
            client.subscribe(SENSOR_REQUEST_TOPIC)
        else:
            logger.error(f"Failed to connect to MQTT broker: {rc}")
    
    def on_message(self, client, userdata, msg):
        """Handle MQTT messages"""
        try:
            topic = msg.topic
            
            if topic == POSITION_REQUEST_TOPIC:
                self.handle_position_request(msg)
            elif topic == SENSOR_REQUEST_TOPIC:
                self.handle_sensor_request(msg)
                
        except Exception as e:
            logger.error(f"Error handling MQTT message: {e}")
    
    def handle_position_request(self, msg):
        """Handle position request messages"""
        try:
            payload = json.loads(msg.payload.decode())
            logger.info(f"Position request received: {payload}")
            
            if payload.get("request") == "current_position":
                position = self.get_printer_position()
                if position:
                    response = {
                        "x": position["x"],
                        "y": position["y"],
                        "z": position["z"],
                        "timestamp": time.time(),
                        "status": "success"
                    }
                    
                    self.mqtt_client.publish(
                        POSITION_RESPONSE_TOPIC, 
                        json.dumps(response)
                    )
                    logger.info(f"Position sent: {response}")
                else:
                    error_response = {
                        "error": "Failed to get position",
                        "timestamp": time.time(),
                        "status": "error"
                    }
                    self.mqtt_client.publish(
                        POSITION_RESPONSE_TOPIC,
                        json.dumps(error_response)
                    )
                    
        except json.JSONDecodeError:
            logger.error(f"Invalid JSON in position request: {msg.payload}")
        except Exception as e:
            logger.error(f"Error handling position request: {e}")
    
    def handle_sensor_request(self, msg):
        """Handle sensor status request messages - FIXED to avoid empty messages"""
        try:
            message_content = msg.payload.decode().strip()
            logger.info(f"Sensor request received: '{message_content}'")
            
            if message_content == "status":
                sensors = self.query_camera_sensors()
                if sensors:
                    # FIXED: Don't send empty messages, just send the response
                    self.mqtt_client.publish(
                        SENSOR_RESPONSE_TOPIC,
                        json.dumps(sensors),
                        qos=2
                    )
                    logger.info(f"Sensor status sent: {sensors}")
                else:
                    # Send valid error response instead of empty
                    error_response = {
                        "error": "Failed to read sensors",
                        "timestamp": time.time(),
                        "status": "error"
                    }
                    self.mqtt_client.publish(
                        SENSOR_RESPONSE_TOPIC,
                        json.dumps(error_response),
                        qos=2
                    )
                    
            elif message_content == "verify_docked":
                result = self.verify_camera_state("docked")
                # Send verification result
                response = {
                    "verification": "docked",
                    "result": result,
                    "timestamp": time.time(),
                    "status": "success" if result else "failed"
                }
                self.mqtt_client.publish(
                    SENSOR_RESPONSE_TOPIC,
                    json.dumps(response),
                    qos=2
                )
                
            elif message_content == "verify_picked":
                result = self.verify_camera_state("picked")
                # Send verification result
                response = {
                    "verification": "picked",
                    "result": result,
                    "timestamp": time.time(),
                    "status": "success" if result else "failed"
                }
                self.mqtt_client.publish(
                    SENSOR_RESPONSE_TOPIC,
                    json.dumps(response),
                    qos=2
                )
                
            elif message_content == "check":
                result = self.check_camera_state()
                # Send check result
                response = {
                    "check": "state",
                    "result": result,
                    "timestamp": time.time(),
                    "status": "success" if result else "failed"
                }
                self.mqtt_client.publish(
                    SENSOR_RESPONSE_TOPIC,
                    json.dumps(response),
                    qos=2
                )
            else:
                logger.warning(f"Unknown sensor request: {message_content}")
                
        except Exception as e:
            logger.error(f"Error handling sensor request: {e}")
            # Send valid error response
            error_response = {
                "error": str(e),
                "timestamp": time.time(),
                "status": "error"
            }
            self.mqtt_client.publish(
                SENSOR_RESPONSE_TOPIC,
                json.dumps(error_response),
                qos=2
            )
    
    def start(self):
        """Start the service"""
        try:
            # Setup MQTT client
            self.mqtt_client = mqtt.Client(client_id="klipper_camera_service")
            self.mqtt_client.on_connect = self.on_connect
            self.mqtt_client.on_message = self.on_message
            
            # Connect to MQTT broker
            self.mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
            
            # Start MQTT loop
            self.mqtt_client.loop_start()
            
            self.running = True
            logger.info("Klipper Camera Service started - handling position requests and sensor monitoring")
            
            # Keep the service running
            try:
                while self.running:
                    time.sleep(1)
            except KeyboardInterrupt:
                logger.info("Service interrupted by user")
                
        except Exception as e:
            logger.error(f"Service error: {e}")
        finally:
            self.stop()
    
    def stop(self):
        """Stop the service"""
        self.running = False
        if self.mqtt_client:
            self.mqtt_client.loop_stop()
            self.mqtt_client.disconnect()
        logger.info("Klipper Camera Service stopped")

if __name__ == "__main__":
    service = KlipperCameraService()
    service.start()
