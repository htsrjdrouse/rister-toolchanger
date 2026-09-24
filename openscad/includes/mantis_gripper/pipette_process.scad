//include <linearactuator.scad>
///Users/richard/Documents/voron/Trident/lineux_toolchanger/production/gantry/optimum_toolchanger_size
include <luerlock.scad>
include <tslot.inc.scad>

include <washstation.scad>
include <multichannel_cameramount.scad>


p10_length = 34;            // mm
p10_top_od = 6;             // mm outer diameter top
p10_top_id = 3.5;           // mm inner diameter top
p10_bottom_od = 0.75;       // mm outer diameter bottom
p10_bottom_id = 0.35;       // mm inner diameter bottom



include <linearactuator.scad>
include <bom_multichannel_syringe.scad>
include <pipette_model.scad>
include <bom_camera.scad>




//include <pipette_wick_assembly.scad>
include <pipette_wick_assembly.scad>

//piezo_dispenser_assy_holder_p200LTS();


//p10_tip();
//p200_cut_tip();
//pipette_p300_lts_model();

//piezo_dispenser_assy_remover();

//translate([425.5,-344.4,-300-4])rotate([0,0,90])peek_nozzle_4channel();
//bayonet_pipette_tipcase_holder();


//import("pipetting/Luer_Connectors_ISO594/Luer_Female_1mm_ID_ISO594.STL");
//peek_nozzle_part1_4channel();
//bayonet_pipette_tipcase_holder();

//peek_nozzle_part3_4channel();
//translate([-15.7,10-10,-20])peek_nozzle_4channel();
//translate([345.5,439,250+20])rotate([0,180,90])coolwashassembly();

//translate([337,427,300-15])rotate([0,180,90])peek_nozzle_part3_4channel();
//peek_nozzle_4channel();
//bayonet_dispenser_assy();
//bayonet_pipette_tip_assy();

/*
translate([400-70,426.5,330-3])rotate([0,0,-90]){
translate([0,0,-13]){
translate([-0.5,-0.7,0])rotate([0,180,180])piezo_dispenser_assy_holder();
}
}
*/

//bayonet_remover_assay();
//bayonet_pipette_tipcase_assy();

//bayonet_pipette_tipcase();
//translate([-15.7,0,-25-0])peek_nozzle_4channel();
//peek_nozzle_part2_4channel();
//piezo_dispenser_assy_holder();

//piezo_dispenser_assy_holder();

//pipette_plug();

//piezo_dispenser_assy_holder_nozzle_base();
//piezo_dispenser_assy_holder_nozzles();
//piezo_dispenser_assy_remover();


//translate([337,427,300])rotate([0,180,90])peek_nozzle_holder_printed();

//translate([337,427,300])rotate([0,180,90])peek_nozzle_part1(); 
//translate([337,427,300-15])rotate([0,180,90])peek_nozzle_part2(); //nozzle end
//translate([337,427,300-15])rotate([0,180,90])peek_nozzle_part3();


//bayonet_pipette_tip_box();
//bayonet_pipette_tipcase();
//bayonet_pipette_tipcase_holder();

/*
*/

//bayonet_pipette_tip_assy();

/*
translate([0,0.8,0])linearactuator_pipette_holder_p200LTS();
difference(){
import("../stls/LiquidDispenserTool0/pipette_loading_module_rack.stl");
translate([310,423,310.5])cube([40,50,7]);
}
*/

//peek_nozzle_4channel();

/*
translate([320-1,427,306+2])
for(i=[0:3]){
translate([i*7,0,0])p200_lts_holder();
}
*/

//p200LTS_guillitine();
//translate([337-12.5,427,300-15])rotate([0,180,90])peek_nozzle_part3_4channel_p200LTS();

//peek_nozzle_part1and2_4channel_p200LTS();
//p200_lts_holder();
//translate([20,0,0])p20_lts_holder();

/*
difference(){
union(){
translate([337-12.5,427,300-15])rotate([0,180,90])peek_nozzle_part3_4channel_p200LTS();
//translate([337-12.5,427,300])rotate([0,180,90])peek_nozzle_part1_4channel_p200LTS(); 

//translate([337-12.5,427,300-15])rotate([0,180,90])peek_nozzle_part2_4channel_p200LTS(); //nozzle end
}
translate([320-1,427,306+2])
for(i=[0:3]){
translate([i*7,0,0])scale([1.0,1.0,1])#p200_lts_holder();
}
}
*/

module peek_nozzle_part1and2_4channel_p200LTS(){
translate([337-12.5,427,300])rotate([0,180,90])peek_nozzle_part1_4channel_p200LTS(); 
translate([337-12.5,427,300-15])rotate([0,180,90])peek_nozzle_part2_4channel_p200LTS(); //nozzle end
}

module p200LTS_guillitine(){
difference(){union(){
//translate([337-12.5,427,300])rotate([0,180,90])peek_nozzle_part1_4channel_p200LTS(); 
corner_radius = 1;  // Adjust this value to change roundness
translate([337-12.5,427,300])rotate([0,180,90])translate([-4-2,-5-15.2,-2-15])rounded_cube([8+4, 10+15.1+5-18, 17+5-5], corner_radius);
translate([337-12.5+1.4+7,427-5,300-17.7])cube([18-7,10,17.7]);
}
translate([320-1,427,306+2])
for(i=[0:3]){
translate([i*7,0,0])scale([1.0,1.0,1])p200_lts_holder();
}
}
}

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


module peek_nozzle_4channel(){
translate([337,427,300])rotate([0,180,90])peek_nozzle_part1_4channel(); 
//translate([337,427,300])rotate([0,180,90])peek_nozzle_part1_4channel_groove(); 
translate([337,427,300-15])rotate([0,180,90])peek_nozzle_part2_4channel(); //nozzle end
translate([337,427,300-15])rotate([0,180,90])peek_nozzle_part3_4channel();
translate([337,427,300]){
for(i=[0:3]){
translate([i*5.2,0,0])pipette_assy_for_peek_nozzle_4channel();
}
}
}


module pipette_assy_for_peek_nozzle_4channel(){
//silicon tubing od 4mm id 2mm
color("lightblue")translate([0,0,5])difference(){
cylinder(d=4.1,h=14,$fn=50);
translate([0,0,-0.5])cylinder(d=2.1,h=15.1,$fn=50);
}
//silicon tubing od 4mm id 2mm stretched part
color("lightblue")translate([0,0,3])difference(){
cylinder(d2=4.1,d1=5,h=2,$fn=50);
translate([0,0,-0.5])cylinder(d2=2.1,d1=3,h=3.1,$fn=50);
}
//silicon tubing od 4mm id 2mm stretched part
color("lightblue")translate([0,0,0])difference(){
cylinder(d=5,h=3,$fn=50);
translate([0,0,-0.5])cylinder(d=3,h=4.1,$fn=50);
}
//plastic polypropylene connector
color("lightgreen")translate([0,0,-5])difference(){
cylinder(d1=2,d2=3,h=8,$fn=50);
translate([0,0,-0.5])cylinder(d1=2,d1=1,h=8.6,$fn=50);
}

//peek nozzle
color("red")translate([0,0,-10])difference(){
cylinder(d=1.5875,h=8,$fn=50);
translate([0,0,-0.5])cylinder(d=0.127,h=8.6,$fn=50);
}

//silicon tubing od 2mm id 1mm stretched part
color("lightblue")translate([0,0,-2])difference(){
cylinder(d=3.5,h=1,$fn=50);
translate([0,0,-0.5])cylinder(d=2.5,h=1.6,$fn=50);
}
//silicon tubing od 2mm id 1mm
color("lightblue")translate([0,0,-5])difference(){
cylinder(d2=3.5,d1=2,h=3,$fn=50);
translate([0,0,-0.5])cylinder(d2=2.5,d1=1.5878,h=3.6,$fn=50);
}
//silicon tubing od 2mm id 1mm stretched
color("lightblue")translate([0,0,-8])difference(){
cylinder(d=3,h=5,$fn=50);
translate([0,0,-0.5])cylinder(d=1.5878,h=5.7,$fn=50);
}
}

