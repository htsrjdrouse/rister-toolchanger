// CABLING SYSTEM (Cable management and connections)
// Voron-style keystone jacks and XT60 power connectors

module cabling_system() {

    /*
    translate([873-151,85,0])rotate([0,0,90]){
    //translate([558.5,279.7,147.81])#rotate([0,90,0])import("voron_keystone_inside_fix.stl");
    translate([576,278.6,168.5])rotate([0,90,0])import("voron_keystone_outside_fix.stl");
    translate([576+0.5,278.6,168.5])rotate([0,90,0])import("voron_keystone_outside_fix.stl");
    translate([576+1,278.6,168.5])rotate([0,90,0])import("voron_keystone_outside_fix.stl");
    difference(){
    translate([582,437,168.5-191.2+5.5])rotate([0,90,0])cube([15.5,16.5,4]);
    translate([581-10,445,168.5-191.2-2])rotate([0,90,0])#cylinder(d=11.7,h=30,$fn=100);
    }
    }
    */


    /*
    */
    /*
    // Keystone jacks - Inside mounting (5 units)
    //import("../stls/Cabling/voron_keystone_inside.stl");
    //import("../stls/Cabling/voron_keystone_inside_1.stl");
    //import("../stls/Cabling/voron_keystone_inside_2.stl");
    //import("../stls/Cabling/voron_keystone_inside_3.stl");
    //import("../stls/Cabling/voron_keystone_inside_4.stl");
    */ 

    /*
    */
    import("../stls/Cabling/voron_keystone_inside_fix_0.stl");
    //import("../stls/Cabling/voron_keystone_inside_fix_1.stl");
    import("../stls/Cabling/voron_keystone_inside_fix_2.stl");
    import("../stls/Cabling/voron_keystone_inside_fix_3.stl");
    import("../stls/Cabling/voron_keystone_inside_fix_4.stl");

    /*  
    */
    import("../stls/Cabling/voron_keystone_outside_fix_0_fix.stl");
    //import("../stls/Cabling/voron_keystone_outside_fix_1.stl");
    import("../stls/Cabling/voron_keystone_outside_fix_2_fix.stl");
    import("../stls/Cabling/voron_keystone_outside_fix_3_fix.stl");
    import("../stls/Cabling/voron_keystone_outside_fix_4_fix.stl");


    /*
    import("../stls/Cabling/voron_keystone_outside_fix_4.stl");
    */

    /* 
    // Keystone jacks - Outside mounting (5 units)
    //import("../stls/Cabling/voron_keystone_outside.stl");
    //import("../stls/Cabling/voron_keystone_outside_1.stl");
    //import("../stls/Cabling/voron_keystone_outside_2.stl");
    //import("../stls/Cabling/voron_keystone_outside_3.stl");
    //import("../stls/Cabling/voron_keystone_outside_4.stl");
    */
    // Power connector
    import("../stls/Cabling/XT60_v2.stl");
}
