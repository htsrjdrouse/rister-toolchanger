# Rister Toolchanger - OpenSCAD Organization

This directory contains the organized OpenSCAD assembly and source files for the Rister 4-dispenser toolchanger system.

## Directory Structure

```
openscad/
├── README.md                    (this file)
├── organized_openscad.scad      (main assembly file)
├── stls/                        (STL files organized by component)
│   ├── A/                       (CoreXY Motor A assembly)
│   ├── B/                       (CoreXY Motor B assembly)
│   ├── Z/                       (Z-axis components)
│   ├── Bed/                     (Build plate assembly)
│   ├── BeltTensioner/           (Belt tensioning system)
│   ├── Carriage/                (Toolhead carriage)
│   ├── Endstop/                 (XY endstops)
│   ├── ZParts/                  (Z-axis carriages)
│   ├── LiquidDispenserTool0/    (4-channel pipette tool)
│   ├── peek_nozzle_4channel/    (PEEK nozzle assembly)
│   ├── TipCase/                 (Tip storage system)
│   ├── PipetteRemoval/          (Tip removal system)
│   ├── RaspiCameraTool/         (Camera tool)
│   ├── ExtruderTool0/           (Extruder tool #1)
│   ├── ExtruderTool1/           (Extruder tool #2)
│   ├── Syringepump_valve/       (Syringe pump & valve system)
│   ├── Washstation/             (Wash station)
│   ├── Cabling/                 (Cable management)
│   └── Klicky/                  (Klicky probe system)
└── scad/                        (OpenSCAD source files)
    ├── tslot.inc.scad           (T-slot extrusion library)
    ├── xyendstop.scad           (XY endstop generator)
    ├── carriage_v2_3dify.scad   (Current carriage version)
    ├── carriage_v2.scad         (Previous carriage version)
    ├── carriage.scad            (Original carriage)
    ├── assembly.scad            (Assembly reference)
    ├── linearactuator.scad      (Linear actuator system)
    ├── holder_half.scad         (Pipette holder)
    ├── pipette_process.scad     (Pipette processing)
    ├── pipette_wick_assembly.scad (Wick assembly)
    ├── fourchannel_pipetteloadingmodule_holder.scad
    ├── rack_renamed.scad        (Rack system)
    ├── luerlock.scad            (Luer lock fittings)
    ├── washstation.scad         (Wash station)
    ├── multichannel_cameramount.scad (Camera mount)
    ├── bom_multichannel_syringe.scad (BOM generator)
    ├── bom_camera.scad          (Camera BOM)
    ├── luerlock_components/     (Luer lock library)
    └── pipetting/               (Pipetting library)
```

## Main Assembly File

**`organized_openscad.scad`** - Complete assembly with all tools and components

### Configuration Options

The main assembly file has toggle switches to control what's displayed:

```openscad
USE_FREECAD_STLS = true;           // Show imported STL components
USE_PARAMETRIC_EXTRUSIONS = true;  // Show parametric T-slot extrusions
```

### Component Sections

The assembly is organized into these major sections:

1. **Frame & Motion System**
   - X-axis (MGN9 rail, 510mm extrusion)
   - Y-axis (dual MGN12 rails, 660mm extrusions)
   - CoreXY motor assemblies (A & B)
   - Belt tensioners and idlers

2. **Z-Axis System**
   - 4x NEMA17 motors
   - 4x 300mm lead screws
   - Z carriages (left/right pairs)

3. **Bed Assembly**
   - Voron Trident 350mm build plate
   - Bed frame extrusions (518mm & 548mm)
   - Z bed mounts

4. **Toolhead Carriage**
   - Carriage body (bottom, middle, rear, top, front)
   - 5015 cooling system
   - Toolchanger interface (locking plate, slider)

5. **Tool Systems**
   - **Liquid Dispenser Tool 0** - 4-channel pipette system
   - **PEEK Nozzle 4-Channel** - Precision nozzle assembly
   - **TipCase System** - Tip storage and loading
   - **Raspberry Pi Camera Tool** - Vision system
   - **Extruder Tool 0** - Sherpa Micro + Bambu hotend
   - **Extruder Tool 1** - Duplicate extruder
   - **Klicky Probe** - Bed leveling probe

6. **Microfluidics Support Systems**
   - **Syringe Pump & Valve System** - 4-channel precision liquid control
   - **Wash Station** - Automated tip cleaning and drying
   - **Cabling System** - Voron-style cable management

## Source File Documentation

Each component section in `organized_openscad.scad` includes comprehensive documentation:

```openscad
// =====================================================================
// COMPONENT NAME
// =====================================================================
// OpenSCAD Sources: openscad_sources/component_name/
//   - source_file_1.scad (description)
//   - source_file_2.scad (description)
//
// Include Dependencies:
//   - tslot.inc.scad (T-slot library)
//
// Source Dependencies (STLs imported by .scad files):
//   - imported_part_1.stl
//   - imported_part_2.stl
//
// Generated STLs:
//   - output_part_1.stl (below)
//   - output_part_2.stl (below)
// =====================================================================
```

