// ============================================================================
//  18650 SCORE-&-DECAP LAB FIXTURE  —  parametric OpenSCAD assembly
// ============================================================================
//
//  PURPOSE
//    Single fixture, TWO independent recipes on a discharged 18650 cell:
//
//    (1) SCORE  — Collet grips the can BODY. SPIN rotates the cell. FEED pushes
//                 a pipe-cutter WHEEL radially inward (from +Y), landing just
//                 under the positive crimp (~4 mm from the cap face). One or two
//                 slow revolutions. A depth collar limits plunge so the wheel
//                 stops BEFORE the jelly roll. FEED then retracts.
//
//    (2) STRIP  — DECAP slides the cell (+X) so the cap meets a FIXED anvil.
//                 A hobby servo pinches the cap against a TPU pad. DECAP reverses
//                 (-X); the body slides off, the cap stays behind. The blade does
//                 NOT participate in this recipe.
//
//    The two recipes are deliberately NOT merged into a helical cut.
//
//  COORDINATE SYSTEM
//    Cell axis   = X   (cap toward +X, body toward -X)
//    Blade feed  = Y   (wheel enters from +Y, travels toward -Y)
//    Up          = Z
//    Origin      = the SCORE POINT (where the wheel meets the can), on the axis.
//
//  AXES / DRIVES
//    SPIN   = NEMA 14, direct rotary on the collet.
//    FEED   = NEMA 14 + T8x2 leadscrew + MGN9 rail, blade in/out along Y.
//    DECAP  = NEMA 17 + T8x2 leadscrew + MGN9 rail, body along cell axis X.
//    CLAMP  = hobby servo (SG90-class) + TPU pad, pinches the cap at the anvil.
//
//  HAZARD / FUME NOTE (HF)
//    Motors are NOT boxed. The PP cowling wraps ONLY the cell + blade zone plus a
//    50 mm snorkel stub for extraction. All motors sit on the same base plate,
//    held motor_standoff (default 190 mm, floor 150 mm) away from the score.
//
// ----------------------------------------------------------------------------
//  STL EXPORT  (set  mode="part"  then set  export_part  to one name; F6; F7)
// ----------------------------------------------------------------------------
//    Printed parts (separate modules):
//      base_plate ....... PA12-CF or 6 mm Al plate substitute   (PA12-CF)
//      collet ........... clamps the can body                    (PA12-CF)
//      spin_mount ....... carries SPIN motor + collet            (PA12-CF)
//      feed_carriage .... rides FEED MGN9, holds blade_fork      (PA12-CF)
//      decap_carriage ... rides DECAP MGN9, carries spin_mount   (PA12-CF)
//      anvil ............ fixed cap stop at +X                   (PA12-CF)
//      servo_bracket .... holds servo + TPU pad at the anvil     (PA12-CF)
//      cowling_lower .... fume shroud, lower half                (PP or PA12-CF)
//      cowling_upper .... fume shroud, upper half + snorkel      (PP or PA12-CF)
//      blade_fork ....... holds cutter wheel + depth collar      (PA12-CF)
//      depth_collar ..... plunge limiter riding on the can       (PA12-CF)
//
//  MATERIALS
//      Cowling ........... PP (chemical/fume) or PA12-CF (stiffer, MJF)
//      Carriages/mounts .. PA12-CF
//      Servo pad ......... TPU (see servo_pad module)
//
//  ASSEMBLY vs PART
//      mode="assembly"  renders the full fixture in the DEFAULT POSE.
//      mode="part"      renders exactly one module named by export_part.
// ============================================================================


// =========================== PARAMETER BLOCK ================================
// ---- global render mode ----
mode        = "part";      // "assembly" | "part"
export_part = "base_plate";        // used only when mode=="part"

$fn = 64;

// ---- cell (Ø18 x 65 nominal 18650) ----
cell_dia        = 18.0;        // can outer diameter
cell_len        = 65.0;        // can length
crimp_from_cap  = 4.0;         // score plane distance from the +X cap face
cap_face_dia    = 17.0;        // positive cap disc diameter (for anvil/servo)

// ---- cutter wheel (pipe-cutter style) ----
wheel_dia       = 21.0;        // Ø20-22
wheel_thick     = 3.5;
wheel_bore      = 4.0;         // axle bore
score_depth     = 0.60;        // radial bite past the can OD (collar-limited)

