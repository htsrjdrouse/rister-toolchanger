#!/bin/bash
# Enhanced query_sensors.sh with correct argument handling
# Usage: ./query_sensors.sh [verify_docked|verify_picked|check]

# MQTT broker settings
BROKER="192.168.1.89"
PORT="1883"
REQUEST_TOPIC="dakash/gpio/sensors/request"
RESPONSE_TOPIC="dakash/gpio/sensors/status"

# Command to run (if provided)
COMMAND="$1"

# Function to pause the print
pause_print() {
    echo "PAUSING PRINT: $1"
    echo "SET_GCODE_VARIABLE MACRO=VARIABLES_LIST VARIABLE=tc_state VALUE=-1" > /tmp/klippy_request
    echo "SET_GCODE_VARIABLE MACRO=VARIABLES_LIST VARIABLE=tc_error_code VALUE=7" >> /tmp/klippy_request 
    echo "SET_GCODE_VARIABLE MACRO=VARIABLES_LIST VARIABLE=error_tools VALUE=\"['camera']\"" >> /tmp/klippy_request
    echo "PAUSE_AND_ALERT" >> /tmp/klippy_request
    
    if [ -p /tmp/klippy_serial ]; then
        cat /tmp/klippy_request > /tmp/klippy_serial
    fi
}

# Clear any retained messages first
mosquitto_pub -h $BROKER -p $PORT -t $RESPONSE_TOPIC -m "" -r > /dev/null 2>&1

# Start a background listener
echo "Querying sensors..."
mosquitto_sub -h $BROKER -p $PORT -t $RESPONSE_TOPIC -v > /tmp/sensor_output &
LISTENER_PID=$!

# Give listener time to connect
sleep 1

# Send query command with QoS 2 for guaranteed delivery
mosquitto_pub -h $BROKER -p $PORT -t $REQUEST_TOPIC -m "status" -q 2

# Wait for response
echo "Waiting for sensor data..."
TIMEOUT=8
START_TIME=$(date +%s)

