include<assembly.scad>

carriage_assy();



//daksh_extruder_bambu_mount();

//translate([2.7+21.75,130-0.65,-150])color("red")cylinder(r=3.8/2,h=300,$fn=300);
//translate([2.7-21.75,130-0.65,-150])color("red")cylinder(r=3.8/2,h=300,$fn=300);


//translate([9,-6.5,22])locking_plate_fix();

//translate([0,-6,22.5])locking_plate_guidepin();

//translate([0,180,20])rotate([0,0,180])import("Back_Plate.stl");



//extruder_assy();

//translate([-5.5,180+2.276,21.4])rotate([0,180,180])import("CarriageBodyRearSpring.stl");
//import("Carriage_Body_Rear_DB.stl");



//carriage_body_front_beltmod();
//carriage_body_rear();

module locking_plate_guidepin(){
difference(){
//translate([12,-0,-1])import("Locking_Plate.stl");
union(){
//translate([12,-0,-1])import("Locking_Plate.stl");
translate([-0.0985,6.4,-22.7])color("lime")import("locking_plate_lineux_one.stl");
}
translate([0,108-3,0])color("silver"){
translate([-3,-6,12])rotate([90,0,0])cylinder(r2=3.8/2,r1=4,h=3,$fn=300);
translate([-3,0,12])rotate([90,0,0])cylinder(r=3.8/2,h=12,$fn=300);
translate([-3,0,-12])rotate([90,0,0])cylinder(r=3.8/2,h=12,$fn=300);
translate([-3,-6,-12])rotate([90,0,0])cylinder(r2=3.8/2,r1=4,h=3,$fn=300);
}
}
}




//color("red")filament_path();
//rotate([0,180,0])toolhead_assy();

module carriage_assy(){

translate([0,-6,22.5])import("locking_plate_guidepin.stl");
color("grey")translate([0,170+10-3.6,22])rotate([0,0,180])import("radial_cooling_5015.stl");
color("pink")translate([0,170+10-178-2.35,22-21.8-0.5])rotate([0,0,0])import("5015_adapter_standoff.stl");
translate([0,200-20,21])color("lime")rotate([0,0,180])import("duct.stl");

import("carriage_body_top.stl");
import("carriage_body_middle.stl");
import("carriage_body_bottom.stl");
//import("carriage_body_front.stl");
translate([0,2,0])import("CarriageBodyFront_editable_belt_holes.stl");
//#carriage_body_rear();
import("carriage_body_rear.stl");
import("slider.stl");
}


module carriage_body_front_beltmod(){

difference(){
//import("carriage_body_front.stl");
import("CarriageBodyFront_editable.stl");
//import("Carriage_Body_A.stl");
translate([8,13,8])cube([8,20,8]);
translate([8,13,8+10])cube([8,20,8]);
translate([8-30,13,8])cube([8,20,8]);
translate([8-30,13,8+10])cube([8,20,8]);
}

}


module carriage_body_rear(){

difference(){
union(){
//import("carriage_body_rear.stl");
translate([-5.5,180+2.276,21.4])rotate([0,180,180])import("CarriageBodyRearSpring.stl");
color("silver")translate([-2.5,100-13.9,-3.55])rotate([-90,0,0])cylinder(r=(8.8+0.5+1)/2,h=3.8+1.589,$fn=6);
color("silver")translate([-2.5-16.2,100-13.9,-3.5+51])rotate([-90,0,0])rotate([0,0,90])cylinder(r=(8.8+0.5+1)/2,h=3.8+1.589,$fn=6);
color("silver")translate([-2.5+15.82,100-13.9,-3.5+51])rotate([-90,0,0])rotate([0,0,90])cylinder(r=(8.8+0.5+1)/2,h=3.8+1.589,$fn=6);
}
translate([16.75,82.45,-30])cylinder(r=3/2,h=300,$fn=300);
translate([-22.55,82.45,-30])cylinder(r=3/2,h=300,$fn=300);

color("silver")translate([-2.5,100-13.9,-3.5])rotate([-90,0,0])cylinder(r=(9.05)/2,h=3.8+1.589+3,$fn=6);
color("silver")translate([-2.5-16.2,100-13.9,-3.5+51])rotate([-90,0,0])rotate([0,0,90])cylinder(r=(9.05)/2,h=3.8+1.589+3,$fn=6);
color("silver")translate([-2.5+15.82,100-13.9,-3.5+51])rotate([-90,0,0])rotate([0,0,90])cylinder(r=(9.05)/2,h=3.8+1.589+3,$fn=6);
}
}

/*
*/
