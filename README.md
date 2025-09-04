# Rister Multi-Modal Toolchanger

<img src="images/rister_multi-modal_toolchanger.png" alt="Rister Multi-Modal Toolchanger Logo" width="400">

A sophisticated **Klipper-based** toolchanger system that integrates multiple fabrication and analysis techniques through **FDM 3D printing**, **liquid dispensing**, and **camera imaging** tools with advanced **pixel-to-printer coordinate calibration**.

## Overview

Unlike traditional toolchangers that focus solely on FDM extruders, the Rister system creates a unified platform for multi-modal manufacturing and analysis built specifically for **Klipper firmware**. The system combines:

- **FDM Tools (E0, E1)**: Traditional 3D printing extruders with CAN bus control
- **Liquid Dispenser (L0)**: Precision liquid handling with linear actuator pipette
- **Camera Tool (C0)**: Programmable focus imaging with MQTT control and **visual calibration system**
- **Microfluidics Integration**: Arduino-controlled wash station for liquid handling

Each tool type uses optimized communication protocols and provides comprehensive sensor feedback for reliable operation.

## Key Features

- **Native Klipper Integration**: Custom Python modules and extensive G-code macro framework
- **Multi-Protocol Communication**: CAN bus for extruders, MQTT for camera, serial for microfluidics
- **Unified Tool Framework**: String-based tool IDs with consistent macro interface
- **Advanced Sensor System**: Dock/carriage detection with LED status feedback
- **Tool State Validation**: Real-time monitoring and error detection
- **Web-Based Camera Control**: Flask interface with programmable focus
- **NEW: Pixel-to-Printer Calibration**: Click-to-coordinate mapping for visual calibration
- **NEW: Extruder Offset Calibration**: Automated visual offset measurement and correction
- **Precision Liquid Handling**: Syringe pump with valve control and wash station
- **Configuration Files**: 20+ Klipper .cfg files for comprehensive system integration
- **Python Modules**: Custom Klipper extras and integrated services
- **G-code Macros**: Unified command interface with 50+ custom macros

## System Architecture

**Built specifically for Klipper firmware**, the Rister Multi-Modal Toolchanger extends Klipper's capabilities through custom Python modules and comprehensive G-code macro integration.

### Hardware Components

**Main Controller**
- BigTreeTech Octopus (STM32F446) running Klipper firmware or equivalent
- Enhanced Gantry: 4 Z-motors (vs. standard 3) for improved stability
- Custom Motor Mounts: Enhanced CoreXY mounts for multi-modal loads
- CoreXY kinematics with 480×380×250mm build volume
- Z-tilt bed leveling with four stepper motors

**Tool Controllers**
- **E0/E1 Extruders**: BTT EBB CAN boards (CAN bus communication)
  - Modified Lineux One design with Bambu Lab hotends
  - Integrated Klicky probe, filament sensors, and LED indicators
  - Custom air ducting and magnetic detachable cooling ducts
- **L0 Liquid Dispenser**: Direct GPIO control with servo linear actuator
  - Precision pipette handling with automated tip loading/unloading
  - 3-way valve system (input/output/bypass)
  - Pressure compensation vessel with level sensing
- **C0 Camera Tool**: Separate Raspberry Pi with MQTT communication
  - Arducam programmable focus camera with web interface
  - **NEW: Visual calibration system** for pixel-to-coordinate mapping

**Specialized Hardware**
- **Camera**: Arducam IMX519 with programmable focus (0-30 range)
- **Syringe Pump**: Stepper motor controlled via extruder interface
- **Microfluidics**: Arduino-controlled wash station with pumps and valves
- **Sensors**: Per-tool dock/carriage detection switches
- **LEDs**: NeoPixel status indicators for each tool

### Communication Protocols

**CAN Bus (Extruders)**
- BTT EBB36 boards for E0/E1 tools
- Direct Klipper stepper/heater/fan control
- Built-in filament runout sensors

**MQTT (Camera Tool)**
- Camera Pi IP: <CAMERA_PI_IP>
- Klipper Pi IP: <KLIPPER_PI_IP> (MQTT broker)
- Topics: `dakash/camera/*`, `dakash/gpio/*`, and `dakash/klipper/*`

**Serial (Microfluidics)**
- Arduino connection: `/dev/ttyACM1`
- Wash/waste pump control
- Pressure compensation vessel

