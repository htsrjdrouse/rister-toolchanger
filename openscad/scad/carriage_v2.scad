
carriage_body_rear_trident_v2();

/*
translate([0,0,-90])rotate([90,0,0])import("openbuild_spacer.stl");

difference(){
cylinder(r=10/2,h=3,$fn=300);
translate([0,0,-1])cylinder(r=6/2,h=13,$fn=300);
}
*/

//carriage_body_middle_trident_v2();
//translate([0,4.95,-3.4])duct_trident_v2();
//import("duct_v2.stl");
//import("Duct_v2_orig.stl");

module duct_10mm_channel(){
difference(){
union(){
hull(){
translate([22.5-2.5,118-8,-18.2])rotate([90,0,0])cylinder(r=3.2,h=10.1,$fn=300);
translate([22.5-2.5+5,118-8,-18.2+2])rotate([90,0,0])cylinder(r=3.2,h=10.1,$fn=300);
}
}

hull(){
translate([22.5-2.5,118-8,-18.2])rotate([90,0,0])cylinder(r=2.2,h=10.1,$fn=300);
translate([22.5-2.5+5,118-8,-18.2+2])rotate([90,0,0])cylinder(r=2.2,h=10.1,$fn=300);
}
}
}

//translate([0.2,0,0])duct_10mm_channel();
//translate([-5.7,0,0])mirror([1,0,0])duct_10mm_channel();


//import("duct_trident_v2_base.stl");
//translate([0,10,0])import("duct_trident_v2_nozzle.stl");
//carriage_body_rear();

//carriage_assy();

//color("lightblue")translate([0,170+10-3.6+1.5,23.6])rotate([0,0,180])import("5015_adapter_v2.stl"); 
//translate([0,4.95,-3.4])color("lime")import("duct_v2.stl");


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

//translate([0,-6,22.5])import("locking_plate_guidepin.stl");
//color("pink")translate([0,170+10-178-2.35,22-21.8-0.5])rotate([0,0,0])import("5015_adapter_standoff.stl");
//translate([0,200-20,21])color("lime")rotate([0,0,180])import("duct.stl");

color("grey")translate([0,170+10-3.6,22])rotate([0,0,180])import("radial_cooling_5015.stl");
import("carriage_body_top.stl");
import("carriage_body_middle_trident_v2.stl"); 
//carriage_body_middle_trident_v2();
import("carriage_body_bottom_trident_v2.stl");
translate([0,2,0])import("CarriageBodyFront_editable_belt_holes.stl");
import("carriage_body_front.stl");
//carriage_body_rear();
import("slider.stl");
/*
*/
translate([0,0,0])color("pink")import("carriage_body_rear_trident_v2.stl");
color("lightblue")translate([0,170+10-3.6+1.5,23.6])rotate([0,0,180])import("5015_adapter_v2.stl"); 
//translate([0,0,0])color("lime")import("duct_trident_v2.stl");
translate([0,0,0])color("lime")import("duct_trident_v2_nozzle_10mm_longer.stl");
//import("duct.stl");
//translate([0,200-20,21])color("orange")rotate([0,0,180])import("duct.stl");
//translate([0,4.5,-3.4])color("lime")duct_trident_v2();
//carriage_body_rear_trident_v2();
}


module carriage_body_middle_trident_v2(){

difference(){union(){
import("carriage_body_middle.stl"); 
translate([10.7-6,200-22-100+0.53-3-7.77,-10+2.2+4.01-1.3])cube([11,12.15,4]);
translate([10.7-6-26,200-22-100+0.53-3-7.77,-10+2.2+4.01-1.3])cube([11,12.15,4]);
}
#translate([10.7,200-22-100+0.53-3,-10+2.2+4.01-1.31])color("silver")rotate([0,0,180])cylinder(r=6/2,h=3,$fn=300);
#translate([10.7-27,200-22-100+0.53-3,-10+2.2+4.01-1.31])color("silver")rotate([0,0,180])cylinder(r=6/2,h=3,$fn=300);
}

}


