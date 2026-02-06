/* [Ferrule Parameters] (for TPU print or reference to P-343) */
tubing_od = 3.0;
ferrule_id = tubing_od - 0.3; // Interference grip
ferrule_od = 5.8;           // Slightly larger to match typical ETFE
ferrule_length = 5.0;
ferrule_taper_height = 2.5;

ferrule();

module ferrule() {
    difference() {
        union() {
            cylinder(h=ferrule_length, d=ferrule_od, $fn=70);
            translate([0,0,ferrule_length])
                cylinder(h=ferrule_taper_height, d1=ferrule_od, d2=ferrule_od*0.65, $fn=70);
        }
        cylinder(h=ferrule_length + ferrule_taper_height + 2, d=ferrule_id, $fn=70);
    }
}