**HTTP (Web Interface)**
- Flask server on port 8080
- Real-time camera control and streaming
- Focus adjustment with visual feedback
- **NEW: Interactive calibration interface** with click-to-coordinate mapping

## File Structure

### Required Files

**Klipper Extras Module (CRITICAL):**
```
~/klipper/klippy/extras/camera_dock_calibrate.py  # Camera dock calibration module
~/klipper/klippy/extras/arduino_serial.py  # Arduino serial connection
~/klipper/klippy/extras/atc_switch.py  # Module for executing shell commands from g-code
~/klipper/klippy/extras/generic_dock_calibrate.py  # Generic dock calibration
~/klipper/klippy/extras/led_effect.py  # Full color programmable led controller
~/klipper/klippy/extras/tool_probe.py  # Per-tool Z-Probe support
~/klipper/klippy/extras/tool_probe_endstop.py  # Per-tool Z-Probe support
```

**Klipper Configuration Files:**
```
~/printer_data/config/
├── printer.cfg                    # Main Klipper printer configuration
├── unified_toolchanger.cfg        # Core toolchanger framework
├── tool_state_handlers.cfg        # Sensor monitoring and LED control
├── variables.cfg                   # Tool coordinates and statistics
├── camera_dock_calibrate.cfg      # Camera dock calibration configuration
│
├── extruder_tool_0.cfg            # E0 FDM extruder
├── extruder_tool_1.cfg            # E1 FDM extruder  
├── liquid_dispenser_0.cfg         # L0 liquid handling
├── camera_tool_0.cfg              # C0 camera tool
│
├── camera_control.cfg             # Camera MQTT commands and basic controls
├── camera_monitor.cfg             # Camera sensor monitoring (replaces shell scripts)  
├── camera_calibration.cfg         # NEW: Pixel-to-printer calibration tools
│
├── syringe_pump_0.cfg             # Liquid pump configuration
├── microfluidics.cfg              # Wash station control
├── tool_probe.cfg                 # Z-offset probing
├── smart_filament_sensor.cfg      # Runout detection
└── [additional configuration files]
```

**Camera Pi Scripts:**
```
~/                                  # Camera Pi home directory
├── camera_flask_mqtt.py           # NEW: Enhanced Flask web interface with calibration
├── mqtt_unified_subscriber_fixed.py # Main MQTT subscriber service
└── start_dakash_service.py        # Service startup script
```

**Klipper Pi Scripts:**
```
~/                                  # Klipper Pi home directory
├── klipper_camera_service.py      # NEW: Integrated position and sensor service
└── check_camera.sh                # Legacy camera monitoring (can be retired)
```

### Prerequisites

**Hardware Requirements**
- BTT octopus mainboard with STM32F446 MCU or equivalent
- 2× BTT EBB CAN boards for extruder tools
- Raspberry Pi for camera tool (tested on Pi 5)
- Arducam IMX519 camera module
- Arduino for microfluidics control
- Linear actuator servo for liquid dispenser
- NeoPixel LEDs for tool status
- Dock/carriage sensor switches per tool

**Software Requirements**
- **Klipper firmware** on main controller (required)
- Python 3.8+ on both Raspberry Pis
- MQTT broker (Mosquitto)
- Required Python packages (see requirements below)

### Klipper Configuration Setup

1. **Install Klipper extras module (REQUIRED):**
   ```bash
   # Copy the camera dock calibration module to Klipper extras
   cp camera_dock_calibrate.py ~/klipper/klippy/extras/
   
   # Restart Klipper service
   sudo systemctl restart klipper
   ```

2. **Clone or copy configuration files to Klipper config directory:**
   ```bash
   cd ~/printer_data/config
   # Copy all .cfg files from this repository
   ```

3. **Key configuration files:**
   ```
   printer.cfg              # Main printer configuration
   unified_toolchanger.cfg  # Core toolchanger framework
   tool_state_handlers.cfg  # Sensor monitoring and LED control
   variables.cfg            # Tool coordinates and statistics
   
   # Individual tool configurations
   extruder_tool_0.cfg      # E0 FDM extruder
   extruder_tool_1.cfg      # E1 FDM extruder  
   liquid_dispenser_0.cfg   # L0 liquid handling
   camera_tool_0.cfg        # C0 camera tool
   
   # NEW: Camera system files
   camera_control.cfg       # Basic camera commands and MQTT interface
   camera_monitor.cfg       # Sensor monitoring (replaces shell scripts)
   camera_calibration.cfg   # Pixel-to-printer calibration tools
   
   # Supporting systems
   syringe_pump_0.cfg       # Liquid pump configuration
   microfluidics.cfg        # Wash station control
   tool_probe.cfg           # Z-offset probing
   smart_filament_sensor.cfg # Runout detection
   ```

