# Rister Toolchanger Tutorials

This directory contains step-by-step video tutorials demonstrating how to use the Rister Toolchanger system effectively. Each tutorial focuses on specific operational aspects, from basic setup to advanced automation techniques.

## Purpose

These tutorials are designed to:
- **Reduce setup time** for new users by providing visual guidance
- **Demonstrate best practices** for tool calibration and operation
- **Show real-world applications** of the toolchanger system
- **Troubleshoot common issues** through practical examples
- **Inspire creative uses** of the multi-tool capabilities

## Tutorial Structure

Each tutorial includes:
- **Video demonstration** with clear narration
- **Written summary** of key steps and parameters
- **Configuration examples** and code snippets where applicable
- **Troubleshooting tips** for common problems
- **Links to relevant documentation** and resources

## Available Tutorials

### 🎯 **Basic Operations**

#### 1. [Tool Calibration and Homing](01-calibration-and-homing.md)
**Video:** `01-calibration-and-homing.md`
- Initial system setup and safety checks
- Homing sequence and endstop verification
- Tool offset calibration procedures
- Z-probe offset configuration
- Tool docking and undocking procedures  
- Verification and testing methods

### 🔧 **Tool-Specific Operations**

#### 2. [Klicky Probe Bed Leveling](02-klicky-bed-leveling.md)
**Video:** `02-klicky-bed-leveling.md`
- Klicky probe setup and calibration
- Automated bed mesh generation
- Manual probing techniques
- Interpreting mesh data and corrections

#### 3. Camera Tool Focus and Positioning
**Video:** `03-camera-focus-positioning.md`
- Camera tool mounting and alignment
- Manual focus adjustment techniques
- Automated focus routines
- Object detection and positioning

#### 4. Linear Actuator Pipette Operations
**Video:** `04-pipette-operations.md`
- Pipette tool setup and calibration
- Liquid loading and dispensing procedures
- Volume accuracy and repeatability
- Cleaning and maintenance protocols

### 🚀 **Advanced Techniques**

#### 5. Camera-Based Extruder Offset Calibration
**Video:** `05-camera-offset-calibration.md`
- 3D printing calibration targets
- Computer vision setup and operation
- Automated offset measurement
- Integration with Klipper configuration

#### 6. Multi-Tool Workflow Automation
**Video:** `06-multi-tool-workflows.md`
- Chaining multiple tool operations
- Creating custom G-code macros
- Error handling and recovery procedures
- Optimizing tool change sequences

#### 7. Custom Tool Integration
**Video:** `07-custom-tool-integration.md`
- Designing tool interfaces
- Electrical integration guidelines
- Software configuration for new tools
- Testing and validation procedures

### 🛠️ **Maintenance and Troubleshooting**

#### 8. System Maintenance
**Video:** `08-system-maintenance.md`
- Regular cleaning procedures
- Lubrication schedules and techniques
- Wear indicator monitoring
- Replacement part installation

#### 9. Common Issues and Solutions
**Video:** `09-troubleshooting.md`
- Tool detection failures
- Calibration drift problems
- Mechanical alignment issues
- Software configuration errors

## Quick Reference

### Essential Commands
```gcode
# Basic homing
G28

# Tool pickup
T0  # Pick up tool 0
T1  # Pick up tool 1

# Tool return
T-1 # Return current tool to dock

# Emergency tool drop
M84  # Disable steppers (manual tool removal)
```

### Safety Reminders
- ⚠️ Always home the system before tool operations
- ⚠️ Ensure proper tool docking before starting prints
- ⚠️ Keep the tool dock area clear of obstructions
- ⚠️ Verify tool detection after each pickup/drop

## Contributing

Found an issue or have suggestions for additional tutorials? Please:
1. Open an issue describing the problem or tutorial request
2. Include relevant system information and configuration details
3. Provide clear steps to reproduce any issues

## Support

For additional help:
- Check the [main repository documentation](../README.md)
- Review [configuration examples](../config/)
- Join community discussions in the repository issues

---

**Note:** These tutorials assume you have a properly assembled Rister Toolchanger system. If you need assembly instructions, please refer to the main repository documentation.

*Tutorial videos are hosted on YouTube and embedded in the individual tutorial files. Click on any tutorial link above to access the content.*
