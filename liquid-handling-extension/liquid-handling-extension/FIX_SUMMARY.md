# Drypad Configuration Sync - Complete Fix Summary

## What Was Fixed

The extension now completely syncs ALL drypad configuration to Klipper's variables.cfg, including:

### 1. Grid Configuration (from drypad object)
- `drypad_base_x` - Base X position (92.0)
- `drypad_base_y` - Base Y position (335.0)
- `drypad_columns` - Number of columns (35)
- `drypad_rows` - Number of rows (6)
- `drypad_x_spacing` - Spacing between columns (4.0)
- `drypad_y_spacing` - Spacing between rows (4.0)
- `drypad_total_positions` - Total positions (210)

### 2. Active Tip Drypad Settings (from active tip)
- `drypad_z` - Z height for touching drypad (70.0)
- `drypad_servo` - Servo angle for drypad contact (115)
- `drypad_time` - Time to hold contact in ms (3000)
- `drypad_linear_pos` - Linear actuator position (115)
- `drypad_delay` - Delay time in ms (2000)

## When Sync Happens

### Automatic Sync:
1. **Extension Startup** - Syncs everything on load
2. **Editing Drypad Object** - Syncs when saving in Object Editor
3. **Editing Active Tip** - Syncs when modifying drypad fields in Fluidics tab
4. **Switching Active Tip** - Syncs new tip's settings to standalone variables
5. **Changing Drypad Controls** - Syncs when adjusting linear position or delay

### Manual Sync:
- Click "🔄 Sync Drypad Grid to Klipper" button in Fluidics Control tab

## Files Modified

### ui/fluidics/fluidics.js
- **`initialize()`** - Added call to sync on startup
- **`saveDrypadSettings()`** - Now syncs Z, servo, time, linear_pos, delay to variables
- **`saveDrypadGridToKlipper()`** - Enhanced to sync grid + active tip settings
- **`autoSaveTip()`** - Syncs to variables when editing active tip
- **`setActiveTip()`** - Syncs new tip's settings when changing active tip
- **UI** - Added "🔄 Sync Drypad Grid to Klipper" button

### ui/object-editor/object-editor.js
- **`saveObject()`** - Made async, calls sync when saving drypad
- **`saveDrypadGridToKlipper()`** - Enhanced to sync grid + active tip settings

## Variables in Klipper

After syncing, your variables.cfg should have:

```
drypad_base_x = 92.0
drypad_base_y = 335.0
drypad_columns = 35
drypad_rows = 6
drypad_x_spacing = 4.0
drypad_y_spacing = 4.0
drypad_total_positions = 210
drypad_z = 70.0
drypad_servo = 115
drypad_time = 3000
drypad_linear_pos = 115
drypad_delay = 2000
```

## Why Both Storage Methods?

The extension uses two storage methods for drypad settings:

### 1. tips_config (Modern)
```
tips_config = {
  'tip0': {
    'name': 'Tip0',
    'drypad_z': 70.0,
    'drypad_servo': 115,
    ...
  }
}
```
- Used by modern macros (TOUCH_DRY_AT, GO_WASH, etc.)
- Supports multiple tips with different settings
- Stored as JSON in variables.cfg

### 2. Standalone Variables (Legacy/Compatibility)
```
drypad_z = 70.0
drypad_servo = 115
```
- Used for backward compatibility
- Simpler access for legacy macros
- Always reflects the ACTIVE tip's settings

## Testing Checklist

- [ ] Load extension, check console for "Drypad configuration saved"
- [ ] Run `GET_VARIABLE` in Klipper, verify all 12 drypad variables exist
- [ ] Run `TOUCH_DRY` in Klipper console, verify correct position
- [ ] Edit drypad in Object Editor, verify variables update
- [ ] Edit drypad Z in Fluidics tab, verify `drypad_z` updates
- [ ] Switch active tip, verify standalone variables update
- [ ] Click sync button, verify alert appears

## Console Output Examples

**On Startup:**
```
Drypad configuration saved to Klipper: {
  grid: {
    baseX: 92, baseY: 335, columns: 35, rows: 6,
    xSpacing: 4, ySpacing: 4, totalPositions: 210
  },
  activeTip: {
    drypadZ: 70, drypadServo: 115, drypadTime: 3000,
    drypadLinearPos: 115, drypadDelay: 2000
  }
}
```

**When Editing Tip:**
```
Auto-saved drypad settings: {
  linearPos: 115, delayTime: 2000,
  z: 70, servo: 115, time: 3000
}
```

## Troubleshooting

### Variables Not Updating
- Check browser console (F12) for errors
- Verify Klipper connection in extension
- Try manual sync button
- Check file permissions on variables.cfg

### Wrong Values
- Verify correct tip is active
- Check that drypad object exists in Object Editor
- Import your config JSON if starting fresh

### Macros Using Wrong Values
- Run `GET_VARIABLE` to verify current values
- Check if macros read from tips_config or standalone variables
- Modern macros should use tips_config structure
- Legacy macros might use standalone variables