4. **Install the integrated camera service on Klipper Pi:**
   ```bash
   # Copy the integrated service
   cp klipper_camera_service.py ~/
   chmod +x ~/klipper_camera_service.py
   
   # Install Python dependencies
   pip3 install paho-mqtt
   
   # Create systemd service
   sudo nano /etc/systemd/system/klipper-camera.service
   ```
   
   Add this service configuration:
   ```ini
   [Unit]
   Description=Klipper Camera Service (Position & Sensor Monitoring)
   After=network.target klipper.service
   Wants=klipper.service
   
   [Service]
   Type=simple
   User=pi
   Group=pi
   WorkingDirectory=/home/pi
   ExecStart=/usr/bin/python3 /home/pi/klipper_camera_service.py
   Restart=always
   RestartSec=5
   StandardOutput=journal
   StandardError=journal
   Environment=PYTHONUNBUFFERED=1
   
   [Install]
   WantedBy=multi-user.target
   ```
   
   ```bash
   # Enable and start the service
   sudo systemctl daemon-reload
   sudo systemctl enable klipper-camera.service
   sudo systemctl start klipper-camera.service
   ```

### Camera Tool Setup (Separate Raspberry Pi)

1. **Install required packages:**
   ```bash
   sudo apt update
   sudo apt install python3-pip mosquitto-clients
   pip3 install flask paho-mqtt lgpio
   ```

2. **Enable camera and configure for libcamera:**
   ```bash
   sudo raspi-config
   # Interface Options → Camera → Enable
   
   # Test camera
   libcamera-still --output test.jpg --timeout 1000
   ```

3. **Install enhanced camera control scripts:**
   ```bash
   # Copy to home directory on Camera Pi
   cp camera_flask_mqtt.py ~/                    # NEW: Enhanced with calibration
   cp mqtt_unified_subscriber_fixed.py ~/
   cp start_dakash_service.py ~/
   
   # Make scripts executable
   chmod +x ~/start_dakash_service.py
   ```

4. **Configure IP addresses in scripts:**
   ```python
   # In camera_flask_mqtt.py and mqtt_unified_subscriber_fixed.py
   MQTT_BROKER = "<KLIPPER_PI_IP>"  # Your Klipper Pi IP
   
   # In camera_control.cfg
   camera0ip = "<CAMERA_PI_IP>"   # Your Camera Pi IP
   ```

5. **Set up auto-start service:**
   ```bash
   sudo nano /etc/systemd/system/dakash-camera.service
   ```
   
   ```ini
   [Unit]
   Description=Dakash Camera Tool Service
   After=network.target
   
   [Service]
   Type=simple
   User=pi
   WorkingDirectory=/home/pi
   ExecStart=/usr/bin/python3 /home/pi/start_dakash_service.py
   Restart=always
   RestartSec=5
   
   [Install]
   WantedBy=multi-user.target
   ```
   
   ```bash
   sudo systemctl enable dakash-camera.service
   sudo systemctl start dakash-camera.service
   ```

### MQTT Broker Setup (Klipper Pi)

1. **Install Mosquitto:**
   ```bash
   sudo apt install mosquitto mosquitto-clients
   sudo systemctl enable mosquitto
   sudo systemctl start mosquitto
   ```

2. **Test MQTT communication:**
   ```bash
   # Subscribe to camera status
   mosquitto_sub -h localhost -t "dakash/camera/status"
   
   # In another terminal, trigger camera status
   mosquitto_pub -h localhost -t "dakash/camera/command" -m '{"command":"status"}'
   
   # NEW: Test calibration communication
   mosquitto_sub -h localhost -t "dakash/klipper/position/response"
   mosquitto_pub -h localhost -t "dakash/klipper/position/request" -m '{"request":"current_position"}'
   ```

## Usage

### Basic Tool Operations

**Load Tools:**
```gcode
E0          # Load extruder tool 0
E1          # Load extruder tool 1  
L0          # Load liquid dispenser tool 0
C0          # Load camera tool 0
```

