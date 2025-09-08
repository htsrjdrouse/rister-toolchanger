#!/bin/bash
# Script: /home/pi/publish_position.sh

# Path to variables.cfg
VARIABLES_FILE="/home/pi/printer_data/config/variables.cfg"

# Extract values from variables.cfg
CURRENT_X=$(grep '^current_x =' "$VARIABLES_FILE" | awk '{print $3}')
CURRENT_Y=$(grep '^current_y =' "$VARIABLES_FILE" | awk '{print $3}')
CURRENT_Z=$(grep '^current_z =' "$VARIABLES_FILE" | awk '{print $3}')

# Validate that values were found
if [ -z "$CURRENT_X" ] || [ -z "$CURRENT_Y" ] || [ -z "$CURRENT_Z" ]; then
    echo "Error: Could not read position values from $VARIABLES_FILE" >&2
    exit 1
fi

# Publish to MQTT
mosquitto_pub -h 192.168.1.89 -t "dakash/klipper/position/response" -m "{\"x\":$CURRENT_X,\"y\":$CURRENT_Y,\"z\":$CURRENT_Z,\"status\":\"success\"}" -q 2

# Check if the publish was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to publish to MQTT" >&2
    exit 1
fi
