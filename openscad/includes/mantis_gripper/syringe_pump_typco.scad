include <bom_multichannel_syringe.scad>

//iverntech_slidermount_motormount();

/*
multichannel_syringe_assy();
multichannel_syringe_module_iverntech();

tyco_syringe_1ml_stack_1piece_multichannel_clamp();
tyco_eight_multichannel_assay();
tyco_multichannel_syringe_module();

syringe_1ml_stack_1piece_multichannel();

translate([0,70,-0.1])syringe_1ml_stack();

iverntech_pump_slider_plate_connect_multichannel();

//color("pink")translate([603,606,230])rotate([90,0,90])oneml_syringe_stepper_linear_m8nut_coupler();

//syringe_1ml();
//multichannel_syringe_assy();
nextgen_syringe1ml_multichannel_assy();
*/
//tuberculin_syringe_1ml();

//tyco kendall monoject
// Tyco Tuberculin Syringe 1ml
// Based on measurements from actual syringe


module tyco_multichannel_syringe_module(){
tyco_eight_multichannel_assay();
translate([-100,160,0])nextgen_syringe1ml_multichannel_assy();
//translate([0,70,-0.1])multichannel_syringe1ml_clamp_luerlock();
multichannel_plunger_clamp();
translate([0,12,0]){
translate([-100,160,0])
//color("gainsboro")
translate([-25.75,123,-30])rotate([90,-90,0])multichannel_syringeshuttle_clipbracket();
}
}



module tyco_iverntech_pump_slider_plate_connect_multichannel(){
translate([-0.3,0,-0.8])difference(){
union(){
translate([-110+54.5+6,-81.5+1.5+40+6.6+3.5-14.5,16+15+6+3])cube([22+5-12,6.5-3,35-15-4-3]);
}
translate([-110+59+5.3+4.5-1,-81.5+1.5+146,36-3.4+10.25+2])rotate([90,90,0])cylinder(r=3.7/2,h=200);
//translate([-110+59+5.3+4.5-1-4.5,-81.5+1.5+146,36-3.4+10.25+2-6])rotate([90,90,0])cylinder(r=2.8/2,h=200);
translate([-110+59+5.3+4.5-1+4.5+3,-81.5+1.5+146,36-3.4+10.25+2+2])rotate([90,90,0])cylinder(r=2.8/2,h=200);


hull(){
translate([-110+59+5.3+4.5-1,-81.5+1.5+146-4-1.5-103.4,36-3.4+10.25+2+0])rotate([90,90,0])cylinder(r=10.5/2,h=1.5);
translate([-110+59+5.3+4.5-1,-81.5+1.5+146-4-1.5-103.4,36-3.4+10.25+2+10])rotate([90,90,0])cylinder(r=10.5/2,h=1.5);
}
hull(){
translate([-110+59+5.3+4.5-1,-81.5+1.5+146-4-1.5-7,36-3.4+10.25+2+0])rotate([90,90,0])cylinder(r=4.5/2,h=100);
translate([-110+59+5.3+4.5-1,-81.5+1.5+146-4-1.5-7,36-3.4+10.25+2+10])rotate([90,90,0])cylinder(r=4.5/2,h=100);
}

}
}




