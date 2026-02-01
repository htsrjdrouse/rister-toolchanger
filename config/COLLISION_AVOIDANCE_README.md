# Collision Avoidance System

Prevents the toolhead from crashing into objects on the bed during tool changes.

## Quick Start

1. **Define objects** in the Objects Editor (Chrome extension)
2. **Sync to Klipper**: Run `python3 sync_objects.py` 
3. **Reload in Klipper**: Run `SYNC_COLLISION_OBJECTS` in console
4. **Verify**: Run `LIST_COLLISION_OBJECTS`

## How It Works

When `LOAD_TOOL` or `UNLOAD_TOOL` runs:
1. System calculates the XY travel path bounding box
2. Finds all objects that intersect with that path
3. Calculates safe Z = tallest intersecting object + clearance
4. Lifts Z, moves XY, then descends

## Console Commands

### Core Commands
| Command | Description |
|---------|-------------|
| `SYNC_COLLISION_OBJECTS` | Reload objects from variables.cfg into memory |
| `LIST_COLLISION_OBJECTS` | Show all configured objects |
| `SAFE_MOVE X=100 Y=200` | Move to position, auto-avoiding objects |
| `TEST_COLLISION_PATH END_X=100 END_Y=200` | Test without moving |

### Configuration
| Command | Description |
|---------|-------------|
| `ENABLE_COLLISION_AVOIDANCE` | Turn on collision checking |
| `DISABLE_COLLISION_AVOIDANCE` | Turn off (dangerous!) |
| `SET_COLLISION_CLEARANCE CLEARANCE=20` | Set clearance above objects (default: 15mm) |

### Managing Objects
| Command | Description |
|---------|-------------|
| `ADD_COLLISION_OBJECT NAME=plate X_MIN=100 X_MAX=200 Y_MIN=100 Y_MAX=200 Z_HEIGHT=50` | Add object manually |
| `TOGGLE_COLLISION_OBJECT NAME=wellplate ENABLE=false` | Disable an object |
| `REMOVE_COLLISION_OBJECT NAME=plate` | Remove an object |

### Quick Presets
| Command | Description |
|---------|-------------|
| `ADD_WELLPLATE X=100 Y=150` | Add 96-well plate (127.8x85.5x14mm) |
| `ADD_RESERVOIR X=100 Y=150` | Add reservoir (150x50x40mm) |
| `ADD_TUBE_RACK X=100 Y=150` | Add tube rack (130x90x80mm) |

## Sync Script Usage

```bash
# Auto-detect paths
python3 sync_objects.py

# Specify paths
python3 sync_objects.py \
  --config ~/liquid_handling_config.json \
  --variables ~/printer_data/config/variables.cfg

# Preview without writing
python3 sync_objects.py --dry-run
```

## Object Format in variables.cfg

```ini
obj_wellplate_enabled = 'true'
obj_wellplate_x_min = 100
obj_wellplate_x_max = 227.8
obj_wellplate_y_min = 150
obj_wellplate_y_max = 235.5
obj_wellplate_z_height = 14
obj_wellplate_z_clearance = 10
```

## Workflow

### Adding Objects via Objects Editor (Recommended)
1. Open Objects Editor in Chrome extension
2. Add/modify objects visually
3. Save config
4. SSH to printer: `python3 ~/printer_data/config/sync_objects.py`
5. Home the printer (`G28`) — **collision objects sync automatically!**

> **Note:** G28 is wrapped to auto-run `SYNC_COLLISION_OBJECTS` after homing.
> You can also run it manually anytime.

### Adding Objects via Console (Quick)
```gcode
ADD_WELLPLATE X=100 Y=150 NAME=my_plate
; or
ADD_COLLISION_OBJECT NAME=beaker X_MIN=200 X_MAX=250 Y_MIN=200 Y_MAX=250 Z_HEIGHT=80
```

### Temporarily Disabling an Object
```gcode
TOGGLE_COLLISION_OBJECT NAME=wellplate ENABLE=false
; ... do your work ...
TOGGLE_COLLISION_OBJECT NAME=wellplate ENABLE=true
```

## Troubleshooting

**Objects not loading?**
- Check `LIST_COLLISION_OBJECTS` output
- Ensure variables.cfg has `obj_NAME_*` entries
- Run `SYNC_COLLISION_OBJECTS` to reload

**Tool still crashing?**
- Check object Z_HEIGHT is correct (measure actual height)
- Increase Z_CLEARANCE for tall/fragile objects
- Run `TEST_COLLISION_PATH` to debug

**Want to bypass collision avoidance?**
- `DISABLE_COLLISION_AVOIDANCE` (be careful!)
- Or use direct `G1` moves instead of `SAFE_MOVE`

## Files

- `collision_avoidance.cfg` - Main macro file
- `sync_objects.py` - Sync script
- `variables.cfg` - Object definitions (auto-updated by sync)
- `unified_toolchanger.cfg` - Modified to use SAFE_MOVE
