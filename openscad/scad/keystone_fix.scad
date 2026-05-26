voron_keystone_inside_fix();

//voron_keystone_outside_fix();

module voron_keystone_inside_fix(){
translate([0,-600,-558])rotate([0,-90,0])import("voron_keystone_inside_1.stl");
translate([0,-0.1,0])difference(){union(){
color("pink")translate([14.5,-46.9,1])cylinder(d=3,h=17,$fn=100);
color("pink")translate([14.5,-46.9,0.52])cylinder(d=5.5,h=4,$fn=100);
color("pink")translate([14.5+21,-46.9,1])cylinder(d=3,h=17,$fn=100);
color("pink")translate([14.5+21,-46.9,0.52])cylinder(d=5.5,h=4,$fn=100);
}
translate([14.5,-46.9,-0.5])cylinder(d=1.8,h=20,$fn=100);
translate([14.5+21,-46.9,-0.5])cylinder(d=1.8,h=20,$fn=100);
}
}

module voron_keystone_outside_fix(){
difference(){
translate([0,-600,-558])rotate([0,-90,0])import("voron_keystone_outside_1.stl");
translate([0,-0.1,10]){
#translate([14.5,-46.9,15.5])cylinder(d=5.5,h=2,$fn=100);
#translate([14.5,-46.9,-0.5])cylinder(d=2.8,h=20,$fn=100);
#translate([14.5+21,-46.9,-0.5])cylinder(d=2.8,h=20,$fn=100);
#translate([14.5+21,-46.9,15.5])cylinder(d=5.5,h=2,$fn=100);
}
}
}



