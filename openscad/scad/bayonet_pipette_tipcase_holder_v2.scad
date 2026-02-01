// Optimized Bayonet Pipette Tipcase Holder v2
// STANDALONE HOLDER - receives the peek_nozzle_4channel during loading
//
// Designed to compensate for servo linear actuator misalignment
// where right side loads ~2mm higher than left
//
// Key improvements:
// 1. Asymmetric pocket - right side 2mm deeper to compensate for tilt
// 2. Tapered entry funnel for self-centering
// 3. Increased height for more vertical guidance
// 4. Guide chamfers on entry

// ========================================
// CONFIGURATION PARAMETERS
// ========================================

// Tilt compensation - right side is 2mm higher, so make LEFT pocket deeper
// (X=0 is LEFT, X=400 is RIGHT in machine coords)
tilt_compensation_mm = 2;    // mm deeper on LEFT side (adjust 1-3mm)

// Height adjustment - increase for more vertical guidance
holder_height_increase = 5;  // mm additional height

// Entry funnel for self-centering
funnel_height = 6;           // mm height of entry chamfer
funnel_angle = 15;           // degrees of chamfer angle

// Pocket clearance adjustment
pocket_clearance = 0.2;      // mm extra clearance in pocket

// Debug mode - set to true to visualize the tilted floor
debug_show_tilt = false;      // Shows colored wedge to verify tilt

// ========================================
// HELPER MODULES
// ========================================

module rounded_cube(size, radius) {
    $fn = 30;
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

// Asymmetric chamfered entry - deeper on one side
module asymmetric_entry_chamfer(width, depth, height, tilt_comp) {
    // Creates a pocket that's deeper on the right (+X) side
    hull() {
        // Bottom left corner (normal depth)
        translate([0, 0, 0])
            cube([0.1, depth, 0.1]);
        // Bottom right corner (deeper by tilt_comp)
        translate([width, 0, -tilt_comp])
            cube([0.1, depth, 0.1]);
        // Top left corner (flared out)
        translate([-height*tan(funnel_angle), -height*tan(funnel_angle), height])
            cube([0.1, depth + 2*height*tan(funnel_angle), 0.1]);
        // Top right corner (flared out)
        translate([width + height*tan(funnel_angle), -height*tan(funnel_angle), height])
            cube([0.1, depth + 2*height*tan(funnel_angle), 0.1]);
    }
}

// ========================================
// ORIGINAL HOLDER (for reference)
// ========================================

module bayonet_pipette_tipcase_holder_original() {
    difference() {
        union() {
            color("peru") {
                translate([-17+10-1.5, 13.5, -14]) cube([10+3, 18, 10]);
                translate([-17+5, 13.5-3, -14]) cube([23, 10-0.5+3, 10]);
                translate([-17+5, 13-36, -14]) cube([23, 10+3, 10]);
                translate([-17+10-1.5, 13-36-8, -14]) cube([10+3, 18, 10]);
                translate([-17+5, 13-36, -14]) cube([5, 10+36, 6]);
                translate([-17+3+20, 13-36, -14]) cube([5, 10+36, 6]);
            }
        }
        corner_radius = 1;
        translate([-2, 0, 5])
            translate([-4.25+10, -5-2-7.5+1, -2-11]) rounded_cube([8+4, 10, 7.5+1], corner_radius);
        translate([-4.25-10, -5-2+10, -2-6]) rounded_cube([8+4, 10, 7.5+1], corner_radius);

        for(i=[-1:1]) {
            for(j=[-1:1]) {
                translate([-6.25+j/2, -5-2-7.5+2.7+i/2, -2-13]) rounded_cube([12, 10+4+10, 7.5+10], corner_radius);
                translate([-6.25+i/2, -5-2-7.5+2.7+j/2, -2-13]) rounded_cube([12, 10+4+10, 7.5+10], corner_radius);
                translate([-6.25+j/2, -5-2-7.5+i/2, -2-10]) rounded_cube([8+4, 10+4+15, 7.5+10], corner_radius);
                translate([-6.25+i/2, -5-2-7.5+j/2, -2-10]) rounded_cube([8+4, 10+4+15, 7.5+10], corner_radius);
            }
        }

        // Mounting holes
        translate([-2, 23, -22]) cylinder(d=5.2, h=42, $fn=100);
        translate([-2, 23, -11]) cylinder(d=10.5, h=20, $fn=100);
        translate([0, -46, 0]) {
            translate([-2, 23, -22]) cylinder(d=5.2, h=42, $fn=100);
            translate([-2, 23, -11]) cylinder(d=10.5, h=20, $fn=100);
        }
    }
}

// ========================================
// OPTIMIZED HOLDER V2
// With tilt compensation and self-centering
// ========================================

module bayonet_pipette_tipcase_holder_v2() {
    base_height = 10 + holder_height_increase;
    rail_height = 6 + holder_height_increase;
    corner_radius = 1;

    // Pocket dimensions (same as original)
    pocket_h = 7.5 + 10 + holder_height_increase;

