// Modified bayonet_pipette_tipcase_holder() to mate with peek_nozzle_part1and2_4channel_p200LTS()
// This version is designed to fit the new rounded cube pipette holder geometry

module bayonet_pipette_tipcase_holder_v2(){
    difference(){
        union(){
            // Main mounting blocks - adjusted to match new pipette holder footprint
            color("lime"){
                // Upper mounting block
                translate([-17+10-1.5,13.5,-14])cube([10+3,18,10]);
                
                // Upper horizontal support
                translate([-17+5,13.5-3,-14])cube([23,10-0.5+3,10]);
                
                // Lower horizontal support
                translate([-17+5,13-36,-14])cube([23,10+3,10]);
                
                // Lower mounting block
                translate([-17+10-1.5,13-36-8,-14])cube([10+3,18,10]);
                
                // Vertical connecting ribs
                translate([-17+5,13-36,-14])cube([5,10+36,6]);
                translate([-17+3+20,13-36,-14])cube([5,10+36,6]);
            }
        }
        
        // ====== MATING INTERFACE FOR NEW PIPETTE HOLDER ======
        
        // Main cavity for peek_nozzle_part2 (nozzle end)
        // This matches the rounded_cube from part2: [8+4+4, 10+4+15+5, 7.5+1]
        corner_radius = 1.1;  // Slightly larger for clearance
        
        // Primary mating cavity - positioned to align with pipette holder
        translate([-2,0,5])
        translate([-4.25+10,-5-2-7.5+1,-2-11])
        rounded_cube([8+4+0.3, 10+0.3, 7.5+1+0.3], corner_radius);
        
        // Secondary clearance cavity
        translate([-4.25-10,-5-2+10,-2-6])
        rounded_cube([8+4+0.3, 10+0.3, 7.5+1+0.3], corner_radius);
        
        // Clearance for the 4-channel nozzle cones
        // The pipettes are spaced 7mm apart in Y, centered around -1.5mm in Y
        for(i=[-1:2]){
            // Cone clearance (d1=8,d2=5,h=3.3 from part2)
            translate([0,-i*7-1.5+0,5])
            cylinder(d1=8.5,d2=5.5,h=4,$fn=50);
            
            // Extended clearance for nozzle tips
            translate([0,-i*7-1.5+0,5])
            cylinder(d=6,h=15,$fn=50);
        }
        
        // Additional clearance pockets for positioning tolerance
        for(i=[-1:1]){
            for(j=[-1:1]){
                translate([-6.25+j/2,-5-2-7.5+2.7+i/2,-2-13])
                rounded_cube([12, 10+4+10, 7.5+10], corner_radius);
                
                translate([-6.25+i/2,-5-2-7.5+2.7+j/2,-2-13])
                rounded_cube([12, 10+4+10, 7.5+10], corner_radius);
                
                translate([-6.25+j/2,-5-2-7.5+i/2,-2-10])
                rounded_cube([8+4, 10+4+15, 7.5+10], corner_radius);
                
                translate([-6.25+i/2,-5-2-7.5+j/2,-2-10])
                rounded_cube([8+4, 10+4+15, 7.5+10], corner_radius);
            }
        }
        
        // ====== MOUNTING HOLES ======
        
        // Upper mounting hole
        translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
        translate([-2,23,-11])cylinder(d=10.5,h=20,$fn=100);
        
        // Lower mounting hole
        translate([0,-46,0]){
            translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
            translate([-2,23,-11])cylinder(d=10.5,h=20,$fn=100);
        }
    }
}

// Helper module - rounded cube for clearances
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

// Render the modified holder
//bayonet_pipette_tipcase_holder_v2();
