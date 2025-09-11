# Rister Camera System - Video Targeting Techniques

This repository contains the camera system for the Rister toolchanger, supporting two distinct video targeting techniques for precision tool positioning.

## Files Overview

- **`camera_flask_mqtt.py`** - Main camera controller with Flask web interface and MQTT communication
- **`calibration_target.pdf`** - Printable fiducial pattern for camera calibration (PDF format)
- **`calibration_target.svg`** - Printable fiducial pattern for camera calibration (SVG format)
- **`mqtt_unified_subscriber_fixed.py`** - MQTT message handler for system communication
- **`start_dakash_service.py`** - Service startup script for the camera system

## Video Targeting Techniques

### Technique 1: Non-Camera Reference Tool

In this technique, a physical tool (typically an extruder or dispenser) serves as the reference point.

**How it works:**
1. Set any non-camera tool as the reference tool
2. Use the camera (C0) purely for measurement and offset detection
3. For each tool, enter:
   - **Programmed Position**: Where the tool should be positioned
   - **Actual Position**: Where the tool actually is (measured using camera)
4. Offsets are calculated as: `Actual Position - Programmed Position`

**Use case:** When you want to use physical tools as your coordinate reference and use the camera only for measurement verification.

### Technique 2: Camera as Reference Tool

In this technique, the camera tool itself becomes the reference point using fiducial markers.

**How it works:**
1. Set the camera tool (C0) as the reference tool
2. Print and place the calibration target on your print bed [calibration_target.pdf](calibration_target.pdf)
3. For the camera tool, enter:
   - **Fiducial X, Y, Z**: Position of the fiducial marker when camera is centered on it
4. For other tools, enter only:
   - **Programmed Position**: Where each tool should be positioned
5. Offsets are calculated as: `Tool Programmed Position - Camera Fiducial Position`

**Use case:** When you want to use printed fiducial markers as your absolute coordinate reference system.

## Setup Instructions

### 1. Print Calibration Target

Use either `calibration_target.pdf` or `calibration_target.svg`:
- Print at **100% scale** (do not scale to fit page)
- Verify the 50mm scale bar measures exactly 50mm with a ruler
- Place the printed target on your print bed within camera view

### 2. Access the Web Interface

Navigate to `http://[your-pi-ip]:8080` to access the camera control interface.

## Tool Configuration

### Camera Tool (C0)
- **Non-reference**: Acts as imaging tool only (no position inputs needed)
- **Reference**: Requires fiducial X, Y, Z positions for Technique 2

### Other Tools (E0, E1, L0, etc.)
- **Programmed Position**: Always required - where the tool should be positioned
- **Actual Position**: Required for Technique 1 only - measured position using camera
- **Linear Actuator**: For liquid dispenser tools only - actuator position value

## Interface Features

- **Live Camera Stream**: Real-time video feed with coordinate overlay
- **Image Mapper**: Click-to-measure pixel coordinates with printer position correlation
- **Pixel Size Calibration**: Draw measurement lines to calibrate microns per pixel
- **Tool Management**: Configure multiple tools with automatic offset calculations
- **Reference Tool Selection**: Switch between Technique 1 and Technique 2 workflows

## Offset Calculations

The system automatically calculates tool offsets based on the selected technique:

- **Technique 1**: `Offset = Actual Position - Programmed Position`
- **Technique 2**: `Offset = Tool Programmed Position - Camera Fiducial Position`

## Requirements

- Raspberry Pi with camera module
- Python 3 with Flask, MQTT, and camera libraries
- MQTT broker for system communication
- Printed calibration target for Technique 2, or a small device with small visable features

