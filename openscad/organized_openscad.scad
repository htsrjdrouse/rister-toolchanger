// Rister Toolchanger - Clean Organized Build
// Using FreeCAD-exported STLs where available, parametric where useful
include <scad/tslot.inc.scad>

// =============================================================================
// COMPONENT INCLUDES
// =============================================================================
include <includes/x_axis.scad>
include <includes/y_axis.scad>
include <includes/xy_joints.scad>
include <includes/extrusions_hfsb5.scad>
include <includes/extrusions_hgsb5.scad>
include <includes/frame_corners.scad>
include <includes/panels_skirts.scad>
include <includes/motor_mount_a.scad>
include <includes/motor_mount_b.scad>
include <includes/z_axis.scad>
include <includes/belt_tensioners.scad>
include <includes/toolhead_carriage.scad>
include <includes/bed_assembly.scad>
include <includes/liquid_dispenser.scad>
include <includes/peek_nozzle.scad>
include <includes/luerlock_nozzle_4channel.scad>
include <includes/tip_case.scad>
include <includes/camera_tool.scad>
include <includes/extruder_tool0.scad>
include <includes/extruder_tool1.scad>
include <includes/syringe_pump.scad>
include <includes/washstation.scad>
include <includes/microfluidics.scad>
include <includes/cabling.scad>
include <includes/klicky_probe.scad>

// =============================================================================
// CONFIGURATION
// =============================================================================

// Toggle between FreeCAD STLs and parametric models
USE_FREECAD_STLS = true;
USE_PARAMETRIC_EXTRUSIONS = false;

// =============================================================================
// VISIBILITY TOGGLES - Set to true/false to show/hide components
// =============================================================================

/*
SHOW_X_AXIS = true;
SHOW_Y_AXIS = true;
SHOW_XY_JOINTS = true;
SHOW_EXTRUSIONS_HFSB5 = true;
SHOW_EXTRUSIONS_HGSB5 = true;
SHOW_FRAME_CORNERS = true;
SHOW_PANELS_SKIRTS = true;
SHOW_MOTOR_MOUNT_A = true;
SHOW_MOTOR_MOUNT_B = true;
SHOW_Z_AXIS = true;
SHOW_Z_CARRIAGES = true;
SHOW_ENDSTOPS = true;
SHOW_BELT_TENSIONERS = true;
SHOW_TOOLHEAD_CARRIAGE = true;
SHOW_BED_ASSEMBLY = true;
*/
SHOW_LIQUID_DISPENSER = true;

/*
SHOW_LUERLOCK_NOZZLE = true;
//SHOW_PEEK_NOZZLE = true;
SHOW_TIP_CASE = true;
SHOW_CAMERA_TOOL = true;
SHOW_EXTRUDER_TOOL0 = true;
SHOW_EXTRUDER_TOOL1 = true;
*/
//SHOW_SYRINGE_PUMP = true;
/*
SHOW_WASHSTATION = true;
SHOW_MICROFLUIDICS = true;
//SHOW_CABLING = true;
//SHOW_KLICKY_PROBE = true;
*/

// =============================================================================
// POSITION OFFSETS
// =============================================================================

// FreeCAD STL assembly offset
FREECAD_OFFSET = [0, -32, 0];

// Parametric extrusion offset
PARAMETRIC_OFFSET = [0, 170 - 1.5 - 15 - 17, 58 - 1.2 - 57];  // [0, 136.5, -0.2]

// X Gantry position (for parametric)
X_GANTRY_X = -30 + 4 + 70 + 1;      // = 45
X_GANTRY_Y = 300 - 129 + 15;         // = 186  
X_GANTRY_Z = 400 - 21.8 - 3 - 15;    // = 360.2
X_GANTRY_LENGTH = 510;

// =============================================================================
// FREECAD STL ASSEMBLY
// =============================================================================

module freecad_assembly() {
    translate(FREECAD_OFFSET) {
        // Motion System
        if (SHOW_X_AXIS) x_axis_components();
        if (SHOW_Y_AXIS) y_axis_components();
        if (SHOW_XY_JOINTS) xy_joints();
        
        // Frame & Extrusions
        if (SHOW_EXTRUSIONS_HFSB5) extrusions_hfsb5();
        if (SHOW_EXTRUSIONS_HGSB5) extrusions_hgsb5();
        if (SHOW_FRAME_CORNERS) frame_corners();
        if (SHOW_PANELS_SKIRTS) panels_skirts();
        
        // Motors & Drive System
        if (SHOW_MOTOR_MOUNT_A) motor_mount_a();
        if (SHOW_MOTOR_MOUNT_B) motor_mount_b();
        if (SHOW_Z_AXIS) z_axis();
        if (SHOW_Z_CARRIAGES) z_carriages();
        if (SHOW_ENDSTOPS) endstops();
        if (SHOW_BELT_TENSIONERS) belt_tensioners();
        
        // Toolhead & Bed
        if (SHOW_TOOLHEAD_CARRIAGE) toolhead_carriage();
        if (SHOW_BED_ASSEMBLY) bed_assembly();
        
        // Tools
        if (SHOW_LIQUID_DISPENSER) liquid_dispenser_tool0();
        if (SHOW_PEEK_NOZZLE) peek_nozzle_4channel();
        if (SHOW_LUERLOCK_NOZZLE) luerlock_nozzle_4channel();
        if (SHOW_TIP_CASE) tip_case_system();
        if (SHOW_CAMERA_TOOL) camera_tool();
        if (SHOW_EXTRUDER_TOOL0) extruder_tool0();
        if (SHOW_EXTRUDER_TOOL1) extruder_tool1();
        
        // Fluid System
        if (SHOW_SYRINGE_PUMP) syringe_pump_system();
        if (SHOW_WASHSTATION) washstation();
        if (SHOW_MICROFLUIDICS) microfluidics_system();
        
        // Accessories
        if (SHOW_CABLING) cabling_system();
        if (SHOW_KLICKY_PROBE) klicky_probe();
    }
}

// =============================================================================
// PARAMETRIC EXTRUSIONS
// =============================================================================

module parametric_extrusions() {
    translate(PARAMETRIC_OFFSET) {
        // X gantry rail (parametric tslot20)
        color("silver")
        translate([X_GANTRY_X, X_GANTRY_Y - 15, X_GANTRY_Z + 15])
        rotate([0, 90, 0])
        tslot20(X_GANTRY_LENGTH);
    }
}

// =============================================================================
// COMPLETE ASSEMBLY
// =============================================================================

module complete_assembly() {
    if (USE_FREECAD_STLS) {
        freecad_assembly();
    }
    
    if (USE_PARAMETRIC_EXTRUSIONS) {
        parametric_extrusions();
    }
}

// =============================================================================
// BUILD
// =============================================================================

complete_assembly();

// Coordinate axes for reference
color("red") cylinder(r=0.5, h=50);        // X-axis
color("green") rotate([0,90,0]) cylinder(r=0.5, h=50);   // Y-axis
color("blue") rotate([90,0,0]) cylinder(r=0.5, h=50);    // Z-axis
