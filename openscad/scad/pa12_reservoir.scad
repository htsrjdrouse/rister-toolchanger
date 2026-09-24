//pa12_aspiration_station();
pa12_purge_station();

//include <../includes/liquid_dispenser.scad>
//pa12_purge_station();
/*
translate([282,447,270]){
pa12_aspiration_station();
}
*/

liquid_dispenser_tool0(); 

module pa12_purge_station(){
difference(){
cube([72+20+4,30,20]);
translate([12,15,24])rotate([0,90,0])#cylinder(d=25,h=72,$fn=4);
}
}

module pa12_aspiration_station(){
difference(){
cube([72+20+4,30,20]);
translate([3.5,0,0])for(i=[0:3]){
//translate([14+i*18,15,20])rotate([0,90,0])cylinder(d=25,h=15,$fn=4);

hull(){
hull(){
translate([14+i*18,15,20])rotate([0,90,0])sphere(d=10,$fn=6);
translate([14+i*18+7,15,20])rotate([0,90,0])sphere(d=10,$fn=6);
translate([14+i*18,15,10])rotate([0,90,0])sphere(d=10,$fn=6);
translate([14+i*18+7,15,10])rotate([0,90,0])sphere(d=10,$fn=6);
}
translate([0,5,0])hull(){
translate([14+i*18,15,20])rotate([0,90,0])sphere(d=10,$fn=6);
translate([14+i*18+7,15,20])rotate([0,90,0])sphere(d=10,$fn=6);
translate([14+i*18,15,10])rotate([0,90,0])sphere(d=10,$fn=6);
translate([14+i*18+7,15,10])rotate([0,90,0])sphere(d=10,$fn=6);
}
translate([0,-5,0])hull(){
translate([14+i*18,15,20])rotate([0,90,0])sphere(d=10,$fn=6);
translate([14+i*18+7,15,20])rotate([0,90,0])sphere(d=10,$fn=6);
translate([14+i*18,15,10])rotate([0,90,0])sphere(d=10,$fn=6);
translate([14+i*18+7,15,10])rotate([0,90,0])sphere(d=10,$fn=6);
}
}

hull(){
translate([14+i*18+3.5,15,20])rotate([0,90,0])sphere(d=15,$fn=6);
#translate([14+i*18+3.5,15,8])rotate([0,90,0])sphere(d=15,$fn=6);
}


}
}
}


