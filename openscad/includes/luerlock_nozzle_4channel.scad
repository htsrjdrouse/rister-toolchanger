// LUER LOCK NOZZLE 4-CHANNEL (Liquid dispenser nozzle assembly)
// LUER LOCK nozzle components and tubing connections

module luerlock_nozzle_4channel() {
     translate([0,32,0])import("../stls/luerlock_pipette_assy/luer_lock_case_lid.stl");
     translate([0,35,-23])import("../stls/luerlock_pipette_assy/luerlock_nozzle_case.stl");
     translate([0,35,-23])import("../stls/luerlock_pipette_assy/luerlock_nozzle_bottom.stl");
     color("white")translate([-1,32,0])import("../stls/luerlock_pipette_assy/p200_LTS_flexpart.stl");
     color("white")translate([-1,32,0])import("../stls/luerlock_pipette_assy/tyco_syringe_barrel_luerlock.stl");
     color("lightgreen")translate([0,32,0])import("../stls/luerlock_pipette_assy/pipette_25g_set.stl");
     /*
     translate([110,4,-10])import("../stls/luerlock_pipette_assy/luer_lock_case_lid.stl");
     translate([110,7,-33])import("../stls/luerlock_pipette_assy/luerlock_nozzle_case.stl");
     translate([110,7,-33])import("../stls/luerlock_pipette_assy/luerlock_nozzle_bottom.stl");
     translate([109,4,-10])import("../stls/luerlock_pipette_assy/p200_LTS_flexpart.stl");
     translate([109,4,-10])import("../stls/luerlock_pipette_assy/tyco_syringe_barrel_luerlock.stl");
     translate([110,4,-10])import("../stls/luerlock_pipette_assy/pipette_25g_set.stl");
     */

}
