# Liquid Handling Control System - Browser Extension

A professional browser extension for controlling Klipper-based liquid handling automation systems.

## Features

### 📐 Object Editor
- Visual printer bed representation
- Create and manage lab objects (well plates, racks, etc.)
- Array positioning with automatic coordinate calculation
- **NEW: Position Z (bed height) instead of object Z height**
- Configurable printer area dimensions
- Export/import object configurations

### 💧 Fluidics Control
- Tip management system with customizable parameters
- **NEW: Macro assignment for wash/waste/eject actions**
- Pipette height control (servo positioning)
- **NEW: Arduino-based syringe pump control** (A1/D1 commands via serial)
- Trigger-based dispensing with arm/disarm and fire controls
- STORE command for pre-loading dispense parameters
- Configurable trigger delay (TD)
- Emergency stop (P0) and clear stop (P999)
- **NEW: 4-servo valve control** with mask selector, state indicator, and 5V rail management
- **NEW: Synchronized dispense mode** (DISPENSE_WITH_VALVES macro)
- **NEW: Enhanced drypad control with linear actuator position and delay settings**
- Quick actions: wash, waste, eject, home, drypad touch

### ⚙️ G-code Builder
- Create automated sequences using objects and tips
- Position to specific objects or array locations
- Save and manage G-code macros
- Download as .gcode files
- Direct printer execution
- Combine multiple sequences

## Installation

### Chrome/Edge
1. Download the extension folder
2. Open `chrome://extensions/`
3. Enable "Developer mode" (top right)
4. Click "Load unpacked"
5. Select the `liquid-handling-extension` folder

### Firefox
1. Download the extension folder
2. Open `about:debugging#/runtime/this-firefox`
3. Click "Load Temporary Add-on"
4. Select any file in the `liquid-handling-extension` folder

## Configuration

### First Time Setup
1. Click the extension icon in your browser toolbar
2. The extension will auto-detect your Klipper printer
3. Configure your printer area dimensions in the Object Editor
4. Create your first objects and tips

### Printer Connection
The extension automatically detects Klipper at:
- `http://192.168.1.89:7125`
- `http://mainsailos.local:7125`
- `http://localhost:7125`

You can modify these endpoints in `shared/api.js` if needed.

## Usage

### Creating Objects
1. Go to the "Object Editor" tab
2. Click "New Object"
3. Configure position, size, and array parameters
4. Save your object

### Managing Tips
1. Go to the "Fluidics" tab
2. Click "New Tip"
3. Configure drypad, wash, waste, and eject parameters
4. Set as active tip

### Building G-code Sequences
1. Go to the "G-code Builder" tab
2. Select an object from the dropdown
3. Click "Position to Object" or "Position to Array"
4. Build your sequence
5. Save, download, or run directly on the printer

### Valve Control
The system has 4 servo-controlled valves on an Arduino Micro (`/dev/ttyMICROFLUIDICS`).

**Valve Positions:**
| Position | Angle | Description |
|----------|-------|-------------|
| BYPASS   | 35°   | Default/closed state — safe resting position |
| OUTPUT   | 90°   | Dispense — liquid flows from syringe to tip |
| INPUT    | 0°    | Aspirate — liquid drawn from reservoir into syringe |
| FLUSH    | 180°  | PCV direct to output, bypasses syringe entirely |

**Mask Parameter:** A 4-digit binary string where each digit controls one servo (1=move, 0=skip):
- `1111` = all 4 valves
- `1010` = valves 1 and 3 only
- `0001` = valve 4 only

Use the toggle buttons (V1–V4) or type a mask directly in the text input.

**5V Rail Management:** Servo power is pulsed on only during valve moves (~350ms total) to extend servo longevity. The Klipper macros (`VALVE_OUTPUT`, etc.) handle this automatically. Manual 5V ON/OFF buttons are provided for debugging.

**Valve switch timing:** ~350ms (50ms 5V stabilize + 150ms servo settle + overhead).

**Angles** are stored in `variables.cfg` and can be reconfigured via `CONFIGURE_SERVO_ANGLES`.

### Synchronized Dispensing
The "Sync Dispense" section sends the `DISPENSE_WITH_VALVES` Klipper macro which:
1. Powers 5V rail and opens valves to OUTPUT
2. Loads trigger with volume/rate parameters
3. Arms trigger, moves to target XY, then disarms
4. Returns valves to BYPASS and powers down 5V

Parameters: Mask, Volume (µL), Rate, Target X/Y, XY Feedrate.

## Data Storage

**Automatic Default Configuration:** On first startup, the extension loads your pre-configured default settings from `default_config.json`. This includes all your objects, tips, macros, and printer settings - no manual import needed!

