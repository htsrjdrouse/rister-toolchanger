// TIP CASE SYSTEM (Pipette tip storage)
// Bayonet-style tip case holders and T-slot mounts

module tip_case_system() {
    // Tipcase clamp
    import("../stls/TipCase/bayonet_pipette_tipcase_clamp.stl");
    translate([0,20,0]){
    // Luerlock tip case components
    translate([0,-5,0])import("../stls/TipCase/luerlock_pipette_tipcase_holder_1.stl");
    translate([0,5,0])import("../stls/TipCase/luerlock_pipette_tipcase_holder.stl");
    //translate([0,0,0])import("../stls/TipCase/1_luerlock_tipcase_makesquare.stl")
    //import("../stls/TipCase/luerlock_tipcase_makesquare.stl");
    import("../stls/TipCase/luerlock_tipcase_makesquare_set.stl");
    // T-slot 20mm tip case mounts (100mm length)
    import("../stls/TipCase/luerlock_tipcase_tslot20_100_A.stl");
    import("../stls/TipCase/luerlock_tipcase_tslot20_100_B.stl");
    }
}
