# Changelog - v1.1.1

## Date: 2026-01-06

### 🔧 Fixed: Complete Drypad Configuration Sync to Klipper

**Problem:**
The extension was not syncing drypad configuration to Klipper's variables.cfg file. This included:
1. Grid configuration (base position, columns, rows, spacing)
2. Active tip's Z height and servo positions

This meant that when drypad settings were changed in the Object Editor or Fluidics Control, the TOUCH_DRY and TOUCH_DRY_AT macros in Klipper would still use old values from variables.cfg.

**Solution:**
Added comprehensive automatic synchronization of ALL drypad configuration to Klipper variables.

### Changes Made:

#### 1. FluidicsControl (`ui/fluidics/fluidics.js`)

**New Function: `saveDrypadGridToKlipper()`**
- Extracts drypad configuration from the stored 'drypad' object
- Calculates:
  - `drypad_base_x`: posx + marginx
  - `drypad_base_y`: posy + marginy
  - `drypad_columns`: arraycolumn
  - `drypad_rows`: arrayrow
  - `drypad_x_spacing`: arraycolumnsp
  - `drypad_y_spacing`: arrayrowsp
  - `drypad_total_positions`: columns × rows
- Sends SAVE_VARIABLE commands to Klipper for each configuration value

**Modified Function: `initialize()`**
- Now calls `saveDrypadGridToKlipper()` on startup
- Ensures variables.cfg is synced when extension loads

**New UI Element:**
- Added "🔄 Sync Drypad Grid to Klipper" button in Drypad Control section
- Allows manual re-sync if needed
- Shows confirmation alert after sync

#### 2. ObjectEditor (`ui/object-editor/object-editor.js`)

**Modified Function: `saveObject()`**
- Now async to support Klipper API calls
- Automatically detects when 'drypad' object is saved
- Calls `saveDrypadGridToKlipper()` after saving drypad

**New Function: `saveDrypadGridToKlipper(drypadObj)`**
- Same implementation as in FluidicsControl
- Ensures drypad changes in Object Editor immediately sync to Klipper

#### 3. User Experience Improvements

**Modified Function: `showNotification()`**
- Now displays actual alert() dialogs
- Provides visible feedback for sync operations
- Can be enhanced with toast notifications in future

### Variables Synced to Klipper:

When drypad object is modified or active tip settings change, these variables are automatically updated in variables.cfg:

**Grid Configuration (from drypad object):**
```gcode
SAVE_VARIABLE VARIABLE=drypad_base_x VALUE=92.0
SAVE_VARIABLE VARIABLE=drypad_base_y VALUE=335.0
SAVE_VARIABLE VARIABLE=drypad_columns VALUE=35
SAVE_VARIABLE VARIABLE=drypad_rows VALUE=6
SAVE_VARIABLE VARIABLE=drypad_x_spacing VALUE=4.0
SAVE_VARIABLE VARIABLE=drypad_y_spacing VALUE=4.0
SAVE_VARIABLE VARIABLE=drypad_total_positions VALUE=210
```

**Active Tip Drypad Settings (from active tip configuration):**
```gcode
SAVE_VARIABLE VARIABLE=drypad_z VALUE=70.0
SAVE_VARIABLE VARIABLE=drypad_servo VALUE=115
SAVE_VARIABLE VARIABLE=drypad_time VALUE=3000
SAVE_VARIABLE VARIABLE=drypad_linear_pos VALUE=115
SAVE_VARIABLE VARIABLE=drypad_delay VALUE=2000
```

These standalone variables provide backward compatibility with legacy macros while the modern macros use the tips_config structure.

### How It Works:

1. **On Extension Startup:**
   - Extension reads drypad object from local storage
   - Calculates grid configuration
   - Gets active tip's drypad settings
   - Syncs everything to Klipper's variables.cfg
   
2. **When Editing Drypad in Object Editor:**
   - User modifies drypad position, array size, or spacing
   - Clicks "Save Changes"
   - Object saved to local storage
   - Automatically syncs grid + active tip settings to Klipper variables.cfg

3. **When Editing Tip Settings:**
   - User modifies drypad Z, servo, time, linear_pos, or delay in Fluidics tab
   - Changes auto-save as user types
   - If editing active tip, standalone variables also sync to Klipper
   
4. **When Switching Active Tip:**
   - User selects different tip as active
   - Extension syncs that tip's drypad settings to standalone variables
   - Ensures macros always use current active tip settings

5. **Manual Sync:**
   - User can click "🔄 Sync Drypad Grid to Klipper" button
   - Useful if variables.cfg was manually edited
   - Provides confirmation alert

### Benefits:

✅ Complete drypad configuration stays in sync between extension and Klipper
✅ Grid position (base X/Y, columns, rows, spacing) always current
✅ Active tip's Z height and servo positions always current
✅ TOUCH_DRY and TOUCH_DRY_AT macros always use correct settings
✅ No manual G-code commands needed to update variables
✅ Automatic sync on startup, save, and active tip change
✅ Manual sync button available if needed
✅ Backward compatibility with legacy macros via standalone variables

### Compatibility:

- Works with existing microfluidics.cfg macros
- No changes needed to Klipper configuration
- Backwards compatible with v1.1.0 configurations
- Automatically migrates on first load

### Testing Recommendations:

1. Load extension and verify console shows "Drypad grid configuration saved to Klipper"
2. Modify drypad object in Object Editor
3. Verify variables.cfg updates via Klipper console: `GET_VARIABLE`
4. Test TOUCH_DRY command uses new positions
5. Click manual sync button and verify alert appears
