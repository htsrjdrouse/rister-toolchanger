// IDEX P-347 Style Flangeless Fitting for 3mm OD PTFE Tubing
// M6 Flat-Bottom Port, Standard Knurl Nut

$fn = 100;

// === PARAMETERS ===
tube_od = 3.0;           // PTFE tubing outer diameter
tube_id = 1.5;           // PTFE tubing inner diameter

// Nut dimensions (M6 flangeless fitting standard)
nut_thread_major = 6.0;   // M6 external thread on nut
nut_thread_pitch = 1.0;   // M6 standard pitch
nut_outer_dia = 10.0;     // Hex/knurl diameter for finger-tight
nut_height = 8.0;         // Total nut height (~8mm per spec)
nut_grip_height = 6.0;    // Height of knurled section
knurl_count = 24;         // Standard knurl pattern
knurl_depth = 0.5;        // Depth of knurl grooves

// Ferrule dimensions  
ferrule_height = 2.5;       // Total ferrule height
ferrule_outer_dia = 5.8;    // Outer diameter 
ferrule_front_dia = 4.2;    // Front diameter (sealing end)
ferrule_bore_dia = 3.2;     // Inner bore (slides over 3mm tube)

// Internal clearances
ferrule_clearance = 0.3;    // Space for ferrule to move
tube_clearance = 0.4;       // Space for tube passage

// Thread parameters for visualization
thread_depth = 0.4;         // Visual thread depth
thread_steps = 20;          // Steps per revolution

// === NUT MODULE ===
module flangeless_nut() {
    difference() {
        union() {
            // Knurled grip section
            difference() {
                // Main cylindrical body
                cylinder(h=nut_grip_height, d=nut_outer_dia);
                
                // Standard knurling pattern
                for(i = [0:knurl_count-1]) {
                    rotate([0, 0, i * 360/knurl_count])
                    translate([nut_outer_dia/2, 0, nut_grip_height/2])
                    rotate([0, 0, 45])
                    cube([knurl_depth*2, 0.8, nut_grip_height + 0.2], center=true);
                }
            }
            
            // Threaded section with simplified M6 external thread
            translate([0, 0, nut_grip_height]) {
                // Base cylinder for thread
                cylinder(h=nut_height - nut_grip_height, d=nut_thread_major - thread_depth);
                
                // Simplified thread visualization (helical ridge)
                thread_height = nut_height - nut_grip_height;
                num_turns = thread_height / nut_thread_pitch;
                
                for(turn = [0:thread_steps * num_turns]) {
                    angle = turn * 360 / thread_steps;
                    z = turn * nut_thread_pitch / thread_steps;
                    
                    if(z < thread_height) {
                        rotate([0, 0, angle])
                        translate([nut_thread_major/2 - thread_depth/2, 0, z])
                        rotate([0, 0, 45])
                        cube([thread_depth, thread_depth*2, nut_thread_pitch/thread_steps + 0.1], center=true);
                    }
                }
            }
        }
        
        // Central through-hole for tubing
        translate([0, 0, -0.1])
        cylinder(h=nut_height + 0.2, d=tube_od + tube_clearance);
        
        // Bottom counterbore for ferrule body (allows ferrule to protrude)
        translate([0, 0, -0.1])
        cylinder(h=ferrule_height - 0.5, d=ferrule_outer_dia + ferrule_clearance);
        
        // Ferrule shoulder seat (captures ferrule)
        translate([0, 0, ferrule_height - 0.8])
        cylinder(h=1.0, d1=ferrule_outer_dia + ferrule_clearance, 
                         d2=ferrule_outer_dia - 0.2);
    }
}

// === FERRULE MODULE ===
module ferrule() {
    difference() {
        union() {
            // Conical outer body (seals against flat-bottom port)
            cylinder(h=ferrule_height, d1=ferrule_front_dia, d2=ferrule_outer_dia);
        }
        
        // Inner bore - straight section for tube
        translate([0, 0, -0.1])
        cylinder(h=ferrule_height * 0.4, d=ferrule_bore_dia);
        
        // Inner taper - grips tube when compressed
        translate([0, 0, ferrule_height * 0.35])
        cylinder(h=ferrule_height * 0.7, 
                 d1=ferrule_bore_dia, 
                 d2=tube_od + 0.05); // Very tight grip when compressed
    }
}

// === FLAT-BOTTOM PORT (receiving port) ===
module flat_bottom_port() {
    difference() {
        // Port body
        cylinder(h=5, d=14);
        
        // M6 threaded hole (female) - simplified
        translate([0, 0, -0.1]) {
            cylinder(h=3, d=nut_thread_major - thread_depth);
            
            // Internal thread visualization
            thread_depth_internal = 0.35;
            for(turn = [0:thread_steps * 3]) {
                angle = turn * 360 / thread_steps;
                z = turn * nut_thread_pitch / thread_steps;
                
                if(z < 3) {
                    rotate([0, 0, -angle])  // Opposite direction for internal thread
                    translate([nut_thread_major/2, 0, z])
                    cube([thread_depth_internal*2, thread_depth_internal, nut_thread_pitch/thread_steps + 0.1], center=true);
                }
            }
        }
        
        // Flat bottom with tube passage
        translate([0, 0, 2.5])
        cylinder(h=2.6, d=tube_od + 0.2);
        
        // Small chamfer where ferrule contacts
        translate([0, 0, 2.3])
        cylinder(h=0.3, d1=ferrule_front_dia + 0.5, d2=tube_od + 0.2);
    }
}

// === ASSEMBLY VIEW ===
// Nut - NOW VISIBLE!
color("lightblue", 0.8)
flangeless_nut();

// Ferrule (positioned to protrude from nut bottom)
color("orange", 0.8)
translate([0, 0, -(ferrule_height - 0.8)])
ferrule();

// PTFE tubing (for reference)
color("white", 0.5)
translate([0, 0, -10])
difference() {
    cylinder(h=25, d=tube_od);
    translate([0, 0, -0.1])
    cylinder(h=25.2, d=tube_id);
}

// Flat-bottom receiving port (for reference)
color("gray", 0.4)
translate([0, 0, -ferrule_height - 3])
flat_bottom_port();

// === FOR PRINTING - UNCOMMENT ONE AT A TIME ===
// Nut - print upright
//translate([15, 0, 0]) flangeless_nut();

// Ferrule - print upside down for better surface finish
//translate([30, 0, ferrule_height]) rotate([180, 0, 0]) ferrule();

// Port (if you want to print a test port)
//translate([0, 15, 0]) flat_bottom_port();
