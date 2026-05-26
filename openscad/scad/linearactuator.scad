include <holder_half.scad>
include <rack_renamed.scad>
include <multichannel_cameramount.scad>
include <fourchannel_pipetteloadingmodule_holder.scad>

//holder_half_bottom();
//servo_linear_actuator_rack_toolchanger_4channel();

//lineux_linearactuator_assy();
//fourchannel_pipette_loading_module();
//translate([53,200-25-1.5,-22])rotate([0,0,180])color("pink")import("carriage_assy.stl");

//lineux_backplate_for_linearactuator_modified();
/*
*/




module led_holder(){
translate([75,147.1,-100])rotate([0,0,-90])difference(){
translate([-20+5,1.539+45-15,-6.6+49.35-10+10+62])translate([80,-50,60])cube([20-5-0.05,15,110+24-0-49.35-72+72-65]);
translate([0,0,0]){
translate([20-0.3+60-3.4+1.8-2,-27-0-0.2+16.8,150-0.3+24.2])color("pink")rotate([0,90,0])rotate([0,0,0])cylinder(r=9.5/2,h=21,$fn=300);
translate([20-0.3+60-3.4+1.8-2-5+0.35,-27-0-0.2+16.8-15,150-0.3+24.2-5.8])color("pink")cube([7-0.35,21.04,4+5.8+4]);
translate([20-0.3+60-3.4+1.8-2-5+0.35,-27-0-0.2+16.8-15,150-0.3+24.2-5.8-4])color("pink")cube([3,21.04,4+5.8+4-1]);
}
}
}

/*
translate([0.5,0,0]){
//import("holder_half_bottom.stl");
//import("holder_half_top.stl");
translate([70-1,-0.45,-35-2])color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,90])holder_half_top();
}
*/



//translate([70-1,-0.45,-35-2])color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,90])holder_half_top();


module lineux_backplate_for_linearactuator_modified(){
led_holder();

translate([47,6.1465+16.23,-3]){
///import("sherpa_micro_ebb_mount.stl");
import("Sherpa_Micro_Ebb_Mount_.stl");

translate([0,-22.2,0])difference(){
translate([-3.5,70-0.085,90+12])color("pink")cube([16,12,15]);
translate([-3.5+4-0.75,70+6.15-2.6,90+5-2])color("pink")cube([9.5,2.3,25]);
//translate([-3.5+8,70+6.15+24,90+5-2+12])rotate([90,0,0])cylinder(r=2.8/2,h=30,$fn=300);
translate([-3.5+8,70+6.15+24-20,90+5-2+16])rotate([90,0,0])cylinder(r=2.8/2,h=30,$fn=300);
}

//translate([0,-16.25,0])import("sherpa_micro_ebb_mount.stl");
}
//translate([55+2,70.5+6+10,14])rotate([0,90,-90])servo();
difference(){
translate([19,20,-100])color("lime")rotate([0,0,90])lineux_backplate_for_linearactuator();
hull(){
translate([19+50-2,60+7,-100+35+60])cylinder(r=5/2,h=30,$fn=300);
translate([19+50-2,60,-100+35+60])cylinder(r=5/2,h=30,$fn=300);
}

translate([-20,0,0])hull(){
translate([19+50-2,60+7,-100+35+60])cylinder(r=5/2,h=30,$fn=300);
translate([19+50-2,60,-100+35+60])cylinder(r=5/2,h=30,$fn=300);
}
translate([55,70.5+6,14])rotate([0,90,-90])servo();
translate([55+2,70.5+6,14])rotate([0,90,-90])servo();
}
}

/*
*/

//holder_half_top();



/*
translate([47+2,0,0]){
import("back_plate.stl");
translate([0,0,0])rotate([-0,0,0])color("lime")
import("sherpa_micro_bambu.stl");
translate([0,0,-0])import("cowl_exo_klicky.stl");
}
*/

//translate([0,180,20])rotate([0,0,180])
//lineux_toolchanger_linearactuator();

//translate([8-6.5+46,-46+50,20])rotate([-0,0,0])color("lime")import("sherpa_micro_bambu.stl");

//translate([19,20,-100])color("lime")rotate([0,0,90])lineux_backplate_for_linearactuator();
//color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,90])holder_half_top();



module lineux_ledarray_assy(){
lineux_backplate_for_linearactuator_modified();

/*
translate([37.5,32,-42.0])color("pink")rotate([0,-90,-90])import("sled_bottom_no_limit_switch_protrusion.stl");
translate([24,0-10+4,-4])rotate([90,0,90])import("pinion.stl");
translate([55,70.5,14])rotate([0,90,-90])servo();
translate([22-0.5,-5.25,-100-40+10+5-20+31])rotate([0,0,90])servo_linear_actuator_rack_toolchanger_4channel();
translate([0.5,0,0]){
translate([70-1,-0.45,-35-2])color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,90])holder_half_top();
translate([70-1,-0.45,-35-2])color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,90])holder_half_bottom();
}
*/




}











