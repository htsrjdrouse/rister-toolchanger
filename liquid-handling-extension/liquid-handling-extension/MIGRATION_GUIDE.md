# Migration Guide: v1.0.0 to v1.1.0

## Overview
Version 1.1.0 adds new fields to tip configurations and changes some terminology in the Object Editor. Your existing configuration will continue to work, but you may want to take advantage of the new features.

## What's Changed

### 1. Automatic Configuration Persistence
**No action required!** Your configuration now auto-saves. You no longer need to export and re-import your config file after browser restarts.

### 2. Object Editor - "Position Z"
The field previously labeled "Z Height" is now called "Position Z (bed height, mm)" for clarity.
- **This is just a label change** - your existing object Z values remain unchanged
- The field still represents the Z position of the printer bed where your object sits

### 3. New Tip Configuration Fields
Your existing tips will gain these new optional fields (with sensible defaults):

#### Drypad Enhancements
- `drypad_linear_pos`: Default value 115 (servo angle for drypad touch)
- `drypad_delay`: Default value 2000ms (how long to stay on drypad)

#### Macro Assignments
- `wash_macro`: Empty by default (uses GO_WASH command)
- `waste_macro`: Empty by default (uses GO_WASTE command)
- `eject_macro`: Empty by default (uses BAYONET_EJECT command)

## How to Upgrade

### Option 1: Automatic Upgrade (Recommended)
1. Simply load the new extension version
2. Your existing configuration will automatically gain the new fields with default values
3. Start using the new features right away!

### Option 2: Fresh Start with Import
If you prefer to be explicit:
1. Export your current configuration using the "Export Config" button
2. Update to v1.1.0
3. Import your configuration - it will be upgraded automatically
4. Configure the new features as desired

## Using New Features

### Setting Up Macro-Based Quick Actions
1. Go to **G-code Builder** tab
2. Create and save your custom macros (e.g., a special washing sequence)
3. Go to **Fluidics** tab
4. Select a tip and click edit
5. Scroll to WASH/WASTE/EJECT sections
6. Select your saved macro from the dropdown
7. Click "Save Changes"
8. Now when you click the Wash/Waste/Eject button, your custom macro runs!

### Configuring Enhanced Drypad Control
1. Go to **Fluidics** tab
2. Select a tip and click edit
3. Scroll to the DRYPAD section
4. Set "Linear Actuator Pos" (servo angle when touching drypad)
5. Set "Delay (ms)" (how long to stay on drypad before lifting)
6. Click "Save Changes"

### Quick Actions in Drypad Control
The main Drypad Control section now has inputs for:
- Linear Actuator Position (for manual testing)
- Delay Time (for manual testing)

These let you test different settings before saving them to your tip configuration.

## Backward Compatibility

- All existing configurations load without any manual intervention
- Default values are automatically added for new fields
- No data loss - all your objects, tips, and macros are preserved
- Old G-code macros continue to work as before

## Troubleshooting

### "My quick actions aren't using macros"
- Check that you've actually selected a macro in the tip editor
- Verify the macro name exists in your Saved G-code Sequences
- If the macro field is empty, the default command is used (this is normal)

### "I want to go back to default commands"
- Edit your tip in the Fluidics tab
- Set the macro dropdown to "-- None --"
- Save changes

### "My configuration didn't auto-load"
This shouldn't happen, but if it does:
1. Check browser extensions page - ensure the extension is enabled
2. Try clicking the extension icon to open the popup
3. If still having issues, use Import Config with your backup file

## Need Help?

If you encounter any issues with the migration:
1. Export your configuration first (backup!)
2. Check the browser console for any error messages
3. Refer to the updated README.md for feature documentation
4. You can always revert to v1.0.0 if needed (just don't forget to export first!)
