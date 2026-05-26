// ============================================================
//  TPU Doctor Blade Holder — Luer Lock Blunt Tip (18G)
//  For: Rister Toolchanger / printed electronics BIPV fab
//  Material: TPU 85A–95A, 0.4 mm nozzle recommended
//  Author: HTS Resources LLC
// ============================================================
//
//  OVERVIEW
//  --------
//  This tool holds an 18G (or similar) Luer Lock blunt tip and
//  carries a flexible TPU doctor blade immediately behind the
//  nozzle exit. The blade spreads dispensed ink into a thin,
//  uniform film on the substrate. Z-height of the printer
//  toolhead controls the working gap (target 100–300 µm).
//
//  The body is split into three functional zones:
//    1. MOUNT PLATE  — attaches to tool head via M3 screws
//    2. BODY BRIDGE  — connects mount to nozzle collar; adds
//                      lateral stiffness while TPU stays flexible
//    3. NOZZLE COLLAR — snug friction fit for Luer Lock hub
//    4. BLADE WING   — thin tapered blade, 30 mm wide, flexible
//
//  PRINT SETTINGS (TPU 85A–95A)
//    - Layer height: 0.15–0.2 mm
//    - Perimeters: 3–4 walls
//    - Infill: 20–30% gyroid
//    - Print slow: 20–25 mm/s for TPU
//    - No supports needed if printed in orientation shown
//    - Orient flat (mount plate face-down on bed)
// ============================================================

/* ── GLOBAL PARAMETERS ── */

// Luer Lock hub outer diameter (18G Treela tip hub ≈ 6.5 mm)
// Increase slightly (e.g. 6.6) for tighter friction fit in TPU
luer_od = 6.5;          // mm — hub OD to grip
luer_depth = 7.0;       // mm — depth of collar socket
collar_wall = 2.0;      // mm — wall thickness around Luer hub
// Tip of collar has a chamfer to guide the Luer hub in
collar_chamfer = 1.0;   // mm

/* ── BLADE PARAMETERS ── */

blade_width     = 30.0; // mm — spreading width of doctor blade
blade_root_t    = 2.5;  // mm — thickness at blade root (stiff)
blade_tip_t     = 0.7;  // mm — thickness at blade edge (flexible)
blade_length    = 14.0; // mm — how far blade extends from nozzle CL
// The blade tapers linearly from root to tip in thickness
// blade_tip_t should be at or below 1 layer × number-of-walls
// for maximum flexibility at the spreading edge

/* ── BODY / BRIDGE PARAMETERS ── */

body_width  = 20.0;  // mm — width of central body (X)
body_depth  = 12.0;  // mm — depth front-to-back (Y)
body_height = 18.0;  // mm — height from mount plate to nozzle CL

/* ── MOUNT PLATE PARAMETERS ── */

mount_w   = 30.0;   // mm — total mount plate width
mount_h   = 16.0;   // mm — total mount plate height (Z axis)
mount_t   =  4.0;   // mm — plate thickness (Y axis, into tool head)
// M3 hole positions — measured from plate centre
m3_spacing_x = 16.0; // mm — horizontal distance between M3 holes
m3_spacing_z =  0.0; // mm — vertical offset (0 = same height)
m3_dia       =  3.4; // mm — M3 clearance hole (3.4 for TPU compression)
m3_head_dia  =  6.2; // mm — M3 countersink / washer recess diameter
m3_head_depth=  2.5; // mm — depth of washer recess

/* ── NOZZLE ALIGNMENT ── */

// Distance from front face of mount plate to nozzle CL (Y)
nozzle_reach   = body_depth + mount_t;
// Height of nozzle centre above bottom of mount plate (Z)
// Adjust this so the blade tip grazes the substrate at the
// desired Z=0 home when mount plate top is at tool head datum
nozzle_z_above_bottom = 8.0; // mm

/* ── DERIVED / CONVENIENCE ── */

collar_od  = luer_od + 2 * collar_wall;  // outer dia of collar
eps        = 0.01; // small epsilon for clean boolean diffs

// ============================================================
//  MODULES
// ============================================================

