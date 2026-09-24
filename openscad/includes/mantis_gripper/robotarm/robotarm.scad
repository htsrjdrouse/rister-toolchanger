
module robotarm(){
//import("ArmWrist005.stl");

/*
difference(){
import("Arm60mm_repaired.stl");
//import("robotArm75mm.stl");
translate([-60,-5,80])#cube([50,80,30]);
}
*/
translate([-298,589,463])rotate([0,180,180])color("pink")import("Arm60mm_cut.stl");
//translate([0,60,135])rotate([90,0,0])
translate([0,-135,60])rotate([-90,0,0]){
import("ArmWrist003.stl");
import("ArmWrist004.stl");
import("ArmWrist002.stl");
import("ArmWrist005_repaired.stl");
import("ArmWrist007.stl");
color("peru"){
import("ArmWrist008.stl");
import("ArmWrist009.stl");
}
translate([91,72,72])rotate([0,0,180])color("blue")import("MG90S.stl");
translate([96,-74.8,218])rotate([-90,0,180])color("blue")import("MG90S.stl");
translate([118,86,104.5])rotate([0,180,90])color("blue")import("MG90S.stl");
}
/*
*/
}
