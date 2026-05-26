// just_doctor_blade_AD.scad
// Modified for A-D outer feed point dispensing
// Blade widened to span all 4 pipettes (A=i0 to D=i3)
// End walls added at A and D ends to contain fluid
// Pipette cutouts extended to include D (i=3)
//
// Pipette spacing: 11.5mm
// A(i=0) to D(i=3) = 3 × 11.5 = 34.5mm span
// Blade width: 34.5 + 5mm overhang each side = 44.5mm
// End walls: 3mm deep × 3mm tall × 2mm thick at each end

include <scad/luerlock_syringe_dispenser_model.scad>

doctor_blade_AD();

module doctor_blade_AD(){

difference(){
  union(){
    translate([0,0,-3])doctor_blade_assy_AD();
    // Main body cube — widened from 31mm to 45mm, recentred
    // Original: translate([-18.5,0,-62.2]) cube([31,13,8])
    // New centre: midpoint of A-D span = 1.5 × 11.5 = 17.25mm from A
    // A is at i=0 position; D is at i=3 position
    translate([-22.25+0,0,-62.2])color("pink")cube([44.5,13,8]);
  }
  // Pipette cutouts — extended from i=[0,1,2] to i=[0,1,2,3]
  translate([0,0,-3])#doctor_blade_assay_pipettes_AD();
  // Mounting hole slots (unchanged)
  translate([0-2.3-7.5,-20,-80.6+22])rotate([0,90,90]){
    translate([0,3.5+4+10-1.9-10.7,0])rotate([0,0,0])cylinder(d=2,h=40,$fn=50);
    translate([0,3.5+4+10-1.9-18-16,0])rotate([0,0,0])cylinder(d=2,h=40,$fn=50);
  }
}
}


module doctor_blade_assay_pipettes_AD(){
  // Extended to i=[0,1,2,3] to include D pipette cutout
  translate([320,-420,200])rotate([0,180,0])translate([-5.5-0.7-1.3,0,0-4+6.5-24])for(i=[0,1,2,3]){
    if (i==1){
      translate([319+i*11.5,427,309-30])scale([0.95,0.95,1])pipette_18g();
    }else{
      translate([319+i*11.5,427,309-30])scale([0.95,0.95,1])pipette_10g();
    }
  }
}


module doctor_blade_assy_AD(){
  difference(){
    translate([0-3,7.5-5,-50.5+1])rotate([90,0,0])color("lime")doctor_blade_AD_blade();
  }
}


// --- DOCTOR BLADE — A to D wide version with end walls ---
// blade_width extended from 30mm to 44.5mm
// End walls added at each X extreme to contain fluid
// All other taper geometry unchanged
module doctor_blade_AD_blade() {

    blade_width     = 44.5; // mm — widened: A-D span 34.5mm + 5mm overhang each side
    blade_root_t    = 2.5;  // mm — unchanged
    blade_tip_t     = 0.7;  // mm — unchanged
    blade_length    = 12.8; // mm — unchanged

    // End wall dimensions
    ew_depth        = 3.0;  // mm — how far end wall extends toward substrate (Y direction)
    ew_height       = 2.5;  // mm — end wall height (Z) — matches root thickness
    ew_thick        = 2.0;  // mm — end wall thickness (X)

    w  = blade_width;
    l  = blade_length;
    rt = blade_root_t;
    tt = blade_tip_t;

    // Root mounting block (unchanged geometry, widened)
    translate([-blade_width/2,-9,0])cube([blade_width,9,2.5]);

    // Main tapered blade body — polyhedron (widened only)
    polyhedron(
        points = [
            // Root face (Y=0) — full thickness
            [-w/2,  0,  0],   // 0
            [ w/2,  0,  0],   // 1
            [ w/2,  0,  rt],  // 2
            [-w/2,  0,  rt],  // 3
            // Tip face (Y=+l) — thin edge
            [-w/2,  l,  (rt-tt)/2],       // 4
            [ w/2,  l,  (rt-tt)/2],       // 5
            [ w/2,  l,  (rt-tt)/2 + tt],  // 6
            [-w/2,  l,  (rt-tt)/2 + tt],  // 7
        ],
        faces = [
            [3,2,1,0],   // root face (facing -Y)
            [4,5,6,7],   // tip face  (facing +Y)
            [3,7,4,0],   // left side  (facing -X)
            [0,4,5,1],   // bottom     (facing -Z)
            [1,5,6,2],   // right side (facing +X)
            [2,6,7,3],   // top        (facing +Z)
        ]
    );

    // END WALL — left side (A end, -X)
    // Positioned at blade tip edge, extends in Y direction
    // Flush with blade tip bottom face
    translate([-w/2, l-ew_depth, (rt-tt)/2])
        cube([ew_thick, ew_depth, ew_height]);

    // END WALL — right side (D end, +X)
    translate([w/2-ew_thick, l-ew_depth, (rt-tt)/2])
        cube([ew_thick, ew_depth, ew_height]);
}