// ---- FEED axis (blade in/out, along Y) ----
feed_retract    = 8.0;         // DEFAULT POSE: blade retracted this far (clear)
feed_travel     = 30.0;        // usable stroke
feed_screw      = "T8x2";      // T8 x 2 mm lead
feed_rail       = "MGN9";
feed_block      = "MGN9H";

// ---- DECAP axis (body along cell axis X) ----
decap_travel    = 55.0;        // must exceed cell_len for full strip-off
decap_screw     = "T8x2";
decap_rail      = "MGN9";
decap_block     = "MGN9H";

// ---- motor standoff (HF: keep motors away from the fume/score zone) ----
motor_standoff  = 190.0;       // from score point; parameterize
MOTOR_STANDOFF_FLOOR = 150.0;  // hard floor
motor_standoff_eff = max(motor_standoff, MOTOR_STANDOFF_FLOOR);

// ---- cowling / fume ----
cowl_wall       = 3.0;
cowl_clear      = 6.0;         // clearance around cell+blade envelope
snorkel_dia     = 50.0;        // extraction stub bore
snorkel_len     = 50.0;        // 50 mm snorkel stub
cowl_split_z    = 0;           // lower/upper split plane at axis height

// ---- base plate ----
base_th         = 8.0;
base_margin     = 20.0;

// ---- rail derivation (length = standoff + travel + block + margin) ----
mgn9_block_len  = 20.0;        // MGN9H carriage body length
mgn9_rail_w     = 9.0;
mgn9_rail_h     = 6.5;         // rail profile height
rail_margin     = 15.0;

feed_rail_len  = motor_standoff_eff + feed_travel + mgn9_block_len + rail_margin;
decap_rail_len = motor_standoff_eff + decap_travel + mgn9_block_len + rail_margin;

// ---- NEMA motor bodies ----
nema14_w = 35.2; nema14_len = 36.0; nema14_shaft_d = 5.0;  nema14_shaft_l = 20.0;
nema17_w = 42.3; nema17_len = 40.0; nema17_shaft_d = 5.0;  nema17_shaft_l = 22.0;

// ---- servo (SG90-class) ----
servo_body   = [23, 12.5, 22];
servo_horn_r = 9.0;
servo_pad    = [10, 14, 4];    // TPU pad footprint (x,y,z)

// ---- collet ----
collet_len   = 22.0;
collet_od    = 34.0;
collet_slots = 4;

// ---- axis height above base ----
axis_z = 40.0;                 // cell centerline height over the base top

// ---- colors ----
C_PRINT = [0.30, 0.55, 0.85];  // printed PA12-CF
C_COWL  = [0.85, 0.85, 0.30, 0.35];
C_METAL = [0.7, 0.7, 0.72];
C_CELL  = [0.55, 0.55, 0.58];
C_TPU   = [0.15, 0.15, 0.15];
C_RAIL  = [0.6, 0.62, 0.66];

// =========================== END PARAMETER BLOCK ===========================


// ------------------------- derived geometry helpers ------------------------
// Score point is the ORIGIN. Cap face sits at +X = crimp_from_cap.
cap_face_x    = crimp_from_cap;               // +X face of cap
cell_neg_x    = cap_face_x - cell_len;        // -X end of body
wheel_center_y = cell_dia/2 + wheel_dia/2 - score_depth; // wheel axle Y at cut
feed_home_y    = wheel_center_y + feed_retract;          // retracted axle Y


// =============================================================================
//  BOUGHT-HARDWARE MODULES  (visual placeholders, not for print)
// =============================================================================


echo(decap_rail_len);



//base_plate();
//mgn9_block_decapper();
//mgn9_block_decapper_base();
//
//color("pink")translate([-150,22,-40])rotate([0,0,-90])oneml_syringe_stepper_linear_m8nut_coupler();
//spinning_cap();
//spinning_part();
//battery_18650_holder();
mgn9_block_makelathe();