module duct_trident_v2(){

difference(){
union(){
//translate([0,200-22,23.5])color("lime")rotate([0,0,180])import("Duct.stl");
//translate([0,200-22,23.5])color("lime")rotate([0,0,180])
//import("duct_v2.stl");
translate([0,200-22,23.5])color("lime")rotate([0,0,180])
import("Duct_v2_orig.stl");

/*
*/
translate([0,-2,2]){
hull(){
translate([10.7,200-22-100+0.53-3.8,-10+2.2])color("lime")rotate([0,0,180])cylinder(r=7.8/2,h=4.1,$fn=300);
#translate([10.7,200-22-100+0.53-4.3-2,-10+2.2])color("lime")rotate([0,0,180])cylinder(r=7.8/2,h=4.1,$fn=300);
}
translate([-27,0,0]){
hull(){
translate([10.7,200-22-100+0.53-3.8,-10+2.2])color("lime")rotate([0,0,180])cylinder(r=7.8/2,h=4.1,$fn=300);
translate([10.7,200-22-100+0.53-4.3-2,-10+2.2])color("lime")rotate([0,0,180])cylinder(r=7.8/2,h=4.1,$fn=300);
}
}
}

/*
color("lime")hull(){
#translate([10.7,200-22-100+0.53,-10+2.2])color("lime")rotate([0,0,180])cylinder(r=7.8/2,h=7-4.3,$fn=300);
#translate([10.7,200-22-100+0.53-3.4,-10+2.2])color("lime")rotate([0,0,180])cylinder(r=7.8/2,h=7-4.3,$fn=300);
}
color("lime")hull(){
translate([10.7-27,200-22-100+0.53,-10+2.2])color("lime")rotate([0,0,180])cylinder(r=7.8/2,h=7-4.3,$fn=300);
translate([10.7-27,200-22-100+0.53-3.4,-10+2.2])color("lime")rotate([0,0,180])cylinder(r=7.8/2,h=7-4.3,$fn=300);
}
*/

}


//translate([-50,95,-25])#cube([100,50,30]);
//translate([-50,95-50.,-25])#cube([100,50,30]);


hull(){
translate([10.7,200-22-100+0.53-3.8,-10+2.2+6.1])color("red")rotate([0,0,180])cylinder(r=9/2,h=6.1,$fn=300);
translate([10.7,200-22-100+0.53-3.8-7,-10+2.2+6.1])color("red")rotate([0,0,180])cylinder(r=9/2,h=6.1,$fn=300);
}
translate([-27,0,0])hull(){
translate([10.7,200-22-100+0.53-3.8,-10+2.2+6.1])color("red")rotate([0,0,180])cylinder(r=9/2,h=6.1,$fn=300);
translate([10.7,200-22-100+0.53-3.8-7,-10+2.2+6.1])color("red")rotate([0,0,180])cylinder(r=9/2,h=6.1,$fn=300);
}

translate([0,-4.95,3.39]){
#translate([10.7,200-22-100+0.53-3,-10+2.2+4.01-4.3])color("silver")rotate([0,0,180])cylinder(r=6.05/2,h=3,$fn=300);
#translate([10.7-27,200-22-100+0.53-3,-10+2.2+4.01-4.3])color("silver")rotate([0,0,180])cylinder(r=6.05/2,h=3,$fn=300);
}

}
}


module carriage_body_bottom_v2(){

//translate([9.8-7.5,43.8+18,-60+8.6+5])#cylinder(r=3.5/2,h=50,$fn=300);
difference(){
import("carriage_body_bottom.stl");


translate([0,0,8.7+5]){
translate([9.8,43.8,-60])#cylinder(r=5/2,h=50,$fn=300);
translate([9.8-25.3,43.8,-60])#cylinder(r=5/2,h=50,$fn=300);
}
}
}


module carriage_body_rear_trident_v2(){

difference(){
//import("carriage_body_rear.stl");
translate([-5.5,182.277,21.4])color("pink")rotate([0,180,180])import("CarriageBodyRearSpring.stl");
//import("carriage_body_rear.stl");
translate([0,-4.5,0]){
translate([-2.5,100-7.+4,-3.6])rotate([90,0,0])cylinder(r=10.15/2,h=3+4,$fn=300);
translate([-2.5+15.8,100-7.+4,-3.6+51.1])rotate([90,0,0])cylinder(r=10.15/2,h=3+4,$fn=300);
translate([-2.5-16.2,100-7.+4,-3.6+51.1])rotate([90,0,0])cylinder(r=10.15/2,h=3+4,$fn=300);
}
}



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