module tyco_syringe_1ml_stack_1piece_multichannel_clamp(){
difference(){union(){
//clamp part
translate([-0.3-14,0+146-2,-0.8])
translate([-110+54.5+6-14,-81.5+1.5+40+6.6+3.5-14.5,16+15+6+3])cube([5,6.5-3,35-15-4-3]);
translate([-0.3-14-(8*14)-3.5,0+146-2,-0.8])
translate([-110+54.5+6-14,-81.5+1.5+40+6.6+3.5-14.5,16+15+6+3])cube([5,6.5-3,35-15-4-3]);
//attach part
//translate([-0.3-14-(8.6*13),0+146-2-7.4,-1])translate([-110+54.5+6-14-3-1,-81.5+1.5+40+6.6+3.5-14.5+2.3,16+15+6])cube([5+3+1,6.5-1.5,35-15-4]);
//translate([-85-(9*14),105.5,44])translate([0-4+10.5+10+1,-5+2.5-22.5-4,-8])cube([14+15-10-10-1,10+5+4,4]);
for(i=[0:7]){
//color("")translate([-85-(i*14),105.5,44])rotate([-0,0,-90])syringe_1ml_plungerclip_1piece();
//translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
translate([0-42.5-(i*14),-4+230-80-2,0])tyco_iverntech_pump_slider_plate_connect_multichannel();
}
}
translate([-77.5-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100,$fn=30);
translate([-77.5-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100, $fn=30);
translate([-77.5-(8*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100, $fn=30);
translate([-77.5-(8*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100, $fn=30);
for(i=[0:7]){
//translate([18-(i*14),0,-8])cylinder(r=3.7/2,h=40);
/*

translate([-85-(i*14),105.5,44])rotate([-0,0,-90])
for(i=[0:10]){
translate([-5,0,0+i])rotate([90,-0,90])cylinder(r=4/2,h=10);
translate([5,0,0+i])rotate([90,-0,90])cylinder(r=10.2/2,h=1.75);
}
*/
translate([-14,0,0]){
translate([-77.5-(i*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100, $fn=30);
translate([-77.5-(i*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100,$fn=30);
}
translate([-77.5-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100,$fn=30);
translate([-77.5-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100,$fn=30);
translate([-77.5-(8*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100,$fn=30);
translate([-77.5-(8*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100,$fn=30);
}
}
}













module tyco_eight_multichannel_assay(){
translate([0,20,0]){
difference(){
union(){
translate([0,70,-0.1])tyco_multichannel_syringe1ml_clamp();
translate([0,30-20,0])tyco_multichannel_syringe1ml_clamp_top_luerlock();
translate([0,70,-0.1])tyco_multichannel_syringe1ml_clamp_luerlock();
}
//translate([-160,220-60,0])cube([150,250,150]);
}
}
}



module tyco_multichannel_syringe1ml_clamp_top_luerlock(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
translate([0,2+7.25+60-1,10/2+10])rotate([0,0,0])cube([120,13/2+1,15/2+2-3]);
}
}
for(i=[0:7]){
//translate([-183+(i*14),170+60,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170-50+60,44])rotate([0,90,90])cylinder(r=(6.5+0.3)/2,h=100);
if(i>0){
translate([-77.5-(i*14)-0.5,175+60.6,0])cylinder(r=3.7/2,h=150);
}else{ 
translate([-77.5-(i*14),175.6+60,0])cylinder(r=3.7/2,h=150);
}
}
translate([-77.5-(8*14)-1.7,175.6+60,0])cylinder(r=3.7/2,h=150);
}
}


module tyco_multichannel_syringe1ml_clamp_luerlock(){
difference(){
union(){
translate([-183-13/2-5,170-13/2+60,30]){
translate([0,2+6.9,0])rotate([0,0,0])cube([120,13.9-7,15]);
translate([69,2-15-1,0])rotate([0,0,0])cube([18+8,23+20+1,5]);
}
}
translate([-120,220-60+60,0])cylinder(r=3.7/2,h=100);
translate([-120+15,220-60+60,0])cylinder(r=3.7/2,h=100);
translate([-120+7.5,220-60+23+60,0])cylinder(r=3.7/2,h=100);
for(i=[0:7]){
//translate([-183+(i*14),170,44])rotate([0,90,90])tuberculin_syringe_1ml();
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=(6.5+0.3)/2,h=200);

/*
if(i>0){
translate([-77.5-(i*14)-0.5,175.6+60,0])cylinder(r=2.8/2,h=150);
}else{
translate([-77.5-(i*14),175.6+60,0])cylinder(r=2.8/2,h=150);
}
*/
}
//translate([-77.5-(8*14)-1.7,175.6+60,0])cylinder(r=2.8/2,h=150);
}
}



module tyco_multichannel_syringe1ml_clamp(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
translate([0,2,0])rotate([0,0,0])cube([120,13.9,15]);
translate([69,2-15,0])rotate([0,0,0])cube([18+8,23+20,5]);
}
}
translate([-120,220-60,0])cylinder(r=3.7/2,h=100);
translate([-120+15,220-60,0])cylinder(r=3.7/2,h=100);
translate([-120+7.5,220-60+23,0])cylinder(r=3.7/2,h=100);
translate([-120,220-60,32])cylinder(r=9.7/2,h=10);
translate([-120+15,220-60,32])cylinder(r=9.7/2,h=10);
translate([-120+7.5,220-60+23,32])cylinder(r=9.7/2,h=10);
for(i=[0:7]){
//translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170,44])rotate([0,90,90])tuberculin_syringe_1ml();
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=6/2,h=100);
if(i>0){
translate([-77.5-(i*14)-0.5,175.6,0])cylinder(r=2.8/2,h=150);
}else{
translate([-77.5-(i*14),175.6,0])cylinder(r=2.8/2,h=150);
}
}
translate([-77.5-(8*14)-1.7,175.6,0])cylinder(r=2.8/2,h=150);
}
}



module tuberculin_syringe_1ml(
    total_length = 155,
    barrel_od = 6.5+0.3,
    barrel_id = 5.0,
    plunger_head_dia = 4.8,
    flange_length = 19,
    flange_width = 12,
    flange_thick = 2.2,
    luer_lock_male = true
) {
    
    barrel_length = 73; // Approximate active barrel length
    luer_length = 2;
    luer_od = 4;
    luer_taper_length = 6;
    color("lightblue")cylinder(d=3,h=130,$fn=30); 
    color("white", 0.7) {
        // Main barrel
        difference() {
            cylinder(h=barrel_length, d=barrel_od, $fn=32);
            translate([0, 0, -0.1])
                cylinder(h=barrel_length+0.2, d=barrel_id, $fn=32);
        }
        
        // Luer lock connector
        translate([0, 0, barrel_length]) {
            // Tapered portion
            cylinder(h=luer_taper_length, d1=9, d2=9, $fn=32);
            
            // Threaded luer lock (simplified external threads)
            translate([0, 0, luer_taper_length])
                cylinder(h=luer_length, d=luer_od, $fn=32);
        }
        
        // Finger flanges at base
        translate([0, 0, 0]) {
            difference() {
                hull() {
                    translate([-flange_length/2, -flange_width/2, 0])
                        cube([flange_length, flange_width, flange_thick]);
                    cylinder(h=2, d=barrel_od, $fn=32);
                }
                // Center hole for barrel
                translate([0, 0, -0.1])
                    cylinder(h=2.2, d=barrel_id, $fn=32);
            }
        }
    }
    
    // Plunger
    plunger_extension = total_length - barrel_length - 10-2.5;
    
    color("gray", 0.8) {
        translate([0, 0, -plunger_extension]) {
            // Plunger rod
            cylinder(h=plunger_extension, d=1.5, $fn=16);
            
            // Plunger head/seal
            translate([0, 0, plunger_extension])
                cylinder(h=8, d=plunger_head_dia, $fn=32);
            
            // Plunger thumb rest
            translate([0, 0, -1]) {
                cylinder(h=2, d=10.1, $fn=32);
            }
        }
    }
}


