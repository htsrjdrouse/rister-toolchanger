Tool Calibration and Homing
Video: [YouTube Link Coming Soon]
This tutorial covers the essential first steps for setting up your Rister Toolchanger: proper homing procedures and tool calibration. These steps are critical for safe and accurate operation.
Overview
Tool calibration establishes the precise dock positions and tool offsets that enable reliable automated tool changes. This process must be completed before any printing operations.
Prerequisites

✅ Rister Toolchanger mechanically assembled
✅ Klipper firmware installed with Rister toolchanger extension
✅ Basic printer configuration completed
✅ All tools physically present and accessible

Safety First
⚠️ Always perform these steps in order:

Emergency stop accessible and tested
Manual tool positioning confirmed safe
Endstops verified functional
Clear workspace around tool dock area

Step 1: Initial System Homing
Manual Verification
Before any automated movements:

Check endstop functionality - Test each endstop manually
Verify safe travel paths - Ensure no obstructions between dock and print area
Confirm tool accessibility - All tools should be reachable and properly seated

Homing Sequence
gcode# Basic system homing
G28
What happens during homing:

X, Y, and Z axes move to their endstop positions
System establishes coordinate reference points
Tool detection sensors are initialized (if equipped)

Verification
After homing, verify:

All axes report correct positions
No error messages in console
Toolhead is in expected home position

Step 2: Tool Dock Calibration
Understanding Dock Positions
Each tool requires precise dock coordinates for reliable pickup and dropoff. The Rister system uses camera-assisted calibration for maximum accuracy.
Camera-Assisted Dock Calibration
For each tool (E0, E1, etc.):
gcode# Calibrate dock location for extruder 0
CALC_DOCK_LOCATION tool_id=e0

# Calibrate dock location for extruder 1  
CALC_DOCK_LOCATION tool_id=e1

# For other tools, use appropriate tool IDs
CALC_DOCK_LOCATION tool_id=l0    # Liquid handler tool
CALC_DOCK_LOCATION tool_id=c0    # Camera tool
Calibration Process

Position camera - System automatically moves camera tool over the specified dock
Visual detection - Camera identifies dock markers or alignment features
Calculate coordinates - System determines precise X/Y dock position
Store values - Coordinates are saved to tool configuration

Manual Dock Position Setup (Alternative)
If camera calibration is not available, dock positions can be set manually:
gcode# Move to dock area manually
G0 X[dock_x] Y[dock_y] Z[safe_z]

# Fine-tune position using small incremental moves
G91  # Relative positioning
G0 X0.1  # Move 0.1mm in X
G0 Y-0.1 # Move -0.1mm in Y
G90  # Back to absolute positioning

# When position is perfect, save coordinates
# Update your configuration with the current position
Step 3: Tool Offset Calibration
Z-Offset Calibration
Each tool requires individual Z-offset calibration to ensure proper first layer height:
gcode# Select tool for calibration
T0  # or T1, T2, etc.

# Perform Z-offset calibration
# Method depends on your probe type:

# For contact probes:
PROBE_CALIBRATE

# For inductive probes:
Z_ENDSTOP_CALIBRATE

# Save results
SAVE_CONFIG
XY Offset Calibration
Using the camera method (covered in advanced tutorials):

Print calibration targets with each extruder
Use camera tool to measure relative positions
Calculate and apply XY offsets

Manual method:
gcode# Print test objects with each tool at same coordinates
# Measure physical offset between printed objects
# Update tool configuration manually
Step 4: Verification and Testing
Test Tool Changes
gcode# Test basic tool pickup/dropoff
T0    # Pick up tool 0
T-1   # Return tool to dock
T1    # Pick up tool 1  
T-1   # Return tool to dock
Verify Tool States
Use the verification macro to check tool sensor states:
gcode# Verify tool is properly docked
VERIFY_TOOL_STATE tool_id=e0 dock=PRESSED carriage=RELEASED

# Check other tools
VERIFY_TOOL_STATE tool_id=e1 dock=PRESSED carriage=RELEASED
VERIFY_TOOL_STATE tool_id=l0 dock=PRESSED carriage=RELEASED
VERIFY_TOOL_STATE tool_id=c0 dock=PRESSED carriage=RELEASED
Sensor states:

dock=PRESSED - Tool is detected in dock position
carriage=RELEASED - Tool is not detected on carriage
This combination confirms proper docking

Verify Calibration
Check dock alignment:

Tools should dock smoothly without binding
No mechanical stress during pickup/dropoff
Consistent electrical contact (if applicable)

Check offsets:

Print small test objects with each tool
Verify alignment and first layer quality
Adjust offsets if needed
