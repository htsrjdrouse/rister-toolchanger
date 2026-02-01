// LUER LOCK NOZZLE 4-CHANNEL (Liquid dispenser nozzle assembly)
// LUER LOCK nozzle components and tubing connections

module luerlock_nozzle_4channel() {
    translate([0,19,0]){
     import("../stls/luerlock_pipette_assy/luer_lock_case_lid.stl");
     import("../stls/luerlock_pipette_assy/luerlock_nozzle_bottom.stl");
     import("../stls/luerlock_pipette_assy/luerlock_nozzle_case.stl");
     import("../stls/luerlock_pipette_assy/p200_LTS_flexpart.stl");
     import("../stls/luerlock_pipette_assy/tyco_syringe_barrel_luerlock.stl");
    }

}
