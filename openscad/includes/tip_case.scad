// TIP CASE SYSTEM (Pipette tip storage)
// Bayonet-style tip case holders and T-slot mounts
//include <../scad/luerlock_syringe_dispenser_model_18mm.scad>
include <../scad/pipette_process.scad>



module tip_case_system() {

    translate([0,31.5,0])import("../stls/TipCase/slotdie_tipcase_holder_18mm.stl");
   translate([0,-30+25,0])import("../stls/TipCase/luerlock_pipette_tipcase_holder_18mm.stl");
   import("../stls/TipCase/luerlock_tipcase_makesquare_18mm.stl");
   import("../stls/TipCase/luerlock_tipcase_makesquare_18mm_1.stl");
   color("silver")translate([-32,-14,0]){
   import("../stls/TipCase/luerlock_tipcase_tslot20_100_A.stl");
   translate([32,0,0])import("../stls/TipCase/luerlock_tipcase_tslot20_100_B.stl");
   }
    translate([0,-20,0])import("../stls/TipCase/bayonet_pipette_tipcase_clamp.stl");
   //# translate([366+50,350.5,0])rotate([0,0,0])bayonet_pipette_tipcase_clamp_50mmstandoff();
   /*
   */
   translate([-32,-14+25,0])color("pink")translate([124.3,-64.7,-9])add_luerlockmodule();
   translate([-32.2,-14+25-36,10])color("pink")translate([124.3,-64.7,-9])add_luerlockmodule_slotdie();
   
    /*
    // Tipcase clamp
    import("../stls/TipCase/bayonet_pipette_tipcase_clamp.stl");
    translate([0,20,0]){
    // Luerlock tip case components
    translate([0,-5,0])import("../stls/TipCase/luerlock_pipette_tipcase_holder_1.stl");
    //#translate([0,5,0])import("../stls/TipCase/luerlock_pipette_tipcase_holder.stl");
    //translate([0,0,0])import("../stls/TipCase/1_luerlock_tipcase_makesquare.stl")
    //import("../stls/TipCase/luerlock_tipcase_makesquare.stl");
    import("../stls/TipCase/luerlock_tipcase_makesquare_set.stl");
    // T-slot 20mm tip case mounts (100mm length)
    import("../stls/TipCase/luerlock_tipcase_tslot20_100_A.stl");
    import("../stls/TipCase/luerlock_tipcase_tslot20_100_B.stl");
    }
    */

}

module add_luerlockmodule_slotdie(){

     translate([0,31,6])import("../stls/luerlock_pipette_assy/p200_lts.stl");
     translate([0,31,6])import("../stls/luerlock_pipette_assy/slot_die_4channel.stl");

}

module add_luerlockmodule(){
     translate([0,31,6])import("../stls/luerlock_pipette_assy/luer_lock_case_lid_18mm.stl");
     translate([0,31,6])import("../stls/luerlock_pipette_assy/luerlock_nozzle_case_18mm.stl");
     translate([0,31,6])import("../stls/luerlock_pipette_assy/luerlock_nozzle_bottom_18mm.stl");
   
     color("white")translate([-1,32,0])import("../stls/luerlock_pipette_assy/p200_LTS_flexpart_tubing_18mm.stl");
     color("white")translate([0,32.5,2])import("../stls/luerlock_pipette_assy/luerlock_connector_18mm.stl");
     color("lightgreen")translate([0,32,4])import("../stls/luerlock_pipette_assy/pipette_18g_set.stl");
     translate([0,31.9,3.5])import("../stls/luerlock_pipette_assy/doctor_blade_4pipette_18mm.stl");

}