    difference() {
        union() {
            color("peru") {
                // Main body - increased height
                translate([-17+10-1.5, 13.5, -14])
                    cube([10+3, 18, base_height]);
                translate([-17+5, 13.5-3, -14])
                    cube([23, 10-0.5+3, base_height]);
                translate([-17+5, 13-36, -14])
                    cube([23, 10+3, base_height]);
                translate([-17+10-1.5, 13-36-8, -14])
                    cube([10+3, 18, base_height]);

                // Side rails - taller for better guidance
                translate([-17+5, 13-36, -14])
                    cube([5, 10+36, rail_height]);
                translate([-17+3+20, 13-36, -14])
                    cube([5, 10+36, rail_height]);
            }
        }

        // ===== STANDARD POCKET (same as v2_simple) =====
        // First cut the normal pocket
        translate([-2, 0, 5])
            translate([-4.25+10, -5-2-7.5+1, -2-11])
                rounded_cube([8+4, 10, 7.5+1+holder_height_increase], corner_radius);

        translate([-4.25-10, -5-2+10, -2-6])
            rounded_cube([8+4+pocket_clearance, 10, 7.5+1+holder_height_increase], corner_radius);

        for(i=[-1:1]) {
            for(j=[-1:1]) {
                translate([-6.25+j/2, -5-2-7.5+2.7+i/2, -2-13])
                    rounded_cube([12, 10+4+10, pocket_h], corner_radius);
                translate([-6.25+i/2, -5-2-7.5+2.7+j/2, -2-13])
                    rounded_cube([12, 10+4+10, pocket_h], corner_radius);
                translate([-6.25+j/2, -5-2-7.5+i/2, -2-10])
                    rounded_cube([8+4, 10+4+15, pocket_h], corner_radius);
                translate([-6.25+i/2, -5-2-7.5+j/2, -2-10])
                    rounded_cube([8+4, 10+4+15, pocket_h], corner_radius);
            }
        }

        // ===== TILTED FLOOR - only affects the bottom of the pocket =====
        // RIGHT side of tool is 2mm HIGHER, so RIGHT side of holder is 2mm DEEPER
        // This wedge tilts along Y axis (LEFT-RIGHT in machine coords)
        // LEFT side (low Y) = NORMAL depth
        // RIGHT side (high Y) = 2mm DEEPER
        translate([-12, -15, -15 - tilt_compensation_mm]) {
            polyhedron(
                points = [
                    // Bottom face (tilted along Y) - high Y (RIGHT) is deeper
                    [0, 0, tilt_compensation_mm],       // 0: left-front (NORMAL)
                    [30, 0, tilt_compensation_mm],      // 1: left-back (NORMAL)
                    [30, 24, 0],                        // 2: right-back (DEEP)
                    [0, 24, 0],                         // 3: right-front (DEEP)
                    // Top face (flat)
                    [0, 0, tilt_compensation_mm + 1],   // 4
                    [30, 0, tilt_compensation_mm + 1],  // 5
                    [30, 24, tilt_compensation_mm + 1], // 6
                    [0, 24, tilt_compensation_mm + 1]   // 7
                ],
                faces = [
                    [0, 1, 2, 3],  // bottom (tilted floor)
                    [4, 7, 6, 5],  // top
                    [0, 4, 5, 1],  // left (normal side)
                    [2, 6, 7, 3],  // right (deep side)
                    [0, 3, 7, 4],  // front
                    [1, 5, 6, 2]   // back
                ]
            );
        }

        // ===== ENTRY FUNNEL - self-centering chamfer at top =====
        translate([-6.25, -5-2-7.5+2.7, -4 + holder_height_increase]) {
            hull() {
                cube([12, 24, 0.1]);
                translate([-funnel_height*tan(funnel_angle), -funnel_height*tan(funnel_angle), funnel_height])
                    cube([12 + 2*funnel_height*tan(funnel_angle),
                          24 + 2*funnel_height*tan(funnel_angle), 0.1]);
            }
        }

        // ===== MOUNTING HOLES =====
        translate([-2, 23, -22-tilt_compensation_mm])
            cylinder(d=5.2, h=42 + holder_height_increase + tilt_compensation_mm, $fn=100);
        translate([-2, 23, -11])
            cylinder(d=10.5, h=20 + holder_height_increase, $fn=100);
        translate([0, -46, 0]) {
            translate([-2, 23, -22-tilt_compensation_mm])
                cylinder(d=5.2, h=42 + holder_height_increase + tilt_compensation_mm, $fn=100);
            translate([-2, 23, -11])
                cylinder(d=10.5, h=20 + holder_height_increase, $fn=100);
        }
    }
}

// ========================================
// SIMPLE V2 - Just height + funnel (no tilt)
// Try this first if asymmetric pocket is too complex
// ========================================

module bayonet_pipette_tipcase_holder_v2_simple() {
    base_height = 10 + holder_height_increase;
    rail_height = 6 + holder_height_increase;
    corner_radius = 1;

