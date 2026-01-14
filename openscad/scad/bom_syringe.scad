include <modparts.scad>
use<writescad/write.scad>
include <dr.robotlab_repstrap.scad>

//syringe_1ml_stack_1piece_multichannel_clamp();
//one_1ml_syringe_parts();

//oneml_cavro_syringe_assy();


//syringe_endstop_flag();

//endstop_multichannel_syringe();



module endstop_multichannel_syringe(){
difference(){
union(){
//import("files/endstop_y.stl");
translate([40+30-38+13,1.5,-0.0])cube([85-10+38-83-13,30,4]);
translate([40+30-52,1.5,-0.0])cube([28,18,4]);
//translate([40+30-38,1.5,-0.0])cube([18,28,4]);
//translate([40.9,12.5,0])rotate([0,0,45])cylinder(r=8.7/2,h=8,$fn=4);
}
translate([60,-114,0])rotate([0,0,90]){
translate([40.75+80,4.5,-0.2])cylinder(r=2.9/2,h=30,$fn=20);
translate([60.75+80,4.5,-0.2])cylinder(r=2.9/2,h=30,$fn=20);
}
translate([40.9,25,-0.2])cylinder(r=4.7/2,h=30,$fn=30);
translate([40.9,10,-0.2])cylinder(r=4.7/2,h=30,$fn=30);
translate([40.9-15,10,-0.2])cylinder(r=4.7/2,h=30,$fn=30);
//translate([50.,12,-0.2])cube([120,20,20]);
}
}





module syringe_endstop_flag(){
difference(){
union(){
translate([-15-10,50-0.5,10])cube([45,10,3]);
translate([-15-10+30,50-0.5+4,-3])cube([15,6,13]);
}
translate([-20.+0.5,57-0.25,-10])cylinder(r=3.7/2,h=30,$fn=30);
translate([-20.5+10.,57-0.25,-10])cylinder(r=3.7/2,h=30,$fn=30);
translate([-20.5+13.25+20-2.3,55+12,2])rotate([90,0,0])#cylinder(r=2.7/2,h=30,$fn=30);
}
}



module oneml_cavro_syringe_assy(){

translate([-126,-10+62,20.5])rotate([0,0,-90])endstop_multichannel_syringe();

translate([-126,-11.3,96.5])rotate([-90,0,0])syringe_endstop_flag();
translate([0,-212,2])one_1ml_syringe_parts();
translate([-160,-80,25.5])rotate([-90,0,0])nema17();
translate([-98,0,0.5]){
translate([-62,-60,25])rotate([-90,0,0])color("silver")cylinder(r=8/2,h=200,$fn=30);
translate([-47,-65,3]){
//here is the rail
color("silver")cube([12,300,8]);
//here is the slider
translate([-27/2+12/2,60,2-3+6])color("silver")cube([27,45,9]);
}
translate([-33,-88,25])rotate([-90,0,0])tslot20(350);
import("iverntech_slidermount_motormount.stl");
import("motormount_screws.stl");
translate([-1,50,0])import("oneml_syringe_stepper_linear_m8nut_coupler.stl");
}

/*
translate([0,-38,0]){
translate([0,-10,0])import("multichannel_syringe1ml_clamp_extrusion_connect.stl");
translate([0,-70,0])import("multichannel_syringe1ml_clamp_extrusion_connect.stl");
import("multichannel_syringe1ml_clamp_luerlock.stl");
import("multichannel_syringe1ml_clamp.stl");
translate([0,-70,0])rotate([0,-180,0])import("multichannel_syringe1ml_clamp_top_luerlock.stl");
}
translate([0,-130,0]){
import("multichannel_syringeshuttle_clipbracket.stl");
import("multichannel_plunger_clamp.stl");
}
translate([0,-38,-4]){
import("syringe_1ml_stack_1piece_multichannel_clamp.stl");
import("syringe_1ml_stack_1piece_multichannel.stl");
}
*/

}








module cavro_250ul_syringe(){
color("silver")cylinder(r=6.25/2,h=10.25,$fn=20);
translate([0,0,-8])color("silver")cylinder(r=11.5/2,h=8,$fn=20);
translate([0,0,-8-36])color("lightblue")cylinder(r=8/2,h=36,$fn=20);
translate([0,0,-8-36-2.5])color("silver")cylinder(r=2/2,h=36+2.5,$fn=20);
translate([0,0,-8-36-2.5-7.5])color("silver")cylinder(r=6.1/2,h=3,$fn=20);
translate([0,0,-8-36-2.5-7.5+3])color("silver")cylinder(r2=5/2,r1=6/2,h=1.5,$fn=20);
translate([0,0,-8-36-2.5-7.5+3+1.5])color("silver")cylinder(r1=5/2,r2=6/2,h=1.5,$fn=20);
translate([0,0,-8-36-2.5-7.5+3+3])color("silver")cylinder(r=6.1/2,h=3,$fn=20);
}



