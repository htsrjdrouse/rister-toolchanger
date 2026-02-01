// Parametric Tubing Clip - Snap-Fit Design
// Supports PTFE (3mm OD x 1.5mm ID) and Silicone tubing
// Based on VC Design's cable clip concept

/* [Tubing Type] */
tubing_type = "ptfe"; // [ptfe:PTFE (3mm OD x 1.5mm ID), silicone:Silicone (3mm OD)]

/* [Tubing Parameters] */
num_tubes = 4;           // Number of tubes to hold
tube_spacing = 6.5;      // Spacing between tube centers (mm)

/* [Clip Dimensions] */
clip_length = 23;        // Overall length of clip (mm)
wall_thickness = 1.2;    // Wall thickness (mm)
base_thickness = 2.0;    // Base plate thickness (mm)

/* [Mounting] */
screw_diameter = 3.0;    // Mounting screw diameter (mm)
screw_head_dia = 6.0;    // Screw head diameter (mm)
countersink = true;      // Use countersunk mounting holes

/* [Print Settings] */
$fn = 64;                // Circle resolution

// Tubing type specific parameters
// PTFE: Stiffer material, needs more clearance, thinner walls
// Silicone: Flexible, compresses slightly, thicker walls
tube_od = (tubing_type == "ptfe") ? 4.0 : 3.0;
tube_id = (tubing_type == "ptfe") ? 2 : 1.5;
channel_clearance = (tubing_type == "ptfe") ? 0.3 : 0.1;  // PTFE needs more clearance (stiffer)
grip_interference = (tubing_type == "ptfe") ? 0.2 : 0.4;  // Silicone can compress more

// Effective channel diameter (tube OD + clearance)
channel_diameter = tube_od + channel_clearance;

// Calculated dimensions
total_width = (num_tubes - 1) * tube_spacing + tube_od + 2 * wall_thickness;
channel_depth = tube_od / 2 + wall_thickness;
clip_height = base_thickness + channel_depth;

// Snap-in opening parameters
// PTFE: Wider opening since tube won't compress
// Silicone: Can use tighter opening
snap_opening = (tubing_type == "ptfe") ? tube_od * 0.85 : tube_od * 0.7;

// Main assembly
module tubing_clip_assembly() {
    base_plate();
    translate([0, 0, base_thickness])
        tube_channels();
}

module base_plate() {
    difference() {
        // Main base
        cube([total_width, clip_length, base_thickness]);

        // Mounting holes
        for (pos = [clip_length * 0.25, clip_length * 0.75]) {
            translate([total_width / 2, pos, -0.1]) {
		/*
                if (countersink) {
                    cylinder(d=screw_diameter, h=base_thickness + 0.2);
                    translate([0, 0, base_thickness - screw_head_dia/2 + 0.5])
                        cylinder(d1=screw_diameter, d2=screw_head_dia, h=screw_head_dia/2);
                } else {
                    cylinder(d=screw_diameter, h=base_thickness + 0.2);
                }
		*/

            }
        }
    }
}

module tube_channels() {
    for (i = [0:num_tubes-1]) {
        x_pos = wall_thickness + tube_od/2 + i * tube_spacing;
        translate([x_pos, 0, 0])
            single_channel();
    }
}

module single_channel() {
    difference() {
        union() {
            // Side walls with snap-in lips
            translate([-tube_od/2 - wall_thickness, 0, 0])
                cube([wall_thickness, clip_length, channel_depth]);
            translate([tube_od/2, 0, 0])
                cube([wall_thickness, clip_length, channel_depth]);

            // Back wall
            translate([-tube_od/2 - wall_thickness, 0, 0])
                cube([tube_od + 2*wall_thickness, wall_thickness, channel_depth]);

            // Front wall
            translate([-tube_od/2 - wall_thickness, clip_length - wall_thickness, 0])
                cube([tube_od + 2*wall_thickness, wall_thickness, channel_depth]);

            // Snap-in lips (grip the tube from above)
            lip_height = channel_depth;
            lip_width = (tube_od - snap_opening) / 2 + grip_interference;

            // Left lip
            translate([-tube_od/2, 0, channel_depth - lip_width])
                snap_lip(lip_width, clip_length);

            // Right lip (mirrored)
            translate([tube_od/2, 0, channel_depth - lip_width])
                mirror([1, 0, 0])
                    snap_lip(lip_width, clip_length);
        }

        // Tube channel cutout (semicircular)
        translate([0, -0.1, channel_diameter/2])
            rotate([-90, 0, 0])
                cylinder(d=channel_diameter, h=clip_length + 0.2);
    }
}

// Snap lip with angled entry for easy tube insertion
module snap_lip(width, length) {
    entry_angle = (tubing_type == "ptfe") ? 35 : 45;  // PTFE needs gentler angle

    difference() {
        cube([width, length, width]);

        // Angled entry chamfer
        translate([0, -0.1, width])
            rotate([0, entry_angle, 0])
                cube([width * 2, length + 0.2, width]);
    }
}

// Render for printing
module render_for_print() {
    tubing_clip_assembly();
}

// Visualization with tubes inserted
module render_with_tubes() {
    tubing_clip_assembly();

    // Show tubes in position
    color("white", 0.6)
        for (i = [0:num_tubes-1]) {
            x_pos = wall_thickness + tube_od/2 + i * tube_spacing;
            translate([x_pos, -5, base_thickness + channel_diameter/2])
                rotate([-90, 0, 0])
                    difference() {
                        cylinder(d=tube_od, h=clip_length + 10);
                        cylinder(d=tube_id, h=clip_length + 10.1);
                    }
        }
}

// Cross-section view
module render_cross_section() {
    difference() {
        render_with_tubes();

        // Cut away front half
        translate([-10, clip_length/2, -10])
            cube([total_width + 20, clip_length, clip_height + 20]);
    }
}

// Info text for console
echo(str("=== Tubing Clip Configuration ==="));
echo(str("Tubing type: ", tubing_type));
echo(str("Tube OD: ", tube_od, "mm, ID: ", tube_id, "mm"));
echo(str("Channel diameter: ", channel_diameter, "mm (includes ", channel_clearance, "mm clearance)"));
echo(str("Snap opening: ", snap_opening, "mm"));
echo(str("Number of tubes: ", num_tubes));
echo(str("Total width: ", total_width, "mm"));
echo(str("Clip dimensions: ", total_width, " x ", clip_length, " x ", clip_height, "mm"));

/* [Render Mode] */
render_mode = "print"; // [print:Print Layout, with_tubes:With Tubes, cross_section:Cross Section]

// Render based on mode
if (render_mode == "print") {
    render_for_print();
} else if (render_mode == "with_tubes") {
    render_with_tubes();
} else if (render_mode == "cross_section") {
    render_cross_section();
}
