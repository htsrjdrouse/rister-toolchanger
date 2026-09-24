/*
import("Industrial_Pinch_Roller_Lower_U-Frame.stl");
import("Industrial_Pinch_Roller_Bearing_Adjustment_Rod.stl");
import("Industrial_Pinch_Roller_Frame_Nut.stl");
import("Industrial_Pinch_Roller_Frame_Rods.stl");
import("Industrial_Pinch_Roller_Adjustment_Nut.stl");
*/


translate([325,300,205])rotate([0,0,-90])pinch_roller();
translate([325,460,205])rotate([0,0,-90])pinch_roller();

translate([-120,0,0]){
translate([325,300,205])rotate([0,0,-90])pinch_roller();
translate([325,460,205])rotate([0,0,-90])pinch_roller();
}


module pinch_roller(){
import("Industrial_Pinch_Roller_Upper_U-Frame.stl");
translate([75,0,0])rotate([0,0,0])import("Industrial_Pinch_Roller_Upper_U-Frame.stl");

translate([0,0,14]){
translate([-45.25,-54.3,30])rotate([0,0,90])color("pink")import("Industrial_Pinch_Roller_Bearing_Block.stl");
translate([-45.25+75,-54.3,30])rotate([0,0,90])color("pink")import("Industrial_Pinch_Roller_Bearing_Block.stl");
translate([9.5,69,36.5])rotate([0,90,0])color("lime")import("Industrial_Pinch_Roller_Roller.stl");
}

translate([0,0,-17]){
translate([-45.25,-54.3,30])rotate([0,0,90])color("pink")import("Industrial_Pinch_Roller_Bearing_Block.stl");
translate([-45.25+75,-54.3,30])rotate([0,0,90])color("pink")import("Industrial_Pinch_Roller_Bearing_Block.stl");
translate([9.5,69,36.5])rotate([0,90,0])color("lime")import("Industrial_Pinch_Roller_Roller.stl");
}
}


