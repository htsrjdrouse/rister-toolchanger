# Camera-Based Extruder Offset Calibration

**Video:** Tutorial demonstrating advanced camera tool calibration and visual offset measurement using the enhanced `camera_flask_mqtt.py` script.

## Overview

The Rister Toolchanger's camera tool (C0) provides advanced computer vision capabilities for precise extruder offset calibration. The enhanced `camera_flask_mqtt.py` script enables real-time video targeting with click-to-coordinate mapping, allowing you to visually measure and calibrate extruder offsets with micron-level precision.

This tutorial covers the complete workflow for setting up and using the video targeting system for automated extruder offset calibration.

## What You'll Learn

- **Video Targeting System**: How the camera_flask_mqtt.py script enables click-to-coordinate mapping
- **Pixel-to-Printer Calibration**: Converting image coordinates to printer coordinates
- **Visual Offset Measurement**: Using computer vision for precise offset calculations
- **Automated Calibration Workflow**: Step-by-step offset calibration process
- **Integration with Klipper**: How the system integrates with Klipper's coordinate system

## Prerequisites

- Assembled Rister Toolchanger with camera tool (C0)
- Camera Pi with Arducam IMX519 programmable focus camera
- Network connectivity between Klipper Pi and Camera Pi
- MQTT broker running on Klipper Pi
- Basic familiarity with previous toolchanger tutorials

## System Architecture

### Communication Flow
```
┌─────────────────┐    MQTT     ┌──────────────────┐
│   Klipper Pi    │◄──────────►│    Camera Pi     │
│   (Broker)      │             │  (camera_flask_  │
│                 │             │   mqtt.py)       │
└─────────────────┘             └──────────────────┘
        ▲                                ▲
        │ G-code Commands               │ HTTP :8080
        │                               │
┌─────────────────┐             ┌──────────────────┐
│   User/Slicer   │             │   Web Browser    │
│                 │             │  (Visual UI)     │
└─────────────────┘             └──────────────────┘
```

### Key Components

**Enhanced Flask Web Interface (`camera_flask_mqtt.py`)**
- Real-time video streaming with MJPEG
- Interactive click-to-coordinate mapping
- Programmable focus control (0-30 range)
- Calibration mode with pixel-to-millimeter conversion
- MQTT integration for position data exchange

**Integrated Position Service (`klipper_camera_service.py`)**
- Publishes real-time printer position via MQTT
- Handles sensor status monitoring
- Provides reliable position data for calibration

**Calibration Data Storage**
- JSON-based calibration file: `/home/pi/calibration/calibration.json`
- Stores pixel scale, reference points, and transformation matrix
- Persistent storage across sessions

## Video Targeting System Overview

### How It Works

The video targeting system uses a sophisticated coordinate transformation system:

1. **Camera Capture**: High-resolution images from programmable focus camera
2. **User Interaction**: Click anywhere in the web interface image
3. **Pixel Coordinates**: Browser reports exact pixel coordinates of click
4. **Coordinate Transformation**: Mathematical conversion from pixels to printer coordinates
5. **Real-time Feedback**: Immediate display of calculated printer position

### Mathematical Foundation

```
Printer_X = (Pixel_X - Reference_Pixel_X) * Microns_Per_Pixel_X + Reference_Printer_X
Printer_Y = (Pixel_Y - Reference_Pixel_Y) * Microns_Per_Pixel_Y + Reference_Printer_Y
```

### Calibration Data Structure

```json
{
  "microns_per_pixel_x": 15.2,
  "microns_per_pixel_y": 15.2,
  "reference_points": [
    {
      "pixel_x": 640,
      "pixel_y": 480,
      "printer_x": 200.0,
      "printer_y": 150.0,
      "printer_z": 5.0
    }
  ],
  "enabled": true
}
```

## Step-by-Step Setup

### 1. Verify System Status

Before starting calibration, ensure all components are operational:

```gcode
# Check overall system status
DEBUG_SENSOR_STATES
CHECK_MACHINE_STATE

# Verify camera tool status
CAMERA_STATUS
CAMERA_SERVICE_STATUS

# Test MQTT communication
QUERY_CAMERA_SENSORS
```

### 2. Access Web Interface

Navigate to the enhanced camera interface:
- **URL**: `http://<CAMERA_PI_IP>:8080`
- **Features**: Real-time streaming, focus control, calibration mode

**Interface Elements:**
- Live video stream with click interaction
- Focus slider (0=near, 30=far)
- Calibration mode toggle
- Resolution selection
- Coordinate display

### 3. Load Camera Tool