module peek_nozzle_part1_4channel(){
difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4,-5-15.2,-2-15])rounded_cube([8, 10+15.1, 17+5-5], corner_radius);
}
translate([0,3.5,-1.5])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,-3.5-15,-1.5])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,0,-12.5]){
translate([0,3.5,-2])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,-3.5-15,-2])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
}
for(i=[0:3]){
translate([0,-i*5.2,0]){
scale([1.02,1.02,1]){
cylinder(d1=3,d2=2.5,h=5,$fn=50);
translate([0,0,-5])cylinder(d=5,h=5,$fn=50);
translate([0,0,-5-15-20])cylinder(d=4.1,h=122,$fn=50);
}
}
}
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



















module nichrome_groove() {
    pitch = 2; // mm between wraps
    groove_depth = 0.6;
    groove_width = 1.0;
    num_wraps = 4;
    
    for(i=[0:num_wraps]) {
        translate([0, 0, -5-i*pitch]) // Start at z=-5 to avoid top features
            rotate_extrude($fn=100)
                translate([4.5, 0, 0]) // radius - adjusted to fit your body width
                    square([groove_width, groove_depth]);
    }
}

module peek_nozzle_part1_4channel_groove(){
    difference(){
        union(){
            corner_radius = 1;  // Adjust this value to change roundness
            translate([-4,-5-15.2,-2-15])rounded_cube([8, 10+15.1, 17+5-5], corner_radius);
        }
        
        // Existing mounting holes
        translate([0,3.5,-1.5])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
        translate([0,-3.5-15,-1.5])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
        translate([0,0,-12.5]){
            translate([0,3.5,-2])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
            translate([0,-3.5-15,-2])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
        }
        
        // Channel holes
        for(i=[0:3]){
            translate([0,-i*5.2,0]){
                scale([1.02,1.02,1]){
                    cylinder(d1=3,d2=2.5,h=5,$fn=50);
                    translate([0,0,-5])cylinder(d=5,h=5,$fn=50);
                    translate([0,0,-5-15-20])cylinder(d=4.1,h=122,$fn=50);
                }
            }
        }
        
        // ADD NICHROME GROOVE HERE
        translate([0,-8,0])scale([0.9,2.5,1])nichrome_groove();
        
        // Optional: Add wire entry/exit notches
        translate([4.5, -10, -5])cube([1, 1, 2], center=true); // wire in
        translate([4.5, -10, -29])cube([1, 1, 2], center=true); // wire out
    }
}
























module peek_nozzle_part2_4channel(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
union(){
translate([-4-2,-5-2-15,-2-17])rounded_cube([8+4, 10+4+15, 7.5+1], corner_radius);
hull(){for(i=[0:3]){
translate([0,-i*5.2,-10.5])cylinder(d1=8,d2=5,h=3.3,$fn=50);
}
}
}
for(i=[0:3]){
translate([0,-i*5.2,-10.5])cylinder(d1=4.2,d2=2.5,h=4,$fn=50);
}
translate([0,0,-14.5]){
translate([0,3.5,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5-15,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}
translate([0,0,-15-12.5]){
translate([0,3.5,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}
translate([0,0,-15])scale([1.02,1.02,1]){
translate([-4,-5-15,-2-15])rounded_cube([8, 10+15, 17+5-5], corner_radius);
//cylinder(d1=3,d2=2.5,h=5,$fn=50);
for(i=[0:3]){
translate([0,-i*5.2,0])cylinder(d1=4.1,d2=4.1,h=5,$fn=50);
translate([0,-i*5.2,-5])cylinder(d=5,h=5,$fn=50);
}
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









module peek_nozzle_part3_4channel(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4-2,-5-2-15,-2-16-16-4])rounded_cube([8+4, 10+4+15, 7.5-1+4], corner_radius);
translate([0,0,-15-12.5]){
translate([0,3.5,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5-15,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}
translate([0,0,-15])scale([1.02,1.02,1]){
translate([-4,-5-15,-2-15-1])rounded_cube([8, 10+15, 17+5-5], corner_radius);
cylinder(d1=3,d2=2.5,h=5,$fn=50);
translate([0,0,-5])cylinder(d=5,h=5,$fn=50);
}
for(i=[0:3]){
translate([0,-i*5.2,-40])cylinder(d=3,h=40,$fn=50);
translate([0,-i*5.2,-40+2])cylinder(d1=5.75,d2=3,h=4,$fn=50);
translate([0+0.5,-i*5.2,-40+2])cylinder(d1=5.75,d2=3,h=4,$fn=50);
translate([0-0.5,-i*5.2,-40+2])cylinder(d1=5.75,d2=3,h=4,$fn=50);
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
}
//underside orifice relfecting the p200 LTS pipette tip
for(i=[-1:2]){
translate([0,-i*7-1.5,-23])scale([1.05,1.05,1])rotate([0,180,0])p200_lts_holder();
}
//topside orifice
for(i=[-1:2]){
translate([0,-i*7-1.5,-40+2-2.01])cylinder(d1=6.25,d2=5,h=5,$fn=50);
}
}
}














module peek_nozzle_part3(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4-2,-5-2,-2-16-16])rounded_cube([8+4, 10+4, 7.5-1], corner_radius);

translate([0,0,-15-12.5]){
translate([0,3.5,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}
translate([0,0,-15])scale([1.02,1.02,1]){
translate([-4,-5,-2-15])rounded_cube([8, 10, 17+5-5], corner_radius);
cylinder(d1=3,d2=2.5,h=5,$fn=50);
translate([0,0,-5])cylinder(d=5,h=5,$fn=50);
translate([0,0,-20])cylinder(d=3,h=20,$fn=50);
}
}
}

module peek_nozzle_part2(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
union(){
translate([-4-2,-5-2,-2-17])rounded_cube([8+4, 10+4, 7.5+1], corner_radius);
translate([0,0,-10.5])cylinder(d1=8,d2=5,h=3.3,$fn=50);
}
translate([0,0,-10.5])cylinder(d1=4.2,d2=3,h=4,$fn=50);
translate([0,0,-14.5]){
translate([0,3.5,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}

translate([0,0,-15-12.5]){
translate([0,3.5,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}
translate([0,0,-15])scale([1.02,1.02,1]){
translate([-4,-5,-2-15])rounded_cube([8, 10, 17+5-5], corner_radius);
//cylinder(d1=3,d2=2.5,h=5,$fn=50);
cylinder(d1=4.1,d2=4.1,h=5,$fn=50);
translate([0,0,-5])cylinder(d=5,h=5,$fn=50);
}
}
}


module peek_nozzle_part1(){
difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4,-5,-2-15])rounded_cube([8, 10, 17+5-5], corner_radius);
}
translate([0,3.5,-1.5])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,-3.5,-1.5])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,0,-12.5]){
translate([0,3.5,-2])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,-3.5,-2])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
}
scale([1.02,1.02,1]){
cylinder(d1=3,d2=2.5,h=5,$fn=50);
translate([0,0,-5])cylinder(d=5,h=5,$fn=50);
translate([0,0,-5-12])cylinder(d=4,h=12,$fn=50);
}
}
}