module one_1ml_syringe_parts(){
 //translate([-22.85,1-123.7,2.5])mirror([0,1,0])oneml_syringe_stepper_linear_m8nut_coupler();
 //translate([-141.5+0.3+100-1,280+6.5-3-225-32,42.5+1.5+2])rotate([-90,90,0])cavro_250ul_syringe();
 /*
 translate([0+100-1,54,2]){
 translate([-141,200-19.7-32-225,44])rotate([0,0,-90])syringe_cavro250ul_plungerclip();
 } 
 */
 //translate([0,-4,0])iverntech_pump_slider_plate_connect();
 //multichannel_syringeshuttle_clipbracket();
 //translate([0,10,0])one_syringe1ml_clamp_top_luerlock();
 //onechannel_plunger_clamp();
 //translate([0,70,-0.1])one_front_syringe1ml_clamp_luerlock();

 translate([0-99,-4+262,-2])iverntech_pump_slider_plate();

 translate([0,70,-0.1])one_channel_cavro250ul_clamp();
 translate([0,96,-0.1-0])multichannel_syringe1ml_clamp_extrusion_connect();
 translate([0,54,0]){
 translate([-141,200-19.7,44])rotate([0,0,-90])syringe_cavro250ul_plungerclip();
 }
 translate([-141.5+0.3,280+6.5-3,42.5+1.5])rotate([-90,90,0])cavro_250ul_syringe();
}




//multichannel_syringe_module();

module multichannel_syringe_module(){
eight_multichannel_assay();
translate([-100,160,0])nextgen_syringe1ml_multichannel_assy();
//translate([0,70,-0.1])multichannel_syringe1ml_clamp_luerlock();
multichannel_plunger_clamp();

translate([0,12,0]){
translate([-100,160,0])
//color("gainsboro")
translate([-25.75,123,-30])rotate([90,-90,0])multichannel_syringeshuttle_clipbracket();
}

}


module multichannel_syringe_module_iverntech(){

translate([-150+3,100,3.0]){
//here is the rail
color("silver")cube([12,200,8]);
//here is the slider 
translate([-27/2+12/2,20,2-3+6])color("silver")cube([27,45,9]);
}
eight_multichannel_assay();
translate([-100,180,0]){
translate([-22.85,1-123.7,2.5])mirror([0,1,0])oneml_syringe_stepper_linear_m8nut_coupler();
translate([0,-4,0])iverntech_pump_slider_plate();
}
translate([0-15+14,92,6.8]){
syringe_1ml_stack_1piece_multichannel();
syringe_1ml_stack_1piece_multichannel_clamp();
}
/*
*/
translate([-1,12-7,7]){
translate([-100,160,0])
translate([-25.75,123,-30])rotate([90,-90,0])multichannel_syringeshuttle_clipbracket();
}
translate([-1,-2,6.8])multichannel_plunger_clamp();
//translate([0,30,0])multichannel_syringe1ml_clamp_top_luerlock();

translate([-100,160,0])nextgen_syringe1ml_multichannel_assy();
}


//syringe_pcb_holder_for_syringemodule();
//openmv_set();

//color("pink")
//syringe_pump_stls();
//syringe_1ml();

//rotate([0,180,0])multichannel_syringe1ml_clamp_top();
//rotate([0,-90,0])syringe_1ml();
//translate([64.5,0,0])syringe_1ml_plungerclip();

//color("gainsboro")translate([-25.75,123,-30])rotate([90,-90,0])syringeshuttle_clipbracket();
//multichannel_syringeshuttle_clipbracket();

//diagphragm_pump_case();
/*

*/
//translate([50,-4,4])igus_TW_04_12_slider_plate();

//translate([-22.85-20,1-24,2.5+91.5])rotate([90,0,90])stepper_linear_m8nut_coupler();
//color("yellow")translate([110,52,26])igus_slidermount_encoder_TW_04_12_motormount_assy_m8();
//smaller_igus_slidermount_vertical_adjust_nema17();




