include<pan-tilt/pan_tilt_assy.scad>

//pantilt_small_gripper();

module pantilt_small_gripper(){
pantilt_assy();
translate([0,1,115.3])rotate([90,0,0])rotate([-16,0,0])small_gripper();
}
//translate([0,30,0])cylinder(d=18,h=65,$fn=30);


module small_gripper(){
import("blocco_pinzablocco_pinza_eco_orizzontale_b.stl");
import("dito_pinza_mg90s.stl");
import("iso_14580_m2x8_4.8.stl");
import("m1_6_8mm_1.stl");
import("m1_6_8mm.stl");
color("black")import("MG90_ldb_v2.stl");
#import("MG90S_ARM_singolo.stl");
color("blue")scale([1,1,1])import("MG90S.stl");
}


