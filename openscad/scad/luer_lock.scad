// Luer Lock Connection - Male and Female Ends
// Based on ISO 80369 / ISO 594 standard dimensions
// Units: millimeters

$fn = 100; // Smooth curves

// ============== PARAMETERS ==============
// Luer taper: 6% (approximately 1.72° half-angle)
taper_angle = 1.72;

// Male fitting dimensions
male_taper_length = 7.5;
male_tip_od = 4.0;       // Outer diameter at tip
male_base_od = 4.9;      // Outer diameter at base

// Female fitting dimensions
female_taper_length = 7.5;
female_tip_id = 4.1;     // Inner diameter at tip (slightly larger for fit)
female_base_id = 5.0;    // Inner diameter at base

// Lock ring dimensions
lock_od = 9.0;           // Outer diameter of lock ring
lock_id = 6.5;           // Inner diameter of lock ring
lock_height = 5.0;       // Height of lock ring
thread_pitch = 1.27;     // Thread pitch (40 TPI standard)
thread_depth = 0.5;      // Thread depth

// Flange/grip dimensions
flange_od = 12.0;
flange_height = 2.0;

// ============== MODULES ==============

// Creates a tapered cylinder (cone section)
module tapered_cylinder(h, r1, r2) {
    cylinder(h=h, r1=r1, r2=r2);
}

// Creates external threads
module external_threads(od, id, height, pitch, starts=2) {
    thread_height = pitch * 0.6;
    turns = height / pitch;

    difference() {
        cylinder(h=height, d=od);
        translate([0, 0, -0.1])
            cylinder(h=height + 0.2, d=id);
    }

    // Add thread profile
    for (start = [0:starts-1]) {
        rotate([0, 0, start * (360/starts)])
        linear_extrude(height=height, twist=-turns*360, convexity=10)
        translate([od/2 - thread_depth/2, 0, 0])
            circle(d=thread_depth, $fn=6);
    }
}

// Creates internal threads
module internal_threads(od, id, height, pitch, starts=2) {
    thread_height = pitch * 0.6;
    turns = height / pitch;

    difference() {
        cylinder(h=height, d=od);
        translate([0, 0, -0.1])
            cylinder(h=height + 0.2, d=id);

        // Cut thread grooves
        for (start = [0:starts-1]) {
            rotate([0, 0, start * (360/starts)])
            linear_extrude(height=height + 0.1, twist=-turns*360, convexity=10)
            translate([id/2 + thread_depth/2, 0, 0])
                circle(d=thread_depth * 1.2, $fn=6);
        }
    }
}

// ============== MALE LUER LOCK ==============
module male_luer_lock() {
    color("SteelBlue") {
        union() {
            // Tapered male fitting (the cone that inserts)
            tapered_cylinder(
                h = male_taper_length,
                r1 = male_base_od / 2,
                r2 = male_tip_od / 2
            );

            // Base flange with grip ridges
            translate([0, 0, -flange_height]) {
                difference() {
                    cylinder(h=flange_height, d=flange_od);
                    // Grip ridges
                    for (i = [0:11]) {
                        rotate([0, 0, i * 30])
                        translate([flange_od/2, 0, -0.1])
                            cylinder(h=flange_height + 0.2, d=1.5);
                    }
                }
            }

            // Threaded collar (external threads for locking)
            translate([0, 0, -flange_height - lock_height]) {
                external_threads(
                    od = lock_od,
                    id = lock_id,
                    height = lock_height,
                    pitch = thread_pitch
                );
            }

            // Inner bore (hollow center)
            translate([0, 0, -flange_height - lock_height - 0.1]) {
                difference() {
                    cylinder(h=0.1, d=lock_id);
                }
            }
        }

        // Make it hollow
        difference() {
            children(0);
            translate([0, 0, -flange_height - lock_height - 0.5])
                cylinder(h=male_taper_length + flange_height + lock_height + 1, d=2.5);
        }
    }
}

// Complete male part with hollow bore
module male_luer_complete() {
    color("SteelBlue")
    difference() {
        union() {
            // Tapered male fitting
            tapered_cylinder(
                h = male_taper_length,
                r1 = male_base_od / 2,
                r2 = male_tip_od / 2
            );

            // Base flange with grip ridges
            translate([0, 0, -flange_height]) {
                difference() {
                    cylinder(h=flange_height, d=flange_od);
                    for (i = [0:11]) {
                        rotate([0, 0, i * 30])
                        translate([flange_od/2, 0, -0.1])
                            cylinder(h=flange_height + 0.2, d=1.5);
                    }
                }
            }

            // Threaded collar
            translate([0, 0, -flange_height - lock_height]) {
                external_threads(
                    od = lock_od,
                    id = lock_id,
                    height = lock_height,
                    pitch = thread_pitch
                );
            }
        }

        // Hollow center bore
        translate([0, 0, -flange_height - lock_height - 0.5])
            cylinder(h=male_taper_length + flange_height + lock_height + 1, d=2.5);
    }
}

// ============== FEMALE LUER LOCK ==============
module female_luer_complete() {
    color("Coral")
    difference() {
        union() {
            // Outer body
            cylinder(h=female_taper_length + 2, d=lock_od + 4);

            // Lock ring with internal threads
            translate([0, 0, female_taper_length + 2]) {
                internal_threads(
                    od = lock_od + 4,
                    id = lock_od + 0.3,  // Clearance for male threads
                    height = lock_height + 1,
                    pitch = thread_pitch
                );
            }

            // Top rim
            translate([0, 0, female_taper_length + 2 + lock_height + 1])
                cylinder(h=1, d=lock_od + 6);
        }

        // Tapered female socket (negative of male taper with clearance)
        translate([0, 0, -0.1])
        tapered_cylinder(
            h = female_taper_length + 0.2,
            r1 = female_base_id / 2,
            r2 = female_tip_id / 2
        );

        // Exit bore
        translate([0, 0, -5])
            cylinder(h=5.1, d=female_tip_id);

        // Clearance for male flange
        translate([0, 0, female_taper_length])
            cylinder(h=3, d=flange_od + 1);
    }
}

// ============== DISPLAY ==============

// Show male part
translate([-15, 0, 12])
rotate([180, 0, 0])
    male_luer_complete();

// Show female part
translate([15, 0, 0])
    female_luer_complete();

// Labels (comment out for printing)
translate([-15, -12, 0])
    text("MALE", size=4, halign="center");

translate([15, -12, 0])
    text("FEMALE", size=4, halign="center");

// ============== CROSS-SECTION VIEW (optional) ==============
// Uncomment to see internal structure

/*
module cross_section() {
    difference() {
        children();
        translate([-50, 0, -20])
            cube([100, 50, 100]);
    }
}

translate([0, 30, 0]) {
    translate([-15, 0, 12])
    rotate([180, 0, 0])
        cross_section() male_luer_complete();

    translate([15, 0, 0])
        cross_section() female_luer_complete();
}
*/
