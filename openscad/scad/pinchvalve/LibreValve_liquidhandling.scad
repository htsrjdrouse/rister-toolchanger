
//librevalve_assy();

module librevalve_assy(){
LibreValve_liquidhandling_pinchvalve_4set();
for(i=[0:3]){
translate([353-i*19,424,410])rotate([0,90,90])import("LibreValve_knob_teeth.stl");
color("green")translate([359-19*i,573.9,532.5])rotate([0,90,180])import("MG90S.stl");
}
}


/*
difference(){
translate([-17.7,5,0])rotate([90,0,0])import("SG90_HORN_TIGHTER.STL");

#translate([0,0,-2])cylinder(d=8,h=5,$fn=100);
difference(){
cylinder(d=48,h=5,$fn=100);
cylinder(d=6,h=5,$fn=100);
}
}
*/


/*
union(){
x = 0.95;
#translate([0,0,7])scale([x,x,1])import("SG90_HORN_TIGHTER_cut.STL");
#translate([0,0,5])scale([x,x,1])import("SG90_HORN_TIGHTER_cut.STL");
import("LibreValve_knob.stl");
difference(){
color("pink")translate([0,0,7.5])cylinder(d=5.3,h=4.5,$fn=100);
color("pink")translate([0,0,7.5])cylinder(d=4.9,h=4.5,$fn=100);
}
}
*/


module LibreValve_liquidhandling_pinchvalve_4set(){
//import("tubing_straight_sledcap.stl");
translate([20,0,9.5]){
translate([333,420,400])rotate([0,90,90])rotate([0,0,180])import("LibreValve_housing.stl");
translate([333-19.,420,400])rotate([0,90,90])rotate([0,0,180])import("LibreValve_housing.stl");
translate([333-(19.*2),420,400])rotate([0,90,90])rotate([0,0,180])import("LibreValve_housing.stl");
translate([333-(19.*3),420,400])rotate([0,90,90])rotate([0,0,180])import("LibreValve_housing.stl");
}
difference(){
union(){
translate([332.7,415+5+2.5,339.5])cube([13,5,49]);
//#translate([266+20,415+2.5,388])cube([77,5,32.5]);
}
translate([334,415+10,355])#cylinder(d=5,h=100,$fn=100);;
translate([339,435,345.2])rotate([90,0,0])cylinder(d=3.8,h=30,$fn=100);
translate([339,435,345.2+37.5])rotate([90,0,0])cylinder(d=3.8,h=30,$fn=100);
}
}

