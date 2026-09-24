/*
import("BearingFix_2x.stl");
import("Claw_3_l.stl");
*/




module mantis_claw_assy(){
translate([-85,-21.5,23.])rotate([0,180,-130])color("lightblue")import("Claw_3_r.stl");
translate([48.6,-9,12])color("lime")rotate([0,0,-56])import("Claw_3_l.stl");

/*
translate([-85+57.3,-21.5-100+2.3,23.])rotate([0,180,-130+50])color("lightblue")import("Claw_3_r.stl");
translate([48.6,-9,12])color("lime")rotate([0,0,-56-50])import("Claw_3_l.stl");
*/

translate([48.7,-9,26])color("pink")import("BearingFix_2x.stl");
translate([48.7,-9,6])color("pink")import("BearingFix_2x.stl");
translate([129,99,34])rotate([0,180,90])import("Mount_B.stl");
translate([0,0,0])import("ServoMount.stl");
translate([0,0,-9]){
translate([9,-8.5,17+3])import("Gear.stl");
translate([-1,-18.5,-20])servo();
}
}
/*
*/

module servo(){
 bcl = 0.4;
 color([bcl,bcl,bcl])
 cube([40.75,19.85,35]);
 difference(){
 color([bcl,bcl,bcl])translate([-(55.5-40.74)/2,0,35-8])cube([55.5,19.85,2.5]);
 translate([-(55.5-40.74)/2+3.8,0+4.5,35-8-10])cylinder(r=3.7/2,h=20);
 translate([-(55.5-40.74)/2+3.8,0+4.5+10,35-8-10])cylinder(r=3.7/2,h=20);
 translate([-(55.5-40.74)/2+3.8+49,0+4.5,35-8-10])cylinder(r=3.7/2,h=20);
 translate([-(55.5-40.74)/2+3.8+49,0+4.5+10,35-8-10])cylinder(r=3.7/2,h=20);
 }
 cl = 0.9;
 translate([0,0,0])color([cl,cl,cl]){
 translate([10,10,30])cylinder(r=8/2,h=12);
 //translate([10,10,41])cylinder(r=30/2,h=5);
 }
 /*
 */

}