module peek_nozzle_holder_printed(){
difference(){
union(){
//translate([-4,-4,0])cube([8,20,7]);
corner_radius = 1;  // Adjust this value to change roundness
translate([-4,-4,0])rounded_cube([8, 23.5-0, 7], corner_radius);
translate([-2,-4,0])rounded_cube([4, 23.5-0, 7+8], corner_radius);
 //translate([0,0+4*5.2,0])cylinder(d1=3.5,d2=2.3,h=9, $fn=50);

for(i=[0:3]){
 translate([0,0+i*5.2,0])print_nozzle_holder();
}

}
for(i=[0:3]){
            translate([0, i*5.2, -0.1]) 
            cylinder(h = print_nozzle_holder_length + 0.2, r1 = print_nozzle_holder_top_id / 2, r2 = print_nozzle_holder_bottom_id / 2, $fn = 50);
            //translate([0,i*5.2,0])cylinder(h = print_nozzle_holder_length + 0.2, d = 1.4, $fn = 50);
            translate([0,0+i*5.2,-0.1])cylinder(d1=3.5,d2=2.2,h=9, $fn=50);
}

            translate([0,0*5.2,-3])cylinder(h = print_nozzle_holder_length + 10.2, d = 1.9, $fn = 50);
            translate([0,1*5.2,-3])cylinder(h = print_nozzle_holder_length + 10.2, d = 2, $fn = 50);
            translate([0,2*5.2,-3])cylinder(h = print_nozzle_holder_length + 10.2, d = 2.1, $fn = 50);
            translate([0,3*5.2,-3])cylinder(h = print_nozzle_holder_length + 10.2, d = 2.1, $fn = 50);


}
}

//p200_cut_tip();


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



module bayonet_pipette_tipcase_assy(){
translate([400-70,426.5,330-3])rotate([0,0,-90]){
translate([0,0,-13]){
//bayonet pipette assay
bayonet_pipette_tipcase();
}
}
}











module bayonet_pipette_tip_box(){
translate([2.4,0,0]){
//translate([330,417.8,260-15])rotate([0,0,90])bayonet_dispenser_assy();
//translate([330,417.8+24,260-15])rotate([0,0,90])bayonet_dispenser_assy();
translate([327.5,428,315+60])rotate([0,0,90]){
bayonet_pipette_tipcase();
//translate([-30-164.5,0,-151.5])rotate([0,-90,0])bayonet_pipette_tipcase_makesquare();
//translate([-30+223.5,0,-151.5-5])rotate([0,90,0])bayonet_pipette_tipcase_makesquare();
}
}
//translate([250,244,-10])bayonet_pipette_tipcase_clamp();

}

//tubing_straight_sledcap();
//bayonet_pipette_tip_assy();

/*
translate([-7.5,-3,1]){
translate([320+5.7+47-30,300-3-31.5+180-6-10+0.4,400-1-57+16.5-34])rotate([0,180,0])small_pipette_assembly();
translate([320+5.7+47-30-4,300-3-31.5+180-6-10+0.4,400-1-57+16.5-34])rotate([0,180,0])small_pipette_assembly();
translate([320+5.7+47-30-8,300-3-31.5+180-6-10+0.4,400-1-57+16.5-34])rotate([0,180,0])small_pipette_assembly();
translate([320+5.7+47-30-12,300-3-31.5+180-6-10+0.4,400-1-57+16.5-34])rotate([0,180,0])small_pipette_assembly();
}
*/

//smallwick_pipette_assembly();

//bayonet_pipette_tipcase_clamp();
//bayonet_cut_tool();




//bayonet_pipette_tipcase();
//translate([-30,0,0])bayonet_pipette_tipcase_makesquare();



module bayonet_dispenser_assy(){
piezo_dispenser_assy_holder_nozzle_base();
piezo_dispenser_assy_holder_nozzles();
}


module barb_end(){
translate([0,0,0])difference(){
union(){
color("lime"){
translate([0,6,4.72])rotate([0,90,0])cylinder(d=1.72,h=7,$fn=300);
translate([0+4,6,4.72])rotate([0,90,0])cylinder(d=(1.72+0.48),h=7,$fn=300);
translate([1.27+7.73,6,4.72])rotate([0,90,0])cylinder(d1=1.72,d2=1.72+4.8,h=2.,$fn=300);
}
}

translate([0-1,6,4.72])rotate([0,90,0])cylinder(d=1.1,h=17,$fn=300);
//translate([0-1,6,4.72])rotate([0,90,0])cylinder(d=0.8,h=17,$fn=300);

/*
translate([0-1,6-0.625,4.72+0.09])rotate([0,90,0])cylinder(d=0.2,h=3.3,$fn=300);
translate([0-1+3,6-0.625-0.1,4.72+0.09])rotate([0,90,0])cylinder(d=0.2,h=9.6,$fn=300);
translate([0-1,6+0.625,4.72+0.09])rotate([0,90,0])cylinder(d=0.2,h=3.3,$fn=300);
translate([0-1+3,6+0.625+0.1,4.72+0.09])rotate([0,90,0])cylinder(d=0.2,h=9.6,$fn=300);
*/
//translate([0-1+11,6-0.625,4.72+0.09])rotate([+50,90,0])cylinder(d=0.2,h=2.5,$fn=300);
//translate([0-1+11+1.5,6-0.625-1.9,4.72+0.09])rotate([0,90,0])cylinder(d=0.2,h=2.5,$fn=300);
}
}


module seal_channel(){
translate([0-1+11+1.45,6+0.625+0.1,4.72+0.09])rotate([180,90,0])cylinder(d=0.2,h=1.5,$fn=300);
translate([0-1+11+1.45,6+0.625,4.72+0.09])rotate([-90,90,0])cylinder(d=0.2,h=1.5,$fn=300);
translate([0-1+11+1.45,6+0.625+1.4,4.72+0.09])rotate([0,90,0])cylinder(d=0.2,h=6.2,$fn=300);
translate([0-1+11+1.45+6,6+0.625+1.4,4.72+0.09])rotate([50,90,0])cylinder(d=0.2,h=1.5,$fn=300);
translate([0-1+11+1.45+6+0.78,6+0.625+1.4-1.1,4.72+0.09])rotate([-20,90,0])cylinder(d=0.2,h=2.1,$fn=300);

translate([0-1+11+1.45,6-0.625-0.1,4.72+0.09])rotate([180,90,0])cylinder(d=0.2,h=1.5,$fn=300);
translate([0-1+11+1.45,6-0.625,4.72+0.09])rotate([90,90,0])cylinder(d=0.2,h=1.5,$fn=300);
translate([0-1+11+1.45,6-0.625-1.4,4.72+0.09])rotate([0,90,0])cylinder(d=0.2,h=6.2,$fn=300);
translate([0-1+11+1.45+6,6-0.625-1.4,4.72+0.09])rotate([-50,90,0])cylinder(d=0.2,h=1.5,$fn=300);
translate([0-1+11+1.45+6+0.78,6-0.625-1.4-1.1+2.2,4.72+0.09])rotate([20,90,0])cylinder(d=0.2,h=2.1,$fn=300);


}