**Configuration Auto-Saves:** All configuration changes are automatically saved to your browser's local storage. Changes persist immediately when you make them - no manual saving required!

Storage includes:
- Objects and their positions
- Tip configurations with macro assignments
- Saved G-code macros
- Printer area settings
- Active tip selection

**Export for Backup:** Use the "Export Config" button to create timestamped backup files (e.g., `liquid_handling_config_2025-01-02.json`). Import these to restore settings or transfer to another browser.

**Workflow:**
1. Install extension → Automatically loads default_config.json
2. Make changes → Auto-saves to browser storage
3. Need backup? → Export creates timestamped file
4. Reinstall extension? → Loads default_config.json again

## Development

### Project Structure
```
liquid-handling-extension/
├── manifest.json              # Extension configuration
├── background.js              # Background service worker
├── content.js                 # Content script for Mainsail/Fluidd
├── shared/
│   ├── storage.js            # Unified data management
│   └── api.js                # Klipper API wrapper
├── ui/
│   ├── popup.html            # Main interface
│   ├── popup.js              # Tab management
│   ├── styles.css            # Styling
│   ├── object-editor/        # Object Editor module
│   ├── fluidics/             # Fluidics Control module
│   └── gcode-builder/        # G-code Builder module
└── assets/
    └── icons/                # Extension icons
```

### Adding Features
Each module (Object Editor, Fluidics, G-code Builder) is self-contained:
- Modify the module's `.js` file to add functionality
- All modules share access to `storage` and `api` instances
- Changes are immediately reflected when reloading the extension

## API Reference

### Storage Manager
```javascript
storage.getObjects()          // Get all objects
storage.addObject(obj)        // Add new object
storage.getTips()             // Get all tips
storage.addTip(tip)           // Add new tip
storage.exportConfig()        // Export as JSON
storage.importConfig(json)    // Import from JSON
```

### Klipper API
```javascript
api.sendGcode(command)        // Send single G-code command
api.sendGcodeMulti(commands)  // Send multiple commands
api.getPrinterStatus()        // Get printer state
api.uploadAndRunGcode(file)   // Upload and run G-code file
```

## License

MIT License - Free to use and modify for your liquid handling automation needs.

## Support

For issues or feature requests, please refer to the source repository.

## Version History

### v1.3.0 (2026-03-25)
- **NEW: 4-servo valve control panel** — mask selector with V1–V4 toggle buttons, INPUT/OUTPUT/BYPASS/FLUSH position buttons with color coding
- **NEW: Valve state indicator** — shows current valve position and 5V rail state
- **NEW: Manual 5V ON/OFF controls** — for debugging servo rail power
- **NEW: Synchronized dispense mode** — sends `DISPENSE_WITH_VALVES` macro with mask, volume, rate, and target XY parameters

### v1.2.2 (2026-03-20)
- **FIX: STORE command** - Now sends `STORE E{vol} F{rate}` format instead of `PUMP_LOAD_TRIGGER VOL= RATE=`
- **FIX: Fire Trigger** - Simplified to send `TRIGGER_FIRE` command instead of SET_PIN toggle; cleaned up button label

### v1.2.1 (2026-03-19)
- **FIX: Trigger system** - Fixed trigger fire functionality
- **NEW: Motor ON/OFF buttons** - Dedicated buttons to enable/disable syringe pump motor

### v1.2.0 (2026-03-19)
- **NEW: Arduino-based syringe pump control** - Replaced Klipper extruder G-code (G1 E/M83) with Arduino serial commands (A1/D1)
- **NEW: Trigger system** - Arm/disarm trigger (TRIGGERON/TRIGGEROFF), fire button only shown when armed
- **NEW: STORE command** - Pre-load dispense parameters on the microcontroller
- **NEW: Trigger delay (TD)** - Configurable delay in milliseconds between trigger and dispense
- **NEW: Emergency stop (P0)** and clear stop (P999) buttons
- **NEW: Pump status (P114)** - Query Arduino state

### v1.1.0 (2025-01-02)
- **NEW: Macro assignment for wash/waste/eject actions** - Select saved G-code macros to run for quick actions
- **NEW: Enhanced drypad control** - Added linear actuator position and delay time settings
- **IMPROVED: Object editor** - Changed "Z Height" to "Position Z" for clarity (bed position)
- **IMPROVED: Auto-save** - Configuration automatically persists, no need to manually export on restart
- Bug fixes and stability improvements

### v1.0.0 (2024)
- Initial release
- Object Editor with visual bed representation
- Fluidics Control with tip management
- G-code Builder with macro system
- Unified configuration management
- Klipper API integration