```gcode
# Home the system
G28

# Load camera tool
C0

# Move to center position for calibration
G0 X200 Y150 Z10 F6000

# Report current position
REPORT_PRINTER_POSITION
```

## Calibration Process

### Phase 1: Pixel Scale Calibration

Establish the relationship between pixels and real-world measurements:

1. **Place Reference Object**
   - Position a ruler or calibration target in the camera view
   - Ensure target is in the same Z-plane as your work surface

2. **Measure Pixel Distance**
   - In the web interface, click on two points of known distance
   - Note the pixel coordinates difference
   - Calculate: `microns_per_pixel = known_distance_microns / pixel_distance`

3. **Set Pixel Scale**
   ```gcode
   # Example: 10mm = 658 pixels → 15.2 microns/pixel
   SET_PIXEL_SCALE MICRONS_PER_PIXEL_X=15.2 MICRONS_PER_PIXEL_Y=15.2
   ```

### Phase 2: Reference Point Setup

Create coordinate transformation anchors:

1. **Move to Known Position**
   ```gcode
   G0 X200 Y150 Z5 F6000
   REPORT_PRINTER_POSITION
   ```

2. **Capture Reference Point**
   - Click on the nozzle tip in the web interface
   - System automatically stores the pixel-to-printer mapping
   - Repeat for multiple positions across the work area

3. **Verify Calibration**
   ```gcode
   # Test calibration accuracy
   CAMERA_CALIBRATION_WIZARD STEP=4
   ```

### Phase 3: Automated Workflow

Use the integrated calibration wizard for streamlined setup:

```gcode
# Complete calibration workflow
CAMERA_CALIBRATION_WIZARD STEP=1  # Home and prepare
CAMERA_CALIBRATION_WIZARD STEP=2  # Pixel scale measurement
CAMERA_CALIBRATION_WIZARD STEP=3  # Reference point setup
CAMERA_CALIBRATION_WIZARD STEP=4  # Accuracy verification
```

## Extruder Offset Calibration

### Automated Visual Measurement

The system can automatically calculate extruder offsets using printed test patterns:

```gcode
# Automated offset calibration
CALIBRATE_EXTRUDER_OFFSETS
```

**Process Overview:**
1. System prints test patterns with each extruder
2. Camera captures high-resolution images
3. User clicks on printed marks in web interface
4. System calculates offset differences
5. New offsets are calculated and displayed

### Manual Measurement Process

For manual offset measurement:

1. **Print Test Patterns**
   ```gcode
   # Load first extruder
   E0
   G0 X200 Y150 Z0.2 F6000
   G1 E5 F100  # Extrude small mark
   
   # Switch to second extruder
   E1
   G0 X200 Y150 Z0.2 F6000
   G1 E5 F100  # Extrude mark at same location
   ```

2. **Visual Measurement**
   - Load camera tool: `C0`
   - Move camera over printed marks
   - Click on each extruder's mark in web interface
   - System calculates pixel differences and converts to printer coordinates

3. **Apply Offsets**
   ```gcode
   # Set calculated offsets
   SET_EXTRUDER_OFFSET_FROM_PIXELS E0_PIXEL_X=100 E0_PIXEL_Y=200 E1_PIXEL_X=105 E1_PIXEL_Y=198 MICRONS_PER_PIXEL=15.2
   ```

## Advanced Features

### Position-Aware Capture

Capture images with embedded position metadata:

```gcode
# Move to position and capture with coordinates
G0 X150 Y100 Z5 F6000
CAMERA_CAPTURE_WITH_POSITION
```

### Real-time Coordinate Display

The web interface provides real-time feedback:
- **Mouse Position**: Live pixel coordinates as you move the cursor
- **Click Coordinates**: Instant conversion to printer coordinates
- **Position History**: Track of recent calibration points

### Focus Optimization

Use programmable focus for different Z-heights:

```gcode
# Automatic focus for current Z-height
CAMERA_FOCUS_AUTO

# Manual focus setting
CAMERA_FOCUS_POSITION POSITION=15.5

# Focus presets for common heights
CAMERA_PRESET_HIGH_RES    # Best for detailed work
CAMERA_PRESET_MEDIUM_RES  # Balanced performance
CAMERA_PRESET_LOW_RES     # Fast streaming
```

## Integration with Print Workflows

### Quality Control

Use the camera system for in-process monitoring:

1. **Pre-print Verification**
   ```gcode
   # Verify extruder positions before printing
   TEST_EXTRUDER_OFFSETS
   ```

2. **Mid-print Inspection**
   - Pause print at layer boundaries
   - Load camera tool for inspection
   - Measure layer alignment visually

