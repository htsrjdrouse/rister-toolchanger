// 3D-Printable Bubble Trap with Compression Ring
// Corrected thread directions:
// - Base: EXTERNAL (male) threads on rim
// - Compression Ring: INTERNAL (female) threads inside
// Membrane sticker adheres to base rim top face
// Gasket placed on top of membrane, compressed by ring

// Parameters - Customize
membrane_dia       = 58;          // Sticker diameter (mm)
base_outer_dia     = membrane_dia + 12;  // Outer diameter of threaded rim
base_wall          = 3;           // Wall thickness
base_chamber_h     = 20;          // Height of fluid chamber below rim
rim_height         = 10;          // Height of threaded section
thread_pitch       = 3;           // Coarse pitch for easy printing
thread_turns       = 3;           // Number of full turns
thread_clearance   = 0.3;         // Tolerance (increase if too tight)
inlet_outlet_dia   = 3;           // Barb/hole diameter for tubing

$fn = 80;

// ────────────────────────────────────────────────
// Simple trapezoidal thread profile (male/external)
module thread_profile_ext() {
    polygon(points=[
        [0,               0],
        [thread_pitch*0.3,  thread_pitch*0.4],
        [thread_pitch*0.7,  thread_pitch*0.4],
        [thread_pitch,    0],
        [thread_pitch,    -thread_pitch*0.25],
        [0,               -thread_pitch*0.25]
    ]);
}

// Simple inverted profile for internal (female) thread
module thread_profile_int() {
    polygon(points=[
        [0,               0],
        [thread_pitch*0.3,  -thread_pitch*0.4],
        [thread_pitch*0.7,  -thread_pitch*0.4],
        [thread_pitch,    0],
        [thread_pitch,    thread_pitch*0.25],
        [0,               thread_pitch*0.25]
    ]);
}

// ────────────────────────────────────────────────
// BASE - with EXTERNAL threads
// ────────────────────────────────────────────────
module base() {
    difference() {
        union() {
            // Fluid chamber cylinder
            cylinder(h = base_chamber_h + rim_height, d = base_outer_dia, center = false);
        }
        
        // Hollow chamber
        translate([0, 0, base_wall])
            cylinder(h = base_chamber_h + rim_height + 1, d = base_outer_dia - 2*base_wall);
        
        // Inlet port (side, near bottom)
        translate([base_outer_dia/2 + 1, 0, base_wall + 5])
            rotate([0, 90, 0])
            cylinder(h = base_outer_dia + 2, d = inlet_outlet_dia, $fn=32);
        
        // Outlet port (opposite side)
        translate([-base_outer_dia/2 - 1, 0, base_wall + 5])
            rotate([0, 90, 0])
            cylinder(h = base_outer_dia + 2, d = inlet_outlet_dia, $fn=32);
    }
    
    // Add EXTERNAL threads on upper rim
    translate([0, 0, base_chamber_h])
        linear_extrude(height = rim_height, twist = -360 * thread_turns, slices = 100)
            translate([base_outer_dia/2 - thread_clearance/2, 0, 0])
            thread_profile_ext();
    
    // Flat top face for membrane sticker
    difference() {
        translate([0, 0, base_chamber_h + rim_height - 0.8])
            cylinder(h = 1.6, d = base_outer_dia);
        translate([0, 0, base_chamber_h + rim_height - 1])
            cylinder(h = 3, d = membrane_dia + 1);
    }
}

// ────────────────────────────────────────────────
// COMPRESSION RING - with INTERNAL threads
// ────────────────────────────────────────────────
module compression_ring() {
    difference() {
        // Outer body
        cylinder(h = rim_height + 4, d = base_outer_dia + 12, center = false);
        
        // Inner cavity to fit over base rim
        translate([0, 0, -0.1])
            cylinder(h = rim_height + 6, d = base_outer_dia + thread_clearance, center = false);
        
        // INTERNAL threads (female)
        translate([0, 0, 2])
            linear_extrude(height = rim_height + 2, twist = 360 * thread_turns, slices = 100)
                translate([base_outer_dia/2 + thread_clearance/2, 0, 0])
                thread_profile_int();
        
        // Large central vent opening
        translate([0, 0, -1])
            cylinder(h = rim_height + 8, d = membrane_dia - 6);
    }
    
    // Grip ridges (optional)
    for (a = [0:45:359]) rotate([0,0,a])
        translate([base_outer_dia/2 + 6, 0, 0])
            cylinder(h = rim_height + 4, d = 5);
}

// ────────────────────────────────────────────────
// Preview
// ────────────────────────────────────────────────
base();

translate([0, 0, base_chamber_h + rim_height + 15])
    compression_ring();

// For separate STL export:
// base();
// compression_ring();
