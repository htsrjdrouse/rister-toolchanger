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
  - Per-tip parameters for each station: drypad, wash, waste (with unique X/Y/Z positions)
  - Active tip selection with live status indicator
  - Support for custom pipette tip designs and bayonet tool changing
  - **Macro assignment** - assign custom macros to wash/waste operations per tip
  - **Auto-save** - tip properties save automatically with immediate UI feedback
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
  - **Position-first workflow** - moves to position, then runs optional macro
  - Go to wash station (with optional custom wash macro)
  - Go to waste (with optional custom waste macro)
  - Home printer
  - Touch drypad (auto position or specific grid location 1-210)
  - **Macro display** - buttons show assigned macros: `🧼 Wash (my_wash)` or `🧼 Wash`

### ⚙️ G-code Builder
- **Active tip indicator** - Shows which tip configuration is active (e.g., "L0Tip0")
- **Tip station positioning** - Dedicated buttons for Drypad, Wash, and Waste using active tip positions
- **Position to objects** or **specific array locations**
  - Navigate to any well in a 35×6 drypad grid (210 positions)
  - Move to individual wells in multi-well plates
  - **Smart object handling** - Wash/Waste/Drypad use tip positions; other objects use Object Editor positions
- **Explicit coordinate generation** - All movements output with separate XY and Z moves
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
   - Default "L0Tip0" exists, click to edit
   - Set positions for:
     - **DRYPAD**: X, Y, Z coordinates, servo angles (move/touch), time, delay
     - **WASH**: X, Y, Z coordinates, servo angles (move/wash), optional custom macro
     - **WASTE**: X, Y, Z coordinates, servo angles (move/waste), optional custom macro
   - Tip properties auto-save on change
   - Click "Set Active" to make it operational
   - **Note:** EJECT operations are managed in custom user macros, not in tip properties

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

**Required Files (v1.3.9+):**
- `preset_tip_positions.cfg` - Preset-based tip position system with macros
  - Three presets: L0TIP0 (preloaded tip), L0TIP1 (bayonet tip 1), L0TIP2 (bayonet tip 2)
  - Movement macros: GO_DRYPAD, GO_WASH_STATION, GO_WASTE_STATION
  - Position macros: SET_TIP_POSITIONS, QUICK_ADJUST
  - Drypad macros: TOUCH_DRY, TOUCH_DRY_AT
- `microfluidics.cfg` - Main fluidics control macros
  - Valve control, syringe pump operations, servo control
  - **Remove old TOUCH_DRY macros** (lines 307-363, 387+) to avoid conflicts
- `variables.cfg` - Runtime storage for tip configurations (auto-generated by save_variables)

**Obsolete Files (v1.3.9+):**
- `inline_tip_positions.cfg` - Replaced by preset system
- `tipset_config.cfg` - Replaced by preset system

**Key Improvements:**
- ✅ **Preset-based configuration** - Load complete tip setups with one command
- ✅ **No hardcoded values** - All tip positions stored in preset macros
- ✅ **Servo move delays** - G4 P500 delays prevent skipped servo moves
- ✅ **Browser-editable** - Change tip configs from extension, use QUICK_ADJUST for testing
- ✅ **Multi-tip support** - Easy switching between tip formations (preloaded, bayonet, custom)
- ✅ **Clean architecture** - User macros separate from system macros

**Migration from v1.0.0:**
1. Replace old tip config files with `preset_tip_positions.cfg`
2. Comment out old TOUCH_DRY macros in `microfluidics.cfg`
3. Create custom bayonet macros in separate files (examples in preset config comments)
4. Update `printer.cfg` to include new preset file
5. Restart Klipper and test with `TOUCH_DRY`

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
- `SET_TIP_POSITIONS` - Load preset tip configuration (e.g., `SET_TIP_POSITIONS PRESET=L0TIP1`)
- `GO_DRYPAD` - Move to drypad using active tip position
- `GO_WASH_STATION` - Move to wash station using active tip position
- `GO_WASTE_STATION` - Move to waste station using active tip position
- `TOUCH_DRY` - Touch drypad at current active tip position
- `TOUCH_DRY_AT` - Touch drypad at specific grid position (1-210)
- `QUICK_ADJUST` - Live position adjustment for testing (e.g., `QUICK_ADJUST DRYPAD_X=92.5`)
- `VALVE_INPUT`, `VALVE_OUTPUT`, `VALVE_BYPASS` - Valve control with mask
- `SAVE_VARIABLE` - Store tip configurations to `variables.cfg`

**Configuration Files:**
- `/config/preset_tip_positions.cfg` - Preset-based tip position macros
- `/config/microfluidics.cfg` - Fluidics control macros (with old TOUCH_DRY macros removed)
- `/config/variables.cfg` - Runtime storage (auto-generated)
- User gcode files - Custom bayonet loading/ejecting macros

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

### Version 1.3.9 - January 2026

**Major Updates:**

