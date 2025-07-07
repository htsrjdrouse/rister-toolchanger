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

