// =============================================================================
// kiro_circulab.scad  -  Config-driven master assembly
// =============================================================================
// Goal: reconfigure robotic setups for client demos by editing ONE table,
// without slow pure-OpenSCAD geometry. All heavy parts stay as STL imports
// (cheap to render). The only parametric geometry is optional low-poly tubing.
//
// HOW TO USE (vibe-coding workflow):
//   1. Scroll to the TOOL REGISTRY below.
//   2. Set  show=true/false  to add/remove a tool from the scene.
//   3. Change the  offset=[x,y,z]  to move a tool.
//   4. (Optional) Edit TUBE_ROUTES to change syringe->tool plumbing.
//   That's it. No need to touch the module code.
// =============================================================================

include <scad/tslot.inc.scad>

// Tell longcutter.scad not to draw itself on include; we place it via registry.
$longcutter_managed = true;

// -----------------------------------------------------------------------------
// COMPONENT INCLUDES  (STL-backed modules - fast)
// -----------------------------------------------------------------------------

//stationary objects
/*
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
//include <includes/target_holder.scad>

//include <includes/luerlock_nozzle_4channel.scad>
include <includes/klicky_probe.scad>
include <includes/longcutter_dock.scad>
include <includes/cutter_dock.scad>
include <includes/gripper_dock.scad>

//moving objects
//include <includes/x_axis.scad>
//include <includes/toolhead_carriage.scad>
//include <includes/liquid_dispenser.scad>
*/

//include <includes/bed_assembly.scad>
//include <includes/bed_assembly_circulab.scad>

//include <includes/pinch_roller/emboss_pinchroller.scad>
include <includes/my_decapper_design_basic.scad>



//include <includes/longcuttertool.scad>
//include <includes/mantis_gripper/mantis_gripper.scad>
//include <includes/cuttertool.scad>

//include <includes/liquid_dispenser.scad>


/*
include <includes/syringe_pump.scad>
include <includes/washstation.scad>
include <includes/microfluidics.scad>
include <includes/cabling.scad>
*/
/*
include <includes/tip_case.scad>
include <includes/camera_tool.scad>
include <includes/extruder_tool0.scad>
include <includes/extruder_tool1.scad>
*/

// -----------------------------------------------------------------------------
// GLOBAL CONFIG
// -----------------------------------------------------------------------------
FREECAD_OFFSET = [0, -32, 0];   // world offset for the whole FreeCAD assembly

SHOW_TUBING    = false;         // parametric tubing off by default (keep it fast)
TUBE_DIAM      = 2.0;           // mm outer diameter of drawn tubes
TUBE_FN        = 8;             // LOW poly on purpose - do NOT raise for demos

// =============================================================================
// TOOL REGISTRY  <-- EDIT THIS TABLE TO RECONFIGURE
// =============================================================================
// Each row: [ "name", show, offset[x,y,z], "module_name" ]
//   show        : true = draw it, false = hide/remove
//   offset      : extra translate applied on top of the tool's baked position
//   module_name : the OpenSCAD module that draws the tool (do not change)
//
// NOTE: geometry positions are currently baked into the STLs, so offset is a
// nudge relative to where the part already sits. To relocate a tool onto
// another tool's spot, set the delta between them here.
// -----------------------------------------------------------------------------
TOOLS = [
    // structural / motion (leave these on)
    ["x_axis",            true,  [0,0,0], "x_axis_components"],
    ["y_axis",            true,  [0,0,0], "y_axis_components"],
    ["xy_joints",         true,  [0,0,0], "xy_joints"],
    ["extrusions_hfsb5",  true,  [0,0,0], "extrusions_hfsb5"],
    ["extrusions_hgsb5",  true,  [0,0,0], "extrusions_hgsb5"],
    ["frame_corners",     true,  [0,0,0], "frame_corners"],
    ["panels_skirts",     true,  [0,0,0], "panels_skirts"],
    ["motor_mount_a",     true,  [0,0,0], "motor_mount_a"],
    ["motor_mount_b",     true,  [0,0,0], "motor_mount_b"],
    ["z_axis",            true,  [0,0,0], "z_axis"],
    ["z_carriages",       true,  [0,0,0], "z_carriages"],
    ["endstops",          true,  [0,0,0], "endstops"],
    ["belt_tensioners",   true,  [0,0,0], "belt_tensioners"],
    ["toolhead_carriage", true,  [0,0,0], "toolhead_carriage"],
    ["bed_assembly",      true,  [0,0,0], "bed_assembly"],

    // tools (the interesting ones to reconfigure per client)
    ["liquid_dispenser",  true,  [0,0,0], "liquid_dispenser_tool0"],
    ["longcutter",        true,  [0,0,0], "longcutter_tool"],
    ["luerlock_nozzle",   true,  [0,0,0], "luerlock_nozzle_4channel"],
    ["tip_case",          true,  [0,0,0], "tip_case_system"],
    ["target_holder",     true,  [0,0,0], "target_holder"],
    ["camera_tool",       false, [0,0,0], "camera_tool"],          // removed
    ["extruder_tool0",    false, [0,0,0], "extruder_tool0"],
    ["extruder_tool1",    false, [0,0,0], "extruder_tool1"],

    // fluid + support systems
    ["syringe_pump",      true,  [0,0,0], "syringe_pump_system"],
    ["washstation",       true,  [0,0,0], "washstation"],
    ["microfluidics",     true,  [0,0,0], "microfluidics_system"],
    ["cabling",           true,  [0,0,0], "cabling_system"],
    ["klicky_probe",      true,  [0,0,0], "klicky_probe"],
];