**Unload Current Tool:**
```gcode
A_1         # Unload currently active tool
```

### Camera Operations (C0) - Enhanced with Calibration

**Load camera tool:**
```gcode
C0               # Load camera tool
```

**Camera control via G-code:**
```gcode
# Basic camera functions
CAMERA_CAPTURE                    # Take high-res photo
CAMERA_STREAM_START              # Start video stream  
CAMERA_STREAM_STOP               # Stop video stream
CAMERA_STATUS                    # Get camera status

# Focus control (0=near, 30=far)
CAMERA_FOCUS_AUTO                # Enable autofocus
CAMERA_FOCUS_POSITION POSITION=15.5  # Set manual focus

# Resolution presets
CAMERA_PRESET_HIGH_RES           # 4656×3496 capture, 1920×1080 stream
CAMERA_PRESET_MEDIUM_RES         # 2328×1748 capture, 1280×720 stream  
CAMERA_PRESET_LOW_RES            # 1164×874 capture, 640×480 stream

# NEW: Calibration commands
REPORT_PRINTER_POSITION          # Send current position to camera
CAMERA_CAPTURE_WITH_POSITION     # Photo with coordinate data
CAMERA_CALIBRATION_WIZARD STEP=1 # Step-by-step calibration setup
CALIBRATE_EXTRUDER_OFFSETS       # Automated offset calibration
TEST_EXTRUDER_OFFSETS            # Verify current offsets

# Help information
CAMERA_HELP                      # Show all available commands
CAMERA_CALIBRATION_HELP          # Show calibration-specific help
```

**Enhanced web interface access:**
- Navigate to `http://<CAMERA_PI_IP>:8080` (camera Pi IP)
- Real-time camera control with focus slider
- Live video streaming with **click-to-coordinate mapping**
- **NEW: Calibration mode** - click on images to get printer coordinates
- **NEW: Microns-per-pixel configuration** for accurate measurements
- Image capture and viewing

**NEW: Visual Calibration Process:**
1. **Access calibration interface**: `http://<CAMERA_PI_IP>:8080`
2. **Enable calibration mode**: Click "Enable Calibration Mode"
3. **Set pixel scale**: Measure a ruler in the image to calculate microns per pixel
4. **Set reference points**: Move printer to known positions and click corresponding points in image
5. **Test accuracy**: Click on nozzle at different positions to verify coordinate mapping
6. **Calibrate extruder offsets**: Use `CALIBRATE_EXTRUDER_OFFSETS` for automated visual offset measurement

### NEW: Extruder Offset Calibration

**Automated visual calibration workflow:**
```gcode
# Step 1: Setup calibration
CAMERA_CALIBRATION_WIZARD STEP=1    # Home and prepare
CAMERA_CALIBRATION_WIZARD STEP=2    # Set up pixel scale measurement
CAMERA_CALIBRATION_WIZARD STEP=3    # Set reference points
CAMERA_CALIBRATION_WIZARD STEP=4    # Test calibration accuracy

# Step 2: Calibrate extruder offsets
CALIBRATE_EXTRUDER_OFFSETS          # Print test patterns for both extruders
# Use web interface to click on printed marks
# Calculate offsets automatically

# Step 3: Test results
TEST_EXTRUDER_OFFSETS               # Print overlapping test lines
# Verify alignment in camera image

# Step 4: Apply calculated offsets to printer.cfg
# Add calculated values to your extruder configuration
```

**Manual offset calculation:**
```gcode
# If you prefer manual calculation
SET_EXTRUDER_OFFSET_FROM_PIXELS E0_PIXEL_X=100 E0_PIXEL_Y=200 E1_PIXEL_X=105 E1_PIXEL_Y=198 MICRONS_PER_PIXEL=15.2
```

### Tool Monitoring - Enhanced Integration

**NEW: Integrated sensor monitoring (replaces shell scripts):**
```gcode
# Camera sensor checks (via integrated service)
QUERY_CAMERA_SENSORS             # Check current sensor states
CHECK_CAMERA_STATE               # Verify no error conditions  
VERIFY_CAMERA_DOCKED             # Confirm camera is properly docked
VERIFY_CAMERA_PICKED             # Confirm camera is on carriage

# Service diagnostics
CAMERA_SERVICE_STATUS            # Check integrated service health
```

### Tool Calibration

