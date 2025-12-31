// Assembly of Printed Eppendorf p1000 Tip + p10 Wick Holder System
// For FASnI₃ Ink Deposition with Glass Fiber Wick
// For Solgel Ink Deposition with Glass Fiber Wick which is twice as wide
// p1000: 71 mm long, 8.5 mm OD top to 4 mm OD bottom
// p10: 34 mm, 6 mm OD to 0.75 mm OD
// Wick Holder: 10 mm long, wider top (3-2 mm OD) fits p10, narrow channel for wick


p10_length = 34;            // mm
p10_top_od = 6;             // mm outer diameter top
p10_top_id = 3.5;           // mm inner diameter top
p10_bottom_od = 0.75;       // mm outer diameter bottom
p10_bottom_id = 0.35;       // mm inner diameter bottom

print_nozzle_holder_length = 17;            // mm
print_nozzle_holder_top_od = 4;             // mm outer diameter top
print_nozzle_holder_top_id = 3.5;           // mm inner diameter top
print_nozzle_holder_bottom_od = 2.7;       // mm outer diameter bottom
print_nozzle_holder_bottom_id = 0.2;       // mm inner diameter bottom

p200_cut_length = 34;            // mm
p200_cut_top_od = 4.2;             // mm outer diameter top
p200_cut_top_id = 1;           // mm inner diameter top
p200_cut_bottom_od = 0.75;       // mm outer diameter bottom
p200_cut_bottom_id = 0.35;       // mm inner diameter bottom





cantilever_length = 10;     // mm
cantilever_thickness = 0.5; // mm (flexible for 55A)
channel_width = 0.2;        // 200 μm V-channel width
channel_depth = 0.2;        // 200 μm depth
FASnI_wick_diameter = 0.15;       // 150 μm glass fiber strip width
solgel_wick_diameter = 0.5;       // 150 μm glass fiber strip width
insert_fiber = true;        // Toggle to show fiber insertion


//FASnI_pipette_assembly();

module small_pipette_assembly(){
 //translate([0,0,-30])three_mm_tubing();
 //translate([0,0,0])p1000_model_eppendorf();
 translate([0,0,-30]){
 translate([0,0,35])p200_cut_tip();
 //translate([0,0,75])FASnI_wick_holder();
 //color("pink")translate([0,0,83])FASnI_glass_fiber_wick();
 }
}

module smallwick_pipette_assembly(){
 translate([0,0,-30])p1000_tubing();
 translate([0,0,0])p1000_model_eppendorf();
 translate([0,0,0]){
 translate([0,0,45])p10_tip();
 translate([0,0,75])FASnI_wick_holder();
 color("pink")translate([0,0,83])FASnI_glass_fiber_wick();
 }
}


module largewick_pipette_assembly(){
translate([20,0,0]){
translate([0,0,0])p1000_model_eppendorf();
translate([0,0,45])p10_tip();
translate([0,0,75])solgel_wick_holder();
color("lightblue")translate([0,0,83])solgel_glass_fiber_wick();
}
}



// Glass Fiber Wick (Inserted Post-Print)
module FASnI_glass_fiber_wick() {
    if (insert_fiber) {
        color("White")
        rotate([0,90,0])cube([cantilever_length + 2, FASnI_wick_diameter, FASnI_wick_diameter], center = true); // Rectangular strip
    }
}

// Wick Holder Cantilever (Printed with Rebound 55A)
module FASnI_wick_holder(){
difference(){
cylinder(d1=3,d2=2,h=5,$fn=300);
translate([0,0,-0.1])cylinder(d1=1.35,d2=0.2,h=4.3,$fn=300);
translate([0,0,-0.1])cylinder(d=0.1,h=5.2,$fn=300);
translate([0,0,4.3])cylinder(d=0.215,h=1,$fn=300);

//translate([-3.5,0,0])rotate([0,0,45])cylinder(d=10,h=5,$fn=4);

}
}

// Glass Fiber Wick (Inserted Post-Print)
module solgel_glass_fiber_wick() {
    if (insert_fiber) {
        color("White")
        rotate([0,90,0])cube([cantilever_length + 2, solgel_wick_diameter, solgel_wick_diameter], center = true); // Rectangular strip
    }
}

// Wick Holder Cantilever (Printed with Rebound 55A)
module solgel_wick_holder(){
difference(){
cylinder(d1=3,d2=2,h=5,$fn=300);
translate([0,0,-0.1])cylinder(d1=1.35,d2=0.2,h=4.3,$fn=300);
translate([0,0,-0.1])cylinder(d=0.3,h=5.2,$fn=300);
translate([0,0,4.3])cylinder(d=0.55,h=1,$fn=300);

//translate([-3.5,0,0])rotate([0,0,45])cylinder(d=10,h=5,$fn=4);

}
}