This creates a complete **audit trail** from parametric sources to final STL outputs.

## Working with Source Files

### OpenSCAD Source Files (`scad/` directory)

These are the parametric source files that generate STL components. They may import other STLs as dependencies.

**Key files:**
- `tslot.inc.scad` - Include this in any file that needs T-slot extrusions
- `carriage_v2_3dify.scad` - Current version for toolhead carriage
- `linearactuator.scad` - Linear actuator for liquid dispenser
- `holder_half.scad` - Pipette holder components

### Dependency Management

Source files may have:
1. **Include dependencies** - Other .scad files (e.g., `include <tslot.inc.scad>`)
2. **Import dependencies** - STL files used as components (e.g., `import("part.stl")`)

All dependencies should be in the same `scad/` directory with simple filenames (no paths).

### Automated Dependency Copying

Use the `copy_stl_dependencies.sh` script to automatically find and copy all dependencies:

```bash
cd scad/
./copy_stl_dependencies.sh your_file.scad
```

The script will:
- ✅ Find all STL imports recursively
- ✅ Find all include files recursively
- ✅ Copy all dependencies to the target directory
- ✅ Fix all import/include paths to use simple filenames
- ✅ Create audit trail of what was found

## Viewing the Assembly

To view the complete assembly:

1. Open `organized_openscad.scad` in OpenSCAD
2. Use the configuration toggles to show/hide sections
3. Individual tool sections can be commented out for faster rendering

**Tip:** For faster rendering, start with just the frame:
```openscad
USE_FREECAD_STLS = true;
USE_PARAMETRIC_EXTRUSIONS = false;
```

Then comment out tool sections you don't need to see.

## Development Workflow

### Adding New Components

1. **Create/edit OpenSCAD source** in appropriate subdirectory
2. **Generate STL** from OpenSCAD
3. **Place STL** in appropriate `stls/` subdirectory
4. **Update organized_openscad.scad** with new import statements
5. **Document sources** in the component header comments

### Modifying Existing Components

1. **Edit source file** in `scad/` directory
2. **Regenerate STL** from OpenSCAD
3. **Replace STL** in `stls/` subdirectory
4. **Update documentation** if dependencies changed

### Version Control Best Practices

- Commit both source files (.scad) AND generated STLs (.stl)
- Update documentation comments when changing dependencies
- Use descriptive commit messages referencing which tool/component changed

## File Naming Conventions

### STL Files
- Descriptive names: `carriage_body_bottom_trident_v2.stl`
- Versioned when applicable: `_v2`, `_v3`
- Positioned versions: `_positioned` (for assemblies)
- Duplicates numbered: `_1`, `_2` (for multiple instances)

### OpenSCAD Files
- Source files: `component_name.scad`
- Version progression: `component.scad` → `component_v2.scad` → `component_v2_3dify.scad`
- Include files: `library_name.inc.scad`

## Key Technologies

- **Motion System:** CoreXY with MGN linear rails
- **Z-Axis:** 4x independent lead screw motors
- **Build Volume:** 350mm (Voron Trident compatible)
- **Tool System:** Lineux-style magnetic toolchanger
- **Liquid Handling:** 4-channel servo-driven linear actuators
- **Nozzles:** 150μm PEEK nozzles for perovskite ink dispensing

## Technical Specifications

**Linear Rails:**
- X-axis: MGN9 450mm
- Y-axis: 2x MGN12 600mm
- Z-axis: 4x lead screw with MGN12 guides

**Extrusions:**
- Frame: Misumi HFSB5-2020 and HGSB5-2020
- X-gantry: 510mm
- Y-rails: 660mm

**Tools:**
- 1x Liquid Dispenser (4-channel pipette system)
- 2x Extruders (Sherpa Micro + Bambu hotend)
- 1x Camera Tool (Raspberry Pi + Arducam)
- 1x Klicky Probe

**Microfluidics Infrastructure:**
- 4-channel syringe pump with servo valves
- Peristaltic pumps for wash/waste
- Automated wash station
- Pressure compensation vessel
- Liquid level sensing

## Related Documentation

- Main project README: `../../README.md`
- Klipper configuration: `../../klipper_config/`
- Hardware BOM: `../../docs/BOM.md` (if exists)

## Contributing

When contributing changes to the OpenSCAD files:

1. Test compile all affected files
2. Update documentation comments
3. Regenerate STLs if source files changed
4. Update this README if structure changes
5. Submit PR with clear description

## License

[Add your license information here]

## Contact

Project maintained by: Richard (HTS Resources LLC)
GitHub: https://github.com/htsrjdrouse/rister-toolchanger

---

*Last updated: 2025-01-01*