**Dock Position Calibration:**
```gcode
# Camera dock calibration (enhanced)
CALC_CAMERADOCK_LOCATION         # Camera-specific dock calibration

# Other tool dock calibration  
CALC_DOCK_LOCATION TOOL_ID="e0"  # Calibrate extruder 0
CALC_DOCK_LOCATION TOOL_ID="e1"  # Calibrate extruder 1
CALC_DOCK_LOCATION TOOL_ID="l0"  # Calibrate liquid dispenser
```

## Configuration

### NEW: Camera Calibration Settings

The system now includes advanced calibration capabilities stored in `/home/pi/calibration/calibration.json`:

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

### Tool Dock Coordinates

Tool dock positions are stored in `variables.cfg` and can be updated manually or via calibration:

```ini
# Camera tool dock (C0)
c0_dock_x = 145.82
c0_dock_y = 450.81
c0_dock_z = 30.0
c0_unlock_x = 133.82
c0_unlock_y = 450.21

# Extruder tool docks (E0, E1)  
e0_dock_x = 226.08
e0_dock_y = 459.62
# ... additional coordinates

# Liquid dispenser dock (L0)
l0_dock_x = 373.53
l0_dock_y = 450.98
# ... additional coordinates
```

### Network Configuration

**IP Address Settings:**
- Klipper Pi (MQTT Broker): `<KLIPPER_PI_IP>`
- Camera Pi: `<CAMERA_PI_IP>`
- Camera Web Interface: Port `8080`

Update these in:
- `camera_control.cfg` → `camera0ip` variable
- `camera_flask_mqtt.py` → `MQTT_BROKER` setting
- `mqtt_unified_subscriber_fixed.py` → `MQTT_BROKER` setting

## NEW: Calibration System Architecture

### Service Integration

**OLD: Multiple separate services and scripts**
```
check_camera.sh → Shell script execution
Multiple MQTT topics → Camera Pi
Manual coordinate measurement
```

**NEW: Integrated service architecture**
```
klipper_camera_service.py → Unified MQTT communication
├── Position requests/responses for calibration
├── Sensor status monitoring (replaces shell scripts)
├── Error detection with automatic print pausing
└── File-based position reporting for reliability
```

### MQTT Topics (Enhanced)

**Position and Calibration:**
- `dakash/klipper/position/request` - Request printer position
- `dakash/klipper/position/response` - Printer position data
- `dakash/camera/calibration` - Calibration data exchange

**Camera Control:**
- `dakash/camera/command` - Camera control commands
- `dakash/camera/config` - Camera configuration updates
- `dakash/camera/status` - Camera status updates

**Sensor Monitoring:**
- `dakash/gpio/sensors/request` - Sensor status requests
- `dakash/gpio/sensors/status` - Sensor status responses

## Safety Features

### Tool State Validation

**Enhanced Sensor Monitoring:**
- Each tool has dock and carriage sensors
- **NEW: Integrated Python service** provides more reliable monitoring than shell scripts
- Invalid states trigger error conditions and pause prints
- **NEW: Automatic error detection** with print pausing

**Error Detection:**
- Tool not properly docked/mounted
- Communication failures (MQTT, CAN bus)
- Sensor inconsistencies
- Tool change verification failures
- **NEW: Position reporting failures** during calibration

## Troubleshooting

### NEW: Camera Calibration Issues

**Position Service Problems:**
```bash
# Check integrated service status
sudo systemctl status klipper-camera

# View service logs
sudo journalctl -u klipper-camera -f

# Test position reporting
mosquitto_pub -h <KLIPPER_PI_IP> -t "dakash/klipper/position/request" -m '{"request":"current_position"}'
mosquitto_sub -h <KLIPPER_PI_IP> -t "dakash/klipper/position/response" -v
```

**Calibration Accuracy Issues:**
1. **Check pixel scale**: Ensure accurate microns-per-pixel measurement
2. **Verify reference points**: Use multiple points across the work area
3. **Camera focus**: Ensure proper focus before calibration
4. **Check coordinate conversion**: Test known positions

**MQTT Communication:**
```bash
# Test camera sensor communication
mosquitto_pub -h <KLIPPER_PI_IP> -t "dakash/gpio/sensors/request" -m "status"
mosquitto_sub -h <KLIPPER_PI_IP> -t "dakash/gpio/sensors/status" -v

# Test camera control
mosquitto_pub -h <KLIPPER_PI_IP> -t "dakash/camera/command" -m '{"command":"status"}'
```

