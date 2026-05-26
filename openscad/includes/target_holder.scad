
      //translate([119,410+50-320,210])color("lightblue")cube([243,355,5]); 

module target_holder() {
     color("aquamarine")import("../stls/TargetHolder/target.stl");
    //translate([-367,0,0])import("../stls/TipCase/bayonet_pipette_tipcase_clamp.stl");
    //plate_aligner();
    //translate([180,374,220])import("plate.stl");
}
/*


module plate_aligner(){
    difference(){
      union(){
      translate([119,410,210])cube([10,35,20]); 
      translate([128,410-50,210])cube([10+37,35+50,5]); 
      translate([128,410-50,210])cube([10+100,10,5]); 
      }
      #translate([128+10,410-40,210])cube([10+17,35+30,5]); 
      translate([109,417,220])rotate([0,90,0])#cylinder(d=4.8,h=20,$fn=100);
      translate([109,437,220])rotate([0,90,0])#cylinder(d=4.8,h=20,$fn=100);
    }
}
*/

