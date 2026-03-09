// LIQUID DISPENSER TOOL 0 (4-channel pipette system)
// OpenSCAD Sources: openscad_sources/liquid_dispenser/

module liquid_dispenser_tool0() {
    translate([0,31,5]) {
        // Dock and backplate
        import("../stls/LiquidDispenserTool0/dock_body_linearactuator_10mmlonger_3.stl");
        import("../stls/LiquidDispenserTool0/lineux_backplate_for_linearactuator_modified.stl");
        color("darkgrey")import("../stls/LiquidDispenserTool0/lineux_backplate_for_linearactuator_modified001.stl");

        // Holder components
        color("darkgrey")import("../stls/LiquidDispenserTool0/holder_half_bottom.stl");
        color("darkgrey")import("../stls/LiquidDispenserTool0/holder_half_top.stl");
        // Pipette system
        translate([0,0,5])color("darkgrey")import("../stls/LiquidDispenserTool0/linearactuator_pipette_holder_4pipette_luerlock.stl");
	color("lightblue")import("../stls/LiquidDispenserTool0/pipette_assembly.stl");
        // Linear actuator components
	color("darkgrey")import("../stls/LiquidDispenserTool0/servo_linear_actuator_rack_toolchanger_4channel.stl");
        color("black")import("../stls/LiquidDispenserTool0/servo_linearactuator.stl");
        color("darkgrey")import("../stls/LiquidDispenserTool0/pinion.stl");
        
        // Sled and cap
        color("darkgrey")import("../stls/LiquidDispenserTool0/sled_bottom_no_limit_switch_protrusion.stl");
        color("darkgrey")import("../stls/LiquidDispenserTool0/tubing_straight_sledcap.stl");
        
        // Tubing and umbilical
        translate([0,-30,-5]) import("../stls/LiquidDispenserTool0/tubing_to_pipettes_valve_side_umbilical.stl");
        color("white")import("../stls/LiquidDispenserTool0/umbilical_cord.stl");
        color("white")import("../stls/LiquidDispenserTool0/umbilical_extrusion_1.stl");
       
	/* 
        // Tip removal and loading
        translate([-47,-31,0]) {
            //import("../stls/PipetteRemoval/piezo_dispenser_assy_remover.stl");
            translate([47,32,-4])import("../stls/PipetteRemoval/luerlock_dispenser_assy_remover.stl");
            import("../stls/PipetteRemoval/singlechannel_tipremoval_base.stl");
        }
	*/
        
        // LED components
        translate([-90,-250,-5]) color("white") {
            import("../stls/LiquidDispenserTool0/led_diffuser_back.stl");
            import("../stls/LiquidDispenserTool0/led_diffuser.stl");
        }
    }
}
