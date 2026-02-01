# Object Names Reference

## Correct Object Names

The extension expects these object names in the Object Editor:

- **drypad** - Drypad array grid
- **wash** - Wash station (NOT wash_station)
- **waste** - Waste station (NOT waste_station)
- **bed** - Print bed (for visualization)
- **small_dispenser_box** - Dispenser storage (optional)

## Current Behavior

**Drypad:**
- Extension reads X/Y position from 'drypad' object
- Automatically calculates grid positions
- Syncs to Klipper variables

**Wash/Waste:**
- Currently stored in tip configuration (tip.wash_x, tip.wash_y, etc.)
- Objects are for visualization only
- Each tip can have different wash/waste positions

## Potential Future Feature

**Auto-populate from Objects:**
If you want the extension to read wash/waste X/Y from objects (like it does for drypad):

1. Extension would look for 'wash' and 'waste' objects
2. Read posx + marginx for X coordinate
3. Read posy + marginy for Y coordinate
4. Auto-populate tip configuration

**Benefits:**
- Single source of truth for positions
- Visual alignment in Object Editor
- Less manual configuration

**Trade-offs:**
- All tips would use same wash/waste positions
- Less flexibility for per-tip customization

## Current Config Structure

Your configuration has:
- Objects: `wash_station` and `waste_station` ← Update these to `wash` and `waste`
- Tips: Individual wash_x, wash_y, waste_x, waste_y per tip

## Migration Note

If you're importing your existing config:
1. Open Object Editor
2. Click on "wash_station" object
3. Change name to "wash"
4. Save
5. Repeat for "waste_station" → "waste"

Or manually edit your JSON config file to rename the objects.
