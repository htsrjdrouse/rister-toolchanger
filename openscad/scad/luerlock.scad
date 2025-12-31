//male_luerlock();
//female_luerlock();

module female_luerlock(){

// Female Luer Lock to 1/16" Barb Adapter (e.g., Value Plastics FTL10)
luer_cone_len = 7.5;      // mm (ISO L1)
luer_cone_d1 = 4.0;       // mm major at base
luer_cone_d2 = 3.4;       // mm minor at tip
thread_len = 6.0;         // mm (ISO lock sleeve)
thread_d = 7.0;           // mm outer
thread_pitch = 0.75;      // mm (M6x0.75 ISO)
barb_len = 5.0;           // mm total barb section
barb_d_base = 3.2;        // mm body
barb_serrations = 2;      // number
barb_d_max = 2.2;         // mm max serration OD
barb_d_min = 1.6;         // mm min (for 1/16" ID tubing)
bore_id = 1.5;            // mm straight bore

difference() {
    union() {
        // Luer lock sleeve (cylindrical with threads)
        cylinder(h=thread_len, d=thread_d, center=false);
        // Tapered female cone (internal, but outer body)
        translate([0,0,thread_len]) cylinder(h=luer_cone_len, d1=luer_cone_d1, d2=luer_cone_d1, center=false);
        // Barb body
        translate([0,0,thread_len + luer_cone_len]) cylinder(h=barb_len, d=barb_d_base, center=false);
        // Barb serrations (external ridges)
        for (i = [1:barb_serrations]) {
            translate([0,0,thread_len + luer_cone_len + i*(barb_len/barb_serrations)]) {
                rotate_extrude() translate([barb_d_max/2 - 0.2,0]) circle(d=0.4);  // Ridge cross-section
            }
        }
    }
    // Central bore: Threaded section + tapered cone + barb
    translate([0,0,-0.1]) cylinder(h=thread_len + 0.2, d=bore_id, center=false);  // Straight through lock
    translate([0,0,thread_len - 0.1]) cylinder(h=luer_cone_len + 0.2, d1=luer_cone_d2, d2=luer_cone_d1, center=false);  // Tapered female
    translate([0,0,thread_len + luer_cone_len - 0.1]) cylinder(h=barb_len + 0.2, d=barb_d_min, center=false);  // Barb bore
}


}


module male_luerlock(){

// Male Luer Lock to 1/16" Barb Adapter (e.g., Qosina 89352)
luer_cone_len = 7.0;      // mm (ISO L1)
luer_cone_d1 = 3.95;      // mm major at base
luer_cone_d2 = 3.35;      // mm minor at tip
lock_collar_len = 4.0;    // mm (optional rotating collar)
lock_collar_d = 7.5;      // mm outer
barb_len = 5.0;           // mm
barb_d_base = 3.2;        // mm body
barb_serrations = 2;      // number
barb_d_max = 2.2;         // mm max OD
barb_d_min = 1.6;         // mm min
bore_id = 1.5;            // mm straight bore

difference() {
    union() {
        // Male cone body
        cylinder(h=luer_cone_len, d1=luer_cone_d1, d2=luer_cone_d2, center=false);
        // Lock collar (threaded hub)
        translate([0,0,luer_cone_len]) cylinder(h=lock_collar_len, d=lock_collar_d, center=false);
        // Barb body
        translate([0,0,luer_cone_len + lock_collar_len]) cylinder(h=barb_len, d=barb_d_base, center=false);
        // Barb serrations
        for (i = [1:barb_serrations]) {
            translate([0,0,luer_cone_len + lock_collar_len + i*(barb_len/barb_serrations)]) {
                rotate_extrude() translate([barb_d_max/2 - 0.2,0]) circle(d=0.4);
            }
        }
    }
    // Central bore through all sections
    translate([0,0,-0.1]) cylinder(h=luer_cone_len + lock_collar_len + barb_len + 0.2, d=bore_id, center=false);
}

}


