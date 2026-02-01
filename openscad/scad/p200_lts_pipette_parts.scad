//include <../bayonet_tipcase_holder_modified.scad>
//include <../bayonet_holder_v3.scad>
//include <../bayonet_pipette_tipcase_holder_FINAL.scad>

//bayonet_pipette_tipcase_assy();
//translate([-1.5,10,-120+5-10])peek_nozzle_part1and2_4channel_p200LTS();

bayonet_pipette_tipcase_holder_LTS();

module bayonet_pipette_tipcase_holder_LTS(){
difference(){
translate([328,437,184])rotate([0,0,-90])bayonet_pipette_tipcase_holder();
translate([-1.5,10,-120-3.1])scale([1,1,1])peek_nozzle_part1and2_4channel_p200LTS_stub();
for(x=[-1:1]){
for(y=[-1:1]){
translate([-1.5+x*(0.75),10+(y*0.75),-120-3])scale([1,1,1])peek_nozzle_part1and2_4channel_p200LTS_stub();
translate([-1.5+x*(0.75),10+(y*0.75),-120])scale([1,1,1])peek_nozzle_part1and2_4channel_p200LTS_stub();
}
}
}
}

//translate([328,437,184])rotate([0,0,-90])bayonet_pipette_tipcase_holder_v2();


module peek_nozzle_part1and2_4channel_p200LTS(){
translate([337-12.5,427,300])rotate([0,180,90])peek_nozzle_part1_4channel_p200LTS(); 
translate([337-12.5,427,300-15])rotate([0,180,90])peek_nozzle_part2_4channel_p200LTS(); //nozzle end
}

module peek_nozzle_part1and2_4channel_p200LTS_stub(){
translate([337-12.5,427,300])rotate([0,180,90])peek_nozzle_part1_4channel_p200LTS_stub(); 
translate([337-12.5,427,300-15])rotate([0,180,90])peek_nozzle_part2_4channel_p200LTS_stub(); //nozzle end
}



module peek_nozzle_part1_4channel_p200LTS_stub(){
difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4-2,-5-15.2,-2-15])rounded_cube([8+4, 10+15.1+5, 17+5-5], corner_radius);
}
#translate([0,0,-12.5]){
translate([0,3.5+4,-2])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,-3.5-15,-2])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
}
/*
for(i=[-1:2]){
translate([0,-i*7-1.5,-8])scale([1.05,1.05,1])rotate([0,180,0])p200_lts_holder();
}
*/

}
}