/*
difference(){
union(){
import("pipetting/Luer_Connectors_ISO594/Luer_Female_1mm_ID_ISO594.STL");
//translate([1.6-10,3.5,4.7-6])scale([1,1,1.0])color("red")cube([5,5,5]);
}
translate([-13.0+2.2,5.98,4.7])color("pink")rotate([0,90,0])cylinder(d=14,h=20,$fn=300);
}
*/

//color("peru")piezo_luerlock_lid();
//color("lime")piezo_luerlock();

//piezo_silicone_tubing();


//hplc_cable_cutter();

/*
*/


//piezo_dispenser_assy_holder_nozzle_base();
//piezo_dispenser_assy_holder_nozzles();
//piezo_dispenser_assy_remover();
//translate([327.5,428,315+60])rotate([0,0,90])bayonet_pipette_tipcase();
//tubing_straight_sledcap();
//bayonet_pipette_tip_assy();
//bayonet_pipette_tipcase_clamp();
//bayonet_cut_tool();



module bayonet_pipette_tipcase_clamp_50mmstandoff(){
translate([140,210-30,230])difference(){
union(){
//translate([-17-8,5,4])cube([5+4+110,16,5]);
translate([-17-8,-5-9,-42-20])cube([5,35,51+20]);
}
translate([0,-10,0]){
translate([0,3,-10+11])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
translate([0,8+15,-10+11])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
hull(){
translate([0,3,-10])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
translate([0,3,-55])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
}
translate([0,15,0])hull(){
translate([0,8,-10])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
translate([0,8,-55])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
}
}
//translate([-12+6,15,0])cylinder(r=4.2/2,h=30,$fn=300);
//translate([-12+95-5,15,0])cylinder(r=4.2/2,h=30,$fn=300);
}
}









module bayonet_pipette_tipcase_clamp(){
translate([140,210-30,230])difference(){
union(){
//translate([-17-8,5,4])cube([5+4+110,16,5]);
translate([-17-8,-5-9,-42-20])cube([5,35,51+20]);
}
translate([0,-10,0]){
translate([0,3,-10+11])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
translate([0,8+15,-10+11])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
hull(){
translate([0,3,-10])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
translate([0,3,-55])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
}
translate([0,15,0])hull(){
translate([0,8,-10])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
translate([0,8,-55])rotate([0,-90,0])cylinder(r=5.7/2,h=50,$fn=300);
}
}
//translate([-12+6,15,0])cylinder(r=4.2/2,h=30,$fn=300);
//translate([-12+95-5,15,0])cylinder(r=4.2/2,h=30,$fn=300);
}
}



module bayonet_cut_tool(){

difference(){
cube([20,10,10]);
translate([10,5,0])cylinder(d=3.1,h=30,$fn=100);
}
}



module linearactuator_pipette_holder_p200LTS(){
translate([0,0,0]){
difference(){
translate([320+5.7+47,300-3-31.5+180-6,400-1-57+16.5])rotate([0,0,180])translate([22-0.5,-5.25,-100-40+10+5-20+31])rotate([0,0,90])pipette_loading_module_rack_base();
translate([320+5.7+47-50,300-3-31.5+180-6-20-5.5-20,400-1-57+16.5-68])cube([20,20+20,20]);
}
}
translate([400-70,426.5,330-3])rotate([0,0,-90]){
translate([0,0,-13]){
translate([-0.5,-0.7,0])rotate([0,180,180])piezo_dispenser_assy_holder_p200LTS();
}
}
}







module linearactuator_pipette_holder(){
translate([0,0,0]){
difference(){
translate([320+5.7+47,300-3-31.5+180-6,400-1-57+16.5])rotate([0,0,180])translate([22-0.5,-5.25,-100-40+10+5-20+31])rotate([0,0,90])pipette_loading_module_rack_base();
translate([320+5.7+47-50,300-3-31.5+180-6-20-5.5-20,400-1-57+16.5-68])cube([20,20+20,20]);
}
}
translate([400-70,426.5,330-3])rotate([0,0,-90]){
translate([0,0,-13]){
translate([-0.5,-0.7,0])rotate([0,180,180])piezo_dispenser_assy_holder();
}
}
}




module bayonet_remover_assay(){
//bayonet remover assay
translate([0,-3,-8]){
translate([400-70,426.5,330-3-18])rotate([0,0,-90])color("pink")piezo_dispenser_assy_remover();
translate([270+120,265+361,422])rotate([0,0,90])import("singlechannel_tipremoval_base.stl");
}
}

module bayonet_pipette_tip_assy(){
translate([320+5.7+47,300-3-31.5+180-6,400-1-57+16.5])rotate([0,0,180])lineux_linearactuator_assy();
linearactuator_pipette_holder();
}



module bayonet_pipette_tipcase_makesquare(){
translate([0-0.5,0-2,-130]){
difference(){
translate([-9,-32,-14])cube([14,64,5]);
translate([0,0,0]){
translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23,-11])cylinder(d=10.5,h=20,$fn=100);
translate([0,-46,0]){
translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23,-11])cylinder(d=10.5,h=20,$fn=100);
}
}
}
}
}


module bayonet_pipette_tipcase_holder(){
difference(){
union(){
color("peru"){
translate([-17+10-1.5,13.5,-14])cube([10+3,18,10]);
translate([-17+5,13.5-3,-14])cube([23,10-0.5+3,10]);
translate([-17+5,13-36,-14])cube([23,10+3,10]);
translate([-17+10-1.5,13-36-8,-14])cube([10+3,18,10]);
translate([-17+5,13-36,-14])cube([5,10+36,6]);
translate([-17+3+20,13-36,-14])cube([5,10+36,6]);
}
}
corner_radius = 1;  // Adjust this value to change roundness
translate([-2,0,5])
translate([-4.25+10,-5-2-7.5+1,-2-11])rounded_cube([8+4, 10, 7.5+1], corner_radius);
translate([-4.25-10,-5-2+10,-2-6])rounded_cube([8+4, 10, 7.5+1], corner_radius);
for(i=[-1:1]){
for(j=[-1:1]){
translate([-6.25+j/2,-5-2-7.5+2.7+i/2,-2-13])rounded_cube([12, 10+4+10, 7.5+10], corner_radius);
translate([-6.25+i/2,-5-2-7.5+2.7+j/2,-2-13])rounded_cube([12, 10+4+10, 7.5+10], corner_radius);
translate([-6.25+j/2,-5-2-7.5+i/2,-2-10])rounded_cube([8+4, 10+4+15, 7.5+10], corner_radius);
translate([-6.25+i/2,-5-2-7.5+j/2,-2-10])rounded_cube([8+4, 10+4+15, 7.5+10], corner_radius);
}
}
translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23,-11])cylinder(d=10.5,h=20,$fn=100);
translate([0,-46,0]){
translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23,-11])cylinder(d=10.5,h=20,$fn=100);
}
}
}














module bayonet_pipette_tipcase(){

translate([0-0.5,0-2,-130]){
translate([-15-35,8,-9])rotate([0,90,0])tslot20(100);
translate([-15-35,8-46,-9])rotate([0,90,0])tslot20(100);
translate([14,0,0])bayonet_pipette_tipcase_holder();
translate([-10,0,0])bayonet_pipette_tipcase_holder();

}
}


