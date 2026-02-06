// PRACTICAL M6 COUPLING NUT
// Fast rendering, excellent print quality, proven geometry
// For PTFE flange compression seal system

$fn = 100;

// === USER ADJUSTABLE PARAMETERS ===
nut_length = 24;                    // Total nut length (mm)
thread_clearance = 0.30;            // Clearance for threading (tune this!)
hex_size = 10;                      // Hex wrench size (across flats)
hex_height = 8;                     // Height of hex grip section

// === M6 THREAD SPECIFICATIONS ===
thread_od = 6.0;                    // M6 outer diameter
thread_pitch = 1.0;                 // M6 standard pitch (mm)
thread_depth = 0.614 * thread_pitch; // ISO metric: depth = 0.614 × pitch

// Calculated dimensions
internal_major_d = thread_od + thread_clearance * 2;
internal_minor_d = thread_od - thread_depth * 2;

// === MAIN NUT ===
difference() {
    // Outer body
    union() {
        // Main cylindrical body
        cylinder(h = nut_length, d = hex_size * 0.92, $fn = 100);
        
        // Hex grip in center
        translate([0, 0, (nut_length - hex_height) / 2])
        hex_grip();
    }
    
    // Internal thread bore
    translate([0, 0, -0.5])
    internal_metric_thread(
        major_d = internal_major_d,
        minor_d = internal_minor_d,
        pitch = thread_pitch,
        length = nut_length + 1
    );
}

// === HEX GRIP MODULE ===
module hex_grip() {
    difference() {
        // Basic hex
        cylinder(h = hex_height, d = hex_size / cos(30), $fn = 6);
        
        // Add knurling for grip
        knurl_pattern();
    }
}

module knurl_pattern() {
    knurl_count = 20;
    for (i = [0 : knurl_count - 1]) {
        rotate([0, 0, i * 360 / knurl_count])
        translate([hex_size / cos(30) / 2 - 0.15, 0, hex_height / 2])
        rotate([0, 0, 45])
        cube([0.35, 0.5, hex_height + 0.2], center = true);
    }
}

// === INTERNAL THREAD MODULE ===
// Uses linear_extrude with twist - fast and reliable
module internal_metric_thread(major_d, minor_d, pitch, length) {
    thread_depth = (major_d - minor_d) / 2;
    num_turns = length / pitch;
    slices_per_turn = 50;  // Adjust for quality vs speed
    
    difference() {
        // Main cylinder bore
        cylinder(h = length, d = major_d, $fn = 100);
        
        // Helical thread groove using linear_extrude
        translate([0, 0, -pitch / 2])
        linear_extrude(
            height = length + pitch,
            twist = -360 * (length + pitch) / pitch,
            slices = num_turns * slices_per_turn,
            convexity = 10,
            $fn = 100
        )
        translate([major_d / 2 - thread_depth * 0.65, 0, 0])
        circle(d = thread_depth * 1.4, $fn = 20);
    }
}

// === VISUALIZATION AIDS (comment/uncomment as needed) ===

// 1. Show cross-section to see internal threads
// difference() {
//     union() {
//         cylinder(h = nut_length, d = hex_size * 0.92);
//         translate([0, 0, (nut_length - hex_height) / 2])
//         hex_grip();
//     }
//     translate([0, 0, -0.5])
//     internal_metric_thread(internal_major_d, internal_minor_d, thread_pitch, nut_length + 1);
//     
//     // Cut in half
//     translate([-15, 0, -1])
//     cube([30, 30, 30]);
// }

// 2. Show bolt engagement simulation
// color("red", 0.3)
// translate([0, 0, -8])
// cylinder(h = 12, d = thread_od - 0.1, $fn = 100);
// 
// color("blue", 0.3)
// translate([0, 0, nut_length - 4])
// cylinder(h = 12, d = thread_od - 0.1, $fn = 100);

// 3. Show PTFE tube passage
// color("white", 0.5)
// translate([0, 0, -15])
// difference() {
//     cylinder(h = nut_length + 30, d = 3.0, $fn = 50);
//     cylinder(h = nut_length + 30.2, d = 1.5, $fn = 50);
// }

/* PRINT SETTINGS RECOMMENDATIONS:
 * 
 * Layer Height: 0.15-0.2mm (finer is better for threads)
 * Infill: 100% (critical for thread strength)
 * Walls: 4+ perimeters
 * Speed: 30-50mm/s (slower for better thread detail)
 * Material: PETG or ABS (better thread strength than PLA)
 * 
 * THREAD CLEARANCE TUNING:
 * - First print: Use default 0.30mm clearance
 * - If too tight to thread: Increase by 0.05mm
 * - If threads are loose: Decrease by 0.05mm
 * - Goal: Hand-tight with slight resistance
 * 
 * USAGE WITH YOUR FLANGE SYSTEM:
 * - Each bolt needs ~10-12mm of thread engagement
 * - Tighten both bolts evenly to compress ferrules
 * - The ferrules will seal against the PTFE tubing
 * - May need to use thread-locking compound if vibration is present
 */