3. **Post-print Analysis**
   - Document print quality with position-tagged images
   - Measure dimensional accuracy
   - Archive calibration data

### Multi-tool Workflows

Integrate camera measurements in complex workflows:

```gcode
# Example: Print → Measure → Adjust → Print
E0                        # Print base layer
C0                        # Switch to camera
CAMERA_CAPTURE_WITH_POSITION  # Document result
# Process measurements and adjust
E1                        # Continue with second extruder
```

## Troubleshooting

### Calibration Accuracy Issues

**Symptoms**: Click coordinates don't match actual printer positions

**Solutions**:
- Verify pixel scale measurement with known reference
- Check Z-height consistency during calibration
- Ensure camera focus is optimal and consistent
- Use multiple reference points across the work area

### Communication Problems

**Symptoms**: Position data not updating, MQTT failures

**Solutions**:
```bash
# Check MQTT broker status
sudo systemctl status mosquitto

# Test position service
sudo systemctl status klipper-camera
sudo journalctl -u klipper-camera -f

# Test MQTT communication
mosquitto_pub -h <KLIPPER_PI_IP> -t "dakash/klipper/position/request" -m '{"request":"current_position"}'
mosquitto_sub -h <KLIPPER_PI_IP> -t "dakash/klipper/position/response" -v
```

### Camera Focus Issues

**Symptoms**: Blurry images, inconsistent measurements

**Solutions**:
- Manually set focus for your working Z-height
- Use consistent lighting conditions
- Verify camera mounting stability
- Check for mechanical vibrations affecting focus

## Configuration Files

### Key Configuration Locations

```
~/printer_data/config/
├── camera_calibration.cfg     # Calibration commands and macros
├── camera_control.cfg         # Basic camera MQTT interface  
├── camera_tool_0.cfg         # Camera tool definition
└── variables.cfg             # Stored calibration data

/home/pi/calibration/
└── calibration.json          # Pixel-to-printer transformation data
```

### Essential Variables

Monitor these variables in `variables.cfg`:

```ini
# Camera calibration status
camera_calibrated = True
camera_pixel_scale_x = 15.2
camera_pixel_scale_y = 15.2

# Tool dock positions
c0_dock_x = 145.82
c0_dock_y = 450.81
c0_dock_z = 30.0
```

## Best Practices

### Calibration Accuracy
- Use consistent Z-heights for all measurements
- Calibrate in similar lighting conditions to actual use
- Take multiple reference points across the work area
- Recalibrate after any mechanical changes

### Measurement Precision
- Use the highest resolution setting for critical measurements
- Ensure stable camera mounting to prevent vibrations
- Allow adequate focus time before making measurements
- Document calibration settings for repeatability

### Workflow Integration
- Establish standard calibration procedures
- Create macros for common measurement tasks
- Maintain calibration logs for troubleshooting
- Regular verification of offset accuracy

## Tool Offset Calibration via Video Targeting

### Visual Offset Measurement Workflow

The system enables precise visual measurement of tool offsets through an integrated workflow:

**Automated Offset Calibration Process**
1. **Dispense Reference Material**
   ```gcode
   # Switch to extruder tool
   E0
   G0 X200 Y150 Z0.2 F6000
   G1 E5 F100  # Extrude small mark
   ```

2. **Visual Measurement**
   ```gcode
   # Switch to camera tool
   C0
   # Camera moves to same nominal position
   ```

3. **Click-Based Measurement**
   - Click on deposited material in web interface
   - System calculates pixel coordinates of actual material location
   - Compares with expected camera position
   - Calculates offset automatically

4. **Offset Storage and Application**
   ```json
   // Tool configuration automatically updated
   {
     "tools": [
       {
         "id": 1,
         "name": "Extruder 1 (E0)",
         "type": "extruder", 
         "offsetX": 25.3,
         "offsetY": -12.7,
         "offsetZ": 0.0,
         "preciseX": 25.28,
         "preciseY": -12.73,
         "preciseZ": 0.0
       }
     ]
   }
   ```

### Multi-Tool Coordinate System

**Camera as Reference Tool**
- Camera tool (C0) serves as coordinate system origin
- All other tools measured relative to camera position
- No offsets for camera tool itself

**Workflow Integration**
```gcode
# Complete multi-tool calibration sequence
C0                    # Set camera reference position
E0                    # Switch to extruder 0, record approximate offset  
L0                    # Switch to liquid dispenser, record approximate offset
E1                    # Switch to extruder 1, record approximate offset

# Precision calibration via visual feedback
E0                    # Dispense material
C0                    # Measure with camera click
# Repeat for each tool
```