// --- 1. MOUNT PLATE -------------------------------------------
// Flat plate with M3 clearance holes and washer recesses.
// Attach this face to your tool head carriage.
module mount_plate() {
    difference() {
        // Main plate body — slightly radiused corners via minkowski
        minkowski() {
            cube([mount_w - 4, mount_h - 4, mount_t - 1], center=true);
            cylinder(r=2, h=0.5, $fn=24);
        }
        // Two M3 clearance holes
        for (dx = [-m3_spacing_x/2, m3_spacing_x/2]) {
            translate([dx, 0, m3_spacing_z]) {
                // Through hole
                cylinder(d=m3_dia, h=mount_t + eps*2, center=true, $fn=16);
                // Washer recess on back face
                translate([0, 0, (mount_t - m3_head_depth)/2])
                    cylinder(d=m3_head_dia, h=m3_head_depth + eps,
                             center=true, $fn=20);
            }
        }
    }
}

// --- 2. BODY BRIDGE -------------------------------------------
// Connects mount plate to nozzle collar.
// Rounded rectangular cross-section for stiffness + printability.
module body_bridge() {
    hull() {
        // At mount plate face
        translate([0, -body_depth/2, 0])
            cube([body_width, eps, body_height], center=true);
        // At nozzle collar face — narrower to blend into collar
        translate([0, body_depth/2, 0])
            cube([collar_od + 4, eps, collar_od + 4], center=true);
    }
}

// --- 3. NOZZLE COLLAR -----------------------------------------
// Cylindrical socket that accepts the Luer Lock hub.
// The front opening is chamfered to guide insertion.
// Inner diameter matches luer_od for a snug friction fit in TPU.
module nozzle_collar() {
    difference() {
        cylinder(d=collar_od, h=luer_depth, $fn=36);
        // Central bore for Luer hub
        translate([0, 0, collar_chamfer])
            cylinder(d=luer_od, h=luer_depth + eps, $fn=30);
        // Entry chamfer — makes it easy to push hub in
        translate([0, 0, -eps])
            cylinder(d1=luer_od + 2*collar_chamfer,
                     d2=luer_od,
                     h=collar_chamfer + eps, $fn=30);
    }
    // Hex grip ring around collar body (optional tactile feature)
    // Uncomment if you want a wrench-grip surface:
    // translate([0,0,luer_depth/2])
    //   rotate([0,0,0]) cylinder(d=collar_od+1, h=3, $fn=6, center=true);
}

// --- 4. DOCTOR BLADE ------------------------------------------
// Wide, thin blade that tapers from root_t to tip_t.
// Centred on X; positioned so root begins at nozzle CL (Y=0).
// The blade extends in the +Y direction (trailing behind nozzle
// as the head moves in -Y, i.e. blade drags the ink).
//
// TIP: For 85A TPU at blade_tip_t=0.7 mm, the edge is very
// flexible. Increase to 1.0 mm for stiffer 95A TPU.
module doctor_blade() {
    // Use a polyhedron for the tapered cross-section
    // Width = X, length = Y, thickness = Z (matches print orientation)
    w  = blade_width;
    l  = blade_length;
    rt = blade_root_t;
    tt = blade_tip_t;

    // 8-point polyhedron: trapezoidal cross-section (thicker at root)
    polyhedron(
        points = [
            // Root face (Y=0) — full thickness
            [-w/2,  0,  0],   // 0
            [ w/2,  0,  0],   // 1
            [ w/2,  0,  rt],  // 2
            [-w/2,  0,  rt],  // 3
            // Tip face (Y=+l) — thin edge, centred in Z at blade_root_t/2
            [-w/2,  l,  (rt-tt)/2],       // 4
            [ w/2,  l,  (rt-tt)/2],       // 5
            [ w/2,  l,  (rt-tt)/2 + tt],  // 6
            [-w/2,  l,  (rt-tt)/2 + tt],  // 7
        ],
        faces = [
            // All faces wound counter-clockwise when viewed from outside
            [3,2,1,0],   // root face (facing -Y)
            [4,5,6,7],   // tip face  (facing +Y)
            [3,7,4,0],   // left side  (facing -X)
            [0,4,5,1],   // bottom     (facing -Z)
            [1,5,6,2],   // right side (facing +X)
            [2,6,7,3],   // top        (facing +Z)
        ]
    );
}

// ============================================================
//  ASSEMBLY
// ============================================================
// Coordinate system:
//   X = left/right  (blade width direction)
//   Y = front/back  (travel direction; blade trails in +Y)
//   Z = up/down     (substrate gap direction; nozzle exits in -Z)
//
// Mount plate: back face at Y=0, extends in -Y into tool head.
// Nozzle collar: bore runs in Z, hub inserts from +Y (front face).
//   The nozzle tip exits downward (-Z) toward the substrate.
// Blade: root begins at nozzle CL (Y = nozzle_y), extends in +Y.
//   Blade edge in Z sits at substrate level; gap set by z_offset.
//
//  ┌──────────────────────────────────────┐
//  │  [mount plate]──[bridge]──[collar]   │  ← side view
//  │                             │        │
//  │                            ▼ nozzle  │
//  │                    [blade ══════════>│  trailing edge
//  └──────────────────────────────────────┘
//                       substrate ────────