module lineux_linearactuator_assy(){
translate([37.5,32,-42.0])color("pink")rotate([0,-90,-90])import("sled_bottom_no_limit_switch_protrusion.stl");
/*
translate([47,6.1465,-3]){
//import("sherpa_micro_ebb_mount.stl");

import("Ebb36_sherpa_micro_spacer.stl");
import("Ebb36_sherpa_micro_spacer_1.stl");
translate([15,6.5,9])import("ebb36_brd.stl");
}
*/
translate([24,0-10+4,-4])rotate([90,0,90])import("pinion.stl");
translate([55,70.5,14])rotate([0,90,-90])servo();
#translate([22-0.5,-5.25,-100-40+10+5-20+31])rotate([0,0,90])servo_linear_actuator_rack_toolchanger_4channel();
lineux_backplate_for_linearactuator_modified();
translate([0.5,0,0]){
translate([70-1,-0.45,-35-2])color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,90])holder_half_top();
translate([70-1,-0.45,-35-2])color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,90])holder_half_bottom();
}
}




/*
//translate([-30,20,-100])color("pink")rotate([0,0,90])import("lineux_backplate_for_linearactuator.stl");
translate([70-1,-0.45,-35-2])color("lime"){
color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,90])holder_half_bottom();
color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,90])holder_half_top();
}
*/
//holder_half_top();

/*

*/


//translate([-30,20,-100])rotate([0,0,90])import("holder_half_top.stl");
//translate([-30,20,-100])rotate([0,0,90])import("holder_half_bottom.stl");



module holder_half_top(){
color("lightblue")translate([64-1.5,-19.5,70-5])rotate([-90,0,90])difference(){
union(){
holder_half();
//translate([40+14-14,0+11-4,0])cube([10.7+8+6,20-11+4,20.5+0]);
}
//translate([40+14-14+19.6,0+11-4+7.15,14.25])rotate([0,90,0])cylinder(r=8/2,h=30,$fn=300);
//translate([40+14-14+19.6-0.2,0+11-4+7.17,14.25-0.9])rotate([0,0,0])cylinder(r=2/2,h=30,$fn=300);
translate([-18+1+41.5,0,-5])cube([5,30+100,10]);
translate([-18+1,0-10,-5])cube([30,30+100,60.5]);
translate([-18+1+58,10,-5])cube([30,30+100,60]);
}

color("lightblue")translate([64-1.5,-19.5-2.,70-5])rotate([-90,0,90])difference(){
union(){
translate([40+14-14+3.2-2,0+11-4,0])cube([10.7+8+6-3.2-2+4,20-11+4+37-30+7.5,20.5+2.1]);
translate([40+14-14+3.2,0+11-4,0])cube([10.7+8+6-3.2-3.2+4,20-11+4+37,20.5+2.1]);
//translate([40+14-14+5,0+11-4+12,-0.65])cube([10.7+8+6,20-11+4+5,20.5+2.1]);
translate([40+14-14+15+3+4,0+11-4+12+18,-8.75])cube([10.7+8+6-15-6,20-11+4+5,20.5+2.1]);
}
translate([40+14-14+19.6-0,0+11-4+7.15,14.25])rotate([0,90,0])cylinder(r=8/2,h=30,$fn=300);

translate([40+14-14+19.6-0.2,0+11-4+7.17,14.25-0.9])rotate([0,0,0])cylinder(r=2/2,h=30,$fn=300);

translate([40+14-14+19.6+2,0+11-4+7.15+40-1.1,14.25+3])rotate([0,90,0])cylinder(r=6/2,h=30,$fn=300);
translate([40+14-14+19.6+2-40,0+11-4+7.15+40-1.1+1,14.25+3-1.5])rotate([0,90,0])cylinder(r=2.5/2,h=70,$fn=300);


}

}

module holder_half_bottom(){
color("lightblue")translate([64-1.5,-19.5+54,70-5-70])rotate([90,0,-90])difference(){
holder_half();
translate([-18+1+41.5,0,-5])cube([5,30+100,10]);
translate([-18+1,0+20,-5])cube([30,30+100,60]);
translate([-18+1+58,10-30,-5])cube([30,30+100,60]);
translate([-18+1+58-70,10-30-2,-5])cube([30+60,30+100-100,20]);
}
}

