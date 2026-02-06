// HIGH QUALITY M6 COUPLING NUT
// Optimized for FDM printing with smooth, accurate threads
// For PTFE tube compression seal system

$fn = 100;

/* [Thread Parameters - ISO M6] */
M6_major_diameter = 6.0;
M6_pitch = 1.0;
M6_minor_diameter = 4.917;  // ISO metric calculation
thread_clearance = 0.3;      // Adjust for your printer (0.2-0.4mm typical)

/* [Nut Dimensions] */
nut_length = 24;             // Total length - fits two ~12mm threaded sections
hex_width = 10;              // Across flats
hex_height = 8;              // Height of hex section
cylinder_diameter = 9;        // Smooth cylindrical sections

/* [Print Quality] */
thread_resolution = 120;     // Circumferential resolution
turns_in_nut = nut_length / M6_pitch;
segments_per_turn = 40;      // Higher = smoother but slower render
total_segments = turns_in_nut * segments_per_turn;

// === MAIN MODULE ===
module m6_coupling_nut() {
    difference() {
        // Outer body
        nut_body();
        
        // Internal threaded hole
        translate([0, 0, -0.5])
        metric_internal_thread(
            diameter = M6_major_diameter + thread_clearance,
            pitch = M6_pitch,
            length = nut_length + 1
        );
    }
}

// === NUT BODY ===
module nut_body() {
    union() {
        // Central hex grip
        translate([0, 0, (nut_length - hex_height) / 2])
        hex_cylinder(hex_width, hex_height);
        
        // Smooth cylindrical sections for easier bolt threading
        cylinder(h = nut_length, d = cylinder_diameter, $fn = thread_resolution);
        
        // Optional: knurling on hex section for better grip
        translate([0, 0, (nut_length - hex_height) / 2])
        knurled_hex(hex_width, hex_height);
    }
}

// === HEX CYLINDER ===
module hex_cylinder(width, height) {
    linear_extrude(height = height)
    circle(d = width / cos(30), $fn = 6);
}

// === KNURLED HEX (optional texture) ===
module knurled_hex(width, height) {
    // Diamond knurl pattern
    knurl_depth = 0.3;
    knurl_count = 24;
    
    for (i = [0 : knurl_count - 1]) {
        rotate([0, 0, i * 360 / knurl_count])
        translate([width / cos(30) / 2 - knurl_depth / 2, 0, height / 2])
        cube([knurl_depth, 0.6, height], center = true);
    }
}

// === METRIC INTERNAL THREAD ===
// High-quality thread using helical extrusion
module metric_internal_thread(diameter, pitch, length) {
    // Thread geometry
    major_r = diameter / 2;
    minor_r = (diameter - pitch * 1.226) / 2;  // ISO metric thread depth
    
    difference() {
        // Bore cylinder
        cylinder(h = length, r = major_r, $fn = thread_resolution);
        
        // Thread helix
        thread_helix_internal(major_r, minor_r, pitch, length);
    }
}

// === INTERNAL THREAD HELIX ===
module thread_helix_internal(major_r, minor_r, pitch, length) {
    thread_depth = major_r - minor_r;
    
    // Create helical thread groove
    for (i = [0 : total_segments - 1]) {
        hull() {
            // Current segment
            rotate([0, 0, i * 360 / segments_per_turn])
            translate([major_r - thread_depth * 0.6, 0, i * pitch / segments_per_turn])
            sphere(r = thread_depth * 0.7, $fn = 20);
            
            // Next segment
            rotate([0, 0, (i + 1) * 360 / segments_per_turn])
            translate([major_r - thread_depth * 0.6, 0, (i + 1) * pitch / segments_per_turn])
            sphere(r = thread_depth * 0.7, $fn = 20);
        }
    }
}

// === ALTERNATIVE: LINEAR EXTRUDE METHOD ===
// Faster rendering, still good quality
module metric_internal_thread_fast(diameter, pitch, length) {
    major_r = diameter / 2;
    thread_depth = pitch * 0.613;
    
    difference() {
        cylinder(h = length, r = major_r, $fn = thread_resolution);
        
        // Helical thread using linear_extrude with twist
        translate([0, 0, -pitch])
        linear_extrude(
            height = length + pitch * 2,
            twist = -360 * (length + pitch * 2) / pitch,
            slices = total_segments,
            convexity = 10
        )
        translate([major_r - thread_depth / 2, 0])
        circle(d = thread_depth * 1.3, $fn = 16);
    }
}

// === RENDER ===
m6_coupling_nut();

// === VISUALIZATION HELPERS ===
// Uncomment to see cross-section or test fit

// Cross-section view
// difference() {
//     m6_coupling_nut();
//     translate([0, -15, -1])
//     cube([30, 30, 30]);
// }

// Test bolt visualization (shows how bolts thread in from each end)
// color("red", 0.3)
// translate([0, 0, -5])
// cylinder(h = 14, d = M6_major_diameter - thread_clearance + 0.1, $fn = 100);
// 
// color("blue", 0.3)
// translate([0, 0, nut_length - 9])
// cylinder(h = 14, d = M6_major_diameter - thread_clearance + 0.1, $fn = 100);

// Measurement references
// %translate([0, 0, nut_length/2 - hex_height/2])
// hex_cylinder(hex_width, hex_height);