module spinning_cap(){

translate([480,320,250])
rotate([0,0,90]){
translate([30,35.5,-38])rotate([90,0,90])color("pink")import("../stls/MGN9CCradileBYGuls.STL");
translate([-130,-160,-40])import("../stls/150mm_MGN9C_Guls.stl");


translate([28,0,0]){
translate([17,45,-8])rotate([0,90,0])bearing_608();
color("silver")translate([-6,45,-8])rotate([0,90,0])cylinder(d=8,h=40,$fn=50);
color("silver")translate([28,45,-8])rotate([0,90,0])cylinder(d=15,h=6.5,$fn=6);
color("silver")translate([7,45,-8])rotate([0,90,0])cylinder(d=15,h=6.5,$fn=6);

battery_makelathe_cap();

translate([-29,79,0])rotate([0,0,180]){ 
mgn9_block_makelathe();
translate([-125,60,-18])rotate([0,90,0])color("silver")cylinder(d=8,h=100,$fn=100);
color("pink")translate([-150,22,-40])rotate([0,0,-90])oneml_syringe_stepper_linear_m8nut_coupler();
}
}
}
}


/*
difference(){
translate([-200,50,-40])rotate([90,0,0])import("../stls/250mm_MGN9C_Guls.STL");
#translate([-200,25,-45])cube([150,50,20]);
}
*/



/*
*/
module spinning_part(){
translate([470,250,250])rotate([0,0,90]){
//mgn9_block_makelathe();
mgn9_block_decapper();
mgn9_block_decapper_base();
translate([-69.6,18,-25.3])rotate([0,0,-90])color("grey")import("../stls/NEMA14.stl");
translate([20-13.5+58,35.2,0-7.7])cell_18650();
battery_18650_holder();
}

translate([425.5,250+150,239.8])rotate([0,0,-90]){
translate([-69.6,18,-25.3])rotate([0,0,-90])color("grey")import("../stls/NEMA14.stl");
translate([0,0,0])mgn9_block_decapper();
}
}

module mgn9_rail(len) {
    color(C_RAIL)
    translate([-len/2, -mgn9_rail_w/2, 0])
        cube([len, mgn9_rail_w, mgn9_rail_h]);
}

module mgn9h_block() {
    // MGN9H carriage: ~20 long x 20 wide x 10 tall, sits over the rail
    color(C_METAL)
    translate([-mgn9_block_len/2, -10, mgn9_rail_h - 1])
        cube([mgn9_block_len, 20, 10]);
}

module leadscrew(len, d=8) {
    color(C_METAL) rotate([0,90,0]) cylinder(h=len, d=d, center=true);
}

module pom_nut() {
    color([0.9,0.9,0.85]) rotate([0,90,0]) {
        cylinder(h=15, d=10.2, center=true);
        translate([0,0,-1]) cylinder(h=4, d=22, center=true); // flange
    }
}

module nema(w, len, shaft_d, shaft_l) {
    color(C_METAL) {
        translate([-len,0,0]) rotate([0,90,0])
            linear_extrude(len) offset(r=2) square(w-4, center=true);
        rotate([0,90,0]) cylinder(h=shaft_l, d=shaft_d); // shaft along +X
    }
}
module nema14() { nema(nema14_w, nema14_len, nema14_shaft_d, nema14_shaft_l); }
module nema17() { nema(nema17_w, nema17_len, nema17_shaft_d, nema17_shaft_l); }

module t8_and_nut(len) { leadscrew(len); pom_nut(); }

module cell_18650() {
    // body toward -X, cap toward +X; origin is the score plane.
    color(C_CELL)
    translate([cell_neg_x, 0, 0]) rotate([0,90,0]) {
        cylinder(h=cell_len, d=cell_dia);                        // can body
        translate([0,0,cell_len]) cylinder(h=1.2, d=cap_face_dia); // + cap disc
    }
}

module cutter_wheel() {
    color(C_METAL) difference() {
        rotate([0,90,0]) cylinder(h=wheel_thick, d=wheel_dia, center=true);
        rotate([0,90,0]) cylinder(h=wheel_thick+1, d=wheel_bore, center=true);
    }
}


// =============================================================================
//  PRINTED-PART MODULES
//  Each is authored at its own local origin, then placed by the assembly.
// =============================================================================