module hplc_cable_cutter(){
$fn = 50; // Increase $fn for smoother curves
difference(){
union(){
rounded_box_minkowski(size = [10, 20, 9], radius = 2, center = true);
translate([1.5,0,-5-3])rounded_box_minkowski(size = [2, 17, 10], radius = 0.5, center = true);
translate([1.5-1,0,-5-4-4])rounded_box_minkowski(size = [4, 17, 2], radius = 0.5, center = true);

translate([0,0,9.3-1]){
translate([0,3.2+2.5,-17])cylinder(d=3.275,h=3,$fn=100);
translate([0,1.8,-17])cylinder(d=3.275,h=3,$fn=100);
translate([0,-1.8,-17])cylinder(d=3.275,h=3,$fn=100);
translate([0,-3.2-2.5,-17])cylinder(d=3.275,h=3,$fn=100);
}


}
//translate([0,0,-17])cylinder(d=3.05,h=50,$fn=100);
/*
translate([0,0,9-9]){
translate([0,3.2+2.5,-17])cylinder(d=3.275,h=50,$fn=100);
translate([0,1.8,-17])cylinder(d=3.275,h=50,$fn=100);
translate([0,-1.8,-17])cylinder(d=3.275,h=50,$fn=100);
translate([0,-3.2-2.5,-17])cylinder(d=3.275,h=50,$fn=100);
}
*/
translate([0,0,20]){
translate([0,3.2+2.5,-17])cylinder(d=3.35,h=50,$fn=100);
translate([0,1.8,-17])cylinder(d=3.35,h=50,$fn=100);
translate([0,-1.8,-17])cylinder(d=3.35,h=50,$fn=100);
translate([0,-3.2-2.5,-17])cylinder(d=3.35,h=50,$fn=100);
}

translate([0,0,-2]){
translate([0,3.2+2.5,-10])cylinder(d=1.7,h=89,$fn=100);
translate([0,1.8,-10])cylinder(d=1.7,h=89,$fn=100);
translate([0,-1.8,-10])cylinder(d=1.7,h=89,$fn=100);
translate([0,-3.2-2.5,-10])cylinder(d=1.7,h=89,$fn=100);
}
}
}


module piezo_dispenser_assy_holder_nozzles(){
$fn = 50; // Increase $fn for smoother curves
color("lightblue")
/*
*/
translate([0,0,9-11]){
l = 21;
translate([0,-5.8+12,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8+8,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8+4,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8,-17])cylinder(d=3.275,h=l,$fn=100);
}
color("red")translate([0,0,1]){
for(i=[0:3]){
translate([0,-5.7+(i*4),-17-8-4])cylinder(d=1.75,h=19,$fn=100);
}
}
/*
*/

color("lightblue")translate([0,0,10.5+16]){
for(i=[0:3]){
difference(){
translate([0,-5.7+(i*4),-17-8-4])cylinder(d2=4,d1=1,h=26,$fn=100);
translate([0,-5.7+(i*4),-17-8-3.9])cylinder(d2=3.2,d1=0.6,h=26,$fn=100);
}
}
}

//pipette_plug();


difference(){
union(){
ad = 3;
translate([1.5+ad/2,0,-5-5])rounded_box_minkowski(size = [2+ad, 17+6.5, 8+6+6], radius = 0.5, center = true);
translate([1.5-1,0,-5-4-4-3-4-1])rounded_box_minkowski(size = [5, 17, 8], radius = 0.5, center = true);
}

translate([0-20,-5.8+15.1+0.3,-17+14])rotate([0,90,0])cylinder(d=3.2,h=50,$fn=100);
translate([0-20,-5.8+15.1-18.5-0.3,-17+14])rotate([0,90,0])cylinder(d=3.2,h=50,$fn=100);
translate([0,0,9-11]){
l = 21;
translate([0,-5.8+12,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8+8,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8+4,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8,-17])cylinder(d=3.275,h=l,$fn=100);
}
translate([0,0,9-9]){
l = 26;
translate([0,-5.8+12,-17])cylinder(d=2.5,h=l,$fn=100);
translate([0,-5.8+8,-17])cylinder(d=2.5,h=l,$fn=100);
translate([0,-5.8+4,-17])cylinder(d=2.5,h=l,$fn=100);
translate([0,-5.8,-17])cylinder(d=2.5,h=l,$fn=100);
}
translate([0,0,-1]){
for(i=[0:3]){
translate([0,-5.7+(i*4),-17-8])cylinder(d=1.68,h=9,$fn=100);
}
}
}
/*
*/
}



module pipette_plug(){
translate([0,0,10.5+16+30]){
for(i=[0]){
difference(){
union(){
translate([0,-5.7+(i*4),-17-8-10])color("yellow")cylinder(d2=3.8,d1=3,h=9,$fn=100);
}
translate([0,-5.7+(i*4),-17-8-3.9-14])cylinder(d2=2.4,d1=2.4,h=36,$fn=100);
}
}
}
}


module piezo_dispenser_assy_remover(){
difference(){
union(){
translate([-7,0,-.75])rounded_box_minkowski(size = [17, 20+2+6.5+30, 4], radius = 0.5, center = true);
translate([-18,0,-.75])rounded_box_minkowski(size = [10, 20+2+6.5+22, 4], radius = 0.5, center = true);
translate([-23,0,-.75])rounded_box_minkowski(size = [10, 20+2+6.5+22, 4], radius = 0.5, center = true);
translate([-23+3.5,0,-.75-7.5])rounded_box_minkowski(size = [15, 20+2+6.5+22, 4+15], radius = 0.5, center = true);
}
translate([-2,0,-.75])rounded_box_minkowski(size = [19, 20+2+6.5+12, 7], radius = 2, center = true);
#translate([-18.8,17.5,-.75-5-15])cylinder(d=6,h=35,$fn=100);
#translate([-18.8,-17.5,-.75-5-15])cylinder(d=6,h=35,$fn=100);
}
}




module piezo_dispenser_assy_holder_p200LTS(){
$fn = 50; // Increase $fn for smoother curves
/*
for(i=[0:3]){
translate([0,-1.9+(i*5.2),18])rotate([0,180,0])pipette_plug();
}
*/
/*
color("lightblue")translate([0,-1.9,10.5+12-20]){
for(i=[0:3]){
difference(){
translate([0,-5.7+(i*5.2),-17-8-4-80-60])cylinder(d=2,h=106+60,$fn=100);
translate([0,-5.7+(i*5.2),-17-8-4.1-80-60])cylinder(d=1,h=106+60,$fn=100);
}
}
}
color("lightgreen")translate([0,-1.9,10.5+12+1]){
for(i=[0:3]){
difference(){
translate([0,-5.7+(i*5.2),-17-8-4])cylinder(d1=5,d2=2.5,h=26,$fn=100);
translate([0,-5.7+(i*5.2),-17-8-4.1])cylinder(d1=3,d2=0.8,h=26,$fn=100);
}
}
}
*/
/*

//for set screws
color("silver")translate([0,-1.9,10.5+12]){
for(i=[0:3]){
translate([0-6.5,-5.7+(i*5.2),-17-5.5])rotate([0,90,0])cylinder(d=3.5,h=1.5,$fn=100);
}
}
*/
difference(){
union(){
rounded_box_minkowski(size = [10+4, 20+2+6.5+6, 7], radius = 2, center = true);
}
translate([0,0,17.8]){
l = 7.2;
for(i=[0:3]){
//translate([0,-5.8+5.2*i-1.8,-21.4])cylinder(d1=5,d2=4,h=l,$fn=100);
#translate([0,-5.8+7*i-4.9,-21.4-3.5])cylinder(d1=7,d2=6,h=13,$fn=30);
}
}
translate([14,0,17.8-18])rotate([0,90,0]){
l = 6;
for(i=[0:3]){
translate([0,-5.8+7*i-4.9,-21.4])cylinder(d=1.8,h=l,$fn=100);
}
}
}
}



































