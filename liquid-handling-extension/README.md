# Liquid Handling Control - Browser Extension

A professional browser extension for the Rister Toolchanger liquid handling automation system. Provides a unified control interface for object positioning, fluidics control, and automated G-code sequence generation.

![Extension Screenshot](https://img.shields.io/badge/Browser-Chrome%20%7C%20Edge%20%7C%20Firefox-orange)
![Klipper](https://img.shields.io/badge/Klipper-Compatible-green)
![License](https://img.shields.io/badge/License-MIT-blue)

## 🎯 Purpose

This extension replaces multiple Tampermonkey scripts with a single, integrated application that:
- **Eliminates licensing concerns** for commercial use
- **Unifies configuration** across all control modules
- **Provides native browser integration** without dependencies
- **Opens as a resizable, movable window** for flexible workflows

Originally developed for automated liquid handling with custom pipette tips and multi-dispenser configurations for precision fluidics applications.

## ✨ Features

### 📐 Object Editor
- **Visual printer bed representation** with live canvas rendering
- **Create and manage lab objects** (well plates, racks, reservoirs, custom fixtures)
- **Array positioning system** with automatic coordinate calculation
  - Example: 96-well plate = 8 rows × 12 columns with precise spacing
- **Configurable printer area** dimensions
- **Color-coded objects** for easy identification
- **Export/import** object configurations as JSON

### 💧 Fluidics Control
- **Multi-tip management system**
  - Configure up to 4 dispensers (current setup uses 4)
  - Per-tip parameters: drypad, wash, waste, eject positions
  - Active tip selection with live status
  - Support for custom pipette tip designs
- **Pipette height control** 
  - Servo positioning (0°-180°)
  - Quick presets for common heights
- **Syringe pump operations**
  - Aspirate/dispense with configurable steps and feedrate
  - Position zeroing
- **4-valve control system** (A, B, C, D)
  - INPUT/OUTPUT/BYPASS modes
  - Binary mask configuration
- **Quick action buttons**
  - Go to wash station
  - Go to waste
  - Eject tip
  - Home printer
  - Touch drypad (auto or specific position)

### ⚙️ G-code Builder
- **Position to objects** or **specific array locations**
  - Navigate to any well in a 35×6 drypad grid (210 positions)
  - Move to individual wells in multi-well plates
- **Build automated sequences**
  - Combine multiple positioning commands
  - Add pauses, Z-moves, and custom G-code
- **Macro management**
  - Save sequences with descriptive names
  - Load and edit existing sequences
  - Combine multiple sequences into complex workflows
  - Reorder sequences (move up/down)
- **Export options**
  - Download as `.gcode` files
  - Copy to clipboard for Mainsail console
  - **Run directly on printer** via Klipper API

## 🚀 Installation

### Prerequisites
- Chrome, Edge, or Firefox browser
- Klipper firmware running on your printer
- Mainsail or Fluidd web interface
- Network access to your printer (typically `http://192.168.1.89` or `http://mainsailos.local`)

### Install Steps

1. **Download the extension**
   ```bash
   git clone https://github.com/htsrjdrouse/rister-toolchanger.git
   cd rister-toolchanger/liquid-handling-extension
   ```

2. **Load into browser**
   
   **Chrome/Edge:**
   - Navigate to `chrome://extensions/`
   - Enable "Developer mode" (toggle in top-right)
   - Click "Load unpacked"
   - Select the `liquid-handling-extension` folder
   
   **Firefox:**
   - Navigate to `about:debugging#/runtime/this-firefox`
   - Click "Load Temporary Add-on"
   - Select any file in the `liquid-handling-extension` folder (e.g., `manifest.json`)

3. **Launch**
   - Click the extension icon in your browser toolbar
   - A resizable window opens with the control interface

## 📖 Quick Start

### First Time Setup

1. **Configure Printer Area**
   - Go to "Object Editor" tab
   - Update printer bed dimensions (default: 380×480mm)
   - Click "Update Printer Area"

2. **Create Your First Object**
   ```
   Example: 96-well plate
   - Name: "96_well_plate"
   - Position X, Y: Location on bed
   - Object Size: 127.76 × 85.48 mm
   - Array Rows: 8
   - Array Columns: 12
   - Row Spacing: 9.0mm
   - Column Spacing: 9.0mm
   ```

3. **Configure Tips**
   - Go to "Fluidics" tab
   - Default "Tip0" exists, click to edit
   - Set positions for:
     - **DRYPAD**: Z-height, servo angle, dwell time
     - **WASH**: X, Y, Z coordinates and servo angle
     - **WASTE**: Waste disposal location
     - **EJECT**: Tip ejection position
   - Click "Set Active" to make it operational

4. **Build Your First Sequence**
   - Go to "G-code Builder" tab
   - Enter sequence name: `sample_collection`
   - Select object from dropdown
   - Enter row/column (e.g., Row 2, Column 3 = well B3)
   - Click "Position to Array"
   - Repeat for multiple wells
   - Click "Save Sequence"

## 🔧 Configuration

### Klipper Configuration Files

This extension works with the following configuration files in your Rister Toolchanger setup:

**New Files (Browser Extension Integration):**
- `tipset_config.cfg` - Tip configuration storage (replaces hardcoded values)
- `microfluidics.cfg` - Main fluidics control macros without hardcoded parameters
- `variables.cfg` - Stores tip configurations and active tip selection

**Key Improvements:**
- ✅ **No hardcoded values** - All tip positions stored in `variables.cfg`
- ✅ **JSON-based storage** - Tip configurations saved as structured data
- ✅ **Dynamic loading** - Tips loaded from storage at startup
- ✅ **Browser-editable** - Change tip configs from extension, saved to Klipper
- ✅ **Multi-tip support** - Manage all 4 dispensers from single interface

**Migration from Old System:**
If you're upgrading from hardcoded tip configurations:
1. Export your current tip positions using the extension
2. Import `microfluidics.cfg` (replaces old microfluidics config)
3. Run `SAVE_CONFIG` to persist tip data to `variables.cfg`

### Printer Endpoints

The extension auto-detects Klipper at these addresses:
- `http://192.168.1.89:7125`
- `http://mainsailos.local:7125`
- `http://localhost:7125`

To add custom endpoints, edit `shared/api.js`:
```javascript
this.endpoints = [
  'http://192.168.1.89:7125',
  'http://your-printer-ip:7125'
];
```

### Storage

All configuration is stored in browser local storage:
- Objects and positions
- Tip configurations  
- Saved G-code sequences
- Printer area settings

**Backup:** Use "Export Config" button to save as JSON file

**Restore:** Use "Import Config" button to load from JSON file

**Sync to Klipper:** Tip configurations are automatically saved to `variables.cfg` when changed

## 🎨 Usage Tips

### Window Management
- **Resize:** Drag edges or corners (recommended: 1200×900 or larger)
- **Move:** Drag title bar to reposition (works across multiple monitors)
- **One instance:** Clicking extension icon focuses existing window instead of opening duplicates

### Workflow Optimization
- Keep control window open on second monitor while working in Mainsail
- Use "Export Config" regularly to backup your setup
- Create reusable sequences for common operations (wash, pick tip, dispense, eject)
- Combine sequences for complex multi-step protocols

### Integration with Rister Toolchanger

This extension is designed to work with the Rister Toolchanger Klipper macros:

**Required Klipper Macros:**
- `SELECT_TIP` - Set active dispenser (reads from `variables.cfg`)
- `GO_WASH` - Move to wash station (uses active tip config)
- `GO_WASTE` - Move to waste disposal (uses active tip config)
- `BAYONET_EJECT` - Eject current tip (uses active tip config)
- `TOUCH_DRY` - Touch drypad at active position
- `TOUCH_DRY_AT` - Touch drypad at specific position (1-210)
- `VALVE_INPUT`, `VALVE_OUTPUT`, `VALVE_BYPASS` - Valve control with mask
- `SAVE_VARIABLE` - Store tip configurations to `variables.cfg`

**Configuration Files:**
- `/config/tipset_config.cfg` - Tip definitions and parameters
- `/config/microfluidics.cfg` - Fluidics control macros
- `/config/variables.cfg` - Runtime storage (auto-generated)

See main [Rister Toolchanger repository](https://github.com/htsrjdrouse/rister-toolchanger) for complete Klipper configuration.

## 🏗️ Architecture

```
liquid-handling-extension/
├── manifest.json              # Extension configuration
├── background.js              # Service worker (window management)
├── content.js                 # Content script (Mainsail integration)
├── shared/
│   ├── storage.js            # Unified configuration manager
│   └── api.js                # Klipper API wrapper
├── ui/
│   ├── popup.html            # Main interface
│   ├── popup.js              # Tab switching logic
│   ├── styles.css            # Application styling
│   ├── object-editor/        # Object positioning module
│   │   └── object-editor.js
│   ├── fluidics/             # Fluidics control module
│   │   └── fluidics.js
│   └── gcode-builder/        # G-code generation module
│       └── gcode-builder.js
└── assets/
    └── icons/                # Extension icons (16, 48, 128px)
```

## 🔌 API Reference

### Storage Manager

```javascript
storage.getObjects()              // Get all objects
storage.addObject(obj)            // Add new object
storage.updateObject(index, obj)  // Update existing object
storage.deleteObject(index)       // Remove object

storage.getTips()                 // Get all tips
storage.addTip(tip)               // Add new tip
storage.setActiveTipIndex(index)  // Set active dispenser

storage.getMacros()               // Get saved sequences
storage.addMacro(macro)           // Save new sequence

storage.exportConfig()            // Export as JSON string
storage.importConfig(jsonString)  // Import from JSON
```

### Klipper API

```javascript
api.sendGcode(command)                    // Send single G-code command
api.sendGcodeMulti(commands)              // Send multiple commands
api.getPrinterStatus()                    // Get printer state
api.uploadAndRunGcode(filename, content)  // Upload and execute file
```

## 🛠️ Development

### Prerequisites
- Node.js (for potential future build tools)
- Basic understanding of JavaScript ES6 modules
- Familiarity with Chrome Extension APIs

### Making Changes

1. **Modify code** in the appropriate module
2. **Reload extension** in browser:
   - Chrome: Go to `chrome://extensions/` → Click reload icon
   - Firefox: Go to `about:debugging` → Click reload button
3. **Test changes** by reopening the control window

### Adding Features

Each module is self-contained:
- **Object Editor:** Modify `ui/object-editor/object-editor.js`
- **Fluidics Control:** Modify `ui/fluidics/fluidics.js`
- **G-code Builder:** Modify `ui/gcode-builder/gcode-builder.js`

All modules share access to `storage` and `api` instances for data persistence and printer communication.

## 🔬 Use Cases

### Custom Pipette Tip Development
This extension was developed alongside custom pipette tip designs for precision liquid handling:
- **4-dispenser configuration** with bayonet tool change system
- **35×6 drypad grid** (210 positions) for tip maintenance
- **Custom tip geometries** optimized for specific applications
- **Multi-valve system** for fluid routing and flow control

### General Liquid Handling
Suitable for any Klipper-based liquid handling application:
- Automated sample collection
- Well plate filling
- Reagent dispensing
- Serial dilutions
- High-throughput screening
- Custom dispensing protocols

## 🆕 What's New

### Version 1.0.0 - Initial Release

**Major Features:**
- Complete browser extension replacing Tampermonkey scripts
- Resizable, movable window interface
- Unified configuration system

**Configuration System Overhaul:**
- ✅ Eliminated all hardcoded tip positions
- ✅ Introduced `tipset_config.cfg` for structured tip storage
- ✅ Updated `microfluidics.cfg` to read from `variables.cfg`
- ✅ Browser-to-Klipper synchronization via `SAVE_VARIABLE`
- ✅ JSON-based tip configuration for easy editing

**Benefits:**
- Change tip positions without editing G-code
- Manage multiple tip sets from browser interface
- Export/import configurations for different setups
- No code changes required for tip adjustments

## 🤝 Contributing

Contributions are welcome! This extension is part of the larger Rister Toolchanger project.

**Areas for improvement:**
- Additional printer bed visualizations
- Support for more complex array geometries
- Integration with external databases for plate definitions
- Macro templates for common operations
- Enhanced error handling and validation
- Support for additional valve configurations

See the main [Rister Toolchanger repository](https://github.com/htsrjdrouse/rister-toolchanger) for contribution guidelines.

## 📝 License

MIT License - Free to use, modify, and distribute for any purpose including commercial applications.

## 🐛 Troubleshooting

### Extension won't load
- Ensure you're loading the entire folder, not individual files
- Check that `manifest.json` is in the root directory
- Try restarting the browser

### "Disconnected" status
- Verify Klipper is running: Navigate to `http://192.168.1.89` in browser
- Check network connectivity
- Verify firewall isn't blocking port 7125
- Update IP address in `shared/api.js` if needed

### G-code commands not executing
- Check connection status in header (should show "Connected")
- Verify Klipper macros exist on printer (check `microfluidics.cfg` is included)
- Check Mainsail console for error messages
- Ensure printer is not in emergency stop state

### Tips not saving to Klipper
- Verify `variables.cfg` exists and is writable
- Check that `[save_variables]` section is configured in Klipper
- Run `SAVE_CONFIG` manually to test persistence
- Check Mainsail console for `SAVE_VARIABLE` errors

### Canvas not displaying correctly
- Try resizing the window
- Check browser console for JavaScript errors
- Verify printer area dimensions are set correctly

## 📚 Resources

- **Main Project:** [Rister Toolchanger GitHub](https://github.com/htsrjdrouse/rister-toolchanger)
- **Klipper Documentation:** [klipper3d.org](https://www.klipper3d.org/)
- **Mainsail Interface:** [mainsail.xyz](https://mainsail.xyz/)
- **Chrome Extension Development:** [developer.chrome.com/docs/extensions](https://developer.chrome.com/docs/extensions)

## 💬 Support

For questions, issues, or feature requests related to this extension, please open an issue in the main [Rister Toolchanger repository](https://github.com/htsrjdrouse/rister-toolchanger/issues).

---

**Built for precision liquid handling automation** 🧪💧

Part of the [Rister Toolchanger](https://github.com/htsrjdrouse/rister-toolchanger) project.