// ---- base_plate --------------------------------------------------------------
module base_plate() {
    // spans from behind the DECAP motor (-X) to the anvil (+X), and across Y
    // to host the FEED rail. Origin = score point, top at z=0 (base below).
    x_min = cell_neg_x - motor_standoff_eff - base_margin;
    x_max = cap_face_x + motor_standoff_eff*0.4 + base_margin; // anvil side
    y_max = feed_home_y + motor_standoff_eff + base_margin;
    y_min = -(cell_dia + base_margin);
    color(C_PRINT)
    translate([x_min, y_min, -axis_z - base_th])
        cube([x_max - x_min, y_max - y_min, base_th]);
}

module motormount_screws(){
 mmx = 42;
 mmy = 42;
 mmz = 8.5;
 mmposx = 0;
 mmposy = 19;
 mmposz = -18.5;
 m6rad = 6.5/2;
 m3rad = 4.5/2;
 motrad = 11.5;
 //motrad = 4;
 difference(){
  translate([mmposx-1,mmposy,mmposz])
  cube([mmx+1,mmy,mmz]);
  translate([mmposx+mmx/2,mmposy+mmy/2,mmposz-0.1])
  cylinder(r=motrad, h=10);
  translate([mmposx+mmx/2,mmposy+mmy/2,mmposz-0.1])
  translate([0,0,-100])
  cylinder(r=4.3, h=400);
  //m3 motor screws
  translate([mmposx+mmx/2-15.5,mmposy+mmy/2-15.5,mmposz-0.1])
  cylinder(r=m3rad, h=9);
  translate([mmposx+mmx/2-15.5,mmposy+mmy/2+15.5,mmposz-0.1])
  cylinder(r=m3rad, h=9);
  translate([mmposx+mmx/2+15.5-1.5,mmposy+mmy/2+15.5,mmposz-0.1])
  cylinder(r=m3rad, h=90);
  translate([mmposx+mmx/2+15.5-1.5,mmposy+mmy/2+15.5,mmposz-0.1])
  translate([0,-2,0])
  cube([8,4.5,90]);
  translate([mmposx+mmx/2+15.5-1.5,mmposy+mmy/2-15.5,mmposz-0.1])
  cylinder(r=m3rad, h=90);
  translate([mmposx+mmx/2+15.5-1.5,mmposy+mmy/2-15.5,mmposz-0.1])
  translate([0,-2.25,0])
  cube([8,4.5,90]);
  translate([-60,32,-14.5])rotate([0,90,0])cylinder(r=2.7/2,h=80);
  translate([-60,32+14,-14.5])rotate([0,90,0])cylinder(r=2.7/2,h=80);
  translate([-60,32,-14.5])rotate([0,90,0])cylinder(r=8/2,h=56);
  translate([-60,32+14,-14.5])rotate([0,90,0])cylinder(r=8/2,h=56);
 }
}


module oneml_syringe_stepper_linear_m8nut_coupler(){
mirror([0,1,0]){
translate([0,-20-9,0])difference(){
union(){
translate([-38.25+14-13.9,-70+30-5,22.5])rotate([-90,0,0])cylinder(r=17.5/2,h=23+3);
translate([-38.25+14-13.9,-70+30.-5,22.5+3.8])cube([31,11+5,3.7+1.25]);
}
//cylinder(r=7.4,h=sl+4,$fn=6);
//translate([-38.25+14-13.9,-70+30,22.5])rotate([-90,0,0])cylinder(r=11.4/2,h=41,$fn=6);
translate([-38.25+14-13.9,-70+30-10+8,22.5])rotate([-90,0,0])cylinder(r=7.25,h=28,$fn=6);
translate([-38.25+14-13.9,-70+30-30,22.5])rotate([-90,0,0])cylinder(r=8.7/2,h=241);
translate([-38.25+14-13.9+13.7,-70+34-4.8,22.5+3.8-30])cylinder(r=3.7/2,h=120);
translate([-38.25+14-13.9+13.7+13,-70+34-4.8,22.5+3.8-30])cylinder(r=3.7/2,h=120);
}
}
}

module cell_18650() {
    // body toward -X, cap toward +X; origin is the score plane.
    color(C_CELL)
    translate([cell_neg_x, 0, 0]) rotate([0,90,0]) {
        cylinder(h=cell_len, d=cell_dia);                        // can body
        translate([0,0,cell_len]) cylinder(h=1.2, d=cap_face_dia); // + cap disc
    }
}