module piezo_dispenser_assy_holder(){
$fn = 50; // Increase $fn for smoother curves
/*
for(i=[0:3]){
translate([0,-1.9+(i*5.2),18])rotate([0,180,0])pipette_plug();
}
*/
color("lightblue")translate([0,-1.9,10.5+12-20]){
for(i=[0:3]){
difference(){
translate([0,-5.7+(i*5.2),-17-8-4-80-60])cylinder(d=2,h=106+60,$fn=100);
translate([0,-5.7+(i*5.2),-17-8-4.1-80-60])cylinder(d=1,h=106+60,$fn=100);
}
}
}
color("lightgreen")translate([0,-1.9,10.5+12+1]){
for(i=[0:3]){
difference(){
translate([0,-5.7+(i*5.2),-17-8-4])cylinder(d1=5,d2=2.5,h=26,$fn=100);
translate([0,-5.7+(i*5.2),-17-8-4.1])cylinder(d1=3,d2=0.8,h=26,$fn=100);
}
}
}
//for set screws
color("silver")translate([0,-1.9,10.5+12]){
for(i=[0:3]){
translate([0-6.5,-5.7+(i*5.2),-17-5.5])rotate([0,90,0])cylinder(d=3.5,h=1.5,$fn=100);
}
}
difference(){
union(){
rounded_box_minkowski(size = [10, 20+2+6.5+6, 7], radius = 2, center = true);
}
translate([0,0,17.8]){
l = 7.2;
for(i=[0:3]){
translate([0,-5.8+5.2*i-1.8,-21.4])cylinder(d1=5,d2=4,h=l,$fn=100);
}
}
translate([14,0,17.8-18])rotate([0,90,0]){
l = 6;
for(i=[0:3]){
translate([0,-5.8+5.2*i-1.8,-21.4])cylinder(d=1.8,h=l,$fn=100);
}
}
}
}








module piezo_dispenser_assy_holder_nozzle_base(){
$fn = 50; // Increase $fn for smoother curves

/*
translate([18,0,0])color("silver"){
translate([0-12,-5.8+15.1+0.3,-17+14])rotate([0,-90,0])cylinder(d=3,h=10,$fn=100);
translate([0-12,-5.8+15.1-18.5-0.3,-17+14])rotate([0,-90,0])cylinder(d=3,h=10,$fn=100);
}
*/
/*
translate([0,0,9-9]){
l = 23;
translate([0,-5.8+12,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8+8,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8+4,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8,-17])cylinder(d=3.275,h=l,$fn=100);
}
*/

/*
translate([0,0,9-9]){
l = 26;
translate([0,-5.8+12,-17])cylinder(d=2.5,h=l,$fn=100);
translate([0,-5.8+8,-17])cylinder(d=2.5,h=l,$fn=100);
translate([0,-5.8+4,-17])cylinder(d=2.5,h=l,$fn=100);
translate([0,-5.8,-17])cylinder(d=2.5,h=l,$fn=100);
}
*/

/*
translate([0,0,1]){
for(i=[0:3]){
translate([0,-5.7+(i*4),-17-8])cylinder(d=1.7,h=9,$fn=100);
}
}
*/

difference(){
union(){
th = 2;
translate([0-th/2,0,0])rounded_box_minkowski(size = [10+th, 20+2+6.5+6, 15], radius = 2, center = true);
ad = 3;
//translate([1.5+ad/2,0,-5-5])rounded_box_minkowski(size = [2+ad, 17, 8+6+6], radius = 0.5, center = true);
//translate([1.5-1,0,-5-4-4-3-3])rounded_box_minkowski(size = [4, 17, 2], radius = 0.5, center = true);
}
translate([1.5+3/2,0,-5-5])scale([1.05,1.05,1.05])rounded_box_minkowski(size = [2+3, 17+6.5, 8+6+6], radius = 0.5, center = true);
//translate([1.5+ad/2,0,-5-5])rounded_box_minkowski(size = [2+ad, 17, 8+6+6], radius = 0.5, center = true);
//translate([0,0,-17])cylinder(d=3.05,h=50,$fn=100);

translate([0-20,-5.8+15.1+0.3,-17+14])rotate([0,90,0])cylinder(d=2.9,h=50,$fn=100);
translate([0-20,-5.8+15.1-18.5-0.3,-17+14])rotate([0,90,0])cylinder(d=2.9,h=50,$fn=100);

translate([0,0,9-9]){
l = 23;
translate([0,-5.8+12,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8+8,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8+4,-17])cylinder(d=3.275,h=l,$fn=100);
translate([0,-5.8,-17])cylinder(d=3.275,h=l,$fn=100);
}

translate([0,0,9-9]){
l = 26;
translate([0,-5.8+12,-17])cylinder(d=2.5,h=l,$fn=100);
translate([0,-5.8+8,-17])cylinder(d=2.5,h=l,$fn=100);
translate([0,-5.8+4,-17])cylinder(d=2.5,h=l,$fn=100);
translate([0,-5.8,-17])cylinder(d=2.5,h=l,$fn=100);
}

translate([0,0,1]){
for(i=[0:3]){
translate([0,-5.7+(i*4),-17-8])cylinder(d=1.7,h=9,$fn=100);
}
}
}
}






module piezo_dispenser_assy(){
translate([0,0,-12]){
silicone_tubing();
//gauge_32_dispense_needle();
hplc_tubing_model();
translate([0,0,-1])piezo_2_2_3_PA3CKW();
}
}

module piezo_2_2_3_PA3CKW(){
translate([-3.5,-1,1.3])color("white")cube([2,2,3]);
}

module tubing_holder(){
difference(){
cube([20,30,15]);
}
}

module rounded_box_minkowski(size, radius, center = false) {
    // Adjust cube size to compensate for the Minkowski sum
    adjusted_size = size - [2*radius, 2*radius, 2*radius];
    
    // Calculate translation for centering if needed
    translate_vec = (center == true) ? 
        [ -size[0]/2 + radius, -size[1]/2 + radius, -size[2]/2 + radius ] :
        [ radius, radius, radius ];

    translate(v = translate_vec) {
        minkowski() {
            cube(size = adjusted_size, center = false);
            sphere(r = radius);
        }
    }
}

module silicone_tubing(){
difference(){
union(){
translate([0,0,-4.9])color("lightblue")cylinder(d=3,h=24.5,$fn=100);
}
translate([0,0,-0.2])cylinder(d=1.59,h=52,$fn=100);
}
}

module gauge_32_dispense_needle(){
difference(){
union(){
//translate([0,0,-6])color("silver")cylinder(d=0.23,h=11,$fn=100);
translate([0,0,-13.5])color("red")cylinder(d=1.59,h=12,$fn=100);
}
translate([0,0,-8])color("silver")cylinder(d=0.1,h=15,$fn=100);
}
}

module hplc_tubing_model(){
difference(){
union(){
//translate([0,0,-6])color("silver")cylinder(d=0.23,h=11,$fn=100);
translate([0,0,-13.5])color("red")cylinder(d=1.59,h=12,$fn=100);
}
translate([0,0,-8])color("silver")cylinder(d=0.1,h=15,$fn=100);
}
}




