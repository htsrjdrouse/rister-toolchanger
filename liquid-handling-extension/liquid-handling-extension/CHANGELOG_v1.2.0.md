# Changelog - v1.2.0

## Date: 2026-01-06

### 🎯 Major Feature: Unified Servo Move/Action Architecture

**Concept:**
Separated servo positions into two distinct purposes for all stations (drypad, wash, waste, eject):
1. **Servo Move** - Safe travel position (typically 0°)
2. **Servo Action** - Working position for the specific action

This makes the system more intuitive and consistent across all operations.

---

## Changes by Station

### 🔸 Drypad
**Old Fields:**
- `drypad_linear_pos` - Single position value
- `drypad_servo` - Touch position

**New Fields:**
- `drypad_servo_move` - Position during travel (default: 0°)
- `drypad_servo_touch` - Position when touching drypad (default: 115°)

**UI Updates:**
- Fluidics Control tab now shows both positions clearly
- Tip Editor shows servo_move and servo_touch separately

### 🧼 Wash Station
**Old Fields:**
- `wash_servo` - Single working position

**New Fields:**
- `wash_servo_move` - Position during travel (default: 0°)
- `wash_servo_wash` - Position when washing (default: 120°)

### 🗑️ Waste Station
**Old Fields:**
- `waste_servo` - Single working position

**New Fields:**
- `waste_servo_move` - Position during travel (default: 0°)
- `waste_servo_waste` - Position when disposing waste (default: 170°)

### 📤 Eject Station
**Old Fields:**
- `eject_servo` - Single working position

**New Fields:**
- `eject_servo_move` - Position during travel (default: 0°)
- `eject_servo_eject` - Position when ejecting (default: 150°)

---

## Technical Implementation

### Data Migration
**Automatic migration** converts old configuration to new structure:
- Old `drypad_servo` → New `drypad_servo_touch`
- Old `wash_servo` → New `wash_servo_wash`
- Old `waste_servo` → New `waste_servo_waste`
- Old `eject_servo` → New `eject_servo_eject`
- All `servo_move` fields default to 0°
- Old `drypad_linear_pos` field removed

### Files Modified

#### ui/fluidics/fluidics.js
- **`createDefaultTip()`** - Updated with new servo field structure
- **`render()`** - Updated drypad control UI (3-column layout)
- **`renderTipEditor()`** - Updated all station UIs with servo_move/action fields
- **`setupTipAutoSave()`** - Added all new field IDs
- **`autoSaveTip()`** - Saves all new servo fields
- **`saveDrypadSettings()`** - Uses servo_move and servo_touch
- **`saveDrypadGridToKlipper()`** - Syncs new fields to variables.cfg
- **`setActiveTip()`** - Syncs new fields when switching tips

#### shared/storage.js
- **`initialize()`** - Comprehensive migration logic for all servo fields
- **Version** - Updated to 1.2.0

#### Configuration Files
- **manifest.json** - Version 1.2.0
- **default_config.json** - Updated tip structure with new fields

---

## Variables Synced to Klipper

**Grid Configuration:**
```gcode
SAVE_VARIABLE VARIABLE=drypad_base_x VALUE=92.0
SAVE_VARIABLE VARIABLE=drypad_base_y VALUE=335.0
SAVE_VARIABLE VARIABLE=drypad_columns VALUE=35
SAVE_VARIABLE VARIABLE=drypad_rows VALUE=6
SAVE_VARIABLE VARIABLE=drypad_x_spacing VALUE=4.0
SAVE_VARIABLE VARIABLE=drypad_y_spacing VALUE=4.0
SAVE_VARIABLE VARIABLE=drypad_total_positions VALUE=210
```

**Active Tip Drypad Settings:**
```gcode
SAVE_VARIABLE VARIABLE=drypad_z VALUE=70.0
SAVE_VARIABLE VARIABLE=drypad_servo_move VALUE=0
SAVE_VARIABLE VARIABLE=drypad_servo_touch VALUE=115
SAVE_VARIABLE VARIABLE=drypad_time VALUE=3000
SAVE_VARIABLE VARIABLE=drypad_delay VALUE=2000
```

---

## Benefits

✅ **Consistent Architecture** - All stations use same servo_move/action pattern
✅ **Safer Travel** - Servo in safe position (0°) during moves
✅ **Clear Purpose** - Separate fields for travel vs. working positions
✅ **Better Readability** - Field names indicate purpose (touch, wash, waste, eject)
✅ **Automatic Migration** - Existing configs upgrade seamlessly
✅ **Backward Compatible** - Old configurations automatically converted

---

## Example Usage

### Drypad Operation:
1. Set servo to `drypad_servo_move` (0°)
2. Move to X/Y position
3. Lower to `drypad_z`
4. Set servo to `drypad_servo_touch` (115°)
5. Hold for `drypad_time` ms
6. Return servo to `drypad_servo_move` (0°)

### Wash Operation:
1. Set servo to `wash_servo_move` (0°)
2. Move to wash X/Y
3. Lower to `wash_z`
4. Set servo to `wash_servo_wash` (120°)
5. Execute wash routine
6. Return servo to `wash_servo_move` (0°)

---

## UI Changes

### Fluidics Control Tab - Drypad Section
**Before:**
- Linear Actuator Position
- Delay Time (ms)

**After:**
- Servo Move (travel): 0-180°
- Servo Touch (contact): 0-180°
- Delay Time (ms): milliseconds

### Tip Editor - All Stations
Each station now shows 5 fields instead of 4:
- **X, Y, Z** - Position coordinates
- **Servo Move** - Travel position
- **Servo [Action]** - Working position (Touch/Wash/Waste/Eject)

---

## Migration Notes

**Automatic on First Load:**
- Extension detects old field names
- Converts to new structure
- Saves updated configuration
- Console logs: "Migrated tips to v1.2.0 schema"

**Manual Check:**
After upgrading, verify in browser console (F12):
```
Migrated tips to v1.2.0 schema
```

**No Data Loss:**
- All existing positions preserved
- Old working positions become action positions
- Move positions default to 0° (safe)

---

## Testing Checklist

- [ ] Load extension, verify migration message in console
- [ ] Check Fluidics tab shows 3 drypad fields (servo_move, servo_touch, delay)
- [ ] Edit a tip, verify 5 fields per station (X, Y, Z, servo_move, servo_action)
- [ ] Modify servo positions, verify auto-save works
- [ ] Run `GET_VARIABLE` in Klipper, verify `drypad_servo_move` and `drypad_servo_touch`
- [ ] Import old v1.1.x config, verify automatic migration
- [ ] Switch active tips, verify new variables sync

---

## Upgrade Path

### From v1.1.x:
- Automatic migration on load
- No manual steps required
- All data preserved

### New Macros (Optional):
Your Klipper macros can now use:
- `printer.save_variables.variables.drypad_servo_move`
- `printer.save_variables.variables.drypad_servo_touch`

### Legacy Macros:
Still supported via tips_config structure:
- `printer.save_variables.variables.tips_config['tip0']['drypad_servo_touch']`

---

## Breaking Changes

**Field Names:**
- `drypad_servo` → `drypad_servo_touch`
- `drypad_linear_pos` → Removed (use `drypad_servo_move`)
- `wash_servo` → `wash_servo_wash`
- `waste_servo` → `waste_servo_waste`
- `eject_servo` → `eject_servo_eject`

**Note:** Migration handles these automatically, so no manual config updates needed!
