// KLICKY PROBE SYSTEM
// Klicky probe dock and magnetic probe components

module klicky_probe() {
    /*
    // Dock mount
    difference(){
    union(){
    import("../stls/Klicky/Dock_mount_fixed_v3.stl");
    translate([106,679.6935,350])color("pink")cube([36,5,45]);
    }
    hull(){   
    #translate([106+9,679.6935+30,350+18-10])rotate([90,0,0])cylinder(d=5,h=50,$fn=100);
    #translate([106+9,679.6935+30,350+18+15])rotate([90,0,0])cylinder(d=5,h=50,$fn=100);
    } 
    hull(){   
    translate([106+9+18,679.6935+30,350+18-10])rotate([90,0,0])cylinder(d=5,h=50,$fn=100);
    translate([106+9+18,679.6935+30,350+18+15])rotate([90,0,0])cylinder(d=5,h=50,$fn=100);
    } 
    }
    */
    translate([0,31,2])import("../stls/Klicky/Dock_mount_fixed_v4.stl");
    import("../stls/Klicky/dock-front_insert.stl");
    
    // Magnetic probe
    import("../stls/Klicky/mag_probe_screw_mod.stl");
}
