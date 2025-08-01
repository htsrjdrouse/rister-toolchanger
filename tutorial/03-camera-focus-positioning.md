# Camera Tool Focus and Positioning

**Video Tutorial:**

This tutorial covers how to use the camera tool (C0) with your Rister Toolchanger for focus control, positioning, and image capture. The camera system operates independently via MQTT communication and provides a web interface for real-time visualization.

## Overview

The Rister camera tool is built around a Raspberry Pi with an IMX519 camera sensor that communicates through MQTT messaging rather than direct Klipper pin control. This allows for advanced imaging capabilities including autofocus, multiple resolution modes, and real-time streaming.

## System Architecture

**Camera Tool Components:**
- **Raspberry Pi** - Runs camera control software and MQTT client
- **IMX519 Camera Sensor** - High-resolution camera with motorized focus
- **MQTT Communication** - Wireless command and status messaging
- **Flask Web Interface** - Real-time stream visualization and manual controls

**Communication Flow:**
1. Klipper sends commands via MQTT
2. Raspberry Pi receives and executes camera operations
3. Status and images returned via MQTT/web interface
4. Live stream available through Flask web service

## Prerequisites

- ✅ Rister Toolchanger calibrated and homed (see [Tool Calibration and Homing](01-calibration-and-homing.md))
- ✅ Camera tool (C0) properly mounted and configured
- ✅ Raspberry Pi camera system powered and connected to network
- ✅ MQTT broker configured and running
- ✅ Camera tool dock position calibrated

## Safety First

⚠️ **Before using the camera tool:**
1. Ensure camera tool pickup/dock area is clear
2. Verify camera is not obstructed during movement
3. Check that lighting conditions are adequate
4. Confirm network connectivity to camera system

## Step 1: Camera Tool Pickup and Status

### Camera Tool Commands

The camera tool uses specific pickup/dock verification commands:

```gcode
# Pick up camera tool
C0

# Verify camera tool is properly connected to carriage
VERIFY_TOOL_PICKUP_C0

# Check camera system status
CAMERA_STATUS

# Show current sensor values
QUERY_CAMERA
```

### Initial Status Check

After picking up the camera tool:

```gcode
# Check for any camera errors
CHECK_CAMERA

# Verify camera is responding
CAMERA_STATUS

# Call after successful pickup (important!)
CAMERA_TOOL_PICKED
```

## Step 2: Camera Focus Control

### Understanding IMX519 Focus Range

The IMX519 camera sensor provides motorized focus control:
- **Focus Range:** 0-30 (0=Near focus, 30=Far focus)
- **Useful Range:** Typically 10-20 for most applications
- **Fine Control:** 0.1 increments for precise adjustment

### Focus Control Commands

```gcode
# Set autofocus mode (camera automatically adjusts)
CAMERA_FOCUS_AUTO

# Set specific focus position
CAMERA_FOCUS_POSITION P=15.5    # Mid-range focus
CAMERA_FOCUS_POSITION P=10.0    # Closer focus
CAMERA_FOCUS_POSITION P=20.0    # Further focus

# Check current focus status
CAMERA_STATUS
```

### Focus Calibration Process

1. **Start with autofocus:**
   ```gcode
   CAMERA_FOCUS_AUTO
   ```

2. **Take test image:**
   ```gcode
   CAMERA_CAPTURE
   ```

3. **Review image quality** via web interface

4. **Fine-tune manually if needed:**
   ```gcode
   CAMERA_FOCUS_POSITION P=12.5
   CAMERA_CAPTURE
   ```

5. **Iterate until optimal focus achieved**

## Step 3: Resolution and Image Quality

### Resolution Presets

The camera supports multiple resolution modes:

```gcode
# High resolution mode (best quality, slower)
CAMERA_PRESET_HIGH_RES

# Medium resolution mode (balanced)
CAMERA_PRESET_MEDIUM_RES

# Low resolution mode (fastest, good for positioning)
CAMERA_PRESET_LOW_RES
```

### Choosing Resolution Mode

**High Resolution:**
- Use for: Final inspection, detailed measurements, archival images
- Trade-off: Slower capture, larger file sizes

**Medium Resolution:**
- Use for: General purpose imaging, calibration targets
- Trade-off: Good balance of speed and quality

**Low Resolution:**
- Use for: Real-time positioning, quick previews, streaming
- Trade-off: Faster operation, smaller files

## Step 4: Live Streaming and Web Interface

### Starting Video Stream

```gcode
# Start live video stream
CAMERA_STREAM_START

# Stream is now available at: http://{camera_ip}:8080
```

**Camera IP Configuration:**
The camera IP address is defined in your `printer.cfg`:

```ini
[gcode_macro CAMERA_CONFIG]
variable_camera0ip: "192.168.1.215"
gcode:
    # This macro just stores variables
```

Access the web interface using this configured IP address.

### Web Interface Features

Access the Flask web interface in your browser:
- **Live Stream View** - Real-time camera feed
- **Manual Focus Control** - Interactive focus adjustment
- **Image Capture** - Take snapshots directly from web interface
- **Resolution Settings** - Change modes without G-code commands
- **Focus Position Display** - Current focus value and range

### Stream Control

```gcode
# Stop video stream when done
CAMERA_STREAM_STOP

# Check streaming status
CAMERA_STATUS
```

## Step 5: Camera Positioning and Calibration

### Camera Dock Calibration

```gcode
# Calibrate camera dock location
CALIBRATE_CAMERA_DOCK

# Alternative command for dock position calculation
CALC_CAMERADOCK_LOCATION
```

### Positioning for Measurements

```gcode
# Move camera tool to specific position
G0 X100 Y100 Z50    # Position over target area

# Set appropriate focus for distance
CAMERA_FOCUS_POSITION P=15.0

# Capture image for analysis
CAMERA_CAPTURE
```

