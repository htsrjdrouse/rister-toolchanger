
//fourchannel_pipette_loading_module();

module fourchannel_pipette_loading_module(){
difference(){
union(){
translate([2,-10,50])cube([45,20,13]);
//translate([2,-15,50])cube([45,8,13+10]);
}
translate([2+28.5,-10,50])cube([7+10,5,13]);
translate([2+28.5-30,-10,50])cube([7+11,5,13]);
/*
translate([20-9,0,68])rotate([90,0,0])#cylinder(d=4.5,h=50,$fn=300);
translate([20-9,0,68])rotate([90,0,0])#cylinder(d=8.5,h=11,$fn=300);
translate([20+18,0,68])rotate([90,0,0])#cylinder(d=4.5,h=50,$fn=300);
translate([20+18,0,68])rotate([90,0,0])#cylinder(d=8.5,h=11,$fn=300);
*/
translate([0,2,0]){
translate([20-9,0,40])cylinder(d=7.8,h=50,$fn=300);
translate([20,0,40])cylinder(d=7.8,h=50,$fn=300);
translate([20+9,0,40])cylinder(d=7.8,h=50,$fn=300);
translate([20+18,0,40])cylinder(d=7.8,h=50,$fn=300);


translate([20-9,20,57])rotate([90,0,0])cylinder(d=1.9,h=20,$fn=300);
translate([20,20,57])rotate([90,0,0])cylinder(d=1.9,h=20,$fn=300);
translate([20+9,20,57])rotate([90,0,0])cylinder(d=1.9,h=20,$fn=300);
translate([20+18,20,57])rotate([90,0,0])cylinder(d=1.9,h=20,$fn=300);


}

}
}