module mgn9_block_decapper_base(){
translate([-100,22,-30-10])color("lime")difference(){
union(){
translate([12,0,0])cube([30,23,10]);
translate([0+14,-10,0])cube([15,23+20,5]);
}

translate([12,0,0]){
translate([9.5,4,-0])cylinder(d=2.8,h=30,$fn=50);
translate([9.5,4+15,-0])cylinder(d=2.8,h=30,$fn=50);
}
translate([14,0,0]){
translate([9.5-2,4-9,0])cylinder(d=3.5,h=30,$fn=50);
translate([9.5-2,4+15+9,0])cylinder(d=3.5,h=30,$fn=50);
}

}
}

module mgn9_block_decapper(){
translate([-100,22,-30])color("lightblue")difference(){
union(){
//translate([12,0,0])cube([30,23,16.2]);
translate([12,0,0])cube([30,23,5]);
translate([7.5+20,7-7-4,0])cube([17+32,22+12,5]);
translate([7.5+64,7-7-4,0])cube([5,22+12,40]);
}
translate([7.5+63.3,7-7-4+17.4,22.3])rotate([0,90,0])cylinder(d=23.5,h=30,$fn=50);

hull(){
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3+5])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
}
translate([0,26,0])hull(){
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3+5])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
}
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3-26])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
translate([7.5+63.3-3,7-7-4+17.4-15+2.1+26,35.3-26])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
/*
*/
translate([12,0,0]){
translate([9.5,4,-2])cylinder(d=3.5,h=30,$fn=50);
translate([9.5,4+15,-2])cylinder(d=3.5,h=30,$fn=50);
/*
#translate([0,0,5]){
translate([9.5,4,-0.2])cylinder(d=7.5,h=30,$fn=50);
translate([9.5,4+15,0])cylinder(d=7.5,h=30,$fn=50);
}
*/


}
}
}

module mgn9_block_makelathe(){
translate([-100,22,-30])color("lightblue")difference(){
union(){
translate([12,0,0])cube([30,23+6,16.2]);
translate([7.5+20,7-7-4,0])cube([17+12,22+12,5]);
translate([7.5+20+15,7-7-4,0])cube([17+12-15,22+12,40]);

//#translate([7.5+64,7-7-4,0])cube([5,22+12,40]);
}
translate([37,-22-11,30])translate([15-1,45,-8])rotate([0,90,0])cylinder(d=22.1,h=6,$fn=50);
translate([7.5+63.3,7-7-4+17.4,22.3])rotate([0,90,0])cylinder(d=23.5,h=30,$fn=50);

/*
hull(){
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3+5])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
}
translate([0,26,0])hull(){
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3+5])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
}
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3-26])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
translate([7.5+63.3-3,7-7-4+17.4-15+2.1+26,35.3-26])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
*/

/*
for(i=[-1:5]){
#translate([9.5-1.7+95+1.25-(i*20),4+7.45,-25])cylinder(d=2.8,h=230,$fn=50);
}
*/

translate([12,0,0]){

translate([9.5-1.7,4+7.45,-2])cylinder(d=2.8,h=30,$fn=50);
translate([9.5-1.7,4+7.45+13,-2])cylinder(d=2.8,h=30,$fn=50);

translate([9.5,4,-2])cylinder(d=3.5,h=30,$fn=50);
translate([9.5,4+15,-2])cylinder(d=3.5,h=30,$fn=50);
translate([0,0,5]){
translate([9.5,4,-0.2])cylinder(d=7.5,h=30,$fn=50);
translate([9.5,4+15,0])cylinder(d=7.5,h=30,$fn=50);
}
}


}
}












module battery_18650_holder(){
color("peru")translate([-20,35.525,0-1.775])
difference(){
union(){
//translate([-15,-15,-13.7])cube([30,30,10]);
//translate([-15+11,-15,-13.7-7])cube([19,30,10]);
translate([0,0,-6])rotate([0,90,0])cylinder(d1=15,d2=25,h=20,$fn=50);
translate([20,0,-6])rotate([0,90,0])cylinder(d=25,h=20,$fn=50);
}
/*
translate([-10.3,7.5,-6])rotate([0,0,0])cylinder(d=3.8,h=20,$fn=50);
translate([-10.3,7.5-13,-6])rotate([0,0,0])cylinder(d=3.8,h=20,$fn=50);
*/

translate([-5,0,0])hull(){
translate([30,-0.2,-6+0])rotate([0,90,0])cylinder(d=18.4,h=20,$fn=50);
translate([30,-0.2,-6+20])rotate([0,90,0])cylinder(d=18.4,h=20,$fn=50);
}
translate([0,0,-6])rotate([0,90,0])cylinder(d=5,h=20,$fn=50);
translate([4,0,-6])rotate([0,0,0])cylinder(d=2.8,h=20,$fn=50);
translate([4,0,-6])rotate([90,0,0])cylinder(d=2.8,h=20,$fn=50);
}
}


