//include <includes/luerlock_nozzle_4channel.scad>
include <scad/luerlock_syringe_dispenser_model.scad>

//luer_lock_case_lid();
//translate([0,3,-1])

//translate([320,-420,200])rotate([0,180,0])luerlock_pipette_assy();
//translate([0,0,-3])doctor_blade_assay_pipettes_sg();


doctor_blade_2pipette();


module doctor_blade_2pipette(){

difference(){
union(){
translate([0,0,-3])doctor_blade_assy();
//translate([0,0,-3])color("peru")doctor_blade_assay_pipettes_blk();
translate([-18.5,0,-62.2])color("pink")cube([31,13,8]);

}
translate([0,0,-3])#doctor_blade_assay_pipettes();
translate([0-2.3-7.5,-20,-80.6+22])rotate([0,90,90]){
translate([0,3.5+4+10-1.9-10.7,0])rotate([0,0,0])rotate([0,0,0])cylinder(d=2,h=40,$fn=50);
translate([0,3.5+4+10-1.9-18-16,0])rotate([0,0,0])rotate([0,0,0])cylinder(d=2,h=40,$fn=50);
}
}
}


module doctor_blade_assay_pipettes_blk(){
translate([320,-420,200])rotate([0,180,0])translate([-5.5-0.7-1.3,0,0-4+6.5-24])for(i=[0,1,2]){
translate([319+i*11.5-5-1,427-7,309-32.3-4])cube([12,10+3,8]);
}
}




module doctor_blade_assay_pipettes_sg(){
translate([320,-420,200])rotate([0,180,0])translate([-5.5-0.7-1.3,0,0-4+6.5-24])for(i=[1]){
if (i==1){
translate([319+i*11.5,427,309-30])pipette_18g();
}else{
translate([319+i*11.5,427,309-30])pipette_10g();
}
}
}


module doctor_blade_assay_pipettes(){
translate([320,-420,200])rotate([0,180,0])translate([-5.5-0.7-1.3,0,0-4+6.5-24])for(i=[0,1,2]){
if (i==1){
translate([319+i*11.5,427,309-30])scale([0.95,0.95,1])pipette_18g();
}else{
translate([319+i*11.5,427,309-30])scale([0.95,0.95,1])pipette_10g();
}
}
}


module doctor_blade_assy(){
difference(){
translate([0-3,7.5-5,-50.5+1])rotate([90,0,0])color("lime")doctor_blade();
/*
translate([0-2.3,-20,-80.6])rotate([0,90,90]){
translate([0,3.5+4+10-1.9-11,0])rotate([0,0,0])rotate([0,0,0])cylinder(d=3.5,h=40,$fn=50);
translate([0,3.5+4+10-1.9-18,0])rotate([0,0,0])rotate([0,0,0])cylinder(d=3.5,h=40,$fn=50);
}
*/
}
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


    blade_width     = 30.0; // mm — spreading width of doctor blade
    blade_root_t    = 2.5;  // mm — thickness at blade root (stiff)
    blade_tip_t     = 0.7;  // mm — thickness at blade edge (flexible)
    blade_length    = 12.8; // mm — how far blade extends from nozzle CL
    // The blade tapers linearly from root to tip in thickness
    // blade_tip_t should be at or below 1 layer × number-of-walls
    // for maximum flexibility at the spreading edge


    // Use a polyhedron for the tapered cross-section
    // Width = X, length = Y, thickness = Z (matches print orientation)
    w  = blade_width;
    l  = blade_length;
    rt = blade_root_t;
    tt = blade_tip_t;

    translate([-blade_width/2,-9,0])cube([blade_width,9,2.5]);
    //#translate([-8,-35,5.5])cube([15,15,3]);
    //#translate([-8,-21,0+6.2])rotate([-24,0,0])cube([15,15,2.5]);

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
