# Multi-Modal Toolchanger CAD Design

This directory contains the complete CAD design files for the Rister Multi-Modal Toolchanger system, including mechanical components and tool designs.

## Overview

The CAD files consist of STL meshes and designs created using **OpenSCAD** and assembled in **FreeCAD**. The system features three distinct tool types integrated into a modified gantry design optimized for multi-modal manufacturing.

## Design Tools

- **Primary Design**: OpenSCAD for parametric modeling
- **Assembly**: FreeCAD for complete system integration
- **Output**: STL files ready for 3D printing

## Tool Designs

### 1. FDM Extruder Tool

**Base Design**: Modified Lineux One extruder design  
**Hotend**: Bambu Lab Hotend with Nozzle (X1/P1 Series compatible)

**Key Modifications:**
- **Custom Air Duct**: Enhanced cooling performance for the Bambu Lab hotend
- **Modified Klicky Probe**: Integrated probe system for tool-specific Z-offset calibration
  - Based on: [PCB Klicky] (https://github.com/tanaes/whopping_Voron_mods/tree/main/pcb_klicky)
- **LED Holder**: Status indication and illumination
- **Umbilical Management**: 0.35" wide zip tie clamps for cable organization
- **Filament Sensor**: Modified Tircown design using ERCF PCB
  - Based on: [Tircown Filament Motion Sensor](https://github.com/Tircown/VoronFrenchUsers/tree/main/Mod/Filament_motion_sensor)
  - Hardware: Blinky ERCF PCB integration
- **Magnetic Air Duct**: Detachable carriage-mounted duct for directed airflow to nozzle

**Features:**
- Direct hotend cooling optimization
- Tool change compatibility
- Integrated sensor feedback
- Professional cable management

### 2. Liquid Dispenser Tool

**Core Components**: Linear actuator with precision pipette handling

**Pipette System:**
- **Linear Actuator**: Automated pipette tip loading/unloading
- **Pipette Holder**: Secure mounting with precise positioning
- **3-Way Valve System**:
  - **Input**: Aspiration into pipette (sample loading)
  - **Output**: Liquid dispensing
  - **Bypass**: Valve closure for system isolation

**Fluid Control System:**
- **Syringe Pump**: Precision volume control
- **Pressure Compensation Vessel (PCV)**: Maintains consistent liquid levels
- **Liquid Level Sensor**: Automated level monitoring
- **Peristaltic Pump**: Automatic PCV refilling when levels drop
- **Microcontroller Integration**: Automated fluid management

**Wash Station:**
- **Pipette Washing**: Automated cleaning cycles
- **Waste Management**: Integrated waste collection and disposal

**Capabilities:**
- Automated pipette tip handling
- Precision liquid dispensing (μL accuracy)
- Self-maintaining fluid levels
- Contamination prevention through washing

### 3. Camera Tool

**Hardware**: Raspberry Pi with programmable focus camera system

**Camera System:**
- **Camera Module**: Arducam programmable focusing camera
- **Control System**: Raspberry Pi integration
- **Web Interface**: Real-time viewing and focus adjustment
- **Focus Range**: 0-30 programmatic control (near to far)

**Features:**
- **Real-time Imaging**: Live video streaming
- **Programmable Focus**: Software-controlled focus adjustment
- **Web Service**: Browser-based control interface
- **Tool Integration**: Coordinated with toolchanger system

**Applications:**
- Quality control imaging
- Process monitoring
- Part inspection
- Documentation and analysis

## Gantry Modifications

### Enhanced Z-Axis System

**Upgrade**: 4 Z-motors instead of standard 3-motor configuration

**Benefits:**
- **Increased Stability**: Enhanced rigidity during tool loading operations
- **Improved Tool Clearance**: More room for complex tool geometries
- **Better Load Distribution**: Reduced stress on individual motors
- **Enhanced Precision**: More consistent bed leveling and positioning

### Custom Limit Switch Mounts

**Design**: Custom XY limit switch mounting system
- Optimized for multi-tool clearance
- Enhanced positioning accuracy
- Improved accessibility for maintenance

### Enhanced Motor Mounts

**Upgrade**: Custom CoreXY motor mounts for improved stability
- **Reference**: [Discord Discussion](https://discord.com/channels/1226812716514021460/1320071538925637642/1320073292857479281)
- **Improvement**: Superior stability compared to standard Voron motor mounts
- **Design**: Optimized for multi-modal tool loads and precision

### Gantry Sizing

**Optimization**: Gantry dimensions specifically designed for multi-modal tool accommodation
- **Tool Clearance**: Adequate space for all three tool types
- **Dock Integration**: Optimized dock spacing and accessibility
- **Cable Management**: Routing considerations for multiple tool types
- **Maintenance Access**: Easy tool servicing and calibration

## File Structure

```
cad/
├── README.md                          # This file
|── freecad/                          # FreeCAD assembly files
    ├── rister-toolchanger-complete.FCStd

## STL File Generation

**All 3D printable components are generated from the FreeCAD files** rather than stored as individual STL files.

### Exporting STL Files from FreeCAD

1. **Open the FreeCAD assembly file** (`rister-toolchanger-complete.FCStd`)
2. **Select the component** you want to print in the model tree
3. **File → Export** or right-click → **Export**
4. **Choose STL format** and save to your desired location
5. **Repeat for each component** you need to manufacture

### Recommended Export Organization

When exporting STLs for manufacturing, organize them by category:

```
your-stl-exports/
├── tools/
│   ├── fdm-extruder/
│   ├── liquid-dispenser/
│   └── camera-tool/
├── gantry/
│   ├── z-motor-mounts/
│   ├── xy-limit-switches/
│   └── corexy-motor-mounts/
└── accessories/
```

## Design Philosophy

### Multi-Modal Integration

The design prioritizes seamless integration between three distinct manufacturing paradigms:
- **Subtractive**: Material removal and shaping
- **Additive**: Layer-by-layer material deposition  
- **Analytical**: Real-time imaging and inspection

### Modularity

Each tool is designed as an independent module with:
- **Standardized Interfaces**: Common mounting and electrical connections
- **Individual Optimization**: Tool-specific performance enhancements
- **Easy Maintenance**: Accessible components and replaceable parts

### Precision Engineering

All components are designed for:
- **Micron-level Accuracy**: Precision positioning and repeatability
- **Thermal Stability**: Materials and designs for temperature consistency
- **Vibration Damping**: Reduced resonance and improved print quality

## Manufacturing Notes

### 3D Printing Requirements

**Material Recommendations:**
- **Structural Components**: PETG or ABS for strength and temperature resistance
- **Precision Parts**: PLA+ for dimensional accuracy (non-heated components)

**Print Settings:**
- **Layer Height**: 0.2mm for structural components, 0.1mm for precision parts
- **Infill**: 30-50% depending on stress requirements
- **Support**: Required for overhangs >45°

### Post-Processing

**Critical Dimensions:**
- Ream holes for precise fits
- Sand contact surfaces for smooth operation
- Check fit before final assembly

## Assembly Instructions

### Tool Assembly Order

1. **FDM Extruder**: Start with hotend integration, then add sensors and ducting
2. **Liquid Dispenser**: Assemble actuator system, then integrate fluid components
3. **Camera Tool**: Mount camera system, then integrate with toolchanger interface

### Gantry Modifications

1. **Z-Motor Upgrade**: Install 4th Z-motor and update firmware configuration
2. **Limit Switches**: Install custom XY limit switch mounts
3. **Motor Mounts**: Replace CoreXY motor mounts with enhanced versions

## Maintenance

### Regular Service Points

- **Linear Actuator**: Lubricate and check alignment monthly
- **Valve System**: Clean and test operation quarterly
- **Camera Focus**: Calibrate and test focus range monthly
- **Motor Mounts**: Check bolt torque and alignment quarterly

### Replacement Parts

Common wear items and replacement intervals:
- **Pipette Tips**: Replace as needed (single-use or cleanable)
- **Valve Seals**: Replace annually or as needed
- **Linear Actuator Bushings**: Replace every 6-12 months
- **Camera Lens**: Clean regularly, replace if damaged

## References

### Source Projects

- **Lineux One**: Base extruder design
- **Bambu Lab**: Hotend and nozzle compatibility
- **Tircown Filament Sensor with Blinky ERCF PCB**: [GitHub Repository](https://github.com/Tircown/VoronFrenchUsers/tree/main/Mod/Filament_motion_sensor)
- **Voron Design**: Base printer architecture
- **Enhanced Motor Mounts**: [Discord Discussion](https://discord.com/channels/1226812716514021460/1320071538925637642/1320073292857479281)

### Design Tools

- **OpenSCAD**: [openscad.org](https://openscad.org/)
- **FreeCAD**: [freecadweb.org](https://www.freecadweb.org/)

## Contributing

When contributing CAD modifications:

1. **Use OpenSCAD** for parametric components when possible
2. **Maintain FreeCAD assembly** for overall system integration
3. **Test print** all modified components before submission
4. **Document changes** in commit messages and pull requests
5. **Update this README** when adding new components or features

## License

CAD files are released under the same license as the main project. See the main repository LICENSE file for details.

---

*The Rister Multi-Modal Toolchanger CAD design represents a comprehensive approach to integrating multiple manufacturing technologies into a single, cohesive platform.*