    difference() {
        union() {
            color("peru") {
                // Main body - increased height
                translate([-17+10-1.5, 13.5, -14])
                    cube([10+3, 18, base_height]);
                translate([-17+5, 13.5-3, -14])
                    cube([23, 10-0.5+3, base_height]);
                translate([-17+5, 13-36, -14])
                    cube([23, 10+3, base_height]);
                translate([-17+10-1.5, 13-36-8, -14])
                    cube([10+3, 18, base_height]);

                // Side rails - taller
                translate([-17+5, 13-36, -14])
                    cube([5, 10+36, rail_height]);
                translate([-17+3+20, 13-36, -14])
                    cube([5, 10+36, rail_height]);
            }
        }

        // Standard pockets (same as original, just taller)
        translate([-2, 0, 5])
            translate([-4.25+10, -5-2-7.5+1, -2-11])
                rounded_cube([8+4, 10, 7.5+1+holder_height_increase], corner_radius);
        translate([-4.25-10, -5-2+10, -2-6])
            rounded_cube([8+4, 10, 7.5+1+holder_height_increase], corner_radius);

        for(i=[-1:1]) {
            for(j=[-1:1]) {
                translate([-6.25+j/2, -5-2-7.5+2.7+i/2, -2-13])
                    rounded_cube([12, 10+4+10, 7.5+10+holder_height_increase], corner_radius);
                translate([-6.25+i/2, -5-2-7.5+2.7+j/2, -2-13])
                    rounded_cube([12, 10+4+10, 7.5+10+holder_height_increase], corner_radius);
                translate([-6.25+j/2, -5-2-7.5+i/2, -2-10])
                    rounded_cube([8+4, 10+4+15, 7.5+10+holder_height_increase], corner_radius);
                translate([-6.25+i/2, -5-2-7.5+j/2, -2-10])
                    rounded_cube([8+4, 10+4+15, 7.5+10+holder_height_increase], corner_radius);
            }
        }

        // Entry funnel
        translate([-6.25, -5-2-7.5+2.7, -4 + holder_height_increase]) {
            hull() {
                cube([12, 24, 0.1]);
                translate([-funnel_height*tan(funnel_angle), -funnel_height*tan(funnel_angle), funnel_height])
                    cube([12 + 2*funnel_height*tan(funnel_angle),
                          24 + 2*funnel_height*tan(funnel_angle), 0.1]);
            }
        }

        // Mounting holes
        translate([-2, 23, -22]) cylinder(d=5.2, h=42+holder_height_increase, $fn=100);
        translate([-2, 23, -11]) cylinder(d=10.5, h=20+holder_height_increase, $fn=100);
        translate([0, -46, 0]) {
            translate([-2, 23, -22]) cylinder(d=5.2, h=42+holder_height_increase, $fn=100);
            translate([-2, 23, -11]) cylinder(d=10.5, h=20+holder_height_increase, $fn=100);
        }
    }
}

// ========================================
// RENDER
// ========================================

// Choose which version to render:

// Full tilt-compensated version (right side 2mm deeper)
bayonet_pipette_tipcase_holder_v2_simple();

// Simpler version (just taller + funnel entry)
// bayonet_pipette_tipcase_holder_v2_simple();

// Original for comparison
// translate([50, 0, 0]) bayonet_pipette_tipcase_holder_original();

// ===== DEBUG VISUALIZATION =====
// Shows the tilt difference with colored markers
// RIGHT side is 2mm DEEPER to accept the tool that's 2mm higher on the right
if (debug_show_tilt) {
    // Blue cube at LEFT floor level (low Y, NORMAL at Z=-15)
    color("blue") translate([0, -15, -15]) cube([3, 3, 2]);

    // Green cube at RIGHT floor level (high Y, DEEPER at Z=-17)
    color("green") translate([0, 7, -17]) cube([3, 3, 2]);

    // Text in console
    echo("=== TILT VERIFICATION ===");
    echo("BLUE marker (LEFT/low Y): Z = -15 (NORMAL)");
    echo("GREEN marker (RIGHT/high Y): Z = -17 (2mm DEEPER)");
    echo(str("Tilt compensation: ", tilt_compensation_mm, "mm"));
    echo("RIGHT side of holder is DEEPER to accept tool that's HIGHER on right");
}

// ========================================
// NOTES
// ========================================
/*
This holder receives the peek_nozzle_4channel during loading.

Optimizations for straighter loading:

1. ASYMMETRIC POCKET (v2):
   - LEFT side of pocket is 2mm deeper
   - Compensates for servo tilt where right side (high X) is higher
   - The nozzle will seat level even with tilted approach

2. ENTRY FUNNEL:
   - Chamfered top edge guides the nozzle into alignment
   - 15° angle provides gradual centering

3. INCREASED HEIGHT:
   - 5mm taller walls provide more guidance during insertion
   - Adjust holder_height_increase if needed

4. TRY SIMPLE VERSION FIRST:
   - bayonet_pipette_tipcase_holder_v2_simple() has just height + funnel
   - If that works, the gcode compensation may be enough
   - Use full v2 only if still loading crooked

To adjust:
- tilt_compensation_mm: Change if 2mm isn't enough (try 1.5-3mm)
- holder_height_increase: More height = more guidance
- funnel_angle: Larger angle = easier entry but less precision
*/