module piezo_luerlock_lid(){
//import("luerlock_stub.stl");
difference(){
union(){
translate([20.6,0,9.5])rotate([0,180,0])barb_end();
translate([1.6+8,6,4.717])rotate([0,-90,0])color("pink")cylinder(d=6.5,h=7+4.5-4.5,$fn=100);
translate([1.6+8-4.5-2,6,4.717])rotate([0,-90,0])color("pink")cylinder(d1=6.5,d2=2,h=7+4.5-4.5-2,$fn=100);
translate([1.6+2,3.5,4.7-6])scale([1.0,1.0,1.0])color("red")cube([5,5,5]);
}
translate([1.6+8+1-2-5-3.5,6,4.717])scale([1,1,1])rotate([0,-90,0])cylinder(d1=2.5,d2=2.5,h=1.3+2,$fn=100);
translate([1.6+8+1-2-5-3.5+2.499,6,4.717])scale([1,1,1])rotate([0,-90,0])cylinder(d2=1.6,d1=0.4,h=2.5,$fn=100);
translate([1.6+2,3.5,4.7-6])scale([1.05,1.05,1.0])color("red")cube([5,5,5]);
translate([1.6+2-20,3.5-5,4.7-6+1])scale([1.05,1.05,1.0])cube([38,15,5]);
translate([0,0,0]){
translate([1.6+8+1,6,4.717])scale([1,1,1])rotate([0,-90,0])color("pink")cylinder(d2=0.6,d1=1.1,h=2.2,$fn=100);
translate([1.6+8+1-2,6,4.717])scale([1,3,1])rotate([0,-90,0])color("pink")cylinder(d=1.1,h=5,$fn=100);
translate([1.6+8+1-2-5,6,4.717])scale([1,3,1])rotate([0,-90,0])color("pink")cylinder(d1=1.1,d2=0.15,h=1,$fn=100);
translate([1.6+8+1-2-5+6,6,4.717])scale([1,3,1])rotate([0,-90,0])cylinder(d2=1.1,d1=0.15,h=1,$fn=100);
translate([1.6+8+1-2-5,6,4.717])scale([1,1,1])rotate([0,-90,0])color("pink")cylinder(d1=0.8,d2=0.8,h=11,$fn=100);

}
//translate([20.6,0,9.5])rotate([0,180,0])seal_channel();
}
}




module piezo_luerlock(){
difference(){
translate([20.6,0,9.5])rotate([0,180,0])barb_end();
//import("luerlock_stub.stl");
translate([1.6+2-20,3.5-5,4.7-6+1+5])scale([1.05,1.05,1.0])cube([24.36+0.2+14,15,5]);
}
difference(){
union(){
translate([1.6+8,6,4.717])rotate([0,-90,0])cylinder(d=6.5,h=7+4.5-4.5,$fn=100);
translate([1.6+8-4.5-2,6,4.717])rotate([0,-90,0])cylinder(d1=6.5,d2=2,h=7+4.5-4.5-2,$fn=100);
translate([1.6+2,3.5,4.7-6])scale([1.0,1.0,1.0])color("red")cube([5,5,5]);
}
translate([1.6+8+1-2-5-3.5,6,4.717])scale([1,1,1])rotate([0,-90,0])cylinder(d1=2.5,d2=2.5,h=1.3+2,$fn=100);
translate([1.6+8+1-2-5-3.5+2.499,6,4.717])scale([1,1,1])rotate([0,-90,0])cylinder(d2=1.6,d1=0.4,h=2.5,$fn=100);

translate([1.6+2,3.5,4.7-6])scale([1.05,1.05,1.0])cube([5,5,5]);
translate([1.6+2-20,3.5-5,4.7-6+1+5])scale([1.05,1.05,1.0])cube([35,15,5]);
translate([0,0,0]){
translate([1.6+8+1,6,4.717])scale([1,1,1])rotate([0,-90,0])cylinder(d2=0.6,d1=1.1,h=2.2,$fn=100);
translate([1.6+8+1-2,6,4.717])scale([1,3,1])rotate([0,-90,0])cylinder(d=1.1,h=5,$fn=100);
translate([1.6+8+1-2-5,6,4.717])scale([1,3,1])rotate([0,-90,0])cylinder(d1=1.1,d2=0.15,h=1,$fn=100);
translate([1.6+8+1-2-5+6,6,4.717])scale([1,3,1])rotate([0,-90,0])cylinder(d2=1.1,d1=0.15,h=1,$fn=100);
translate([1.6+8+1-2-5,6,4.717])scale([1,1,1])rotate([0,-90,0])cylinder(d1=0.8,d2=0.8,h=11,$fn=100);
//translate([1.6+8+1-2-5,6,4.717])scale([1,1,1])rotate([0,-90,0])cylinder(d1=0.325,d2=0.325,h=11,$fn=100);
}

//translate([20.6,0,9.5])rotate([0,180,0])seal_channel();

}
}

//luerlock_piezo_luerlock();



//piezonozzle_0_9orifice();

//translate([315.7,426.5-0.1,283])rotate([4.7,0,0])color("red")import("thorlabs_piezo_CTN002736.stl");
//translate([315.7,426.5-0.1,283])rotate([4.7,0,0])color("red")translate([-1.5,0,-1.5])cube([3,2,3]); //thorlabs_piezo_PA3JEAW 
// translate([320+5.7+47-55.7-1.3,300-3-31.5+180-6-10+0.4-35.5+35.2,400-1-57+16.5-124+32.6])translate([0,0,75])p10_05_orifice_end();

//color("red")import("thorlabs_piezo_CTN002736.stl");
//translate([-1.5,0,-1.5])cube([3,2,3]);
/*
//translate([320+5.7+47-55.7,300-3-31.5+180-6-10+0.4-35.5,400-1-57+16.5-124])rotate([0,0,0])thorlabs_piezo_model();

translate([320+5.7+47,300-3-31.5+180-6,400-1-57+16.5])rotate([0,0,180])lineux_linearactuator_assy();




for(i=[0:2]){
for(j=[0:2]){
translate([i*7,j*5,0])rotate([0,0,0])p10_05_orifice_end();
}
}
*/

/*
//translate([315.7,426.5-0.1,283])rotate([4.7,0,0])color("red")translate([-1.5,0,-1.5])cube([3,2,3]); //thorlabs_piezo_PA3JEAW 
translate([320+5.7+47-55.7-1.3,300-3-31.5+180-6-10+0.4-35.5+35.2,400-1-57+16.5-124+32.6]){
translate([0,0,84])rotate([0,180,0]){
 //translate([0,0,45])p10_tip();
 translate([0,0,75])p10_05_orifice_end_piezo();
}
}


*/


/*
//translate([315.7,426.5-0.1,283])rotate([4.7,0,0])color("red")translate([-1.5,0,-1.5])cube([3,2,3]); //thorlabs_piezo_PA3JEAW 
translate([320+5.7+47-55.7-1.3,300-3-31.5+180-6-10+0.4-35.5+35.2,400-1-57+16.5-124+32.6]){
//color("red")translate([-2.5,-2.5,18-7])thorlabs_piezo();
translate([0,0,84])rotate([0,180,0]){
 //smallwick_pipette_assembly();
 //translate([0,0,45])p10_tip();
 translate([0,0,75])p10_05_orifice_end_piezo();
}
}
*/
//lineux_linearactuator_assy();