module lineux_toolchanger_linearactuator(){

servo_linear_actuator_rack_toolchanger();
ebb_mount();

//lineux_toolchange_openscad();
translate([0,-55+4,63]){
//color("lime")translate([64-1.5,-20,70-5])rotate([-90,0,90])import("servo_linear_assy_servo_holder_top.stl");
//color("lime")translate([64-1.5,-20,70-5])rotate([-90,0,90])holder_half_bottom();
color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,0])holder_half_bottom();
color("")translate([64-1.5-61.5+1.5,-20+20,0])rotate([-0,0,0])holder_half_top();


color("black")translate([64,-20,70-5])rotate([-90,0,90])translate([37,14-0,-12])rotate([0,0,90])servo();
//color("lime")translate([64,-20,70-5])rotate([-90,0,90])import("servo_linear_assy.stl");
//translate([70-8.5,70.7,34.5])rotate([0,180,90])
color("pink")translate([60+6,-7.5-5,-6+20])rotate([0,-90,0])import("pinion.stl");
translate([37-1.0,35,65])rotate([0,90,0])mirror([0,1,0]){
translate([0,0,-0.0])color("lightblue")rotate([0,0,0])import("sled_bottom_no_limit_switch_protrusion.stl");
color("peru")translate([0,-7.5,-6])import("sled_cap.stl");
}
}
}


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
/*
*/
 cl = 0.9;
 color([cl,cl,cl]){
 translate([10,10,30])cylinder(r=8/2,h=14);
 translate([10,10,41-6+8])difference(){
  cylinder(r=21/2,h=2);
  translate([0,7,-4])cylinder(r=2.6/2,h=20,$fn=30);
  translate([0,-7,-4])cylinder(r=2.6/2,h=20,$fn=30);
 }
 }
}


module servo_linear_actuator_rack_toolchanger(){
difference(){
union(){
translate([0,0,20]){
translate([35,-65+4,40])mirror([0,1,0])rotate([0,-90,0])rack();
translate([25,-35,37.5+27])rotate([0,180,0])pipette_p1000_noextrusion(8.3,0,"y",10);
}
}
translate([28,-30,29])cube([20,20,35]);
}
}

module servo_linear_actuator_rack_toolchanger_4channel(){
difference(){
union(){
translate([30.25,-8.4,58])rotate([0,-90,180])import("sled_cap.stl");

translate([0,0,20]){
translate([35,-65+4,40])mirror([0,1,0])rotate([0,-90,0])rack();
//translate([25,-35,37.5+27])rotate([0,180,0])pipette_p1000_noextrusion(8.3,0,"y",10);
//translate([17.0,-46.5,6.5])rotate([0,0,90])fourchannel_pipette_loading_module();
}
}
translate([28,-30,29])cube([20,20,35]);
}
}



