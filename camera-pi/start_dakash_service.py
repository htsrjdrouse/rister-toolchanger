#!/usr/bin/env python3
"""
Startup script for Dakash Toolchanger
First initializes GPIO pins with proper pull-up resistors using lgpio
Then launches the main MQTT script
"""

import lgpio
import time
import subprocess
import sys
import os

# GPIO pin definitions (same as in main script)
PIN_DOCK_SENSOR = 24
PIN_CARRIAGE_SENSOR = 23

def initialize_gpio_pins():
    """
    Initialize GPIO pins with proper pull-up resistors
    This is the key functionality that makes the sensors work correctly
    """
    print("Initializing GPIO pins with pull-up resistors...")
    
    try:
        # Initialize the lgpio library
        h = lgpio.gpiochip_open(0)
        
        # Set up GPIO pins as input with pull-up resistors
        # This is what makes the script work!
        lgpio.gpio_claim_input(h, PIN_DOCK_SENSOR, lgpio.SET_PULL_UP)
        lgpio.gpio_claim_input(h, PIN_CARRIAGE_SENSOR, lgpio.SET_PULL_UP)
        
        # Wait a short time to ensure pins are initialized
        time.sleep(0.5)
        
        # Read initial state of pins for confirmation
        dock_state = lgpio.gpio_read(h, PIN_DOCK_SENSOR)
        carriage_state = lgpio.gpio_read(h, PIN_CARRIAGE_SENSOR)
        
        print(f"Dock sensor (pin {PIN_DOCK_SENSOR}) initial state: {dock_state}")
        print(f"Carriage sensor (pin {PIN_CARRIAGE_SENSOR}) initial state: {carriage_state}")
        
        # Close the lgpio connection - the pull-up configuration will remain
        lgpio.gpiochip_close(h)
        
        return True
        
    except Exception as e:
        print(f"Error initializing GPIO pins: {str(e)}")
        return False

def start_mqtt_script():
    """
    Start the main MQTT script
    """
    script_path = os.path.dirname(os.path.abspath(__file__))
    mqtt_script = os.path.join(script_path, "mqtt_unified_subscriber_fixed.py")
    
    print(f"Starting MQTT script: {mqtt_script}")
    
    # Make sure the script is executable
    try:
        os.chmod(mqtt_script, 0o755)
    except Exception:
        pass
    
    # Execute the MQTT script, replacing the current process
    try:
        # Use execv to replace the current process with the MQTT script
        # This ensures that signals (like Ctrl+C) are properly passed to the MQTT script
        os.execv(sys.executable, [sys.executable, mqtt_script])
    except Exception as e:
        print(f"Error starting MQTT script: {str(e)}")
        return False

if __name__ == "__main__":
    print("Starting Dakash Toolchanger services...")
    
    # First initialize the GPIO pins
    success = initialize_gpio_pins()
    
    if success:
        print("GPIO pins successfully initialized with pull-up resistors")
        # Start the main MQTT script
        start_mqtt_script()
    else:
        print("Failed to initialize GPIO pins. MQTT script may not function correctly.")
        # Still try to start the MQTT script
        start_mqtt_script()