module peek_nozzle_part1_4channel_p200LTS(){
difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4-2,-5-15.2,-2-15])rounded_cube([8+4, 10+15.1+5, 17+5-5], corner_radius);
}
#translate([0,0,-12.5]){
translate([0,3.5+4,-2])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,-3.5-15,-2])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
}
for(i=[-1:2]){
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

module peek_nozzle_part2_4channel_p200LTS_stub(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
union(){
translate([-4-2-2,-5-2-15,-2-17])rounded_cube([8+4+4, 10+4+15+5, 7.5+1], corner_radius);
hull(){for(i=[-1:2]){
translate([0,-i*7-1.5,-10.5])cylinder(d1=8,d2=5,h=3.3,$fn=50);
}
}
}
/*
for(i=[-1:2]){
translate([0,-i*7-1.5,-23])scale([1.05,1.05,1])rotate([0,180,0])p200_lts_holder();
}
*/
}
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




module p200_lts_holder(){
color("pink")cylinder(d2=7.1,d1=6.1,h=13,$fn=30);
#color("lime")translate([0,0,-9.])cylinder(d2=5,d1=4.8,h=9,$fn=30);
color("lightblue")translate([0,0,-9.-6.0])cylinder(d2=4.5,d1=4,h=6,$fn=30);
color("peru")translate([0,0,-9.-6.0-10])cylinder(d2=3.85,d1=2.85,h=10,$fn=30);
color("")translate([0,0,-9.-6.0-10-10])cylinder(d2=2.6,d1=1,h=10,$fn=30);
}


module bayonet_pipette_tipcase_assy(){
translate([400-70,426.5,330-3])rotate([0,0,-90]){
translate([0,0,-13]){
//bayonet pipette assay
bayonet_pipette_tipcase();
}
}
}

module bayonet_pipette_tipcase(){

translate([0-0.5,0-2,-130]){
//translate([-15-35,8,-9])rotate([0,90,0])tslot20(100);
//translate([-15-35,8-46,-9])rotate([0,90,0])tslot20(100);
//translate([14,0,0])bayonet_pipette_tipcase_holder();
translate([-10,0,0])bayonet_pipette_tipcase_holder();

}
}


module bayonet_pipette_tipcase_holder(){
difference(){
union(){
color("peru"){
translate([-17+10-1.5,13.5,-14])cube([10+3,18,10]);
translate([-17+5,13.5-3,-14])cube([23,10-0.5+3,13]);
translate([-17+5,13-36,-14])cube([23,10+3,13]);
translate([-17+10-1.5,13-36-8,-14])cube([10+3,18,10]);
translate([-17+5,13-36,-14])cube([5,10+36,13]);
translate([-17+3+20,13-36,-14])cube([5,10+36,13]);
}
}
corner_radius = 1;  // Adjust this value to change roundness
translate([-2,0,5])
translate([-4.25+10,-5-2-7.5+1,-2-11])rounded_cube([8+4, 10, 7.5+1], corner_radius);
translate([-4.25-10,-5-2+10,-2-6])rounded_cube([8+4, 10, 7.5+1], corner_radius);
/*
for(i=[-1:1]){
for(j=[-1:1]){
translate([-6.25+j/2,-5-2-7.5+2.7+i/2,-2-13])rounded_cube([12, 10+4+10, 7.5+10], corner_radius);
translate([-6.25+i/2,-5-2-7.5+2.7+j/2,-2-13])rounded_cube([12, 10+4+10, 7.5+10], corner_radius);
translate([-6.25+j/2,-5-2-7.5+i/2,-2-10])rounded_cube([8+4, 10+4+15, 7.5+10], corner_radius);
translate([-6.25+i/2,-5-2-7.5+j/2,-2-10])rounded_cube([8+4, 10+4+15, 7.5+10], corner_radius);
}
}
*/

translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23,-11])cylinder(d=10.5,h=20,$fn=100);
translate([0,-46,0]){
translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23,-11])cylinder(d=10.5,h=20,$fn=100);
}
}
}

//(C) Nathan Zadoks 2011
//CC-BY-SA or GPLv2, pick your poison.
module tslot(
	size=10,	//size of each side
	length=10,	//length. descriptive enough, no?
	thickness=3,	//thickness of the 'sheet'
	gap=0,		//gap, thickness of the lower part of the 'T'
	center=false,	//somewhat vague. todo.
	nut=false,	//set to true to make a fitting T-slot nut
){
	start=thickness/sqrt(2);
	if(nut){
		linear_extrude(height=10)
		intersection(){
			polygon([[size/2-gap/2,0],[size/2-gap/2,thickness],[thickness+start,thickness],[size/2,size/2-2],[size-thickness-start,thickness],[size/2+gap/2,thickness],[size/2+gap/2,0]]);
			square([size,size/2-(gap+thickness)/2]);
		}
	}	
	else{
		color([0.5,0.5,0.5])
		linear_extrude(height=length,center=center)
		translate([15,15])
		difference(){
			union(){
				for(d=[0:3]) rotate([0,0,d*90]) polygon(points=[
					[0,0],
					[0,start],[size/2-thickness-start,size/2-thickness],[gap/2,size/2-thickness],[gap/2,size/2],
					[size/2,size/2],[size/2,gap/2],[size/2-thickness,gap/2],[size/2-thickness,size/2-thickness-start],[start,0]
				]);
				square(gap+thickness,center=true);
			}
			circle(r=gap/2,center=true);
		}
	}
}
module tslot20(length,nut){
	tslot(size=20,gap=5.26,thickness=1.5,length=length,nut=nut);
}

















