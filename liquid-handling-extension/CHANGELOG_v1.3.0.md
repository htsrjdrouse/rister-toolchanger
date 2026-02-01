# Changelog - v1.3.0

## Date: 2026-01-06

### 🎯 Major Feature: Per-Tip Position System & Tool-Specific Naming

**Concept:**
Each tip configuration now stores ALL position data (X, Y, Z) for all stations, enabling different pipette formations and tool-specific tip management.

---

## Key Changes

### 1. Drypad Now Has X/Y Positions
**Old System:** Drypad positions read from 'drypad' object (shared for all tips)
**New System:** Each tip has its own `drypad_x` and `drypad_y`

**Benefits:**
- Different pipette formations can have different drypad positions
- Tips loaded via bayonet have custom positions
- L0Tip0 (preloaded) vs L0Tip1 (loaded via Bayonet_load_1) can use different spots

### 2. Tool-Specific Tip Naming
**Old:** `Tip0`, `Tip1`, `Tip2`
**New:** `L0Tip0`, `L0Tip1`, `L1Tip0`, `L1Tip1`

**Format:** `L[tool]Tip[index]`
- `L0Tip0` - Liquid tool 0, tip 0 (preloaded, always present)
- `L0Tip1` - Liquid tool 0, tip 1 (loaded via macro)
- `L1Tip0` - Liquid tool 1, tip 0 (if you have multiple tools)

### 3. Comprehensive Station Variables
All station positions now sync to Klipper for the active tip:

**Drypad:**
- `drypad_x`, `drypad_y`, `drypad_z`
- `drypad_servo_move`, `drypad_servo_touch`
- `drypad_time`, `drypad_delay`

**Wash:**
- `wash_x`, `wash_y`, `wash_z`
- `wash_servo_move`, `wash_servo_wash`

**Waste:**
- `waste_x`, `waste_y`, `waste_z`
- `waste_servo_move`, `waste_servo_waste`

**Eject:**
- `eject_x`, `eject_y`, `eject_z`
- `eject_servo_move`, `eject_servo_eject`

---

## UI Improvements

### Fluidics Control - Drypad Section
**New Compact Layout (5 columns + 2 rows):**

Row 1: `X | Y | Z | Move° | Touch°`
Row 2: `Time (ms) | Delay (ms)`

**Before (3 columns):**
```
Servo Move (travel) | Servo Touch (contact) | Delay Time (ms)
```

**After (5 columns):**
```
X | Y | Z | Move° | Touch°
```

### Tip Editor - All Stations
**Consistent 5-column layout for all stations:**
```
X | Y | Z | Move° | [Action]°
```

Where `[Action]` is:
- Touch° for drypad
- Wash° for wash station
- Waste° for waste station
- Eject° for eject station

**Space Savings:**
- Shorter labels (Move° instead of "Servo Move")
- Consistent column count across all stations
- Cleaner, more professional appearance

---

## Technical Implementation

### Files Modified

#### ui/fluidics/fluidics.js
- **`createDefaultTip()`** - Added `drypad_x`, `drypad_y`, renamed to `L0Tip0`
- **`render()`** - Updated drypad control with 5-column layout + X/Y fields
- **`renderTipEditor()`** - Uniform 5-column layout for all stations
- **`setupTipAutoSave()`** - Added drypad X/Y/time fields
- **`autoSaveTip()`** - Saves drypad X/Y/time
- **`saveDrypadSettings()`** - Handles all 7 drypad fields
- **`saveAllStationVariables()`** - NEW: Syncs all 20 station variables to Klipper
- **`initialize()`** - Calls `saveAllStationVariables()` on startup
- **`setActiveTip()`** - Syncs all station variables when switching tips

#### shared/storage.js
- **Migration** - Adds `drypad_x`, `drypad_y` to existing tips
- **Migration** - Renames tips with L0 prefix if needed
- **Version** - Updated to 1.3.0

#### Configuration Files
- **manifest.json** - Version 1.3.0
- **default_config.json** - Updated with L0Tip0 and drypad X/Y

---

## Data Migration

**Automatic on First Load:**
1. Detects tips without `drypad_x`/`drypad_y`
2. Adds default values (92.0, 335.0)
3. Renames tips without tool prefix (Tip0 → L0Tip0)
4. Saves updated configuration

**Console Output:**
```
Migrated tips to v1.3.0 schema
```

---

