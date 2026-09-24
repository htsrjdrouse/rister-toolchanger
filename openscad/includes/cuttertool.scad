//include <liquid_dispenser.scad>

//liquid_dispenser_tool0();


cutter_tool();
// Wrapped so the master file can place/toggle it via a module call
// instead of it drawing itself the moment this file is included.

module cutter_tool() {
    translate([-11+60,-33+220,1]){
        cutter_finger_tool0();
        translate([0,31,5]){
            holder_half_bottom_cutter_mod();
            //holder_half_bottom_longcutter_mod();
            cutter();
            //longcutter();
        }
    }
}

// Standalone behavior: if this file is opened directly it draws the tool.
// A master file can suppress this by setting  $longcutter_managed = true;
// ($-variables use dynamic scope, so the master's value is respected here.)
//$longcutter_managed = is_undef($longcutter_managed) ? false : $longcutter_managed;
//if (!$longcutter_managed) longcutter_tool();


module holder_half_bottom_cutter_mod(){
difference(){
        color("darkgrey")import("../stls/LiquidDispenserTool0/holder_half_bottom.stl");
	translate([314,410,320])rotate([90,0,0])cylinder(d=2.8,h=30,$fn=50);
	translate([305,410,320])rotate([90,0,0])cylinder(d=2.8,h=30,$fn=50);
	translate([305+4.5+2.5,410,320-35])rotate([90,0,0])cylinder(d=4.8,h=30,$fn=50);
}
}

module holder_half_bottom_longcutter_mod(){
difference(){
	union(){
        color("darkgrey")import("../stls/LiquidDispenserTool0/holder_half_bottom.stl");
	translate([294.2,377.5,320-3.5])cube([8,15,10]);
	}
	translate([-23,-29,0]){
	translate([305,410,320])rotate([90,0,90])cylinder(d=3.5,h=30,$fn=50);
	translate([305,418,320])rotate([90,0,90])cylinder(d=3.5,h=30,$fn=50);
	}
	/*
	translate([305+4.5+2.5,410,320-35])rotate([90,0,0])cylinder(d=4.8,h=30,$fn=50);
	*/
}
}


module longcutter(){
echo(0.19*25.4);
difference(){
translate([312-10,410-13-9.6-10,320-25.6-14])cube([8,14.8,44]);
translate([312,410-13-12,320-25.6-10])rotate([-90,0,90])cylinder(d=0.19*25.4,h=0.17*25.4+14,$fn=30);
translate([-23,-29,0]){
  translate([305,410,320])rotate([90,0,90])cylinder(d=2.8,h=30,$fn=50);
  translate([305,418,320])rotate([90,0,90])cylinder(d=2.8,h=30,$fn=50);
 }
/*
translate([312,410-13,320-35])rotate([90,0,0])
#translate([0,0,-1])cylinder(d=0.19*25.4,h=0.17*25.4+4,$fn=30);
*/
}
translate([310,410-25,320-35.6])rotate([90,0,90])color("silver")difference(){
cylinder(d=0.62*25.4,h=0.17*25.4,$fn=30);
translate([0,0,-1])cylinder(d=0.19*25.4,h=0.17*25.4+4,$fn=30);
}
}



module cutter(){
echo(0.19*25.4);
difference(){
translate([312-10,410-13-9.6,320-25.6-14])cube([20,5,44]);
translate([312,410-13-13.6,320-25.6-10])rotate([-90,0,0])#cylinder(d=0.19*25.4,h=0.17*25.4+14,$fn=30);
translate([314,410-13-13.6,320-25.6+25.6])rotate([-90,0,0])#cylinder(d=3.6,h=0.17*25.4+14,$fn=30);
translate([305,410-13-13.6,320-25.6+25.6])rotate([-90,0,0])#cylinder(d=3.6,h=0.17*25.4+14,$fn=30);
/*
translate([312,410-13,320-35])rotate([90,0,0])
#translate([0,0,-1])cylinder(d=0.19*25.4,h=0.17*25.4+4,$fn=30);
*/
}
translate([312,410-13,320-35])rotate([90,0,0])color("silver")difference(){
cylinder(d=0.62*25.4,h=0.17*25.4,$fn=30);
translate([0,0,-1])cylinder(d=0.19*25.4,h=0.17*25.4+4,$fn=30);
}
}