**Tip Management Improvements:**
- ✅ **Removed EJECT section** from Edit Tip Properties - eject operations now fully managed in custom user macros for maximum flexibility
- ✅ **Per-tip position configuration** for all stations (Drypad, Wash, Waste) with unique X/Y/Z coordinates per tip
- ✅ **Macro assignment per station** - assign custom macros to wash/waste operations on a per-tip basis
- ✅ **Real-time UI updates** - Quick Action buttons update immediately when macros are assigned/changed

**Quick Actions Enhancement:**
- ✅ **Position-first workflow** - Quick Actions now move to position FIRST, then execute optional macro
  - Example: Click "Wash" → `GO_WASH_STATION` (moves to position) → Run assigned macro (if any)
- ✅ **Macro name display** - Buttons show assigned macro: `🧼 Wash (my_wash_macro)` or just `🧼 Wash` if none
- ✅ **Smart macro execution** - If no macro assigned, just moves to position using tip coordinates

**G-code Builder Enhancements:**
- ✅ **Active tip indicator** - Displays which tip configuration is currently active (e.g., "L0Tip0")
- ✅ **Tip station position buttons** - New dedicated buttons for Drypad, Wash, and Waste that use active tip positions
- ✅ **Functional vs. display positions** - Wash/Waste/Drypad objects are for graphical display only; functional positions come from tip properties
- ✅ **Explicit coordinate generation** - All movements output as explicit X/Y/Z coordinates with separate Z moves:
  ```gcode
  G90  ; Absolute positioning
  G1 X134.000 Y325.000 F3000  ; Move to wash XY position
  G1 Z70.000 F1500  ; Move to wash Z height
  G4 P500  ; Pause 500ms for stabilization
  ```

**Preset System (Klipper Config):**
- ✅ **Preset-based tip positions** - New `preset_tip_positions.cfg` with macro-based presets (L0TIP0, L0TIP1, L0TIP2)
- ✅ **One-line tip switching** - Load complete tip configuration with `SET_TIP_POSITIONS PRESET=L0TIP1`
- ✅ **Servo move delays** - Added `G4 P500` delays between all servo movements to prevent skipped moves
- ✅ **Live position adjustment** - `QUICK_ADJUST` macro for testing positions without Klipper restart
- ✅ **Clean macro architecture** - Bayonet loading/ejecting macros moved to user gcode files for easy customization

**UI/UX Improvements:**
- ✅ **Removed popup notifications** - Cleaner interface without annoying alerts
- ✅ **Compact table layout** - Reorganized Edit Tip Properties with visual groupings (X/Y/Z | Servos | Timing)
- ✅ **Console debugging** - Enhanced logging for troubleshooting button clicks and G-code commands
- ✅ **Auto-save functionality** - Tip properties save automatically on change with immediate UI feedback

**Bug Fixes:**
- ✅ Fixed TOUCH_DRY malformed command error (removed old conflicting macros)
- ✅ Fixed macro assignment indexing (wash/waste macros now read correctly)
- ✅ Fixed Quick Actions not updating until page refresh
- ✅ Fixed syntax errors in event listeners
- ✅ Fixed Position to Object reading wrong coordinates for wash/waste/drypad

**Configuration Files:**

**New/Updated Files:**
- `preset_tip_positions.cfg` - Preset-based tip position system with three presets (L0TIP0, L0TIP1, L0TIP2)
  - Contains macros: `SET_TIP_POSITIONS`, `GO_DRYPAD`, `GO_WASH_STATION`, `GO_WASTE_STATION`, `TOUCH_DRY`, `TOUCH_DRY_AT`
  - Includes `QUICK_ADJUST` for live position tuning without restart
  - All movement macros include `G4 P500` delays between servo moves

**Files to Remove:**
- `inline_tip_positions.cfg` - Obsolete (replaced by preset system)
- Old `TOUCH_DRY` and `TOUCH_DRY_AT` macros in `microfluidics.cfg` (lines 307-363, 387+) - Comment out or remove to avoid conflicts

**Migration Guide:**
1. Include `preset_tip_positions.cfg` in your `printer.cfg`
2. Comment out old TOUCH_DRY macros in `microfluidics.cfg` (if present)
3. Create your custom bayonet macros in separate gcode files:
   ```gcode
   [gcode_macro Bayonet_load_1]
   gcode:
       # Your physical loading sequence
       SET_TIP_POSITIONS PRESET=L0TIP1
   
   [gcode_macro Bayonet_eject]
   gcode:
       # Your physical eject sequence
       SET_TIP_POSITIONS PRESET=L0TIP0
   ```
4. Restart Klipper
5. Test with `TOUCH_DRY` in console

**Key Benefits:**
- Edit tip positions from browser without touching config files
- Mix and match tip configurations easily (bayonet tips, different formations)
- All station positions adapt automatically to active tip
- Clean separation: display objects vs. functional positions
- Build complex G-code sequences with correct tip-specific coordinates

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