## Step 6: Continuous Monitoring

### Sensor Monitoring

For long-term operations or troubleshooting:

```gcode
# Start continuous monitoring
START_CAMERA_MONITORING

# Monitor will report status changes automatically
# Check periodically for errors
CHECK_CAMERA

# Stop monitoring when complete
STOP_CAMERA_MONITORING
```

### Monitoring Applications

**Quality Control:**
- Continuous inspection during automated processes
- Real-time defect detection
- Process verification

**System Health:**
- Camera temperature monitoring
- Focus mechanism status
- Communication link quality

## Step 7: Tool Return and Cleanup

### Proper Tool Return Sequence

```gcode
# Stop any active streams
CAMERA_STREAM_STOP

# Stop monitoring if active
STOP_CAMERA_MONITORING

# Call before docking (important!)
CAMERA_TOOL_DOCKED

# Return camera tool to dock
A_1

# Verify tool is properly docked
VERIFY_TOOL_DOCKED_C0
```

## Troubleshooting

### MQTT Communication Issues
- **Symptom:** Camera commands not responding
- **Solution:** Check MQTT broker status, verify network connectivity
- **Prevention:** Use reliable network connection, monitor MQTT logs

### Focus Problems
- **Symptom:** Images consistently blurry
- **Solution:** Recalibrate focus range, check for mechanical obstruction
- **Prevention:** Regular focus calibration, protect camera from impacts

### Web Interface Access
- **Symptom:** Cannot access camera stream
- **Solution:** Verify camera IP address, check Flask service status
- **Prevention:** Use static IP for camera system, monitor service health

### Tool Detection Issues
- **Symptom:** `VERIFY_TOOL_PICKUP_C0` fails
- **Solution:** Check MQTT communication, verify camera tool is properly seated
- **Prevention:** Ensure clean tool connections, regular system checks

## Advanced Applications

### Automated Inspection Workflow

```gcode
[gcode_macro INSPECT_PART]
gcode:
    # Pick up camera
    C0
    VERIFY_TOOL_PICKUP_C0
    CAMERA_TOOL_PICKED
    
    # Set up for inspection
    CAMERA_PRESET_HIGH_RES
    CAMERA_FOCUS_POSITION P=15.0
    
    # Move to inspection points
    G0 X{params.X} Y{params.Y} Z{params.Z}
    G4 P500  # Allow settling
    CAMERA_CAPTURE
    
    # Return tool
    CAMERA_TOOL_DOCKED
    A_1
    VERIFY_TOOL_DOCKED_C0
```

### Multi-Point Measurement

```gcode
[gcode_macro MEASURE_MULTIPLE_POINTS]
gcode:
    C0
    CAMERA_TOOL_PICKED
    CAMERA_PRESET_MEDIUM_RES
    
    {% for point in range(5) %}
        G0 X{point * 20} Y{point * 20} Z10
        CAMERA_FOCUS_AUTO
        G4 P1000
        CAMERA_CAPTURE
    {% endfor %}
    
    CAMERA_TOOL_DOCKED
    A_1
```

## Essential Commands Reference

```gcode
# Tool Operations
C0                        # Pick up camera tool
A_1                       # Return tool to dock
CAMERA_TOOL_PICKED        # Call after pickup
CAMERA_TOOL_DOCKED        # Call before docking
VERIFY_TOOL_PICKUP_C0     # Verify pickup success
VERIFY_TOOL_DOCKED_C0     # Verify docking success

# Focus Control
CAMERA_FOCUS_AUTO         # Enable autofocus
CAMERA_FOCUS_POSITION P=15.5  # Set focus position (0-30)

# Image Capture
CAMERA_CAPTURE            # Take single image
CAMERA_STREAM_START       # Start video stream
CAMERA_STREAM_STOP        # Stop video stream

# Resolution Control
CAMERA_PRESET_HIGH_RES    # High resolution mode
CAMERA_PRESET_MEDIUM_RES  # Medium resolution mode
CAMERA_PRESET_LOW_RES     # Low resolution mode

# Status and Monitoring
CAMERA_STATUS             # Show camera status
CHECK_CAMERA              # Check for errors
QUERY_CAMERA              # Show sensor values
START_CAMERA_MONITORING   # Begin monitoring
STOP_CAMERA_MONITORING    # Stop monitoring

# Calibration
CALIBRATE_CAMERA_DOCK     # Calibrate dock position
CALC_CAMERADOCK_LOCATION  # Calculate dock location

# Help
CAMERA_HELP               # Show command help
```

## Configuration Notes

**Network Setup:**
- Camera system requires stable network connection
- Flask web interface runs on port 8080
- MQTT broker must be accessible to both Klipper and camera system
- Camera IP address configured in `CAMERA_CONFIG` macro in `printer.cfg`

**Example IP Configuration:**
```ini
[gcode_macro CAMERA_CONFIG]
variable_camera0ip: "192.168.1.215"
gcode:
    # This macro just stores variables
```

**Focus Range Guidelines:**
- **0-5:** Macro/close-up work
- **10-15:** General purpose imaging
- **15-20:** Medium distance subjects
- **20-30:** Far subjects (limited usefulness)

## Next Steps

After mastering camera tool operations:
1. **Linear Actuator Operations** - Learn liquid handling techniques
2. **Camera-Based Calibration** - Use camera for automated offset measurement
3. **Multi-Tool Workflows** - Combine camera with other tools for advanced automation

---

**Web Interface Access:** http://192.168.1.215:8080 (or your configured camera IP)

**IMX519 Focus Range:** 0=Near, 30=Far (useful range typically 10-20)

**Camera IP Configuration:** Set in `CAMERA_CONFIG` macro within `printer.cfg`
