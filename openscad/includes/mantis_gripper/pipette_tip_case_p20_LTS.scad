//translate([337-12.5,427,300-15+0.2])rotate([0,180,90])peek_nozzle_part3_4channel_p20LTS();
//peek_nozzle_part1and2_4channel_p20LTS();



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
color("pink")cylinder(d2=5.8+0.2,d1=5.5+0.2,h=9,$fn=30);
color("lime")translate([0,0,-5.5])cylinder(d2=4.5+1,d1=2+1,h=5.5,$fn=30);
color("lightblue")translate([0,0,-5.5-8])cylinder(d2=2+0.6,d1=1.8+0.6,h=8,$fn=30);
color("peru")translate([0,0,-5.5-8-13])cylinder(d2=1.6,d1=1.1,h=13,$fn=30);
color("")translate([0,0,-5.5-8-13-8])cylinder(d2=1,d1=0.6,h=8,$fn=30);
}

// ============================================================================
// P20 LTS 4-CHANNEL HOLDER - PART 1 (Base with screw holes)
// ============================================================================
module peek_nozzle_part1_4channel_p20LTS(){
difference(){
union(){
corner_radius = 1;  // Rounded corners
// Main body - scaled down from P200 dimensions
translate([-4-2,-5-15.2,-2-13])rounded_cube([8+4, 10+15.1+5, 15+3], corner_radius);
}
// Screw holes for assembly
translate([0,0,-11]){
translate([0,3.5+4,-2])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,-3.5-15,-2])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
}
// Cutouts for 4 P20 tips
#for(i=[-1:2]){
translate([0,-i*7-1.5,-7])scale([1.05,1.05,1])rotate([0,180,0])p20_lts_holder();
}
}
}

// ============================================================================
// P20 LTS 4-CHANNEL HOLDER - PART 2 (Tip retention collar)
// ============================================================================
module peek_nozzle_part2_4channel_p20LTS(){
difference(){
corner_radius = 1;
union(){
// Main collar body
translate([-4-2-2,-5-2-15,-2-15])rounded_cube([8+4+4, 10+4+15+5, 6.5+1], corner_radius);
// Conical transition to tip orifices
hull(){for(i=[-1:2]){
translate([0,-i*7-1.5,-9.5])cylinder(d1=7,d2=4.5,h=3,$fn=50);
}
}
}
// Cutouts for 4 P20 tips
for(i=[-1:2]){
translate([0,-i*7-1.5,-20])scale([1.05,1.05,1])rotate([0,180,0])p20_lts_holder();
}
}
}

// ============================================================================
// P20 LTS 4-CHANNEL HOLDER - PART 3 (Top cap with screw bosses)
// ============================================================================
module peek_nozzle_part3_4channel_p20LTS(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4-2-2,-5-2-15,-2-16-16-4-2+6])rounded_cube([8+4+4, 10+4+15+5, 7.5-1+4+2+2-6], corner_radius);
translate([0,0,-15-12.5+2]){
translate([0,3.5+4,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5-15,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}
translate([0,0,-15])scale([1.02,1.02,1]){
translate([-4-2,-5-15,-2-15-1-2+5])rounded_cube([8+4, 10+15+5, 17+5-5], corner_radius);
}
//underside orifice reflecting the p20 LTS pipette tip
for(i=[-1:2]){
translate([0,-i*7-1.5,-23+0.9])scale([1.05,1.05,1])rotate([0,180,0])p20_lts_holder();
}
//topside orifice - smaller at top to grip tip
for(i=[-1:2]){
translate([0,-i*7-1.5,-40+2-2.01+4])#cylinder(d1=6.2,d2=5,h=5,$fn=50);
}
}
}

// ============================================================================
// ASSEMBLY MODULE - Parts 1 and 2
// ============================================================================
module peek_nozzle_part1and2_4channel_p20LTS(){
translate([337-12.5,427,300])rotate([0,180,90])peek_nozzle_part1_4channel_p20LTS(); 
translate([337-12.5,427,300-15])rotate([0,180,90])peek_nozzle_part2_4channel_p20LTS(); //nozzle end
}

// ============================================================================
// HELPER MODULE - Rounded cube
// ============================================================================
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

// ============================================================================
// ASSEMBLY NOTES
// ============================================================================
/*
P20 LTS 4-CHANNEL PIPETTE TIP HOLDER
=====================================

PARTS:
- Part 1: Base with M2 screw holes (bottom)
- Part 2: Tip retention collar (middle)  
- Part 3: Top cap with screw bosses (top)

DIMENSIONS (compared to P200):
- Tip spacing: 7mm (same as P200 for compatibility)
- Overall height: ~35mm (vs 43mm for P200)
- Body width: 12mm (vs 12mm - same)
- Body length: ~30mm (vs 30mm - same)

ASSEMBLY:
1. Cut the lightgreen mounting section from P20 tips
2. Insert tips through Part 3 from top
3. Slide Part 2 over tips to retain them
4. Attach Part 1 base
5. Secure with M2 screws through holes

SCREW SPECIFICATIONS:
- 2x M2 screws (12-15mm length recommended)
- Screw holes: 1.7mm diameter
- Screw boss holes: 2.5mm diameter

PRINTING NOTES:
- Material: PETG recommended for dimensional stability
- Layer height: 0.2mm
- Infill: 30-50%
- Supports: May be needed for screw holes
- Orientation: Print Part 1 and 2 upright, Part 3 can be inverted

USAGE:
- Compatible with Rister 4-dispenser toolchanger
- 7mm tip spacing allows independent control
- Tips can be cut to different lengths for variable orifice sizes
- Designed for heated pipette operation at 60°C
*/
