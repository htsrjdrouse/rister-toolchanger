// LIQUID DISPENSER TOOL 0 (4-channel pipette system)
// OpenSCAD Sources: openscad_sources/liquid_dispenser/

//include <../scad/pinchvalve/LibreValve_liquidhandling.scad>
//include <../scad/luerlock_syringe_dispenser_model_18mm.scad>
//include <includes/x_axis.scad>

module liquid_dispenser_tool0() {
    translate([0,31,5]) {
	//translate([0,-5,0])librevalve_assy();

	translate([0,1,-5])import("../stls/LiquidDispenserTool0/LibreValve_liquidhandling_pinchvalve_4set.stl");
	translate([0,1,-5])import("../stls/LiquidDispenserTool0/LibreValve_knob_teeth_4.stl");
	translate([0,1,-5])import("../stls/LiquidDispenserTool0/MG90S_4.stl");

	color("lightblue")import("../stls/LiquidDispenserTool0/pipette_assembly.stl");

        // Dock and backplate
        translate([0,-30,0])import("../stls/LiquidDispenserTool0/dock_body_linearactuator_10mmlonger_3.stl");
        import("../stls/LiquidDispenserTool0/lineux_backplate_for_linearactuator_modified.stl");
        color("darkgrey")import("../stls/LiquidDispenserTool0/lineux_backplate_for_linearactuator_modified001.stl");

        // Holder components
        color("darkgrey")import("../stls/LiquidDispenserTool0/holder_half_bottom.stl");
        color("darkgrey")import("../stls/LiquidDispenserTool0/holder_half_top.stl");
        // Pipette system
        translate([0,0,5])color("darkgrey")import("../stls/LiquidDispenserTool0/linearactuator_pipette_holder_4pipette_luerlock_18mm.stl");
        translate([0,0,5])color("darkgrey")import("../stls/LiquidDispenserTool0/pipette_holder_4tip_luerlock_lid_18mm.stl");

        // Linear actuator components

        color("black")import("../stls/LiquidDispenserTool0/servo_linearactuator.stl");
        color("darkgrey")import("../stls/LiquidDispenserTool0/pinion.stl");
        
        // Sled and cap
        color("darkgrey")import("../stls/LiquidDispenserTool0/sled_bottom_no_limit_switch_protrusion.stl");
        //color("darkgrey")import("../stls/LiquidDispenserTool0/tubing_straight_sledcap.stl");

        color("red")scale([1,1,1])translate([342.5,414.5,386.8])rotate([0,90,-90])mirror([0,1,0])import("../stls/LiquidDispenserTool0/sled_cap.stl");
        
        // Tubing and umbilical
        //translate([0,-30,-5]) import("../stls/LiquidDispenserTool0/tubing_to_pipettes_valve_side_umbilical.stl");
        color("white")import("../stls/LiquidDispenserTool0/umbilical_cord.stl");
	/*
        translate([406.4,685.4,480])cube([9,2,255]);
        translate([406.4,685.4,480+255])rotate([90,0,0])cube([9,2,321.5]);
        translate([406.4,685.4-321.5,480+207])rotate([0,0,0])cube([9,2,50]);
        translate([406.4-90,685.4-322,470+115])rotate([0,40,0])cube([9,2,143]);
        translate([406.4-90,685.4-322,470])rotate([0,0,0])cube([9,2,115]);
	*/
        translate([0,-32.5,0])color("white")import("../stls/LiquidDispenserTool0/umbilical_extrusion_1.stl");
       
        // Tip removal and loading
        translate([-47+270,-31,0]) {
            //import("../stls/PipetteRemoval/piezo_dispenser_assy_remover.stl");
            translate([47,32,-4+18])import("../stls/PipetteRemoval/luerlock_dispenser_assy_remover.stl");
            import("../stls/PipetteRemoval/singlechannel_tipremoval_base.stl");
        }
        
        // LED components
        translate([-90,-250,-5]) color("white") {
            import("../stls/LiquidDispenserTool0/led_diffuser_back.stl");
            import("../stls/LiquidDispenserTool0/led_diffuser.stl");
        }

    }
}
