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