// =============================================================================
// TUBE ROUTES  <-- EDIT to change syringe -> tool plumbing
// =============================================================================
// The syringe pump has 4 channels (0..3). Route each to a destination point.
// Only drawn when SHOW_TUBING = true. Endpoints are placeholders you tune once.
//   [ channel, [from x,y,z], [to x,y,z], "color" ]
//
// Current intent: 2 tubes -> liquid_dispenser, 2 tubes -> longcutter.
// Coordinates below are approximate anchors; adjust after a render.
TUBE_ROUTES = [
    [0, [30, 40, 200], [300, 410, 320], "deepskyblue"],   // -> liquid_dispenser
    [1, [30, 60, 200], [305, 410, 320], "deepskyblue"],   // -> liquid_dispenser
    [2, [30, 80, 200], [300, 380, 300], "orange"],        // -> longcutter
    [3, [30,100, 200], [305, 380, 300], "orange"],        // -> longcutter
];

// -----------------------------------------------------------------------------
// LOW-COST PARAMETRIC TUBE  (straight low-poly cylinder between two points)
// -----------------------------------------------------------------------------
module tube(p1, p2, d=TUBE_DIAM) {
    v = p2 - p1;
    len = norm(v);
    if (len > 0.001) {
        // rotate a +Z cylinder to align with vector v
        ax = acos(v[2] / len);                 // polar angle from Z
        az = atan2(v[1], v[0]);                 // azimuth
        translate(p1)
        rotate([0, 0, az]) rotate([0, ax, 0])
        cylinder(d=d, h=len, $fn=TUBE_FN);
    }
}

module draw_tubes() {
    if (SHOW_TUBING) {
        for (r = TUBE_ROUTES) {
            color(r[3]) tube(r[1], r[2], TUBE_DIAM);
        }
    }
}

// -----------------------------------------------------------------------------
// REGISTRY DISPATCH
// -----------------------------------------------------------------------------
// Maps a module-name string to an actual module call. OpenSCAD can't call a
// module by string, so we branch once here. Add a line if you add a new tool.
module call_tool(name) {
    if      (name == "x_axis_components")        x_axis_components();
    else if (name == "y_axis_components")        y_axis_components();
    else if (name == "xy_joints")                xy_joints();
    else if (name == "extrusions_hfsb5")         extrusions_hfsb5();
    else if (name == "extrusions_hgsb5")         extrusions_hgsb5();
    else if (name == "frame_corners")            frame_corners();
    else if (name == "panels_skirts")            panels_skirts();
    else if (name == "motor_mount_a")            motor_mount_a();
    else if (name == "motor_mount_b")            motor_mount_b();
    else if (name == "z_axis")                   z_axis();
    else if (name == "z_carriages")              z_carriages();
    else if (name == "endstops")                 endstops();
    else if (name == "belt_tensioners")          belt_tensioners();
    else if (name == "toolhead_carriage")        toolhead_carriage();
    else if (name == "bed_assembly")             bed_assembly();
    else if (name == "liquid_dispenser_tool0")   liquid_dispenser_tool0();
    else if (name == "longcutter_tool")          longcutter_tool();
    else if (name == "luerlock_nozzle_4channel") luerlock_nozzle_4channel();
    else if (name == "tip_case_system")          tip_case_system();
    else if (name == "target_holder")            target_holder();
    else if (name == "camera_tool")              camera_tool();
    else if (name == "extruder_tool0")           extruder_tool0();
    else if (name == "extruder_tool1")           extruder_tool1();
    else if (name == "syringe_pump_system")      syringe_pump_system();
    else if (name == "washstation")              washstation();
    else if (name == "microfluidics_system")     microfluidics_system();
    else if (name == "cabling_system")           cabling_system();
    else if (name == "klicky_probe")             klicky_probe();
    else echo(str("WARNING: unknown tool module '", name, "'"));
}

// -----------------------------------------------------------------------------
// ASSEMBLY
// -----------------------------------------------------------------------------
module complete_assembly() {
    translate(FREECAD_OFFSET) {
        for (t = TOOLS) {
            if (t[1]) {                 // show flag
                translate(t[2])         // per-tool offset
                    call_tool(t[3]);    // module name
            }
        }
        draw_tubes();
    }
}

complete_assembly();

