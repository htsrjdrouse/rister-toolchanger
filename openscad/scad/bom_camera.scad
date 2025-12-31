include <hardware.scad> 
include <arducam-raspi.scad>


//import("miuzei_camera_breadboard_screwstub.stl");


//stroboscope_mod();


module stroboscope_mod(){

translate([45-7,-8,8])scale([24.5/2,24.5/2,24.5/2])rotate([0,0,40])color("white")import("LED.stl");

translate([0,-10,0]){
translate([14,19.5,5])rotate([0,0,14])color("silver")cube([10,2,10]);
color("lightblue")import("stroboscope_miuzei_mirror.stl");
color("lime")import("stroboscope_miuzei_back.stl");
}
color("green")translate([13.5,-30,15])rotate([-90,0,0])arducam_basecase();
color("pink")translate([13.5,-30+8,15])rotate([-90,0,0])arducam_basecase_cover();
translate([13.5,-30+8,15])rotate([-90,0,0])arducam_basecase_attachstem();
}





module miuzei_lenscap_stroboscope(h){
/*
translate([-21,0,-5])difference(){cube([8+7,8,5]);
translate([4,4,-1])cylinder(r=3.7/2,h=8);
}
translate([13,0,-5])difference(){translate([-7,0,0])cube([8+7,8,5]);
translate([4,4,-1])cylinder(r=3.7/2,h=26);
}
*/
translate([0,4,-10])
difference(){
union(){
translate([0-4,-4-21+10,10-h])difference(){#cube([8,8,h]);}
translate([0-4,-4-21+32,10-h])difference(){#cube([8,8,h]);}
translate([0,0,-6-h+16])cylinder(r=20/2,h=h);
translate([-21,-4,5])difference(){cube([8+7,8,5]);
translate([4,4,-1])cylinder(r=3.7/2,h=8);
}
translate([13,-4,5])difference(){translate([-7,0,0])cube([8+7,8,5]);
translate([4,4,-1])#cylinder(r=3.7/2,h=26);
}
}

translate([0,4-17,-10])#cylinder(r=2.8/2,h=26);
translate([0,4+8,-10])#cylinder(r=2.8/2,h=26);

//#translate([0,0,5])cylinder(r2=14/2,r1=11.7/2,h=5);
translate([0,0,1+0.1+4])#cylinder(r2=15.5/2,r1=11.7/2,h=5);
//translate([0,0,8])cylinder(r=15/2,h=2);
translate([0,0,-0.1-10])cylinder(r=11.7/2,h=h+1+10);
}
}



module mnt_md_justclip(dd){
  translate([0,-3,0])difference(){
  md_justclip();
  translate([-7+13-11,5+2,-5])cylinder(r=4/2,h=50);
  translate([-7+13-11,5+2,10-5])cylinder(r=9/2,h=5);
  }
}

module md_justclip(){
translate([0, 15]) rotate([90]) difference() {
  //color("blue")
  union(){
  translate([-10,0,0])cube([15+0, 10, 15]);
  translate([-10,0,-17])cube([5+0, 13, 17]);
  }
  translate([-60,9.5,-5])rotate([0,90,0])cylinder(r=3.7/2,h=130,$fn=30);
  translate([-60,9.5,-13])rotate([0,90,0])cylinder(r=3.7/2,h=130,$fn=30);
  //translate([0,4.5])
  //cube([10, 6.2, 15]);
}
}






module wheel_camera_assay(){

translate([-30,-7,-80])rotate([90,0,180])mnt_md_justclip();
translate([-20,10,-50])rotate([90,90,90])setup_assay_display();
import("miuzei_camera_breadboard_screwstub.stl");
translate([-32,-5,-58])rotate([-90,90,0])import("miuzei_camera_breadboard_a.stl");
translate([-22+8,-9-12,-81])rotate([90,90,0])import("miuzei_camera_breadboard_b.stl");
translate([0,0,-9*9])import("miuzei_camera_breadboard_screwstub.stl");


/*
translate([-27,5,-9*9])rotate([90,0,180])import("mnt_md_justclip.stl");
translate([-27,5,-9*9])rotate([90,0,180])import("connectionarms2.stl");
*/
}



module miuzei_camera_breadboard_screwstub(){
difference(){
union(){
//translate([-3,-1+5,0])cube([25-13,35-10,10]);
//color("red")translate([-3,-1+5-42,-22.5])cube([25-13,30,10]);
translate([4,16.5,-7])rotate([90,0,0]){
translate([-4,-3,-15]){
//translate([-3,0-25,35.5-10+6])cube([7,11,34]);
translate([-3-4-15+5+5,0-25+5.7,35.5-10+6+27])rotate([0,90,0])cylinder(r=7/2,h=10);
translate([-3-4-15+5+17,0-25+5.7,35.5-10+6+27-26+6])rotate([0,0,0])difference(){
rotate([0,0,45])cylinder(r=12/2,h=30-6,$fn=4);
translate([0+5,0,0])rotate([0,0,45])cylinder(r=12/2,h=30-6,$fn=4);
}
//translate([-3-4-15+5+17-7-5,0-25+5.7,35.5-10+6+27-26+6])rotate([0,0,45])cylinder(r=12/2,h=8,$fn=4);
translate([-3-4-15+5+17-7-1,0-25+5.7,35.5-10+6+27-26+6])rotate([0,0,45])cylinder(r=12/2,h=8,$fn=4);
//translate([-3,0-25,35.5-10+6])cube([7,11,34]);
}
}
//translate([-3.1+7.3,-11.725-15,-17.5-17.5+7.05 ])rotate([90,0,90]){cylinder(r=9.9/2,h=7.8);}
//translate([-3.1+7.3,-34+22.27-15,-17.5+56.55 ])rotate([90,0,90]){cylinder(r=9.9/2,h=10.53);}
}
translate([-8.5,32,-29.3])rotate([90,90,0])cylinder(r=2.8/2,h=50);
//translate([-8.5+9-3,32,-29.3])rotate([90,90,0])cylinder(r=2.8/2,h=50);
}
}







module setup_assay_display(){
/*
translate([40-10,8,0])rotate([0,180,90]){
camera_corexy_linear();
}
*/

translate([0,0,0])color("black")microservo();
//filterwheel();
import("filterwheel.stl");
translate([-14,5,30])color("red")cylinder(r=20/2,h=2,$fn=30);
translate([-14+20,25,30])color("blue")cylinder(r=20/2,h=2,$fn=30);
translate([-14+40,5,30])color("green")cylinder(r=20/2,h=2,$fn=30);
translate([-14+20,25-40,30])color("orange")cylinder(r=20/2,h=2,$fn=30);
import("arducam_servomnt.stl");
/*
mirror([0,0,0])microservomount();
translate([0,23,0])mirror([0,1,0])microservomount();
translate([28,16,0])rotate([0,0,-90])arducam_basecase();
*/
}
module camera_corexy_linear(){
difference(){
miuzei_raspicam_base();
translate([-3.5,30-44,-300])rotate([0,0,0])cylinder(r=2.8/2,h=400,$fn=30);
translate([-3.5+8,30-44,-300])rotate([0,0,0])cylinder(r=2.8/2,h=400,$fn=30);
}
}


module microservomount(){
difference(){
union(){
translate([0,-10,0])cube([17,9.6,4]);
translate([0,-10+5,0])cube([17-7,9.6-5,16]);
}
translate([5+4-3,-7+4+0.7,-10])cylinder(r=1.7/2,h=30,$fn=30);
translate([5,-7.5,4])cylinder(r=8/2,h=30,$fn=30);
translate([5,-7.5,-1])cylinder(r=3.7/2,h=30,$fn=30);
translate([5+8,-7.5,-1])cylinder(r=3.7/2,h=30,$fn=30);
translate([5+8,-7.5,4])cylinder(r=8/2,h=30,$fn=30);
}
}


module filterwheel(){
ldia = 35;
difference(){ 
translate([6,6,28])cylinder(r=ldia,h=6,$fn=30);
translate([6,6,28+2.4])cylinder(r=9/2,h=4,$fn=30);
translate([6,6,28-2])cylinder(r=2,h=10,$fn=30);
color("")translate([25.4/4-20,25.4/4,30])filter(25.4);
color("")translate([25.4/4+20,25.4/4,30])filter(25.4);
color("")translate([25.4/4-0,25.4/4-20,30])filter(25.4);
color("")translate([25.4/4-0,25.4/4+20,30])filter(25.4);
color("")translate([25.4/4-20,25.4/4,30-2])filter(20.4);
color("")translate([25.4/4+20,25.4/4,30-2])filter(20.4);
color("")translate([25.4/4-0,25.4/4-20,30-2])filter(20.4);
color("")translate([25.4/4-0,25.4/4+20,30-2])filter(20.4);
}
}











