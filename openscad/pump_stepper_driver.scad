

//DRV8825 Stepper Motor Driver Modules and Expansion Boards Compatible with Arduino ESP32 Raspberry Pi for Precise Motor Control, 2 Sets
//https://www.amazon.com/dp/B0FF44DF9Q?ref=fed_asin_title&th=1
pump_stepper_driver();

module pump_stepper_driver(){

difference(){
union(){
cube([42,42,5]);
translate([40,15,0])cube([22,12,5]);
translate([-5,3.5,0])cube([5,35,5]);
translate([-58,3.5,0])cube([55,35,5]);
translate([3,3,0]){
cylinder(d=8.2/2,h=8,$fn=100);
translate([0,35.5,0])cylinder(d=8.8/2,h=8,$fn=100);
}
translate([3+35.5,3,0]){
cylinder(d=8.2/2,h=8,$fn=100);
translate([0,35.5,0])cylinder(d=8.2/2,h=8,$fn=100);
}

translate([-58+10-10+7.5,3.5+35/2,0]){
translate([0,0,0])cylinder(d=8.2,h=8,$fn=100);
translate([41,0,0])cylinder(d=8.3,h=8,$fn=100);
}



}

translate([-58+10,3.5+5,-2])cube([55-20,35-10,10]);

translate([-58+10-10+7.5,3.5+35/2,-2]){
translate([0,0,-2])cylinder(d=2.8,h=20,$fn=100);
translate([41,0,-2])cylinder(d=2.8,h=20,$fn=100);
}


translate([55,21,-2])cylinder(d=5.8,h=20,$fn=100);
translate([20,21,-2])cylinder(d=25.8,h=20,$fn=100);
translate([3,3,0]){
cylinder(d=3.2/2,h=20,$fn=100);
translate([0,35.5,0])cylinder(d=2.8/2,h=20,$fn=100);
}

translate([3+35.5,3,0]){
cylinder(d=3.2/2,h=20,$fn=100);
translate([0,35.5,0])cylinder(d=2.8/2,h=20,$fn=100);
}

}
}
