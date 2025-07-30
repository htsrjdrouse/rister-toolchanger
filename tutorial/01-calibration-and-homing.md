# Tool Calibration and Homing

**Video Tutorial:**

[![Rister Toolchanger - Tool Calibration and Homing](https://img.youtube.com/vi/rcP2ZRtmrNg/0.jpg)](https://www.youtube.com/watch?v=rcP2ZRtmrNg)

*Click the thumbnail above to watch the video tutorial*

This tutorial covers the essential first steps for setting up your Rister Toolchanger: proper homing procedures and tool calibration. These steps are critical for safe and accurate operation.

## Overview

Tool calibration establishes the precise dock positions and tool offsets that enable reliable automated tool changes. This process must be completed before any printing operations.

## Prerequisites

- ✅ Rister Toolchanger mechanically assembled
- ✅ Klipper firmware installed with Rister toolchanger extension
- ✅ Basic printer configuration completed
- ✅ All tools physically present and accessible

## Safety First

⚠️ **Always perform these steps in order:**
1. Emergency stop accessible and tested
2. Manual tool positioning confirmed safe
3. Endstops verified functional
4. Clear workspace around tool dock area

## Step 1: Initial System Homing

### Manual Verification
Before any automated movements:
1. **Check endstop functionality** - Test each endstop manually
2. **Verify safe travel paths** - Ensure no obstructions between dock and print area
3. **Confirm tool accessibility** - All tools should be reachable and properly seated

### Homing Sequence
```gcode
# Basic system homing
G28
```

**What happens during homing:**
- X, Y, and Z axes move to their endstop positions
- System establishes coordinate reference points
- Tool detection sensors are initialized (if equipped)

### Verification
After homing, verify:
- All axes report correct positions
- No error messages in console
- Toolhead is in expected home position

## Step 2: Tool Dock Calibration

### Understanding Dock Positions

Each tool requires precise dock coordinates for reliable pickup and dropoff. The Rister system uses camera-assisted calibration for maximum accuracy.

### Camera-Assisted Dock Calibration

**For each tool (E0, E1, etc.):**

```gcode
# Calibrate dock location for extruder 0
CALC_DOCK_LOCATION tool_id=e0

# Calibrate dock location for extruder 1  
CALC_DOCK_LOCATION tool_id=e1

# For other tools, use appropriate tool IDs
CALC_DOCK_LOCATION tool_id=l0    # Liquid handler tool
CALC_DOCK_LOCATION tool_id=c0    # Camera tool
```

### Calibration Process

1. **Position camera** - System automatically moves camera tool over the specified dock
2. **Visual detection** - Camera identifies dock markers or alignment features
3. **Calculate coordinates** - System determines precise X/Y dock position
4. **Store values** - Coordinates are saved to tool configuration

### Manual Dock Position Setup (Alternative)

If camera calibration is not available, dock positions can be set manually:

```gcode
# Move to dock area manually
G0 X[dock_x] Y[dock_y] Z[safe_z]

# Fine-tune position using small incremental moves
G91  # Relative positioning
G0 X0.1  # Move 0.1mm in X
G0 Y-0.1 # Move -0.1mm in Y
G90  # Back to absolute positioning

# When position is perfect, save coordinates
# Update your configuration with the current position
```

## Step 3: Verification and Testing

### Test Tool Changes

```gcode
# Test basic tool pickup/dropoff
E0    # Pick up extruder tool 0
A_1   # Return tool to dock
E1    # Pick up extruder tool 1  
A_1   # Return tool to dock
L0    # Pick up liquid handler tool
A_1   # Return tool to dock
C0    # Pick up camera tool
A_1   # Return tool to dock
```

### Verify Tool States

**For extruder and liquid handler tools (E0, E1, L0):**
These tools use direct hardware sensor feedback through Klipper GPIO pins:
```gcode
# Verify tool is properly docked
VERIFY_TOOL_STATE tool_id=E0 dock=PRESSED carriage=RELEASED
VERIFY_TOOL_STATE tool_id=E1 dock=PRESSED carriage=RELEASED
VERIFY_TOOL_STATE tool_id=L0 dock=PRESSED carriage=RELEASED
```

**For camera tool (C0) - uses MQTT communication:**
The camera tool communicates through MQTT messaging rather than direct pin sensing:
```gcode
# Verify camera tool is properly connected to carriage
VERIFY_TOOL_PICKUP_C0

# Verify camera tool is properly docked
VERIFY_TOOL_DOCKED_C0
```

**Technical difference:**
- **E0, E1, L0**: Klipper directly reads dock/carriage sensor pins for immediate hardware feedback
- **C0**: Status communicated via MQTT messages, allowing wireless/network-based tool state reporting

**Sensor states for E0, E1, L0:**
- `dock=PRESSED` - Tool is detected in dock position via hardware sensor
- `carriage=RELEASED` - Tool is not detected on carriage via hardware sensor
- This combination confirms proper docking through direct pin sensing

### Verify Calibration

**Check dock alignment:**
- Tools should dock smoothly without binding
- No mechanical stress during pickup/dropoff
- Consistent electrical contact (if applicable)

**Check offsets:**
- Print small test objects with each tool
- Verify alignment and first layer quality
- Adjust offsets if needed

## Next Steps

After completing basic calibration:
1. **Docking and Undocking Tutorial** - Learn detailed tool change procedures
2. **Tool-Specific Operations** - Individual tool setup and usage
3. **Advanced Calibration** - Camera-based offset measurement and fine-tuning