module cutter_finger_tool0() {
    translate([0,31,5]) {
	//translate([0,-5,0])librevalve_assy();
	/*
	translate([0,1,-5])import("../stls/LiquidDispenserTool0/LibreValve_liquidhandling_pinchvalve_4set.stl");
	translate([0,1,-5])import("../stls/LiquidDispenserTool0/LibreValve_knob_teeth_4.stl");
	color("black")translate([0,1,-5])import("../stls/LiquidDispenserTool0/MG90S_4.stl");
	*/

        // Dock and backplate
        //translate([0,-30,0])import("../stls/LiquidDispenserTool0/dock_body_linearactuator_10mmlonger_3_shorter.stl");
        #import("../stls/LiquidDispenserTool0/lineux_backplate_for_linearactuator_modified.stl");
        color("darkgrey")import("../stls/LiquidDispenserTool0/lineux_backplate_for_linearactuator_modified001.stl");

        // Holder components
        color("darkgrey")import("../stls/LiquidDispenserTool0/holder_half_bottom.stl");
        color("darkgrey")import("../stls/LiquidDispenserTool0/holder_half_top.stl");

        // Pipette system
        translate([0,0,0]){
        //translate([0,0,5])color("darkgrey")import("../stls/LiquidDispenserTool0/linearactuator_pipette_holder_4pipette_luerlock_18mm.stl");
        //translate([0,0,5])color("darkgrey")import("../stls/LiquidDispenserTool0/pipette_holder_4tip_luerlock_lid_18mm.stl");
        translate([0,0,5])color("plum")import("../stls/LiquidDispenserTool0/pipette_holder_4tip_luerlock_lid_18mm_slotdie.stl");
        translate([0,0,5])color("lavender")import("../stls/LiquidDispenserTool0/linearactuator_rack_adjuster.stl");
        translate([0,0,5])color("mediumaquamarine")import("../stls/LiquidDispenserTool0/linearactuator_pipette_holder_4pipette_luerlock_18mm_slotdie.stl");
        translate([0,0,5])color("lightpink")import("../stls/LiquidDispenserTool0/compression_washers.stl");
        translate([0,0,5])color("silver")import("../stls/LiquidDispenserTool0/m3_screw_rackadjusters.stl");
	/*
	*/
	}
        //color("lightblue")import("../stls/LiquidDispenserTool0/pipette_assembly.stl");
        color("white")import("../stls/LiquidDispenserTool0/luerlock_connector_slotdie.stl");
        //color("lime")import("../stls/LiquidDispenserTool0/pipette_10g_slotdie.stl");
        color("lime")translate([0,0,12])import("../stls/CutterTools/airknife_finger.stl");

        // Linear actuator components

        color("black")import("../stls/LiquidDispenserTool0/servo_linearactuator.stl");
        color("lightsteelblue")import("../stls/LiquidDispenserTool0/pinion.stl");
        
        // Sled and cap
        color("darkgrey")import("../stls/LiquidDispenserTool0/sled_bottom_no_limit_switch_protrusion.stl");
        //color("darkgrey")import("../stls/LiquidDispenserTool0/tubing_straight_sledcap.stl");

        color("red")scale([1,1,1])translate([342.5,414.5,386.8])rotate([0,90,-90])mirror([0,1,0])import("../stls/LiquidDispenserTool0/sled_cap.stl");
        
        // Tubing and umbilical
        //translate([0,-30,-5]) import("../stls/LiquidDispenserTool0/tubing_to_pipettes_valve_side_umbilical.stl");
        //translate([0,0,-15])color("white")import("../stls/LiquidDispenserTool0/umbilical_cord.stl");
        //translate([0,-32.5,0])color("white")import("../stls/LiquidDispenserTool0/umbilical_extrusion_1.stl");

	/*
        translate([406.4,685.4,480])cube([9,2,255]);
        translate([406.4,685.4,480+255])rotate([90,0,0])cube([9,2,321.5]);
        translate([406.4,685.4-321.5,480+207])rotate([0,0,0])cube([9,2,50]);
        translate([406.4-90,685.4-322,470+115])rotate([0,40,0])cube([9,2,143]);
        translate([406.4-90,685.4-322,470])rotate([0,0,0])cube([9,2,115]);
	*/
       
        // Tip removal and loading
	/*
        translate([-47+270,-31,0]) {
            //import("../stls/PipetteRemoval/piezo_dispenser_assy_remover.stl");
            #translate([47,32,-4+17.6])import("../stls/PipetteRemoval/luerlock_dispenser_assy_remover.stl");
            import("../stls/PipetteRemoval/singlechannel_tipremoval_base.stl");
        }
	*/

}
}