module bearing_6204(){

// OpenSCAD Model: Standard 6204 Ball Bearing
// Dimensions: 20mm (Bore) x 47mm (OD) x 14mm (Width)

$fn = 100; // High resolution for smooth curves

// 6204 Dimensions (in mm)
bore_d = 20;
outer_d = 47;
width = 14;

// Ball and Track Details
ball_d = 7.94; // Standard ball size for 6204 (~5/16 inch)
pitch_d = (outer_d + bore_d) / 2; // 33.5mm center track diameter
num_balls = 8; 

module inner_ring() {
    difference() {
        cylinder(h = width, d = pitch_d - (ball_d * 0.8), center = true);
        cylinder(h = width + 2, d = bore_d, center = true); // Inner hole
        // Ball race groove
        rotate_extrude() translate([pitch_d / 2, 0, 0]) circle(d = ball_d + 0.2);
    }
}

module outer_ring() {
    difference() {
        cylinder(h = width, d = outer_d, center = true);
        cylinder(h = width + 2, d = pitch_d + (ball_d * 0.8), center = true);
        // Ball race groove
        rotate_extrude() translate([pitch_d / 2, 0, 0]) circle(d = ball_d + 0.2);
    }
}


module balls() {
    for (i = [0 : num_balls - 1]) {
        rotate([0, 0, i * (360 / num_balls)])
        translate([pitch_d / 2, 0, 0])
        sphere(d = ball_d, $fn = 50);
    }
}

// Assemble the bearing
color("Silver") inner_ring();
color("Silver") outer_ring();
color("Gold") balls(); // Colored gold just to make the balls highly visible


}


module bearing_608(){
// OpenSCAD Model: Standard 608 Ball Bearing
// Dimensions: 8mm (Bore) x 22mm (OD) x 7mm (Width)

$fn = 100; // High resolution for smooth curves

// 608 Dimensions (in mm)
bore_d = 8;
outer_d = 22;
width = 7;

// Ball and Track Details
ball_d = 3.969; // Standard 5/32" ball size for 608 bearings
pitch_d = (outer_d + bore_d) / 2; // 15mm center track diameter
num_balls = 7; 

module inner_ring() {
    difference() {
        cylinder(h = width, d = pitch_d - (ball_d * 0.8), center = true);
        cylinder(h = width + 2, d = bore_d, center = true); // Inner hole
        // Ball race groove
        rotate_extrude() translate([pitch_d / 2, 0, 0]) circle(d = ball_d + 0.1);
    }
}

module outer_ring() {
    difference() {
        cylinder(h = width, d = outer_d, center = true);
        cylinder(h = width + 2, d = pitch_d + (ball_d * 0.8), center = true);
        // Ball race groove
        rotate_extrude() translate([pitch_d / 2, 0, 0]) circle(d = ball_d + 0.1);
    }
}

module balls() {
    for (i = [0 : num_balls - 1]) {
        rotate([0, 0, i * (360 / num_balls)])
        translate([pitch_d / 2, 0, 0])
        sphere(d = ball_d, $fn = 40);
    }
}

// Assemble the bearing
color("Silver") inner_ring();
color("Silver") outer_ring();
color("Gold") balls(); // Colored gold to make the balls highly visible
}

module battery_makelathe_cap(){
difference(){
union(){
color("red")translate([-7,45,-8])rotate([0,90,0])cylinder(d=12,h=6.5,$fn=50);
color("red")translate([-7-5,45,-8])rotate([0,90,0])cylinder(d=22,h=6.5,$fn=50);
}
translate([-7-5-4,45,-8])rotate([0,90,0])cylinder(d=18.5,h=6.5,$fn=50);
translate([-7-5-4,45,-8])rotate([0,90,0])cylinder(d=8.1,h=56.5,$fn=50);
}
}





