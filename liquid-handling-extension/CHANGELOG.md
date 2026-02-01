# Changelog

All notable changes to the Liquid Handling Control System will be documented in this file.

## [1.1.0] - 2025-01-02

### Added
- **Macro Assignment for Quick Actions**: You can now assign saved G-code macros to wash, waste, and eject actions in the Fluidics tab. When a macro is assigned, clicking the quick action button will execute that macro instead of the default G-code command.
  - Select macros from the dropdown when editing tip properties
  - Macros are optional - leave blank to use default commands
  - Great for custom washing routines or complex eject sequences

- **Enhanced Drypad Control**: New settings for precise drypad operations
  - Linear Actuator Position: Set the servo angle when touching the drypad
  - Delay Time: Configure how long the tip stays on the drypad before lifting
  - Both settings are configurable per tip in the Tip Editor

### Changed
- **Object Editor - Position Z**: Renamed "Z Height" to "Position Z (bed height, mm)" for better clarity. This field represents the Z position of the printer bed where the object sits, not the height of the object itself.

### Improved
- **Auto-Save Configuration**: All settings now automatically persist to browser storage immediately when changed. You no longer need to remember to export your configuration file after making changes - it's always saved!
- Configuration still includes Export/Import functions for backup and transfer purposes

### Technical Details
- Updated storage schema to include `wash_macro`, `waste_macro`, `eject_macro` fields for tips
- Added `drypad_linear_pos` and `drypad_delay` fields for enhanced drypad control
- Improved renderTipEditor() to include macro selection dropdowns
- Updated quick action handlers to check for assigned macros before executing default commands
- Version bumped to 1.1.0 across all files

## [1.0.0] - 2024

### Initial Release
- Object Editor with visual bed representation
- Fluidics Control with comprehensive tip management
- G-code Builder with sequence creation and macro system
- Unified configuration management
- Klipper API integration
- Export/Import configuration
- Multi-valve control system
- Syringe pump operations
- Array coordinate calculation
