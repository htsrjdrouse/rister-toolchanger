// M6 Hex Head Screw (metric coarse thread)
// M6 × 1 pitch, standard dimensions

/* [Screw Dimensions] */
head_across_flats = 10.0;      // Standard hex width across flats for M6
head_height       = 4.0;       // Standard hex head height ≈ 4 mm
thread_diameter   = 6.0;       // Nominal major diameter
thread_pitch      = 1.0;       // Coarse pitch for M6
thread_length     = 20.0;      // Length of threaded portion
shank_length      = 5.0;       // Unthreaded shank length (set 0 for full thread)
total_shaft_length = shank_length + thread_length;

/* [Render Settings] */
$fn = 80;                      // Smoothness
clearance = 0.15;              // Slight tolerance for printed threads

/* [Advanced - optional] */
head_chamfer = 0.8;            // Chamfer on head edges
tip_chamfer  = 0.6;            // Chamfer on screw tip

// ────────────────────────────────────────────────
// Simple trapezoidal thread profile
module thread_profile() {
    polygon(points=[
        [0,               0],
        [thread_pitch/4,  0],
        [thread_pitch/2,  thread_pitch * 0.55],
        [thread_pitch*3/4,0],
        [thread_pitch,    0]
    ]);
}

// Helical external thread
module external_thread(length) {
    linear_extrude(
        height = length,
        twist = -360 * length / thread_pitch,
        slices = 120,
        convexity = 10
    )
    for (a = [0 : 30 : 359]) rotate(a)
        translate([thread_diameter/2 - clearance, 0, 0])
            thread_profile();
}

// ────────────────────────────────────────────────
// Hex head
module hex_head() {
    difference() {
        // Main hex body
        cylinder(
            h = head_height,
            d = head_across_flats * 2 / sqrt(3),  // circumscribed diameter
            $fn = 6
        );
        
        // Optional: slight chamfer on top
        translate([0, 0, head_height - head_chamfer])
            cylinder(
                h = head_chamfer + 0.1,
                d1 = head_across_flats * 2 / sqrt(3) - head_chamfer * 1.5,
                d2 = head_across_flats * 2 / sqrt(3) - head_chamfer * 3,
                $fn = 6
            );
    }
}

// ────────────────────────────────────────────────
// The complete screw
union() {
    // Hex head
    hex_head();
    
    // Shaft (shank + threaded part)
    translate([0, 0, -total_shaft_length]) {
        // Unthreaded shank (if any)
        if (shank_length > 0) {
            cylinder(
                h = shank_length,
                d = thread_diameter - 0.3,  // slightly undersized
                $fn = 60
            );
        }
        
        // Threaded portion
        translate([0, 0, shank_length]) {
            external_thread(thread_length);
            
            // Core cylinder under threads
            cylinder(
                h = thread_length,
                d = thread_diameter - thread_pitch * 1.2,  // approx minor diameter
                $fn = 60
            );
        }
        
        // Tip chamfer
        translate([0, 0, shank_length + thread_length - tip_chamfer])
            cylinder(
                h = tip_chamfer + 0.1,
                d1 = thread_diameter - 0.2,
                d2 = thread_diameter - 3,
                $fn = 60
            );
    }
}