// Y position of nozzle centreline (front face of bridge + collar radius)
nozzle_y = mount_t + body_depth;

module assembly() {
    // ----- MOUNT PLATE -----
    // Plate XZ plane, centred in X and Z, back face at Y=0
    translate([0, -mount_t/2, mount_h/2])
        rotate([90, 0, 0])
            mount_plate();

    // ----- BODY BRIDGE -----
    // Fills the gap between mount plate front face and collar
    translate([0, mount_t + body_depth/2, nozzle_z_above_bottom])
        rotate([90, 0, 0])
            body_bridge();

    // ----- NOZZLE COLLAR -----
    // Hub inserts from +Y (front face); nozzle exits downward (-Z).
    #translate([0, nozzle_y, nozzle_z_above_bottom])
        nozzle_collar_horizontal();

    // ----- DOCTOR BLADE -----
    // Root starts at nozzle_y (just behind nozzle exit).
    // Blade extends in +Y (trailing direction).
    // Z offset puts blade edge at substrate level.
    blade_z_offset = nozzle_z_above_bottom - blade_root_t;
    translate([0, nozzle_y, blade_z_offset])
    #    doctor_blade();
}

// Collar variant with bore running in Z and hub entry from +Y.
// The Luer hub slides in horizontally from the front; the nozzle
// tip points straight down toward the substrate.
module nozzle_collar_horizontal() {
    // Body: short cylinder in Z, wide enough to embed the luer socket
    // We embed the luer bore horizontally (Y axis) inside a block.
    cw = collar_od + 2;          // collar block width (X)
    ch = collar_od + 2;          // collar block height (Z)
    cd = luer_depth + collar_wall; // collar block depth (Y)

    difference() {
        // Rounded rectangular block
        translate([0, cd/2, 0])
            minkowski() {
                cube([cw-2, cd-2, ch-2], center=true);
                sphere(r=1, $fn=16);
            }

        // Luer hub bore — runs in Y (hub enters from +Y front face)
        translate([0, cd + eps, 0])
            rotate([90, 0, 0])
                cylinder(d=luer_od, h=luer_depth + eps, $fn=30);

        // Entry chamfer at front face (+Y)
        translate([0, luer_depth, 0])
            rotate([90, 0, 0])
                cylinder(d1=luer_od + 2*collar_chamfer, d2=luer_od,
                         h=collar_chamfer + eps, $fn=30);

        // Nozzle exit bore — runs in -Z (down toward substrate)
        // Positioned at the end of the luer hub bore
        translate([0, collar_wall, -ch/2 - eps])
            cylinder(d=luer_od * 0.6, h=ch/2 + collar_wall + eps, $fn=24);
    }
}

// ============================================================
//  RENDER
// ============================================================

assembly();


// ============================================================
//  NOTES FOR TUNING
// ============================================================
//
//  WORKING GAP (100–300 µm):
//    Set your slicer Z-offset or Klipper z_offset so that the
//    blade edge clears the substrate by the desired gap.
//    At blade_tip_t = 0.7 mm (3 walls × 0.25 mm), the edge
//    will flex and self-level somewhat on the substrate.
//
//  FRICTION FIT TUNING:
//    If Luer hub is loose: reduce luer_od by 0.1–0.2 mm.
//    If Luer hub won't insert: increase luer_od by 0.1 mm.
//    TPU will grip well; you may need to wiggle the hub in.
//
//  BLADE STIFFNESS:
//    85A TPU + blade_tip_t = 0.7 mm → very flexible, self-levels
//    95A TPU + blade_tip_t = 1.0 mm → stiffer, more consistent gap
//
//  BLADE WIDTH vs SUBSTRATE:
//    blade_width = 30 mm is suitable for ~1" (25 mm) substrates.
//    Increase to 40–50 mm for 2"×2" glass tiles.
//
//  M3 HOLE SPACING:
//    m3_spacing_x = 16 mm matches common toolchanger carriage
//    plate patterns. Adjust to match your specific mount pattern.
//
// ============================================================
