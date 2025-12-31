
module filament_path(){
translate([2.7,130-0.65,-150])color("red")cylinder(r=3.8/2,h=300,$fn=300);
}

module toolhead_assy(){
//import("Back_Plate.stl");
translate([0,0,6.75])import("Cowl_Klicky.stl");


//locking_plate_guidepin();
#translate([0,5,3+7])color("lime")import("Back_Plate_Beacon_Cartographer_guidepin.stl");
//back_plate_cartographer();
//translate([141-0.08,-88+1+450-18+1.65,273.5])color("lightblue")rotate([-90,0,180])extruder_assy();
translate([141-0.08-280-7.3,-88+1+450-18+1.65-434.5,273.5-1])color("lightblue")rotate([-90,0,0])extruder_assy();



color("pink")translate([0,5.4,10]){
//import("Orbiter_V2_Bambu_TZ_Mount.stl");
import("daksh_extruder_bambu_mount.stl");
//daksh_extruder_bambu_mount();
//translate([32,-5.2+190,20.25+2])import("HGX_Lite_2.0_Mount.stl");
}
/*
*/


}




module daksh_extruder_bambu_mount(){

difference(){union(){
import("Orbiter_V2_Bambu_TZ_Mount.stl");
translate([-5.4,-5.5,0]){
translate([2.7+21.75-2.2-45,130-0.65-9-2.25,23])color("red")cube([50.5,15+6,10.5-3]);
//translate([2.7+21.75-2.2,130-0.65,20])color("red")cylinder(r=5/2,h=4.2-2,$fn=300);
//translate([2.7+21.75-2.2-37,130-0.65,20])color("red")cylinder(r=5/2,h=4.2-2,$fn=300);
}
}
translate([-5.4,-5.5,0]){
translate([2.7,130-0.65,-150])color("red")cylinder(r=3.8/2,h=300,$fn=300);
#translate([2.7+21.75,130-0.65,22])color("red")cylinder(r=2.9/2,h=30,$fn=300);
#translate([2.7-21.75,130-0.65,22])color("red")cylinder(r=2.9/2,h=30,$fn=300);
}
}

}


module extruder_assy(){
translate([-50+0.75,70+0.6,-9.1])extruder_back();
color("pink")extruder_front();
}

module extruder_front(){
difference(){
union(){
        //import("extruder_front.stl");
        import("extruder_front.stl");

/*
translate([130-0.15,225-0.5,230-20+17]){
  translate([14-0.2,-32-5-4,0-10+0.5])rotate([90,0,0])
  difference(){
  color("pink")cylinder(r=12.15/2,h=6,$fn=300);
  translate([0,0,0-1])cylinder(r=3.9/2,h=10,$fn=300);
  }
 }
*/

}

/*
#translate([130-0.15,225-0.5,230-20+17]){
translate([0,0,0])color("pink")cylinder(r=12.15/2,h=5,$fn=300);
translate([28,0,0])color("pink")cylinder(r=12.15/2,h=5,$fn=300);
}
*/
}
}


module extruder_back(){
difference(){
union(){
//import("extruder_back.stl");
import("extruder_back.stl");
}
//#translate([200-2.8,130-2.8,213.55-5])color("pink")cylinder(r=9.15/2,h=12.7,$fn=300);
}
}


module back_plate_cartographer(){
difference(){
import("Back_Plate_Beacon_Cartographer.stl");
translate([0,108-3+0.25,0]){
#translate([-3,0,12])rotate([90,0,0])cylinder(r=2.95/2,h=12,$fn=300);
#translate([-3,0,-12])rotate([90,0,0])cylinder(r=2.95/2,h=12,$fn=300);
}
}
}


module locking_plate_guidepin(){
difference(){
//translate([12,-0,-1])import("Locking_Plate.stl");
translate([12,-0,-1])import("Locking_Plate.stl");
translate([0,108-3,0])color("silver"){
#translate([-3,-6,12])rotate([90,0,0])cylinder(r2=3.8/2,r1=4,h=3,$fn=300);
translate([-3,0,12])rotate([90,0,0])cylinder(r=3.8/2,h=12,$fn=300);
translate([-3,0,-12])rotate([90,0,0])cylinder(r=3.8/2,h=12,$fn=300);
#translate([-3,-6,-12])rotate([90,0,0])cylinder(r2=3.8/2,r1=4,h=3,$fn=300);
}
}
}
/*
*/