module one_multichannel_assay(){
//translate([64.5,0,0])syringe_1ml_plungerclip();
translate([0,20,0]){
translate([0,70,-0.1])syringe_1ml_stack();
translate([0,70,-0.1])multichannel_syringe1ml_clamp();
//color("pink")
translate([0,70,-0.1])multichannel_syringe1ml_clamp_extrusion_connect();
//translate([0,70,-0.1+0])multichannel_syringe1ml_clamp_top();
translate([0,70,-0.1])multichannel_syringe1ml_clamp_luerlock();
//translate([0,70,-0.1+0])multichannel_syringe1ml_clamp_top_luerlock();
//color("pink")
translate([0,70+60,-0.1])multichannel_syringe1ml_clamp_extrusion_connect();
}
}









module eight_multichannel_assay(){
translate([0,20,0]){
translate([0,70,-0.1])syringe_1ml_stack();
translate([0,70,-0.1])multichannel_syringe1ml_clamp();
translate([0,70,-0.1])multichannel_syringe1ml_clamp_extrusion_connect();
translate([0,70,-0.1])multichannel_syringe1ml_clamp_luerlock();
translate([0,70+60,-0.1])multichannel_syringe1ml_clamp_extrusion_connect();
translate([0,30-20,0])multichannel_syringe1ml_clamp_top_luerlock();
}
}

/*
multichannel_syringe1ml_clamp_extrusion_connect();
syringe_1ml_stack();
rotate([0,180,0])multichannel_syringeshuttle_clipbracket();
multichannel_syringe1ml_clamp_extrusion_connect();

rotate([0,180,0])multichannel_syringe1ml_clamp_top();
rotate([0,180,0])multichannel_syringe1ml_clamp_top_luerlock();

multichannel_syringe1ml_clamp_top();
multichannel_syringe1ml_clamp_luerlock();
multichannel_syringe1ml_clamp_top_luerlock();
multichannel_syringe1ml_clamp_extrusion_connect();
*/