## Example Use Cases

### Use Case 1: Preloaded Tip
**L0Tip0** - Always present on liquid tool
- `drypad_x: 92.0, drypad_y: 335.0` - Standard position
- `wash_x: 134.0, wash_y: 374.5` - Standard wash

### Use Case 2: Bayonet-Loaded Tip
**L0Tip1** - Loaded via `Bayonet_load_1` macro
- `drypad_x: 100.0, drypad_y: 340.0` - Offset position for different formation
- `wash_x: 140.0, wash_y: 380.0` - Offset wash position
- Different Z heights for different tip length

### Use Case 3: Multi-Tool System
**L0Tip0** - First liquid handling tool, tip 0
**L1Tip0** - Second liquid handling tool, tip 0
- Each tool can have completely different station positions

---

## Klipper Integration

### When Tip is Loaded (Example Macro):
```gcode
[gcode_macro LOAD_TIP_1]
gcode:
    # Your bayonet loading sequence here
    # ...
    
    # Set this tip as active
    SELECT_TIP TIP=1
    
    # All station variables now updated automatically:
    # drypad_x, drypad_y, wash_x, wash_y, waste_x, waste_y, etc.
```

### Accessing Variables in Macros:
```gcode
[gcode_macro GO_DRYPAD]
gcode:
    # Use standalone variables (always reflect active tip)
    G0 X{printer.save_variables.variables.drypad_x}
    G0 Y{printer.save_variables.variables.drypad_y}
    G0 Z{printer.save_variables.variables.drypad_z}
    
    # Or use tips_config structure
    {% set active_tip_num = printer.save_variables.variables.active_tip %}
    {% set tip = printer.save_variables.variables.tips_config['tip' ~ active_tip_num] %}
    G0 X{tip.drypad_x} Y{tip.drypad_y} Z{tip.drypad_z}
```

---

## Variables Synced to Klipper (20 Total)

**Drypad (7):**
```
drypad_x, drypad_y, drypad_z
drypad_servo_move, drypad_servo_touch
drypad_time, drypad_delay
```

**Wash (5):**
```
wash_x, wash_y, wash_z
wash_servo_move, wash_servo_wash
```

**Waste (5):**
```
waste_x, waste_y, waste_z
waste_servo_move, waste_servo_waste
```

**Eject (5):**
```
eject_x, eject_y, eject_z
eject_servo_move, eject_servo_eject
```

---

## Benefits

✅ **Per-Tip Positioning** - Each tip can have unique positions for all stations
✅ **Bayonet Support** - Different tips loaded dynamically have correct positions
✅ **Tool Organization** - Clear naming: L0Tip0, L0Tip1, L1Tip0
✅ **Compact UI** - 5-column layout saves space, easier to read
✅ **Complete Sync** - All 20 variables sync when switching tips
✅ **Automatic Migration** - Existing configs upgrade seamlessly
✅ **L0Tip0 Reserved** - Always the preloaded tip on liquid tool

---

## Breaking Changes

**Field Names (automatically migrated):**
- Added: `drypad_x`, `drypad_y`
- Tip names: `Tip0` → `L0Tip0`

**UI Layout:**
- Drypad control now 5 columns (was 3)
- All station editors now 5 columns (was variable)

---

## Testing Checklist

- [ ] Load extension, verify migration message
- [ ] Check tip renamed to L0Tip0
- [ ] Verify drypad shows 5 fields: X, Y, Z, Move°, Touch°
- [ ] Edit drypad X/Y, verify auto-save
- [ ] Run `GET_VARIABLE`, verify all 20 station variables
- [ ] Switch tips, verify variables update
- [ ] Create new tip (should be L0Tip1)
- [ ] Load via bayonet macro, set as active

---

## Upgrade Path

### From v1.2.x:
- Automatic migration adds `drypad_x`, `drypad_y`
- Automatic tip renaming with L0 prefix
- No manual steps required

### Recommended Workflow:
1. Load extension (auto-migration runs)
2. Review tip names (Tip0 → L0Tip0)
3. Adjust drypad X/Y if using bayonet-loaded tips
4. Test with `GET_VARIABLE` in Klipper
5. Update macros to use new variables

---

## Future Considerations

With per-tip positioning, you can now:
- Have multiple pipette formations
- Load tips dynamically and switch positions
- Support multi-tool systems (L0, L1, L2)
- Fine-tune each tip's station access independently
