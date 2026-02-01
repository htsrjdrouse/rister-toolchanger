// Modified bayonet_pipette_tipcase_holder() to fit peek_nozzle_part1and2_4channel_p200LTS()
//
// VERIFIED GEOMETRY IN HOLDER'S LOCAL COORDINATES:
// - Pipette body: [-8, -27, -8.5] to [8, 7, 0] (size: [16, 34, 8.5])
// - Nozzles at: X=0, Y=-27.5/-20.5/-13.5/-6.5, Z=-8.5
// - Nozzle cones: d1=8mm, d2=5mm, h=3.3mm extending downward

module bayonet_pipette_tipcase_holder(){
    difference(){
        union(){
            // Main mounting structure - UNCHANGED
            color("peru"){
                // Upper mounting block
                translate([-17+10-1.5,13.5,-14])
                    cube([10+3,18,10]);
                
                // Upper horizontal support
                translate([-17+5,13.5-3,-14])
                    cube([23,10-0.5+3,10]);
                
                // Lower horizontal support  
                translate([-17+5,13-36,-14])
                    cube([23,10+3,10]);
                
                // Lower mounting block
                translate([-17+10-1.5,13-36-8,-14])
                    cube([10+3,18,10]);
                
                // Vertical connecting ribs
                translate([-17+5,13-36,-14])
                    cube([5,10+36,6]);
                translate([-17+3+20,13-36,-14])
                    cube([5,10+36,6]);
            }
        }
        
        // ====== MAIN PIPETTE BODY CLEARANCE ======
        // Body spans [-8, -27, -8.5] to [8, 7, 0]
        // Add 0.5mm clearance on all sides
        
        corner_radius = 1.2;
        
        translate([-8-0.5, -27-0.5, -8.5-0.5])
            rounded_cube([16+1, 34+1, 8.5+1], corner_radius);
        
        // ====== 4-CHANNEL NOZZLE CLEARANCES ======
        // Nozzles at Y = -27.5, -20.5, -13.5, -6.5
        // All at X = 0, starting Z = -8.5
        
        nozzle_y_positions = [-27.5, -20.5, -13.5, -6.5];
        
        for(y_pos = nozzle_y_positions){
            // Cone clearance (d1=8→9mm for clearance, d2=5→6mm, h=3.3→4mm)
            translate([0, y_pos, -8.5])
                cylinder(d1=9, d2=6, h=4, $fn=50);
            
            // Extended tip clearance below cone
            translate([0, y_pos, -8.5-12])
                cylinder(d=6, h=12, $fn=50);
        }
        
        // ====== MOUNTING HOLES (unchanged) ======
        
        // Upper mounting hole
        translate([-2,23,-22])
            cylinder(d=5.2,h=42,$fn=100);
        translate([-2,23,-11])
            cylinder(d=10.5,h=20,$fn=100);
        
        // Lower mounting hole  
        translate([0,-46,0]){
            translate([-2,23,-22])
                cylinder(d=5.2,h=42,$fn=100);
            translate([-2,23,-11])
                cylinder(d=10.5,h=20,$fn=100);
        }
    }
}

// Helper module for rounded cube clearances
module rounded_cube(size, radius) {
    $fn=50;
    hull() {
        for(x = [radius, size[0]-radius])
            for(y = [radius, size[1]-radius])
                for(z = [radius, size[2]-radius])
                    translate([x, y, z])
                        sphere(r=radius);
    }
}

// Render
//bayonet_pipette_tipcase_holder();