module luerlock_piezo_luerlock(){
translate([-13,0,9.4])rotate([0,180,0])import("pipetting/Luer_Connectors_ISO594/Luer_Female_1mm_ID_ISO594_snipped.STL");
import("pipetting/Luer_Connectors_ISO594/Luer_Female_1mm_ID_ISO594_snipped.STL");
translate([1.6,3.5,4.7-6])scale([1,1,1.0])color("red")cube([5,5,5]);
difference(){
union(){
translate([8,5.98,4.7])scale([4,8,4])rotate([0,-90,0])rotate([0,0,45])cylinder(d1=1.1,d2=1.1,h=7,$fn=4);
}
translate([1.5,3.3,4.7-6])scale([1.05,1.05,1.0])color("red")cube([5,5,5]);
translate([0,0,0]){
translate([9,5.98,4.7])color("pink")rotate([0,-90,0])cylinder(d1=1.1,d2=1.1,h=2,$fn=300);
hull(){
translate([7,5.98,4.7])color("pink")rotate([0,-90,0])cylinder(d1=1.1,d2=1.1,h=2,$fn=300);
translate([5,5.98,4.7])scale([1,6,1])color("pink")rotate([0,-90,0])rotate([0,0,45])cylinder(d1=1.1,d2=1.1,h=2,$fn=4);
translate([3,5.98,4.7])color("pink")rotate([0,-90,0])cylinder(d1=0.7,d2=0.7,h=2,$fn=300);
}
translate([1,5.98,4.7])color("pink")rotate([0,-90,0])cylinder(d1=0.7,d2=0.7,h=1,$fn=300);
translate([-6.5,0,0])hull(){
translate([7,5.98,4.7])color("pink")rotate([0,-90,0])cylinder(d1=0.7,d2=0.7,h=2,$fn=300);
translate([5,5.98,4.7])scale([1,2,1])color("pink")rotate([0,-90,0])rotate([0,0,45])cylinder(d1=1.1,d2=1.1,h=8,$fn=4);
translate([3-6,5.98,4.7])color("pink")rotate([0,-90,0])cylinder(d1=1,d2=1,h=2,$fn=300);
}
translate([-10.3,5.98,4.7])color("pink")rotate([0,-90,0])cylinder(d1=1,d2=1,h=30,$fn=300);
}
}
}






module piezonozzle_0_9orifice(){
difference(){
union(){
//translate([0.1,-3.2,-6.9+10.5-5])rotate([-4.7,0,0])color("red")translate([-1.5,0-1,-1.5-0.5])cube([3,2+1,3+1]); //thorlabs_piezo_PA3JEAW
cylinder(d1=3.5,d2=0.6,h=5,$fn=300);
difference(){
union(){
translate([0,0,-5.-4.5])cylinder(d1=4,d2=3.5,h=10,$fn=300);
translate([0,0,-5.-4.5-30])cylinder(d1=4,d2=4,h=30,$fn=300);
}
//for(i=[0:5]){
//translate([0,i*0.2,-30])p10_tip_diff();
//}
}
}
translate([0.1,-3.2,-6.9+10.5-5])rotate([-4.7,0,0])translate([-1.5,0,-1.5])cube([3,2,3]); //thorlabs_piezo_PA3JEAW
//translate([0,0,-30])p10_tip_diff();
translate([0,0,0]){
//translate([0,0,-0.1-5])cylinder(d1=2.2,d2=1.2,h=4.12,$fn=300);
//translate([0,0,-9.2-10])scale([1,1.1,1])cylinder(d1=0.3,d2=0.3,h=10.2,$fn=300);
translate([0,0,-9.2-6-32])scale([1,1,1])cylinder(d=1,h=10,$fn=300);
translate([0,0,5.5]){
translate([0,0,-9.2-6-30])scale([2,1,1])cylinder(d=0.5,h=34,$fn=300);
translate([0,0,-9.2-2])scale([1,0.8,1])cylinder(d1=1,d2=0.3,h=1,$fn=300);
translate([0,0,-9.2-1])scale([1,0.8,1])cylinder(d1=0.3,d2=1,h=1,$fn=300);
translate([0,0,-9.2])scale([2.5,1,1])cylinder(d=0.5,h=4,$fn=300);
translate([0,0,-9.2+4])scale([1.2,0.8,1])cylinder(d1=1,d2=0.5,h=1,$fn=300);
}
translate([0,0,-9.2+10])scale([1,1,1])cylinder(d1=0.5,d2=0.3,h=3.2,$fn=300);
translate([0,0,4])cylinder(d1=0.3,d2=0.15,h=1,$fn=300);
translate([0,0,4])cylinder(d1=0.15, d2=0.09, h=1.2, $fn=300);
}
}
}





module p10_05_orifice_end_piezo(){
difference(){
union(){
//translate([0.1,-3.2,-6.9+10.5-5])rotate([-4.7,0,0])color("red")translate([-1.5,0-1,-1.5-0.5])cube([3,2+1,3+1]); //thorlabs_piezo_PA3JEAW
cylinder(d1=3.5,d2=0.6,h=5,$fn=300);
difference(){
union(){
translate([0,0,-5.-4.5])cylinder(d1=4,d2=3.5,h=10,$fn=300);
translate([0,0,-5.-4.5-30])cylinder(d1=4,d2=4,h=30,$fn=300);
}
//for(i=[0:5]){
//translate([0,i*0.2,-30])p10_tip_diff();
//}
}
}
translate([0.1,-3.2,-6.9+10.5-5])rotate([-4.7,0,0])translate([-1.5,0,-1.5])cube([3,2,3]); //thorlabs_piezo_PA3JEAW
//translate([0,0,-30])p10_tip_diff();
translate([0,0,0]){
//translate([0,0,-0.1-5])cylinder(d1=2.2,d2=1.2,h=4.12,$fn=300);
//translate([0,0,-9.2-10])scale([1,1.1,1])cylinder(d1=0.3,d2=0.3,h=10.2,$fn=300);
translate([0,0,-9.2-6-32])scale([1,1,1])cylinder(d=1,h=10,$fn=300);
translate([0,0,5.5]){
translate([0,0,-9.2-6-30])scale([2,1,1])cylinder(d=0.5,h=34,$fn=300);
translate([0,0,-9.2-2])scale([1,0.8,1])cylinder(d1=1,d2=0.3,h=1,$fn=300);
translate([0,0,-9.2-1])scale([1,0.8,1])cylinder(d1=0.3,d2=1,h=1,$fn=300);
translate([0,0,-9.2])scale([2.5,1,1])cylinder(d=0.5,h=4,$fn=300);
translate([0,0,-9.2+4])scale([1.2,0.8,1])cylinder(d1=1,d2=0.5,h=1,$fn=300);
}
translate([0,0,-9.2+10])scale([1,1,1])cylinder(d1=0.5,d2=0.3,h=3.2,$fn=300);
translate([0,0,4])cylinder(d1=0.3,d2=0.05,h=1,$fn=300);
translate([0,0,4])cylinder(d1=0.06, d2=0.05, h=1.2, $fn=300);
}
}
}


module p10_tip_diff() {
    color("Lightgreen") {
        difference() {
            cylinder(h = p10_length, r1 = p10_top_od / 2, r2 = p10_bottom_od / 2, $fn = 50);
            //translate([0, 0, -0.1])
            //cylinder(h = p10_length + 0.2, r1 = p10_top_id / 2, r2 = p10_bottom_id / 2, $fn = 50);
        }
    }
}