// p200_cut Tip Model (Modified for Wick Holder)
module p200_cut_tip() {
 union(){
    color("Lightgreen") {
        difference() {
            cylinder(h = p200_cut_length, r1 = p200_cut_top_od / 2, r2 = p200_cut_bottom_od / 2, $fn = 50);
            translate([0, 0, -0.1])
            #cylinder(h = p200_cut_length + 0.2, r1 = p200_cut_top_id / 2, r2 = p200_cut_bottom_id / 2, $fn = 50);
        }
    }
  }

}

// print nozzlew Tip Model (Modified for Wick Holder)
module print_nozzle_holder() {
 union(){
    color("Lightgreen") {
        difference() {
            cylinder(h = print_nozzle_holder_length, r1 = print_nozzle_holder_top_od / 2, r2 = print_nozzle_holder_bottom_od / 2, $fn = 50);
            translate([0, 0, -0.1])
            #cylinder(h = print_nozzle_holder_length + 0.2, r1 = print_nozzle_holder_top_id / 2, r2 = print_nozzle_holder_bottom_id / 2, $fn = 50);
        }
    }
  }

}






// p10 Tip Model (Modified for Wick Holder)
module p10_tip() {
    color("Lightgreen") {
        difference() {
            cylinder(h = p10_length, r1 = p10_top_od / 2, r2 = p10_bottom_od / 2, $fn = 50);
            translate([0, 0, -0.1])
            cylinder(h = p10_length + 0.2, r1 = p10_top_id / 2, r2 = p10_bottom_id / 2, $fn = 50);
        }
    }
}




module p1000_new(){
 difference(){union(){
 difference(){
  cylinder(d=8.8,h=17,$fn=300);
  translate([0,0,-0.5])cylinder(d=7.5,h=18,$fn=300);
 }
 translate([0,0,17])difference(){
  cylinder(d=7.9,h=38.4,$fn=300);
  translate([0,0,-0.5])cylinder(d=7.5,h=39.4,$fn=300);
 }
 translate([0,0,17+38.4])difference(){
  cylinder(d1=7.6,d2=1.3,h=32.3,$fn=300);
  cylinder(d1=7,d2=0.83,h=32.3,$fn=300);
 }
 }
 }
}


module p1000_tubing(){
color("lightblue")cylinder(r=5/2,h=30,$fn=300);
translate([0,0,-45-3-0])color("lightblue")cylinder(r=3/2,h=55,$fn=300);
}

module three_mm_tubing(){
//color("lightblue")cylinder(r=3/2,h=30,$fn=300);
translate([0,0,-45-3+30-70])color("lightblue")cylinder(r=3/2,h=55+68,$fn=300);
}



module p1000_model_eppendorf(){
rotate([0,0,0]){
difference(){
union(){
color("lightblue")cylinder(r=8.5/2,h=17,$fn=300);
translate([0,0,1])color("black")cylinder(r=8.6/2,h=1,$fn=300);
}
translate([0,0,-0.1])cylinder(r=(8.5-1.5)/2,h=5.12,$fn=300);
translate([0,0,2])cylinder(r=(8.5-1.5)/2,h=2,$fn=300);
translate([0,0,5])cylinder(r=(8.5-1.5)/2,h=2,$fn=300);
translate([0,0,6.9])cylinder(r=(8.5-1.5)/2,h=4.11+6.6,$fn=300);
}
color("lightblue")translate([0,0,11])
difference(){ 
cylinder(r1=7.5/2,r2=7.5/2,h=16.5,$fn=300);
translate([0,0,-0.1])cylinder(r1=(8.5-1.5)/2,r2=(7.5-1)/2,h=16.85+2,$fn=300);
}
color("lightblue")translate([0,0,11+16.5])
difference(){
cylinder(r1=7.25/2,r2=7/2,h=4,$fn=300);
translate([0,0,-0.1])cylinder(r1=(7.25-1)/2,r2=(7-1)/2,h=4.15,$fn=300);
}
color("lightblue")translate([0,0,11+16.5+4])
difference(){
union(){
cylinder(r1=7/2,r2=4/2,h=15,$fn=300);
translate([0,0,15-2-12.5])cylinder(r2=7/2,r1=7/2,h=5,$fn=300);
translate([0,0,15-2-7.5])difference(){
//#cylinder(r2=4.5/2,r1=7/2,h=9.5,$fn=300);
cylinder(r2=3.5/2,r1=7/2,h=10.5,$fn=300);
}
}
translate([0,0,-0.1])cylinder(r1=(7-1)/2,r2=(4-1)/2,h=15+.2,$fn=300);
}

}
}
