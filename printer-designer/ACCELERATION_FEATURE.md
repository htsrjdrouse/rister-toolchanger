# Line Dispenser Acceleration & Per-Line Override Feature

## Overview
Added global acceleration control and per-line E multiplier and acceleration overrides to the line dispenser G-code generator.

## Changes Made

### 1. Default Settings (DEFAULT_SETTINGS)
Added three new settings:
- `dispenseAccel: 500` - Default acceleration during dispensing (mm/s²)
- `restoreAccel: 3000` - Acceleration to restore after all lines complete (mm/s²)
- `perLineOverrides: []` - Array storing per-line E multiplier and acceleration values

### 2. UI Changes

#### Motion Section (🚀 Motion)
Added two new input fields:
- **Dispense Acceleration (mm/s²)** - Global default acceleration for dispensing
  - Step: 50, Min: 50, Default: 500
- **Restore Acceleration (mm/s²)** - Acceleration to restore after dispensing
  - Step: 100, Min: 100, Default: 3000

#### Per-Line Overrides Section
Added collapsible section below E Multiplier:
- **Disclosure control**: Click to expand/collapse
- **Dynamic rows**: One row per line (updates with "Number of Lines")
- **Three columns per row**:
  1. Line label ("Line 1", "Line 2", etc.)
  2. E Multiplier (numeric input, step 0.1, min 0.1)
  3. Acceleration in mm/s² (numeric input, step 50, min 50)

#### Smart Default Behavior
- New rows initialize with global E Multiplier and Dispense Acceleration values
- When global values change, only non-edited rows update automatically
- Manually edited rows retain their custom values
- Edit tracking persists during session

### 3. G-code Generation Changes

#### Acceleration Commands
- **At start of line set**: `M204 S{globalDispenseAccel}`
- **Before each line**: `M204 S{perLineAccel[i]}` only if different from previous line
- **After all lines**: `M204 S{restoreAccel}`

#### Per-Line E Calculation
Each line now uses its own E multiplier:
```javascript
lineEDisplacement = volumePerLine * perLineMultiplier[i]
```

#### Comment Updates
Line comments now show the E multiplier used:
```gcode
; Line 1 (E mult: 1.50)
```

### 4. State Management
Added:
- `editedOverrides` - Set tracking which lines have been manually edited
- `overridesExpanded` - Boolean controlling disclosure state
- `useEffect` hooks to:
  - Initialize per-line overrides when numLines changes
  - Update non-edited overrides when global values change
- `updateLineOverride()` - Function to update individual line overrides

## Use Case Example

**Problem**: Lines 1-2 under-dispense due to stepper ramp-up, while lines 3-5 are accurate.

**Solution**:
1. Set global E Multiplier to 1.0 and Dispense Acceleration to 500 mm/s²
2. Expand "Per-Line Overrides"
3. Set Line 1: E Mult = 1.5, Accel = 300
4. Set Line 2: E Mult = 1.3, Accel = 400
5. Lines 3-5 automatically use global defaults (1.0, 500)

**Generated G-code**:
```gcode
M204 S500 ; set dispense acceleration

; Line 1 (E mult: 1.50)
M204 S300
G1 Y135.000 E7.50 F300

; Line 2 (E mult: 1.30)
M204 S400
G1 Y135.000 E14.00 F300

; Line 3 (E mult: 1.00)
M204 S500
G1 Y135.000 E19.00 F300

; Line 4 (E mult: 1.00)
; (no M204 - same as previous)
G1 Y135.000 E24.00 F300

; Line 5 (E mult: 1.00)
; (no M204 - same as previous)
G1 Y135.000 E29.00 F300

G1 Z5 F500 ; lift to travel height
M204 S3000 ; restore acceleration
```

## Technical Details

### Redundant M204 Elimination
The code tracks `prevAccel` and only emits `M204` when acceleration changes between lines, reducing G-code size.

### Backward Compatibility
- Old saved settings without new fields will use defaults
- `perLineOverrides` array initializes automatically on first use
- All existing functionality preserved

### localStorage Persistence
All settings including per-line overrides are saved to browser localStorage and restored on page reload.

## Files Modified
- `client/src/components/ShapeDesigner.js` - All changes in single file

## Testing
Build tested successfully:
```bash
cd printer-designer/client
npm run build
# Compiled successfully ✓
```