### Common Issues

**Tool Change Failures:**
1. Check tool dock calibration: `CALC_DOCK_LOCATION TOOL_ID="xx"`
2. Verify sensor readings: `DEBUG_SENSOR_STATES`
3. Inspect LED status for visual feedback
4. Check tool dock mechanical alignment

**Camera Tool Issues:**
1. Verify MQTT broker running: `sudo systemctl status mosquitto`
2. Check camera Pi service: `sudo systemctl status dakash-camera`
3. **NEW: Check integrated service**: `sudo systemctl status klipper-camera`
4. Test camera hardware: `libcamera-still --output test.jpg`
5. Check network connectivity between Pis

### Diagnostic Commands

**System Status:**
```gcode
DEBUG_SENSOR_STATES          # Show all sensor readings
CHECK_MACHINE_STATE          # Overall system status  
CAMERA_STATUS               # Camera system status
QUERY_CAMERA_SENSORS        # NEW: Camera sensor status via integrated service
CAMERA_SERVICE_STATUS       # NEW: Check integrated service health
```

**NEW: Calibration Diagnostics:**
```gcode
CAMERA_CALIBRATION_HELP      # Show calibration commands
REPORT_PRINTER_POSITION      # Test position reporting
CAMERA_CAPTURE_WITH_POSITION # Test position-aware capture
```

## Advanced Features

### NEW: Pixel-to-Printer Coordinate System

**Visual Calibration Capabilities:**
- Click anywhere in camera image to get printer coordinates
- Configurable pixel-to-millimeter conversion ratios
- Multiple reference point support for improved accuracy
- Real-time coordinate conversion via web interface

**Integration with Toolchanger:**
- Visual measurement of extruder offsets
- Click-based coordinate input for calibration
- Automated test pattern generation
- Direct integration with Klipper's coordinate system

### Research Applications

**Multi-Modal Manufacturing:**
- Print → Image → Dispense → Analysis workflows
- **NEW: Visual quality control** with pixel-level measurements
- **NEW: Automated extruder offset correction** using camera feedback
- In-situ liquid application during printing
- Real-time process monitoring and adjustment

**Enhanced Liquid Handling:**
- Precision dispensing (μL quantities)
- Multiple liquid types via wash station
- Automated pipette tip changing
- Integration with microfluidics protocols

## Migration from Previous Versions

### Upgrading to Calibration System

If upgrading from a previous version:

1. **Backup existing configs:**
   ```bash
   cp camera_control.cfg camera_control.cfg.backup
   cp camera_monitor.cfg camera_monitor.cfg.backup
   ```

2. **Install new files:**
   - Replace `camera_flask_mqtt.py` with enhanced version
   - Install `klipper_camera_service.py` on Klipper Pi
   - Add `camera_calibration.cfg` to your config

3. **Update includes in printer.cfg:**
   ```ini
   # Remove or comment out:
   # [include camera_state_detection.cfg]
   
   # Add:
   [include camera_calibration.cfg]
   ```

4. **Test new functionality:**
   ```gcode
   # Test position publishing
   G0 X200 Y150 Z100    # Move to known position  
   REPORT_PRINTER_POSITION  # Should save to variables.cfg and publish via MQTT
   
   # Optional: Test sensor monitoring
   CAMERA_SERVICE_STATUS        # If using integrated service
   CAMERA_CALIBRATION_WIZARD    # Test calibration system
   ```

## License

*Specify your license here (MIT, GPL, Apache, etc.)*

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test thoroughly with the multi-modal system
4. Submit a pull request with detailed description

### Development Guidelines

- Follow Klipper configuration conventions
- Test all tool types when making changes
- **NEW: Test calibration functionality** when modifying camera system
- Update documentation for new features
- Maintain backward compatibility where possible

## Acknowledgments

- Klipper firmware team for the excellent foundation
- BTT for CAN bus toolboard development  
- Arducam for programmable focus camera modules
- MQTT and Flask communities for communication tools
- Contributors to the toolchanger and liquid handling communities

## Support

- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check this README and configuration comments
- **Community**: Share improvements and modifications

---

**Rister Multi-Modal Toolchanger** - Advancing multi-protocol manufacturing through integrated FDM, liquid handling, and imaging capabilities with native **Klipper firmware** integration and **advanced visual calibration systems**.

*Last updated: September 2025*
