# Klicky Probe Bed Leveling

**Video Tutorial:**
[![Rister Toolchanger - Klicky Probe Bed Leveling](https://img.youtube.com/vi/WLuoEnq4lEo/0.jpg)](https://www.youtube.com/watch?v=WLuoEnq4lEo)

*Click the thumbnail above to watch the video tutorial*

This tutorial covers how to use the Klicky probe system with your Rister Toolchanger for automated bed leveling and mesh generation. The Klicky probe attaches to the E0 extruder tool for precise Z-axis measurements.

## Overview

The Klicky probe system provides automated bed leveling capabilities by temporarily attaching a magnetic probe to your E0 extruder tool. This allows for accurate bed mesh generation and Z-offset calibration without permanent probe mounting.

## Prerequisites

- ✅ Rister Toolchanger calibrated and homed (see [Tool Calibration and Homing](01-calibration-and-homing.md))
- ✅ Klicky probe hardware installed and accessible
- ✅ E0 extruder tool properly configured
- ✅ `tool_probe.cfg` included in printer configuration

## Configuration Setup

### Tool Probe Configuration

Add the following configuration to your `tool_probe.cfg` file:

```ini
[tool_probe T0]
pin: EBB1:PB8              # Probe signal pin
tool: 1                    # Associated tool number
x_offset: 27.5             # Probe X offset from nozzle
y_offset: 0                # Probe Y offset from nozzle  
z_offset: 3.15             # Probe Z offset (calibrated)
speed: 5                   # Probing speed
samples: 1                 # Number of samples per point
samples_result: median     # How to process multiple samples
sample_retract_dist: 5     # Distance to retract between samples
samples_tolerance: 0.075   # Acceptable tolerance between samples
samples_tolerance_retries: 3  # Retry attempts if tolerance exceeded
```

### Include in Printer Configuration

Make sure to include the probe configuration in your `printer.cfg`:

```ini
[include tool_probe.cfg]
```

## Safety First

⚠️ **Before using the Klicky probe:**
1. Ensure E0 tool is properly calibrated and functional
2. Verify probe pickup/dropoff area is clear of obstructions  
3. Check that bed surface is clean and level
4. Confirm probe attachment mechanism is working smoothly

## Step 1: Klicky Probe Commands

### Basic Probe Operations

The Rister system provides two main commands for Klicky probe operation:

```gcode
# Load the Klicky probe onto E0 tool
KLICKY_PROBE_LOAD

# Unload the Klicky probe from E0 tool  
KLICKY_PROBE_UNLOAD
```

### Command Sequence

A typical probing session follows this pattern:
1. **Load probe** - Attach Klicky probe to E0
2. **Perform measurements** - Execute bed leveling commands
3. **Unload probe** - Return Klicky probe to storage

## Step 2: Manual Probe Testing

### Initial Probe Test

Before automated bed leveling, verify probe functionality:

```gcode
# Ensure system is homed
G28

# Load the Klicky probe
KLICKY_PROBE_LOAD

# Verify probe is attached and functional
PROBE_ACCURACY

# Test single probe point
PROBE

# Unload probe when testing complete
KLICKY_PROBE_UNLOAD
```

### Verify Probe Response

During testing, confirm:
- Probe triggers reliably when contacting bed
- Z-offset is accurate (nozzle-to-bed distance)
- No mechanical interference during attachment/detachment
- Consistent probe readings across multiple samples

## Step 3: Bed Mesh Calibration

### Generate Bed Mesh

```gcode
# Home all axes
G28

# Load Klicky probe
KLICKY_PROBE_LOAD

# Generate bed mesh (adjust parameters as needed)
BED_MESH_CALIBRATE

# Unload probe
KLICKY_PROBE_UNLOAD

# Save the mesh
SAVE_CONFIG
```

### Mesh Parameters

Common bed mesh settings (add to `printer.cfg`):

```ini
[bed_mesh]
speed: 120
horizontal_move_z: 10
mesh_min: 35, 6
mesh_max: 340, 351
probe_count: 5, 3
```

## Step 4: Z-Offset Calibration

### Calibrate Probe Z-Offset

```gcode
# Home system
G28

# Load probe
KLICKY_PROBE_LOAD

# Start calibration process
PROBE_CALIBRATE

# Follow on-screen prompts to adjust Z-offset
# Use paper test method for final adjustment

# Save results
SAVE_CONFIG

# Unload probe
KLICKY_PROBE_UNLOAD
```

### Fine-Tuning Z-Offset

For precise first layer calibration:
1. **Paper test** - Slide paper between nozzle and bed
2. **Adjust offset** - Increase/decrease until proper resistance felt
3. **Test print** - Print calibration square to verify height
4. **Iterate** - Repeat adjustment if needed

## Step 5: Automated Bed Leveling Routine

### Create Leveling Macro

Add this macro to your configuration for automated bed leveling:

```gcode
[gcode_macro BED_LEVEL_ROUTINE]
gcode:
    # Home all axes
    G28
    
    # Load Klicky probe
    KLICKY_PROBE_LOAD
    
    # Generate fresh bed mesh
    BED_MESH_CALIBRATE
    
    # Unload probe
    KLICKY_PROBE_UNLOAD
    
    # Load the mesh
    BED_MESH_PROFILE LOAD=default
    
    M117 Bed leveling complete
```

### Usage in Print Start

Include bed leveling in your print start routine:

```gcode
[gcode_macro PRINT_START]
gcode:
    # ... other start commands ...
    
    # Perform bed leveling
    BED_LEVEL_ROUTINE
    
    # ... continue with print preparation ...
```

## Step 6: Verification and Testing

### Test Probe Attachment

```gcode
# Test multiple load/unload cycles
KLICKY_PROBE_LOAD
G4 P1000  # Wait 1 second
KLICKY_PROBE_UNLOAD
G4 P1000
# Repeat several times to verify reliability
```

### Verify Bed Mesh Quality

After mesh generation:
1. **Review mesh data** - Check for consistent measurements across bed
2. **Look for outliers** - Identify any anomalous probe points  
3. **Validate coverage** - Ensure mesh covers entire print area
4. **Test first layer** - Print test object to verify leveling accuracy

## Troubleshooting

### Probe Attachment Issues
- **Symptom:** Probe fails to attach reliably
- **Solution:** Check magnetic connection, clean attachment surfaces
- **Prevention:** Regular maintenance of probe mechanism

### Inconsistent Readings
- **Symptom:** Probe readings vary significantly
- **Solution:** Increase samples count, check bed surface cleanliness
- **Prevention:** Maintain consistent bed temperature, clean probe tip

### Z-Offset Drift
- **Symptom:** First layer height changes over time
- **Solution:** Re-calibrate probe Z-offset, check mechanical stability
- **Prevention:** Regular calibration checks, proper probe storage

## Configuration Reference

### Complete Tool Probe Section

```ini
[tool_probe T0]
pin: EBB1:PB8
tool: 1
x_offset: 27.5
y_offset: 0
z_offset: 3.15
speed: 5
samples: 1
samples_result: median
sample_retract_dist: 5
samples_tolerance: 0.075
samples_tolerance_retries: 3
```

## Next Steps

After mastering Klicky probe bed leveling:
1. **Camera Tool Operations** - Learn focus and positioning techniques
2. **Multi-Tool Workflows** - Combine probing with printing operations
3. **Advanced Calibration** - Camera-based offset measurement techniques

## Essential Commands Reference

```gcode
# Basic probe operations
KLICKY_PROBE_LOAD        # Attach probe to E0
KLICKY_PROBE_UNLOAD      # Remove probe from E0

# Calibration commands  
PROBE_CALIBRATE          # Z-offset calibration
BED_MESH_CALIBRATE       # Generate bed mesh
PROBE_ACCURACY           # Test probe repeatability

# Verification
PROBE                    # Single probe measurement
BED_MESH_PROFILE LOAD=default  # Load saved mesh
```
