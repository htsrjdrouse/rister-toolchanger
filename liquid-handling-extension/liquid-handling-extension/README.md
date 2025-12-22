# Liquid Handling Control System - Browser Extension

A professional browser extension for controlling Klipper-based liquid handling automation systems.

## Features

### 📐 Object Editor
- Visual printer bed representation
- Create and manage lab objects (well plates, racks, etc.)
- Array positioning with automatic coordinate calculation
- Configurable printer area dimensions
- Export/import object configurations

### 💧 Fluidics Control
- Tip management system with customizable parameters
- Pipette height control (servo positioning)
- Syringe pump operations (aspirate/dispense)
- Multi-valve control (A, B, C, D)
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

## Data Storage

All configuration is stored locally in your browser using Chrome's storage API:
- Objects and their positions
- Tip configurations
- Saved G-code macros
- Printer area settings

Use the "Export Config" button to backup your configuration, and "Import Config" to restore it.

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

### v1.0.0 (2024)
- Initial release
- Object Editor with visual bed representation
- Fluidics Control with tip management
- G-code Builder with macro system
- Unified configuration management
- Klipper API integration