while [ $(($(date +%s) - START_TIME)) -lt $TIMEOUT ]; do
    # Check if we've received valid sensor data
    if grep -q "dock_sensor" /tmp/sensor_output; then
        # Extract the last valid response
        VALID_RESPONSE=$(grep "dock_sensor" /tmp/sensor_output | tail -1 | cut -d' ' -f2-)
        
        # Parse the response and format it nicely
        if command -v jq &> /dev/null; then
            # Parse using jq if available
            DOCK_VALUE=$(echo "$VALID_RESPONSE" | jq -r '.dock_sensor')
            CARRIAGE_VALUE=$(echo "$VALID_RESPONSE" | jq -r '.carriage_sensor')
            
            echo "✓ Sensor data received"
            echo "┌─────────────────────────────────────┐"
            echo "│ SENSOR STATUS                       │"
            echo "├─────────────────┬───────────────────┤"
            
            if [ "$DOCK_VALUE" = "true" ]; then
                echo "│ Dock sensor     │ NOT PRESSED        │"
            else
                echo "│ Dock sensor     │ PRESSED            │"
            fi
            
            if [ "$CARRIAGE_VALUE" = "true" ]; then
                echo "│ Carriage sensor │ NOT PRESSED        │"
            else
                echo "│ Carriage sensor │ PRESSED            │"
            fi
            echo "└─────────────────┴───────────────────┘"
           




            # Process command arguments if provided
            if [ "$COMMAND" = "verify_docked" ]; then
                # CORRECTED: For properly docked camera: dock="true" (NOT PRESSED), carriage="false" (PRESSED)
                if [ "$DOCK_VALUE" = "true" ] && [ "$CARRIAGE_VALUE" = "false" ]; then
                    echo "✅ Camera properly docked"
                else
                    echo "❌ ERROR: Camera not properly docked"
                    echo "Expected: Dock NOT PRESSED, Carriage PRESSED"
                    echo "Actual: Dock $([ "$DOCK_VALUE" = "true" ] && echo "NOT PRESSED" || echo "PRESSED"), Carriage $([ "$CARRIAGE_VALUE" = "false" ] && echo "PRESSED" || echo "NOT PRESSED")"
                    pause_print "Camera not properly docked"
                fi
            elif [ "$COMMAND" = "verify_picked" ]; then
                # CORRECTED: For camera on carriage: dock="false" (PRESSED), carriage="true" (NOT PRESSED)
                if [ "$DOCK_VALUE" = "false" ] && [ "$CARRIAGE_VALUE" = "true" ]; then
                    echo "✅ Camera properly on carriage"
                else
                    echo "❌ ERROR: Camera not properly on carriage"
                    echo "Expected: Dock PRESSED, Carriage NOT PRESSED"
                    echo "Actual: Dock $([ "$DOCK_VALUE" = "true" ] && echo "NOT PRESSED" || echo "PRESSED"), Carriage $([ "$CARRIAGE_VALUE" = "false" ] && echo "PRESSED" || echo "NOT PRESSED")"
                    pause_print "Camera not properly on carriage"
                fi
            elif [ "$COMMAND" = "check" ]; then
                # Check for impossible states
                if [ "$DOCK_VALUE" = "true" ] && [ "$CARRIAGE_VALUE" = "true" ]; then
                    # Both NOT PRESSED - camera detached
                    echo "❌ ERROR: Camera detached - not detected in dock or on carriage"
                    pause_print "Camera detached"
                elif [ "$DOCK_VALUE" = "false" ] && [ "$CARRIAGE_VALUE" = "false" ]; then
                    # Both PRESSED - impossible state
                    echo "❌ ERROR: Impossible state - camera detected in both dock and carriage"
                    pause_print "Impossible sensor state"
                else
                    # Normal state - already displayed in the table
                    if [ "$DOCK_VALUE" = "true" ]; then
                        echo "✅ Camera tool status: IN DOCK (dock sensor NOT PRESSED)"
                    elif [ "$CARRIAGE_VALUE" = "true" ]; then
                        echo "✅ Camera tool status: ON CARRIAGE (carriage sensor NOT PRESSED)"
                    fi
                fi
            fi
        else
            # Simpler output without jq
            echo "Sensor data received: $VALID_RESPONSE"
            
            # Parse with grep instead of jq
            if echo "$VALID_RESPONSE" | grep -q "dock_sensor\": true"; then
                DOCK_VALUE="true"
            else
                DOCK_VALUE="false"
            fi
            
            if echo "$VALID_RESPONSE" | grep -q "carriage_sensor\": true"; then
                CARRIAGE_VALUE="true"
            else
                CARRIAGE_VALUE="false"
            fi
            
            # Process verification commands even without jq
            if [ -n "$COMMAND" ]; then
                echo "Processing command: $COMMAND"
                
                if [ "$COMMAND" = "verify_docked" ]; then
                    # CORRECTED: For properly docked camera
                    if [ "$DOCK_VALUE" = "true" ] && [ "$CARRIAGE_VALUE" = "false" ]; then
                        echo "✅ Camera properly docked"
                    else
                        echo "❌ ERROR: Camera not properly docked"
                        pause_print "Camera not properly docked"
                    fi
                elif [ "$COMMAND" = "verify_picked" ]; then
                    # CORRECTED: For camera on carriage
                    if [ "$DOCK_VALUE" = "false" ] && [ "$CARRIAGE_VALUE" = "true" ]; then
                        echo "✅ Camera properly on carriage"
                    else
                        echo "❌ ERROR: Camera not properly on carriage"
                        pause_print "Camera not properly on carriage"
                    fi
                fi
            fi
        fi
        
        # Clean up and exit successfully
        kill $LISTENER_PID 2>/dev/null
        rm /tmp/sensor_output
        exit 0
    fi
    
    # Brief pause before checking again
    sleep 0.5
done

# If we get here, we timed out without receiving valid data
echo "❌ ERROR: No valid sensor data received within timeout"
echo "Make sure the CameraPi is online and the MQTT subscriber script is running"

# Clean up
kill $LISTENER_PID 2>/dev/null
rm /tmp/sensor_output
exit 1
