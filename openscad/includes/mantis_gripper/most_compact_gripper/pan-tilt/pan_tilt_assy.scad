module pantilt_assy(){

union(){
import("Top.stl");
difference(){
translate([-3.15,-15.5,95])color("pink")cube([6,15,14]);
translate([-3.15-30,-15.5+4.4,101.3])rotate([0,90,0])cylinder(d=3,h=50,$fn=30);
translate([-3.15-30,-15.5+4.4+6,101.3])rotate([0,90,0])cylinder(d=3,h=50,$fn=30);
}
}
//import("Mount.stl");
import("Joint.stl");
import("Bot.stl");

import("Stand.stl");
translate([472,540,-600])rotate([0,-90,90])color("grey")import("servo.stl");
translate([-542,-590,-412])rotate([90,0,90])color("grey")import("servo.stl");
}
