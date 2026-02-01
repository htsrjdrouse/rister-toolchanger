# Liquid Handling Extension v1.1.1 - Setup & Testing Guide

## Installation

1. **Unzip the extension:**
   - Extract `liquid-handling-extension-v1_1_1-FIXED.zip` to a folder

2. **Load in Chrome:**
   - Open Chrome and go to `chrome://extensions/`
   - Enable "Developer mode" (toggle in top right)
   - Click "Load unpacked"
   - Select the extracted `liquid-handling-extension-updated` folder

3. **Configure Klipper URL:**
   - The extension is pre-configured for:
     - `http://192.168.1.89/*`
     - `http://mainsailos.local/*`
     - `http://localhost/*`
   - If your Klipper is at a different address, edit `manifest.json` and update `host_permissions`

## First-Time Setup

### 1. Import Your Configuration

1. Click the extension icon in Chrome toolbar
2. Go to **G-code Builder** tab
3. Click **Import Configuration**
4. Select your `liquid_handling_config_2026-01-06.json` file
5. Configuration will be loaded with your:
   - Printer area (380x480mm)
   - Objects (bed, wash, waste, drypad, small_dispenser_box)
   - Tips (Tip0 with all settings)
   - Saved macros

### 2. Verify Drypad Sync

After importing, the extension will automatically sync drypad configuration to Klipper.

**Check the browser console (F12) for:**
```
Drypad grid configuration saved to Klipper: {
  baseX: 92,
  baseY: 335,
  columns: 35,
  rows: 6,
  xSpacing: 4,
  ySpacing: 4,
  totalPositions: 210
}
```

**Verify in Klipper console:**
```
GET_VARIABLE
```

You should see all these variables in variables.cfg:

**Grid Configuration:**
- drypad_base_x = 92.0
- drypad_base_y = 335.0
- drypad_columns = 35
- drypad_rows = 6
- drypad_x_spacing = 4.0
- drypad_y_spacing = 4.0
- drypad_total_positions = 210

**Active Tip Settings:**
- drypad_z = 70.0
- drypad_servo = 115
- drypad_time = 3000
- drypad_linear_pos = 115
- drypad_delay = 2000

## Testing the Touch Drypad Function

### Test 1: Basic TOUCH_DRY Command (Console)

In Klipper console, run:
```
TOUCH_DRY
```

**Expected behavior:**
1. System calculates position based on current_position variable (starts at 1)
2. Moves to drypad position 1: X=92.0, Y=335.0
3. Executes touch sequence
4. Increments position for next call
5. Shows message: "Next TOUCH_DRY will use position 2"

### Test 2: Specific Position (Console)

In Klipper console, run:
```
TOUCH_DRY_AT KEY=15
```

**Expected behavior:**
1. Calculates position 15 in the 35-column grid
2. Position 15 is row 0, column 14
3. X = 92.0 + (14 × 4.0) = 148.0
4. Y = 335.0 + (0 × 4.0) = 335.0
5. Shows: "Drypad position 15: X148.0 Y335.0"

### Test 3: Touch Drypad Button (Extension)

1. Open extension
2. Go to **Fluidics Control** tab
3. Click **"Touch Drypad"** button

**Expected behavior:**
- Sends TOUCH_DRY command to Klipper
- Uses auto-increment position
- No error messages

### Test 4: Touch At Specific Position (Extension)

1. In **Fluidics Control** tab
2. Enter a position number (1-210) in the input field
3. Click **"Touch At #"** button

**Expected behavior:**
- Sends TOUCH_DRY_AT KEY=<number> to Klipper
- Moves to that specific drypad position
- No error messages

## Modifying Drypad Configuration

### In Object Editor:

1. Go to **Object Editor** tab
2. Click on **"drypad"** in the object list
3. Modify any of these settings:
   - **Position X/Y (posx, posy)**: Base position of drypad grid
   - **Margin X/Y**: Offset from base position to first position
   - **Array Columns/Rows**: Number of positions in grid
   - **Column/Row Spacing**: Distance between positions

4. Click **"Save Changes"**

**Automatic sync happens:**
- Extension saves to local storage
- Immediately syncs to Klipper variables.cfg
- Alert confirms save

### Manual Sync:

If you manually edit variables.cfg or want to force a sync:

1. Go to **Fluidics Control** tab
2. Click **"🔄 Sync Drypad Grid to Klipper"** button
3. Confirmation alert will appear

## Troubleshooting

### Problem: "Malformed command 'RESPOND MSG="Touch Dry'"

**This was the original bug - now fixed!**

If you still see this error:
1. Verify you're using v1.1.1 of the extension
2. Check that drypad variables exist in variables.cfg
3. Try manual sync button

### Problem: Drypad positions are wrong

**Cause:** Variables.cfg has old values

**Solution:**
1. Click "🔄 Sync Drypad Grid to Klipper" in Fluidics tab
2. Verify with GET_VARIABLE in Klipper console
3. Test with TOUCH_DRY_AT KEY=1

### Problem: Variables not saving

**Cause:** Klipper can't write to variables.cfg

**Check:**
1. File permissions on variables.cfg
2. Klipper has [save_variables] section in printer.cfg:
   ```
   [save_variables]
   filename: ~/printer_data/config/variables.cfg
   ```

## Configuration Files Reference

### Your Current Drypad Setup:
- Base Position: (92.0, 335.0)
- Margins: X=7, Y=5
- First Position: (92.0+7=99.0, 335.0+5=340.0) 
- Grid: 35 columns × 6 rows = 210 positions
- Spacing: 4mm between positions

### Position Calculation:
```
row = (position - 1) ÷ columns
col = (position - 1) mod columns
X = base_x + (col × x_spacing)
Y = base_y + (row × y_spacing)
```

Example: Position 50
- row = 49 ÷ 35 = 1
- col = 49 mod 35 = 14
- X = 92.0 + (14 × 4.0) = 148.0
- Y = 335.0 + (1 × 4.0) = 339.0

## Support

For issues or questions:
1. Check browser console (F12) for errors
2. Check Klipper console for G-code errors
3. Verify GET_VARIABLE shows correct values
4. Review CHANGELOG_v1.1.1.md for technical details
