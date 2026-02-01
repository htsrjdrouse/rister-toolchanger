translate([337-12.5,427,300-15])rotate([0,180,90])peek_nozzle_part3_4channel_p200LTS();
//peek_nozzle_part1and2_4channel_p200LTS();



module p200_lts_holder(){
//translate([0,0,13.0])color("lightgreen")cylinder(d2=7.5,d1=7.1,h=8,$fn=30); //this part I cut out to assemble
color("pink")cylinder(d2=7.1,d1=6.1,h=13,$fn=30);
color("lime")translate([0,0,-9.])cylinder(d2=5,d1=4.8,h=9,$fn=30);
color("lightblue")translate([0,0,-9.-6.0])cylinder(d2=4.5,d1=4,h=6,$fn=30);
color("peru")translate([0,0,-9.-6.0-10])cylinder(d2=3.85,d1=2.85,h=10,$fn=30);
color("")translate([0,0,-9.-6.0-10-10])cylinder(d2=2.6,d1=1,h=10,$fn=30);
}

module p20_lts_holder(){
//translate([0,0,9])color("lightgreen")cylinder(d2=6,d1=5.8,h=6.2,$fn=30); // this part I cut out.
color("pink")cylinder(d2=5.8,d1=5.5,h=9,$fn=30);
color("lime")translate([0,0,-5.5])cylinder(d2=4.5,d1=2,h=5.5,$fn=30);
color("lightblue")translate([0,0,-5.5-8])cylinder(d2=2,d1=1.8,h=8,$fn=30);
color("peru")translate([0,0,-5.5-8-13])cylinder(d2=1.6,d1=1.1,h=13,$fn=30);
color("")translate([0,0,-5.5-8-13-8])cylinder(d2=1,d1=0.6,h=8,$fn=30);
}

module peek_nozzle_part1_4channel_p200LTS(){
difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4-2,-5-15.2,-2-15])rounded_cube([8+4, 10+15.1+5, 17+5-5], corner_radius);
}
translate([0,0,-12.5]){
translate([0,3.5+4,-2])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,-3.5-15,-2])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
}
#for(i=[-1:2]){
translate([0,-i*7-1.5,-8])scale([1.05,1.05,1])rotate([0,180,0])p200_lts_holder();
}
}
}

module peek_nozzle_part2_4channel_p200LTS(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
union(){
translate([-4-2-2,-5-2-15,-2-17])rounded_cube([8+4+4, 10+4+15+5, 7.5+1], corner_radius);
hull(){for(i=[-1:2]){
translate([0,-i*7-1.5,-10.5])cylinder(d1=8,d2=5,h=3.3,$fn=50);
}
}
}
for(i=[-1:2]){
translate([0,-i*7-1.5,-23])scale([1.05,1.05,1])rotate([0,180,0])p200_lts_holder();
}
}
}




module peek_nozzle_part3_4channel_p200LTS(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4-2-2,-5-2-15,-2-16-16-4-2])rounded_cube([8+4+4, 10+4+15+5, 7.5-1+4+2+2], corner_radius);
translate([0,0,-15-12.5+2]){
translate([0,3.5+4,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5-15,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}
translate([0,0,-15])scale([1.02,1.02,1]){
translate([-4-2,-5-15,-2-15-1-2])rounded_cube([8+4, 10+15+5, 17+5-5], corner_radius);
cylinder(d1=3,d2=2.5,h=5,$fn=50);
translate([0,0,-5])cylinder(d=5,h=5,$fn=50);
}
for(i=[-1:2]){
translate([0,-i*7-1.5,-23])scale([1.05,1.05,1])rotate([0,180,0])p200_lts_holder();
}
for(i=[-1:2]){
translate([0,-i*7-1.5,-40+2-2.01])cylinder(d1=6.25,d2=5,h=5,$fn=50);
}
}
}


module peek_nozzle_part1and2_4channel_p200LTS(){
translate([337-12.5,427,300])rotate([0,180,90])peek_nozzle_part1_4channel_p200LTS(); 
translate([337-12.5,427,300-15])rotate([0,180,90])peek_nozzle_part2_4channel_p200LTS(); //nozzle end
}

module rounded_cube(size, radius) {
$fn=50;
    hull() {
        translate([radius, radius, radius])
            sphere(r=radius);
        translate([size[0]-radius, radius, radius])
            sphere(r=radius);
        translate([radius, size[1]-radius, radius])
            sphere(r=radius);
        translate([size[0]-radius, size[1]-radius, radius])
            sphere(r=radius);
        translate([radius, radius, size[2]-radius])
            sphere(r=radius);
        translate([size[0]-radius, radius, size[2]-radius])
            sphere(r=radius);
        translate([radius, size[1]-radius, size[2]-radius])
            sphere(r=radius);
        translate([size[0]-radius, size[1]-radius, size[2]-radius])
            sphere(r=radius);
    }
}