**Precision vs Approximate Offsets**
- **Approximate**: Manual positioning, ±1mm accuracy
- **Precision**: Visual measurement, ±0.1mm accuracy
- **Use Cases**: Approximate for rough positioning, precision for final operations

## Communication Architecture

### MQTT Topics and Data Flow

**Core MQTT Topics**
```
dakash/camera/command      # Camera control commands
dakash/camera/config       # Configuration updates  
dakash/camera/status       # Camera system status
dakash/camera/calibration  # Calibration data exchange
dakash/klipper/position/request   # Position requests
dakash/klipper/position/response  # Position data
dakash/gpio/sensors/request       # Sensor status requests
dakash/gpio/sensors/status        # Sensor responses
```

**Data Flow Example**
```javascript
// User clicks on image
handleImageClick(event) → 
  getPixelCoordinates() → 
    requestPrinterPosition() → 
      MQTT: dakash/klipper/position/request → 
        Klipper API response → 
          addReferencePoint() → 
            saveCalibrationData()
```

### Service Integration

**Camera Pi Services**
- `camera_flask_mqtt.py`: Main web interface and targeting system
- `mqtt_unified_subscriber_fixed.py`: MQTT message handling
- `start_dakash_service.py`: Service startup and management

**Klipper Pi Services**  
- `klipper_camera_service.py`: Position reporting and sensor monitoring
- Integration with Klipper G-code macro system
- Real-time sensor state monitoring

## Integration with Print Workflows

### Quality Control Applications

**In-Process Monitoring**
```gcode
# Pause print for inspection
PAUSE
C0                    # Load camera tool
G0 X200 Y150 Z20 F6000
CAMERA_CAPTURE_WITH_POSITION
# Resume after visual verification
```

**Layer Alignment Verification**
- Visual inspection between tool changes
- Click-based measurement of layer registration
- Automated offset correction if drift detected

**Dimensional Accuracy Checking**
- Click-based measurement of printed features
- Comparison with CAD dimensions
- Real-time process adjustment capabilities

### Multi-Tool Manufacturing Workflows

**FDM + Liquid Dispensing**
```gcode
# Print base structure
E0
# ... print base layers ...

# Switch to liquid dispensing
L0
# Dispense liquid at precise locations using camera calibration

# Return to printing
E1  
# Continue with different material
```

**Camera-Guided Assembly**
- Visual verification of component placement
- Click-based coordinate input for assembly operations
- Integration with robotic assembly systems

## System Configuration Files

### Key Configuration Elements

**Camera Calibration Config** (`camera_calibration.cfg`)
```ini
[gcode_macro CAMERA_CAPTURE_WITH_POSITION]
gcode:
    REPORT_PRINTER_POSITION
    CAMERA_CAPTURE
    # Embedded position data in image metadata
```

**Tool Management Config** (`tools_config.json`)
- Persistent tool offset storage
- Multiple offset types (approximate/precision)
- Tool type classification and capabilities

**Calibration Data Storage** (`/home/pi/calibration/calibration.json`)
- Reference point coordinates
- Pixel scale factors
- Transformation matrices
- Timestamp tracking for recalibration needs

## Summary

The enhanced `camera_flask_mqtt.py` script transforms the Rister Toolchanger's camera tool into a sophisticated metrology system. The video targeting functionality enables:

**Core Capabilities**
- **Interactive Coordinate Mapping**: Click anywhere for instant printer coordinates
- **Automated Camera Centering**: Click objects to auto-center them
- **Visual Scale Calibration**: Draw lines to measure pixel scale
- **Multi-Tool Offset Measurement**: Visual tool calibration workflow
- **Real-Time Position Integration**: Live coordinate display and conversion

**Integration Benefits**  
- **Seamless Tool Switching**: Precise offsets between all tool types
- **Quality Control**: Visual verification and measurement capabilities
- **Process Optimization**: Real-time feedback for manufacturing workflows
- **Calibration Maintenance**: Built-in tools for system recalibration

**Technical Implementation**
- **Direct API Integration**: Fast position reporting via Klipper API
- **MQTT Communication**: Reliable command/control architecture  
- **Thread-Safe Operation**: Concurrent position updates and image processing
- **Persistent Calibration**: JSON-based configuration storage
- **Visual Feedback**: Real-time coordinate display and interactive overlays

The system represents a comprehensive solution for precision multi-tool manufacturing with integrated computer vision capabilities, enabling workflows that seamlessly combine FDM 3D printing, liquid dispensing, and visual quality control.
