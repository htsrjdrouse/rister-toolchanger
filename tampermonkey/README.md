# Mainsail Lab Automation Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Klipper](https://img.shields.io/badge/Klipper-Compatible-green.svg)](https://www.klipper3d.org/)
[![Mainsail](https://img.shields.io/badge/Mainsail-Compatible-blue.svg)](https://mainsail.xyz/)

Advanced userscripts for Mainsail that add comprehensive lab automation capabilities to your Rister Toolchanger system. These scripts provide real-time fluidics control and visual object positioning for precise laboratory automation workflows.

## 🧪 Features

### 📱 Mainsail Fluidics Control
- **Real-time G-code Control**: Direct integration with Klipper/Mainsail for instant command execution
- **Timed Wash Sequences**: Automated wash cycles with customizable duration (1-300 seconds)
- **Comprehensive Valve Control**: Input, Output, Bypass valve positioning
- **Pump Management**: Wash pump and waste pump controls with feedback/manual modes
- **Interactive UI**: Draggable, collapsible control panel that stays accessible
- **Smart Command Routing**: Multiple fallback methods for reliable G-code delivery

### ⬜ Object Editor & G-code Builder
- **Visual Object Positioning**: Interactive P5.js canvas for precise lab object placement
- **Multi-Well Plate Support**: Configure complex arrays with custom well spacing and dimensions
- **G-code Sequence Builder**: Generate movement macros with visual well selection
- **Configuration Management**: Save/load object layouts with persistent storage
- **Macro Combination**: Merge multiple G-code sequences into complex workflows
- **Real-time Coordinate Display**: Live updates of object positions and well coordinates

## 🛠️ Installation

### Quick Install (Recommended)

1. **Download the installer**: [lab_automation_installer.html](./lab_automation_installer.html)
2. **Open the HTML file** in Chrome/Brave/Edge
3. **Install Tampermonkey** from the Chrome Web Store
4. **Copy and paste scripts** following the guided installation

### Manual Installation

1. Install [Tampermonkey](https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo) browser extension
2. Copy the script content from:
   - [mainsail_fluidics_control.js](./mainsail_fluidics_control.js)
   - [mainsail_objects_editor.js](./mainsail_objects_editor.js)
3. In Tampermonkey Dashboard, create new scripts and paste the content
4. Save and enable the scripts

## ⚙️ Configuration

### URL Patterns
Update the `@match` patterns in each script to match your Mainsail installation:

```javascript
// Default patterns
@match        http://192.168.1.89:81/*
@match        http://mainsailos.local/*
@match        http://your-printer-ip/*

// Update to your specific URL
@match        http://your-mainsail-url/*
```

### Fluidics Commands
The fluidics control panel sends these G-code commands to your Rister system:

| Button | G-code Command | Function |
|--------|---------------|----------|
| Feedback PCV On | `FEEDBACK_PCV` | Enable pressure control valve feedback |
| Manual PCV | `MANUAL_PCV` | Switch to manual pressure control |
| Wash On | `WASH_ON` | Activate wash pump |
| Wash Off | `WASH_OFF` | Deactivate wash pump |
| Dry On | `WASTE_ON` | Activate waste/dry pump |
| Dry Off | `WASTE_OFF` | Deactivate waste/dry pump |
| Valve Input | `VALVE_INPUT` | Set valve to input position |
| Valve Output | `VALVE_OUTPUT` | Set valve to output position |
| Valve Bypass | `VALVE_BYPASS` | Set valve to bypass position |
| Waste Position | `WASTE_POSITION` | Move to waste disposal position |
| Eject Pipette | `EJECT_PIPETTE` | Eject current pipette tip |

## 🎯 Usage

### Fluidics Control Panel

1. **Navigate to Mainsail** - The fluidics panel appears on the left side
2. **Expand the panel** - Click the `+` button to show controls
3. **Set wash duration** - Configure timed wash cycles (1-300 seconds)
4. **Control valves and pumps** - Use the grid of control buttons
5. **Monitor status** - View real-time command feedback

### Object Editor & G-code Builder

1. **Access the editor** - Panel appears on the right side of Mainsail
2. **Create objects** - Click "New Object" to add lab equipment
3. **Position visually** - Click on the canvas to position objects
4. **Configure arrays** - Set up multi-well plates with custom spacing
5. **Generate G-code** - Use the macro builder to create movement sequences
6. **Save configurations** - Export/import object layouts for reuse

### Creating Lab Workflows

1. **Define your lab setup** in the Object Editor:
   ```
   - Sample plates (96-well, 384-well, custom arrays)
   - Reagent reservoirs
   - Waste containers
   - Tool positions
   ```

2. **Build G-code sequences** for common operations:
   ```
   - Sample aspiration from specific wells
   - Reagent dispensing patterns
   - Wash station protocols
   - Multi-step analytical procedures
   ```

3. **Execute workflows** directly in Mainsail console or save as `.gcode` files

## 🔧 Integration with Rister Toolchanger

These scripts are designed specifically for the [Rister Toolchanger](https://github.com/htsrjdrouse/rister-toolchanger) system and provide:

### Fluidics Integration
- **Direct Klipper Integration**: Commands are sent directly to your Rister's Klipper configuration
- **Real-time Control**: Instant response for time-critical lab operations
- **Safety Features**: Timed operations prevent over-processing of samples

### Precision Positioning
- **Tool-aware Movements**: Object editor accounts for different tool geometries
- **Well-plate Standards**: Pre-configured for common laboratory plate formats
- **Custom Arrays**: Support for non-standard lab equipment and custom fixtures

### Workflow Automation
- **Macro Generation**: Convert visual layouts into executable G-code
- **Sequence Management**: Build complex multi-step protocols
- **Configuration Persistence**: Lab setups saved between sessions

## 📋 Requirements

- **Klipper Firmware**: Compatible with Rister Toolchanger configuration
- **Mainsail Interface**: Version 2.0+ recommended
- **Modern Browser**: Chrome, Brave, or Edge with Tampermonkey extension
- **Network Access**: Browser must reach Mainsail interface

## 🐛 Troubleshooting

### Scripts Don't Appear
1. Check URL patterns match your Mainsail installation
2. Verify Tampermonkey is enabled and scripts are active
3. Refresh Mainsail page after script installation

### Commands Not Executing
1. Ensure Klipper macros are defined in your configuration
2. Check Mainsail console for error messages
3. Verify WebSocket connection to Moonraker

### Object Editor Canvas Issues
1. P5.js library must load (check browser console)
2. Clear browser cache and refresh page
3. Ensure popup blockers aren't interfering

### Performance Issues
1. Disable unused browser extensions
2. Close unnecessary tabs
3. Use recommended browsers (Chrome/Brave/Edge)

## 🤝 Contributing

This project is part of the Rister Toolchanger ecosystem. Contributions are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow existing code style and patterns
- Test thoroughly with different Mainsail configurations
- Document new features and configuration options
- Consider backward compatibility with existing installations

## 📖 Documentation

### Advanced Configuration
- [Klipper Macro Setup](./docs/klipper-macros.md)
- [Custom Object Templates](./docs/object-templates.md)
- [G-code Workflow Examples](./docs/workflow-examples.md)

### API Reference
- [Fluidics Control Functions](./docs/fluidics-api.md)
- [Object Editor Data Structures](./docs/object-editor-api.md)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Klipper Team** - For the excellent 3D printer firmware
- **Mainsail Team** - For the beautiful web interface
- **P5.js Team** - For the interactive graphics library
- **Tampermonkey Team** - For enabling userscript functionality

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/htsrjdrouse/rister-toolchanger/issues)
- **Rister Community**: Join discussions about lab automation workflows
- **Documentation**: Check the `/docs` folder for detailed guides

---

*Part of the [Rister Toolchanger](https://github.com/htsrjdrouse/rister-toolchanger) ecosystem for advanced laboratory automation.*