module lineux_backplate_for_linearactuator(){
difference(){
union(){
translate([50.813,-55.8-2,70-0.95-6])cube([11.3,46+2,70-6.2+10]);
translate([50.813-8.1,-19.8-0.2+1.2,91.485])cube([11.3+20-20,8-0.2,16.905]);
translate([50.813-7.7-1,-55.8-2,70-0.95-10+4])cube([11.3+20+4-22,46-26,10]);
translate([50.813-7.7-1,-55.8-2,70-0.95-10+4+51])cube([11.3+20+4-22,46-26+26,10-3]);
}
translate([50.813-10,-55.8-2-20-2,70-0.95-6-66])cube([11.3+10,46+2-30+14,70-6.2+10]);
translate([50.813-13,-55.8-2-20+53,70-0.95-6-66])cube([11.3+20,46+2-30+14,70-6.2+10]);
//guide pins 12mm
translate([200+17,-77.05+47,100+0.95])rotate([0,0,90])translate([0,108-3,0])color("silver"){
translate([-3,60,12])rotate([90,0,0])cylinder(r=2.9/2,h=102,$fn=300);
translate([-3,60,-12])rotate([90,0,0])cylinder(r=2.9/2,h=102,$fn=300);
}
translate([50.813-8.1+3.5,-19.8-0.2+1.2-2,91.485+1.8])cube([11.3-5-3.2,8-0.2+10,16.905-4]);
translate([50.813-8.1+3.5-1.5,-19.8-0.2+1.2-2+4,91.485+1.8])cube([11.3-5-3.2+1.5+1.5,8-0.2+10,16.905-4+0.3]);
translate([50.813-2,-55.8,70-0.95])
translate([10-1.75,11.5,42.75])rotate([0,90,0]){
translate([-14+8.25,-4.5-5+1.3,-12-20])cylinder(r=2.9/2,h=26.8,$fn=300);
translate([-14+8.25,-4.5-5+1.3+10,-12-20])cylinder(r=2.9/2,h=26.8,$fn=300);
translate([49,0,0]){
translate([-14+8.25,-4.5-5+1.3,-12-20])cylinder(r=2.9/2,h=26.8,$fn=300);
translate([-14+8.25,-4.5-5+1.3+10,-12-20])cylinder(r=2.9/2,h=26.8,$fn=300);
}
cylinder(r=10.03/2,h=5.15,$fn=300);
translate([0,23,0])cylinder(r=10.03/2,h=5.15,$fn=300);
translate([12,0,0])cylinder(r=10.03/2,h=5.15,$fn=300);
translate([12,23,0])cylinder(r=10.03/2,h=5.15,$fn=300);
translate([24,0,0])cylinder(r=10.03/2,h=5.15,$fn=300);
translate([24,23,0])cylinder(r=10.03/2,h=5.15,$fn=300);
translate([0.25,-1,-13])cylinder(r=2.15/2,h=15.05,$fn=300);
translate([0.25,23,-13])cylinder(r=2.15/2,h=15.05,$fn=300);
translate([0.25,-1,-13-7.3])cylinder(r=4.8/2,h=15.05,$fn=300);
translate([0.25,23,-13-7.3])cylinder(r=4.8/2,h=15.05,$fn=300);
translate([0,0,0]){
translate([12,0,-13])cylinder(r=2.15/2,h=88.05,$fn=300);
translate([12,23,-13])cylinder(r=2.15/2,h=88.05,$fn=300);
translate([24,0,-13])cylinder(r=2.15/2,h=88.05,$fn=300);
translate([24,23,-13])cylinder(r=2.15/2,h=88.05,$fn=300);
}
translate([-14,-4.5,0])cylinder(r=10.15/2,h=5.05,$fn=300);
translate([-14-3.5,-4.5-6,0])cube([7.0,12,5.15]);
translate([-14,-4.5,-12-20])cylinder(r=10.15/2,h=26.8,$fn=300);
translate([-14,-4.5,-12])cylinder(r=5.8/2,h=16.8,$fn=300);

translate([-14,27.5,0])cylinder(r=10.15/2,h=5.05,$fn=300);
translate([-14-3.5,-4.5-6+32,0])cube([7.0,12,5.15]);
translate([-14,27.5,-12-20])cylinder(r=10.15/2,h=26.8,$fn=300);
translate([-14,27.5,-12])cylinder(r=5.8/2,h=16.8,$fn=300);

translate([51,-32/2+0.2,0]){
translate([-14,27.5,0])cylinder(r=10.15/2,h=5.05,$fn=300);
translate([-14-3.5,-4.5-6+32,0])cube([7.0,12,5.15]);
translate([-14,27.5,-12])cylinder(r=10.15/2,h=6.8,$fn=300);
translate([-14,27.5,-12])cylinder(r=5.8/2,h=16.8,$fn=300);
}
/*
translate([51.35,-32/2-17.5,0]){
translate([-14,27.5,0])cylinder(r=6.5/2,h=5.05,$fn=300);
translate([-14,27.5,-10])cylinder(r=3.7/2,h=35.05,$fn=300);
}
translate([51.35,-32/2+17.5,0]){
translate([-14,27.5,0])cylinder(r=6.5/2,h=5.05,$fn=300);
translate([-14,27.5,-10])cylinder(r=3.7/2,h=35.05,$fn=300);
}
*/
translate([1.35-4.35,-32/2+5.9,0]){
translate([-14,27.5,-10])cylinder(r=3.5/2,h=35.05,$fn=300);
translate([-14,27.5,-33])cylinder(r=7.2/2,h=35.05,$fn=6);
translate([-14,15.5,-10])cylinder(r=3.5/2,h=35.05,$fn=300);
translate([-14,15.5,-33])cylinder(r=7.2/2,h=35.05,$fn=6);
}
translate([1.35-4.35,-32/2+5.9,0]){
translate([-14+22-0.25,27.5+11.5,-10+7])cylinder(r=2./2,h=35.05,$fn=300);
translate([-14+22-0.25+15.7,27.5+11.5,-10+7])cylinder(r=2./2,h=35.05,$fn=300);
}
translate([-13.5,-4.5-6+15.5,-3])cube([6.1,13,8.15]);
translate([-13.5+1.7,-4.5-6+15.5,-10])cube([6.1-3.3,13,18.15]);
translate([0,4.-5.05,0]){
translate([-14+15.65-7.5,27.5+3,-1.2])rotate([-90,0,0])cylinder(r=4/2,h=135.05,$fn=300);
translate([-14+15.65,27.5+3,-1.2])rotate([-90,0,0])cylinder(r=7.9/2,h=135.05,$fn=300);
translate([-14+15.65+21.9,27.5+3,-1.2])rotate([-90,0,0])cylinder(r=7.9/2,h=135.05,$fn=300);
translate([-14+15.65+21.9+7.5,27.5+3,-1.2])rotate([-90,0,0])cylinder(r=4/2,h=135.05,$fn=300);
}
}
}
}