module onechannel_plunger_clamp(){
difference(){
translate([-183-13/2-5,170-13/2,30]){
union(){
//translate([0,2+7.25-2,2])rotate([0,0,0])cube([120,13/2+7,4]);
//translate([40,2,0])rotate([0,0,0])cube([42,13.9,15]);
translate([44,2+7.25-2,2])rotate([0,0,0])cube([20,13/2+7,4]);
translate([0+41.2,2+7.25-7-3,2])rotate([0,0,0])cube([25,10,4]);
}
}
translate([-183-13/2-5,170-13/2,30]){
translate([64.7-5-36.15,14.4-3-0.87-50+8-0.08,-55.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([0,0,0])cylinder(r=3.7/2, h=200);
translate([64.7-5-36.15+17.5,14.4-3-0.87-50+8-0.08,-55.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([0,0,0])cylinder(r=3.7/2, h=200);
for(i=[3]){
translate([64.7-5-36.15+17.5-50.75+(i*14),14.4-3-0.87-50+8-0.08+9.75,-55.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([0,0,0])cylinder(r=2.7/2, h=200);
}
}
}
}









module multichannel_plunger_clamp(){
difference(){
translate([-183-13/2-5,170-13/2,30]){
union(){
translate([0,2+7.25-2,2])rotate([0,0,0])cube([120,13/2+7,4]);
translate([0+41.2,2+7.25-7-3-5,2])rotate([0,0,0])cube([25,10+5,4]);
}
}
translate([-183-13/2-5,170-13/2,30]){
translate([64.7-5-36.15,14.4-3-0.87-50+8-0.08-5,-55.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([0,0,0])cylinder(r=3.7/2, h=200);
translate([64.7-5-36.15+17.5,14.4-3-0.87-50+8-0.08-5,-55.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([0,0,0])cylinder(r=3.7/2, h=200);
for(i=[0:7]){
translate([64.7-5-36.15+17.5-50.75+(i*14),14.4-3-0.87-50+8-0.08+9.75,-55.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([0,0,0])cylinder(r=2.7/2, h=200);
}
}
}
}






module multichannel_syringeshuttle_clipbracket(){
translate([46.25,-57,300-4])rotate([180,0,90])difference(){
union(){
translate([64.7-5,14.4-3-3,155.75-10])cube([25,15+3+3,10+11+10-3-15]);
translate([64.7-5,14.4-3-3,155.75-10])cube([25,15+3+3-9.75-4,10+11+10-3]);
}
translate([65.2+0.75,14.4+7.5,155.75+20-1.5-4])cube([14-1.5,14,24]);

//translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([0,0,4])cylinder(r=6.9/2, h=3.2, $fn=6);
//translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([0,0,4])translate([0,-3.5,0])cube([12,7,3.2]);
//translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([-9,0,4])cylinder(r=6.9/2, h=3.2, $fn=6);
//translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([-9,0,4])translate([-12,-3.5,0])cube([12,7,3.2]);
translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([0,0,-100])cylinder(r=2.7/2, h=200);
translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([-9,0,-100])cylinder(r=2.7/2, h=200);
translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([90,0,0])cylinder(r=2.7/2, h=200);
translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([-9+15-2-17.5,30,23])rotate([90,0,0])cylinder(r=2.7/2, h=200);
}
}



module syringe_1ml_plungerclip_1piece(){
difference(){
union(){
translate([0-4+10,-5+2.5,-8])cube([5,10+5,16]);
translate([0-4+10,-5+2.5,-8])cube([14+15-10+4,10+5-1,4]);
}
translate([18+4,0,-8])cylinder(r=3.7/2,h=40);
/*
for(i=[0:10]){
translate([-5,0,0+i])rotate([90,-0,90])cylinder(r=4/2,h=10);
translate([5,0,0+i])rotate([90,-0,90])cylinder(r=10.2/2,h=1.75);
}
*/
translate([2.5-2,40,4])rotate([90,0,0])cylinder(r=2.8/2,h=100);
}
}


module syringe_1ml_plungerclip(){
difference(){
union(){
translate([0-4,-5,-8])cube([14,10,16]);
translate([0-4,-5,-8])cube([14+15,10,4]);
}
translate([18,0,-8])cylinder(r=3.7/2,h=40);
for(i=[0:10]){
translate([-5,0,0+i])rotate([90,-0,90])cylinder(r=4/2,h=10);
translate([5,0,0+i])rotate([90,-0,90])cylinder(r=10.2/2,h=1.75);
}
translate([2.5-2,40,4])rotate([90,0,0])cylinder(r=2.8/2,h=100);
}
}

module syringe_cavro250ul_plungerclip(){
difference(){
union(){
translate([0-4,-5-4,-8-4])cube([14+4,10+8,12+4]);
//translate([0-4,-5,-8])cube([14+15,10,4]);
}
translate([18-20,0-4.75,-8+1.75])rotate([0,90,0])cylinder(r=2.8/2,h=40);
translate([18-20,0+4.4,-8+1.75])rotate([0,90,0])cylinder(r=2.8/2,h=40);
translate([18,0,-8])cylinder(r=3.7/2,h=40);
for(i=[0:10]){
translate([-5,0,0+i])rotate([90,-0,90])cylinder(r=6.6/2,h=10);
//translate([5,0,0+i])rotate([90,-0,90])cylinder(r=10.2/2,h=1.75);
}
translate([2.5-2,40,-0])rotate([90,0,0])cylinder(r=2.8/2,h=100);
}
}






module syringe_1ml_stack(){
for(i=[0:7]){
color("")translate([-85-(i*14),105.5,44])rotate([-0,0,-90])syringe_1ml_plungerclip();
//color("white")
translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
}
}

module syringe_1ml_stack_1piece_multichannel(){
difference(){union(){
/*
//clamp part
translate([-0.3-14,0+146-2,-0.8])
translate([-110+54.5+6-14,-81.5+1.5+40+6.6+3.5-14.5,16+15+6])cube([5,6.5,35-15-4]);
translate([-0.3-14-(8*14)-3.5,0+146-2,-0.8])
translate([-110+54.5+6-14,-81.5+1.5+40+6.6+3.5-14.5,16+15+6])cube([5,6.5,35-15-4]);
*/
//attach part
translate([-0.3-14-(8.6*13),0+146-2-7.4,-1])
translate([-110+54.5+6-14-3-1,-81.5+1.5+40+6.6+3.5-14.5+2.3,16+15+6])cube([5+3+1,6.5-1.5,35-15-4]);
translate([-85-(9*14),105.5,44])
translate([0-4+10.5+10+1,-5+2.5-22.5-4,-8])cube([14+15-10-10-1,10+5+4,4]);
for(i=[0:7]){
color("")translate([-85-(i*14),105.5,44])rotate([-0,0,-90])syringe_1ml_plungerclip_1piece();
//translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
//translate([0-42.5-(i*14),-4+230-80-2,0])iverntech_pump_slider_plate_connect_multichannel();
}
}
translate([-77.5-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
translate([-77.5-(8*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-(8*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
for(i=[0:7]){
//translate([18-(i*14),0,-8])cylinder(r=3.7/2,h=40);
/*

translate([-85-(i*14),105.5,44])rotate([-0,0,-90])
for(i=[0:10]){
translate([-5,0,0+i])rotate([90,-0,90])cylinder(r=4/2,h=10);
translate([5,0,0+i])rotate([90,-0,90])cylinder(r=10.2/2,h=1.75);
}
*/
translate([-14,0,0]){
translate([-77.5-(i*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-(i*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
}
translate([-77.5-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
translate([-77.5-(8*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-(8*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
}
}
}





module syringe_1ml_stack_1piece_multichannel_clamp(){
difference(){union(){
/*
*/
//clamp part
translate([-0.3-14,0+146-2,-0.8])
translate([-110+54.5+6-14,-81.5+1.5+40+6.6+3.5-14.5,16+15+6+3])cube([5,6.5,35-15-4-3]);
translate([-0.3-14-(8*14)-3.5,0+146-2,-0.8])
translate([-110+54.5+6-14,-81.5+1.5+40+6.6+3.5-14.5,16+15+6+3])cube([5,6.5,35-15-4-3]);
//attach part
//translate([-0.3-14-(8.6*13),0+146-2-7.4,-1])translate([-110+54.5+6-14-3-1,-81.5+1.5+40+6.6+3.5-14.5+2.3,16+15+6])cube([5+3+1,6.5-1.5,35-15-4]);
//translate([-85-(9*14),105.5,44])translate([0-4+10.5+10+1,-5+2.5-22.5-4,-8])cube([14+15-10-10-1,10+5+4,4]);
for(i=[0:7]){
//color("")translate([-85-(i*14),105.5,44])rotate([-0,0,-90])syringe_1ml_plungerclip_1piece();
//translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
translate([0-42.5-(i*14),-4+230-80-2,0])iverntech_pump_slider_plate_connect_multichannel();
}
}
translate([-77.5-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
translate([-77.5-(8*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-(8*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
for(i=[0:7]){
//translate([18-(i*14),0,-8])cylinder(r=3.7/2,h=40);
/*

translate([-85-(i*14),105.5,44])rotate([-0,0,-90])
for(i=[0:10]){
translate([-5,0,0+i])rotate([90,-0,90])cylinder(r=4/2,h=10);
translate([5,0,0+i])rotate([90,-0,90])cylinder(r=10.2/2,h=1.75);
}
*/
translate([-14,0,0]){
translate([-77.5-(i*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-(i*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
}
translate([-77.5-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
translate([-77.5-(8*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-(8*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
}
}
}












































/*
rotate([0,0,0])difference(){
//translate([0,70,-0.1+0])multichannel_syringe1ml_clamp_top();
//translate([0,70,-0.1+0])multichannel_syringe1ml_clamp_top();
translate([0,70,-0.1])multichannel_syringe1ml_clamp();
translate([-183-13/2-5,170-13/2+70,30]){
translate([0,2,10/2+10-20])rotate([0,0,0])cube([70,15,15/2+2+30]);
translate([0+102,2,10/2+10-20])rotate([0,0,0])cube([70,15,15/2+2+30]);
}
}
*/


//translate([0,70,-0.1+0])multichannel_syringe1ml_clamp_top();
//translate([0,70,-0.1])multichannel_syringe1ml_clamp();
//translate([0,70+60,-0.1])multichannel_syringe1ml_clamp_luerlock();

module multichannel_syringe1ml_clamp_extrusion_connect(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
//translate([0,2,0])rotate([0,0,0])cube([120,13,15]);
translate([69,2-15,-9.5])rotate([0,0,0])cube([18+8,23+20,9.48]);
}
}
translate([-120,220-60,0])cylinder(r=2.8/2,h=100);
translate([-120+15,220-60,0])cylinder(r=2.8/2,h=100);
translate([-120+7.5,220-60+23,0])cylinder(r=2.8/2,h=100);
translate([-120+7.5-4,220-60+23+7,0])cylinder(r=4.7/2,h=100);
translate([-120+7.5-4,220-60+23+7,26.5-2])cylinder(r=10.5/2,h=5.5);
translate([-120+7.5-4,220-60+23-28.5-1,26.5-2])cylinder(r=10.5/2,h=5.5);
translate([-120+7.5-4,220-60+23-28.5-1,0])cylinder(r=4.7/2,h=100);
}
}




module one_syringe1ml_clamp_top_luerlock(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
//translate([0,2+7.25+60-1,10/2+10])rotate([0,0,0])cube([120,13/2+1,15/2+2]);
translate([40,2+7.25+60-1,10/2+10])rotate([0,0,0])cube([42,13/2+1,15/2+2]);
}
}
for(i=[3]){
translate([-183+(i*14),170+60,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170-50+60,44])rotate([0,90,90])cylinder(r=6/2,h=100);
if(i>0){
translate([-77.5-(i*14)-0.5,175+60.6,0])cylinder(r=3.7/2,h=150);
translate([-77.5-((i+2)*14)-0.5,175+60.6,0])cylinder(r=3.7/2,h=150);
}else{
translate([-77.5-(i*14),175.6+60,0])cylinder(r=3.7/2,h=150);
}
}
translate([-77.5-(8*14)-1.7,175.6+60,0])cylinder(r=3.7/2,h=150);
}
}




module multichannel_syringe1ml_clamp_top_luerlock(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
translate([0,2+7.25+60-1,10/2+10])rotate([0,0,0])cube([120,13/2+1,15/2+2]);
}
}
for(i=[0:7]){
translate([-183+(i*14),170+60,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170-50+60,44])rotate([0,90,90])cylinder(r=6/2,h=100);
if(i>0){
translate([-77.5-(i*14)-0.5,175+60.6,0])cylinder(r=3.7/2,h=150);
}else{
translate([-77.5-(i*14),175.6+60,0])cylinder(r=3.7/2,h=150);
}
}
translate([-77.5-(8*14)-1.7,175.6+60,0])cylinder(r=3.7/2,h=150);
}
}




module multichannel_syringe1ml_clamp_top(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
translate([0,2+7.25,10/2+10])rotate([0,0,0])cube([120,13/2,15/2+2]);
}
}
for(i=[0:7]){
translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=6/2,h=100);
if(i>0){
translate([-77.5-(i*14)-0.5,175.6,0])cylinder(r=3.7/2,h=150);
}else{
translate([-77.5-(i*14),175.6,0])cylinder(r=3.7/2,h=150);
}
}
translate([-77.5-(8*14)-1.7,175.6,0])cylinder(r=3.7/2,h=150);
}
}



module multichannel_syringe1ml_clamp_luerlock(){
difference(){
union(){
translate([-183-13/2-5,170-13/2+60,30]){
translate([0,2+6.9,0])rotate([0,0,0])cube([120,13.9-7,15]);
translate([69,2-15-1,0])rotate([0,0,0])cube([18+8,23+20+1,5]);
}
}
translate([-120,220-60+60,0])cylinder(r=3.7/2,h=100);
translate([-120+15,220-60+60,0])cylinder(r=3.7/2,h=100);
translate([-120+7.5,220-60+23+60,0])cylinder(r=3.7/2,h=100);
for(i=[0:7]){
translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=6/2,h=100);

/*
if(i>0){
translate([-77.5-(i*14)-0.5,175.6+60,0])cylinder(r=2.8/2,h=150);
}else{
translate([-77.5-(i*14),175.6+60,0])cylinder(r=2.8/2,h=150);
}
*/
}
//translate([-77.5-(8*14)-1.7,175.6+60,0])cylinder(r=2.8/2,h=150);
}
}

module one_front_syringe1ml_clamp_luerlock(){
difference(){
union(){
translate([-183-13/2-5,170-13/2+60,30]){
//translate([0,2+6.9,0])rotate([0,0,0])cube([120,13.9-7,15]);
translate([40,2+6.9,0])rotate([0,0,0])cube([42,13.9-7,15]);
translate([69,2-15-1,0])rotate([0,0,0])cube([18+8,23+20+1,5]);
}
}
translate([-120,220-60+60,0])cylinder(r=3.7/2,h=100);
translate([-120+15,220-60+60,0])cylinder(r=3.7/2,h=100);
translate([-120+7.5,220-60+23+60,0])cylinder(r=3.7/2,h=100);
for(i=[3]){
translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=6/2,h=100);

/*
if(i>0){
translate([-77.5-(i*14)-0.5,175.6+60,0])cylinder(r=2.8/2,h=150);
}else{
translate([-77.5-(i*14),175.6+60,0])cylinder(r=2.8/2,h=150);
}
*/
}
//translate([-77.5-(8*14)-1.7,175.6+60,0])cylinder(r=2.8/2,h=150);
}
}










module one_syringe1ml_clamp_luerlock(){
difference(){
union(){
translate([-183-13/2-5,170-13/2+60,30]){
translate([0,2+6.9,0])rotate([0,0,0])cube([120,13.9-7,15]);
translate([69,2-15-1,0])rotate([0,0,0])cube([18+8,23+20+1,5]);
}
}
translate([-120,220-60+60,0])cylinder(r=3.7/2,h=100);
translate([-120+15,220-60+60,0])cylinder(r=3.7/2,h=100);
translate([-120+7.5,220-60+23+60,0])cylinder(r=3.7/2,h=100);
for(i=[0:7]){
translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=6/2,h=100);

/*
if(i>0){
translate([-77.5-(i*14)-0.5,175.6+60,0])cylinder(r=2.8/2,h=150);
}else{
translate([-77.5-(i*14),175.6+60,0])cylinder(r=2.8/2,h=150);
}
*/
}
//translate([-77.5-(8*14)-1.7,175.6+60,0])cylinder(r=2.8/2,h=150);
}
}




module one_channel_cavro250ul_clamp(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
//translate([40,2,0])rotate([0,0,0])cube([42,13.9,15]);
translate([40+25,2,0])rotate([0,0,0])cube([42-25,13.9,14]);
translate([40+25,2+48.5,0])rotate([0,0,0])cube([42-25,13.9,14]);
translate([40+5,2+5+43.5,0])rotate([0,0,0])cube([42-15-5,13.9-5+5,14+6]);
translate([40,2+5,0])rotate([0,0,0])cube([42-15,13.9-5,14]);
translate([69,2-15+25,0])rotate([0,0,0])cube([18+8,23+20+10,5]);
}
}
translate([0,26,0]){
translate([-120,220-60,0])cylinder(r=3.7/2,h=100);
translate([-120+15,220-60,0])cylinder(r=3.7/2,h=100);
translate([-120+7.5,220-60+23,0])cylinder(r=3.7/2,h=100);
translate([-120,220-60,32])cylinder(r=9.7/2,h=10);
translate([-120+15,220-60,32])cylinder(r=9.7/2,h=10);
translate([-120+7.5,220-60+23,32])cylinder(r=9.7/2,h=10);
}
for(i=[3]){
//translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
 translate([-141.5+0.3,280+6.5-73,42.5+1.6])rotate([-90,90,0])cavro_250ul_syringe();
 translate([-141.5+0.3,280+6.5-73,42.5+1.6])rotate([-90,90,0])cylinder(r=6.25/2,h=18.25,$fn=20);
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=6/2,h=100);
if(i>0){
translate([-77.5-(i*14)-0.5,175.6,0])cylinder(r=2.8/2,h=150);
translate([-77.5-((i+2)*14)-0.5,175.6,0])cylinder(r=2.8/2,h=150);
}else{
translate([-77.5-(i*14),175.6,0])cylinder(r=2.8/2,h=150);
}
}
translate([-77.5-(8*14)-1.7,175.6,0])cylinder(r=2.8/2,h=150);
}
}



















module one_channel_syringe1ml_clamp(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
//translate([0,2,0])rotate([0,0,0])cube([120,13.9,15]);
translate([40,2,0])rotate([0,0,0])cube([42,13.9,15]);
translate([69,2-15,0])rotate([0,0,0])cube([18+8,23+20,5]);
}
}
translate([-120,220-60,0])cylinder(r=3.7/2,h=100);
translate([-120+15,220-60,0])cylinder(r=3.7/2,h=100);
translate([-120+7.5,220-60+23,0])cylinder(r=3.7/2,h=100);
translate([-120,220-60,32])cylinder(r=9.7/2,h=10);
translate([-120+15,220-60,32])cylinder(r=9.7/2,h=10);
translate([-120+7.5,220-60+23,32])cylinder(r=9.7/2,h=10);
for(i=[3]){
translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=6/2,h=100);
if(i>0){
translate([-77.5-(i*14)-0.5,175.6,0])cylinder(r=2.8/2,h=150);
translate([-77.5-((i+2)*14)-0.5,175.6,0])cylinder(r=2.8/2,h=150);
}else{
translate([-77.5-(i*14),175.6,0])cylinder(r=2.8/2,h=150);
}
}
translate([-77.5-(8*14)-1.7,175.6,0])cylinder(r=2.8/2,h=150);
}
}















module multichannel_syringe1ml_clamp(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
translate([0,2,0])rotate([0,0,0])cube([120,13.9,15]);
translate([69,2-15,0])rotate([0,0,0])cube([18+8,23+20,5]);
}
}
translate([-120,220-60,0])cylinder(r=3.7/2,h=100);
translate([-120+15,220-60,0])cylinder(r=3.7/2,h=100);
translate([-120+7.5,220-60+23,0])cylinder(r=3.7/2,h=100);
translate([-120,220-60,32])cylinder(r=9.7/2,h=10);
translate([-120+15,220-60,32])cylinder(r=9.7/2,h=10);
translate([-120+7.5,220-60+23,32])cylinder(r=9.7/2,h=10);
for(i=[0:7]){
translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=6/2,h=100);
if(i>0){
translate([-77.5-(i*14)-0.5,175.6,0])cylinder(r=2.8/2,h=150);
}else{
translate([-77.5-(i*14),175.6,0])cylinder(r=2.8/2,h=150);
}
}
translate([-77.5-(8*14)-1.7,175.6,0])cylinder(r=2.8/2,h=150);
}
}








module syringe_1ml(){

//translate([0,0,4])rotate([0,0,45])cylinder(r=10,h=15,$fn=4);
//translate([0,0,74])rotate([0,0,45])cylinder(r=10,h=15,$fn=4);
union(){
color("lightblue")translate([0,0,100])cylinder(r=3/2,h=30);
color("white")cylinder(r=9.5/2,h=92);
color("white")cylinder(r2=5.5/2,r1=9.5/2,h=92+7);
color("white")translate([0,0,-12-(71-12)])cylinder(r=4/2,h=92);
color("white")translate([0,0,-12-(71-12)])cylinder(r=(10-0.2)/2,h=1.5);
color("white")translate([0,0,0])cylinder(r=(10.5)/2,h=10.5);
color("white")translate([-12.5,-13/2-1,0])cube([25,13+2,2.4]);

/*
//luerlock
color("white")translate([0,0,98])cylinder(r=12/2,h=3);
color("white")translate([0,0,98+3])cylinder(r=8/2,h=3);

//tubing
color("lightblue")translate([0,0,98+3+3])cylinder(r=3.175/2, h=200);
//sphere(r=3.175/2,$fn=30);
*/
}
}



module syringe_pump_stls(){
//nextgen_syringe10ml_assy();
translate([0,0,-20]){
syringe_pcb_holder_for_syringemodule();
translate([40,68,0])syringe10mlmount_plungerfix_assy();
translate([-26.5,130,104.45])rotate([90,90,0])syringe10ml_clipmount();
color("yellow")translate([110,52,26])igus_slidermount_encoder_TW_04_12_motormount_assy_m8();
translate([50,-4,4])igus_TW_04_12_slider_plate();
translate([-25.75+30-17,123,-34.65])rotate([90,-90,0])syringeshuttle_clipbracket();
translate([-22.85-20,1-24,2.5+91.5])rotate([90,0,90])stepper_linear_m8nut_coupler();
//translate([-50,0,-13])valve_assy();
//start valve_assy
translate([-38,50,23.8])rotate([0,0,90])valveconnectpart();
translate([36,295.5-130+10,18-2.5])rotate([90,0,0])valvemountplate_screwattach_smallersyringe_vertical_attach();
translate([10,165.5-32,18+74])rotate([0,90,0])valvemountplate_screwattach_smallersyringe();
translate([52,190-30,49.5])rotate([-90,90,90])smallsyringe_valvesupportmodule_plate();
//end valve_assy()

}
}


module nextgen_syringe1ml_multichannel_assy(){
/*
*/
color("silver")translate([-70+8,-80+40-50,30-5])rotate([-90,0,0])cylinder(r=8.7/2,h=250);
color("silver")translate([-70+8,-80,30-5])rotate([-90,0,0])cylinder(r=16/2,h=18);
translate([-70+8,-80,30-5])rotate([-90,0,0])nema17();
igus_slidermount_encoder_TW_04_12_motormount_assy_m8();
translate([-25-6.5,320,-4.6])rotate([90,0,0])tslot20(400);
}








































