// Rister Toolchanger - Clean Organized Build
// Using FreeCAD-exported STLs where available, parametric where useful
include <scad/tslot.inc.scad>


// For STL source documentation, see: stl_source_tracking.scad
// Optional: Uncomment to display source documentation in console
// use <stl_source_tracking.scad>
// generate_readme();

// =============================================================================
// CONFIGURATION
// =============================================================================

// Toggle between FreeCAD STLs and parametric models
USE_FREECAD_STLS = true;
USE_PARAMETRIC_EXTRUSIONS = false;

// =============================================================================
// POSITION OFFSETS
// =============================================================================

// FreeCAD STL assembly offset
FREECAD_OFFSET = [0, -32, 0];

// Parametric extrusion offset
PARAMETRIC_OFFSET = [0, 170 - 1.5 - 15 - 17, 58 - 1.2 - 57];  // [0, 136.5, -0.2]

// X Gantry position (for parametric)
X_GANTRY_X = -30 + 4 + 70 + 1;      // = 45
X_GANTRY_Y = 300 - 129 + 15;         // = 186  
X_GANTRY_Z = 400 - 21.8 - 3 - 15;    // = 360.2
X_GANTRY_LENGTH = 510;

// =============================================================================
// FREECAD STL ASSEMBLY
// =============================================================================

module freecad_assembly() {
    translate(FREECAD_OFFSET) {
        // =====================================================================
        // X-AXIS COMPONENTS
        // =====================================================================
        
        // MGN9H shuttle/carriage (X-axis)
        color("silver")import("stls/mgn9H_shuttle.stl");
        
        // X gantry extrusion (from FreeCAD)
        color("silver")import("stls/HFSB5-2020-510_freecad.stl");
        
        // MGN9 450mm rail assembly (X-axis)
        color("silver")
        import("stls/rister_multi-modal_toolchanger-mgn9_450.stl");
        
        // =====================================================================
        // Y-AXIS COMPONENTS
        // =====================================================================
        
        // Y1 rail assembly
        color("silver")import("stls/HGSB5-2020-660.stl");
        color("silver")import("stls/MGN12_600_y1.stl");
        color("silver")import("stls/MGN12H_shuttle_y1.stl");
        
        // Y2 rail assembly
        color("silver")import("stls/HGSB5-2020-660_5.stl");
        color("silver")import("stls/MGN12_600_y2.stl");
        color("silver")import("stls/MGN12H_shuttle_y2.stl");
        
        // =====================================================================
        // XY JOINTS
        // =====================================================================
        
        import("stls/xy_joint_left_lower_MGN12HHHHHH.stl");
        import("stls/xy_joint_left_upper_MGN12.stl");
        import("stls/xy_joint_right_lower_MGN12HHHHH.stl");
        import("stls/xy_joint_right_upper_MGN12.stl");
        
        // =====================================================================
        // MISUMI EXTRUSIONS - HFSB5 (20x20mm standard)
        // =====================================================================
        color("silver"){
        import("stls/HFSB5-2020-480.stl");
        //import("stls/HFSB5-2020-510.stl");
        
        // 500mm extrusions with accessories
        import("stls/HFSB5-2020-500-LCP-RCP-AV360.stl");
        import("stls/HFSB5-2020-500-LCP-RCP-AV360_1.stl");
        import("stls/HFSB5-2020-500-LCP-RCP-AV360_2.stl");
        import("stls/HFSB5-2020-500-LCP-RCP-AV360_3.stl");
        
        // 550mm extrusions
        import("stls/HFSB5-2020-550.stl");
        import("stls/HFSB5-2020-550_1.stl");
        import("stls/HFSB5-2020-550_2.stl");
        import("stls/HFSB5-2020-550_3.stl");
        
        // 660mm extrusions with accessories
        import("stls/HFSB5-2020-660.stl");
        import("stls/HFSB5-2020-660_7.stl");
        import("stls/HFSB5-2020-660_8.stl");
        import("stls/HFSB5-2020-660-AV335.stl");
        import("stls/HFSB5-2020-660-AV335_1.stl");
        
        // =====================================================================
        // MISUMI EXTRUSIONS - HGSB5 (20x20mm heavy duty)
        // =====================================================================
        
        import("stls/HGSB5-2020-260.stl");
        import("stls/HGSB5-2020-270.stl");
        
        // 660mm heavy duty extrusions with accessories
        import("stls/HGSB5-2020-660_1.stl");
        import("stls/HGSB5-2020-660_2.stl");
        import("stls/HGSB5-2020-660_3.stl");
        import("stls/HGSB5-2020-660_4.stl");
        import("stls/HGSB5-2020-660_6.stl");
        import("stls/HGSB5-2020-660-AV336.stl");
        }
        
        // =====================================================================
        // FRAME CORNERS & BRACKETS
        // =====================================================================
        
        import("stls/corner_a_x2.stl");
        import("stls/corner_a_x2_1.stl");
        import("stls/corner_b_x2.stl");
        import("stls/corner_b_x2_1.stl");
        
        // =====================================================================
        // PANELS & SKIRTS
        // =====================================================================
        
        // Bottom panels
        import("stls/bottom_left_panel.stl");
        import("stls/bottom_right_panel.stl");
        import("stls/top_left_panel.stl");
        import("stls/top_right_panel.stl");
        
        // Side skirts
        import("stls/left_skirt.stl");
        import("stls/front_side_skirt.stl");
        import("stls/back_side_skirt.stl");
        import("stls/right_skirt_powercord.stl");
        
        // =====================================================================
        // REAR BELT BEARING MOUNT - A (Y1 motor assembly)
        // =====================================================================
        
        // Bearings
        import("stls/A/F695-2Z.stl");
        import("stls/A/F695-2Z_1.stl");
        import("stls/A/F695-2Z_2.stl");
        import("stls/A/F695-2Z_3.stl");
        import("stls/A/F695-2Z_4.stl");
        import("stls/A/F695-2Z_5.stl");
        
        // Washers
        import("stls/A/m5_washer.stl");
        import("stls/A/m5_washer_1.stl");
        import("stls/A/m5_washer_2.stl");
        import("stls/A/m5_washer_3.stl");
        import("stls/A/m5_washer_4.stl");
        import("stls/A/m5_washer_5.stl");
        import("stls/A/m5_washer_6.stl");
        
        // Brackets & mounts
        import("stls/A/mod_corner_bracket_long_2020_bottom.stl");
        import("stls/A/mod_corner_bracket_long_2020_top.stl");
        import("stls/A/mod_Motor_Mount_v2Motor_Mount_A_Bottom.stl");
        import("stls/A/mod_Motor_Mount_v2Motor_Mount_A_Top.stl");
        import("stls/A/printed_spacer.stl");
        
        // Motor
        color("black")import("stls/A/nema17.stl");
        
        // =====================================================================
        // REAR BELT BEARING MOUNT - B (Y2 motor assembly)
        // =====================================================================
        
        // Bearings
        import("stls/B/F695-2Z_6.stl");
        import("stls/B/F695-2Z_7.stl");
        import("stls/B/F695-2Z_8.stl");
        import("stls/B/F695-2Z_9.stl");
        import("stls/B/F695-2Z_10.stl");
        import("stls/B/F695-2Z_11.stl");
        
        // Washers
        import("stls/B/m5_washer_7.stl");
        import("stls/B/m5_washer_8.stl");
        import("stls/B/m5_washer_9.stl");
        import("stls/B/m5_washer_10.stl");
        import("stls/B/m5_washer_11.stl");
        import("stls/B/m5_washer_12.stl");
        import("stls/B/m5_washer_13.stl");
        
        // Brackets & mounts
        import("stls/B/mod_corner_bracket_long_2020_bottom_1.stl");
        import("stls/B/mod_corner_bracket_long_2020_top_1.stl");
        import("stls/B/mod_Motor_Mount_v2Motor_Mount_B_Bottom.stl");
        import("stls/B/mod_Motor_Mount_v2Motor_Mount_B_Top.stl");
        import("stls/B/printed_spacer_1.stl");
        
        // Motor
        color("black")import("stls/B/nema17_1.stl");
        
        // =====================================================================
        // Z-AXIS MOTORS & LEAD SCREWS
        // =====================================================================
        
        // Z motors
        color("black"){
        import("stls/Z/nema17001.stl");
        import("stls/Z/nema17_1001.stl");
        import("stls/Z/nema17_2.stl");
        import("stls/Z/nema17_3.stl");
        }
        
        // Lead screws (300mm threaded rods)
        color("silver")import("stls/Z/threaded_rod_300.stl");
        color("silver")import("stls/Z/threaded_rod_300_1.stl");
        color("silver")import("stls/Z/threaded_rod_300_2.stl");
        color("silver")import("stls/Z/threaded_rod_300_3.stl");
        
        // Z stepper mounts
        import("stls/Z/z_stepper_left.stl");
        import("stls/Z/z_stepper_left_1.stl");
        import("stls/Z/z_stepper_right.stl");
        import("stls/Z/z_stepper_right_1.stl");
        
        // =====================================================================
        // ENDSTOPS
        // =====================================================================
        
        import("stls/Endstop/xyendstop_lineax.stl");
        
        // =====================================================================
        // BELT TENSIONERS (CoreXY system)
        // =====================================================================
        
        // Tensioners
        import("stls/BeltTensioner/[a]_tensioner_left_1.stl");
        import("stls/BeltTensioner/[a]_tensioner_right_1.stl");
        
        // Front idlers - A side
        import("stls/BeltTensioner/front_idler_a_x2_1.stl");
        import("stls/BeltTensioner/front_idler_a_x2_2.stl");
        
        // Front idlers - B side
        import("stls/BeltTensioner/front_idler_b_x2_1.stl");
        import("stls/BeltTensioner/front_idler_b_x2_2.stl");
        
        // =====================================================================
        // Z-AXIS CARRIAGES
        // =====================================================================
        
        // Left Z carriages
        import("stls/ZParts/z_carriage_left.stl");
        import("stls/ZParts/z_carriage_left_1.stl");
        
        // Right Z carriages
        import("stls/ZParts/z_carriage_right.stl");
        import("stls/ZParts/z_carriage_right_1.stl");
        
        // =====================================================================
        // TOOLHEAD CARRIAGE (rides on MGN9 X-axis)
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/carriage/
        //   - carriage_v2_3dify.scad (current version)
        //   - carriage_v2.scad (previous iteration)
        //   - carriage.scad (original)
        //   - assembly.scad (assembly reference)
        // 
        // Source Dependencies (imported by .scad files):
        //   - carriage_body_bottom.stl
        //   - carriage_body_middle.stl
        //   - carriage_body_rear.stl
        //   - Back_Plate_Beacon_Cartographer.stl
        //   - Back_Plate_Beacon_Cartographer_guidepin.stl
        //   - 5015_adapter_v2.stl
        //   - 5015AdapterRister.stl
        //   - 5015AdapterRister_mod_channel.stl
        //   - 5015AdapterRister_mod_fanside.stl
        //   - 5015_adapter_standoff.stl
        //   - duct_v2.stl
        //   - Duct_v2_orig.stl
        //   - duct.stl
        //   - DuctRister.stl
        //   - duct_trident_v2.stl
        //   - duct_trident_v2_base.stl
        //   - duct_trident_v2_nozzle.stl
        //   - openbuild_spacer.stl
        //   - Locking_Plate.stl
        //   - locking_plate_guidepin.stl
        //   - Cowl_Klicky.stl
        //   - HGX_Lite_2.0_Mount.stl
        //   - Orbiter_V2_Bambu_TZ_Mount.stl
        //   - daksh_extruder_bambu_mount.stl
        //   - extruder_back.stl
        //   - extruder_front.stl
        //   - carriage_assy.stl
        // 
        // Generated STLs (output from carriage_v2_3dify.scad):
        //   - carriage_body_bottom_trident_v2.stl (below)
        //   - carriage_body_middle_trident_v2.stl (below)
        //   - carriage_body_rear_trident_v2.stl (below)
        //   - carriage_body_top.stl (below)
        //   - CarriageBodyFront_editable_belt_holes.stl (below)
        //   - 5015AdapterRister_longer.stl (below)
        //   - duct_trident_v2_nozzle_10mm_longer.stl (below)
        //   - radial_cooling_5015.stl (below)
        //   - locking_plate_lineux_one.stl (below)
        //   - slider.stl (below)
        // =====================================================================
        
        // Carriage body components
        import("stls/Carriage/carriage_body_bottom_trident_v2.stl");
        import("stls/Carriage/carriage_body_middle_trident_v2.stl");
        import("stls/Carriage/carriage_body_rear_trident_v2.stl");
        import("stls/Carriage/carriage_body_top.stl");
        import("stls/Carriage/CarriageBodyFront_editable_belt_holes.stl");
        
        // Cooling system
        import("stls/Carriage/5015AdapterRister_longer.stl");
        import("stls/Carriage/duct_trident_v2_nozzle_10mm_longer.stl");
        import("stls/Carriage/radial_cooling_5015.stl");
        
        // Toolchanger components
        import("stls/Carriage/locking_plate_lineux_one.stl");
        import("stls/Carriage/slider.stl");
       

 
        // =====================================================================
        // BED ASSEMBLY
        // =====================================================================
        color("silver"){
        // Bed frame extrusions (518mm)
        import("stls/Bed/HFSB5-2020-518.stl");
        import("stls/Bed/HFSB5-2020-518_1.stl");
        
        // Bed frame extrusions (548mm with accessories)
        import("stls/Bed/HFSB5-2020-548-AV103.5-BV444.5.stl");
        import("stls/Bed/HFSB5-2020-548-AV103.5-BV444.5_1.stl");
        
        // Build plate (Voron Trident 350mm)
        import("stls/Bed/voron_trident_350_buildplate.stl");
        }
        // Bed Z mounts
        import("stls/Bed/z_bed_left.stl");
        import("stls/Bed/z_bed_left_1.stl");
        import("stls/Bed/z_bed_right.stl");
        import("stls/Bed/z_bed_right_1.stl");
        
 
        
        // =====================================================================
        // LIQUID DISPENSER TOOL 0 (4-channel pipette system)
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/liquid_dispenser/
        //   - linearactuator.scad
        //   - holder_half.scad
        //   - pipette_process.scad
        //   - pipette_wick_assembly.scad
        //   - fourchannel_pipetteloadingmodule_holder.scad
        //   - rack_renamed.scad
        //   - luerlock.scad
        //   - washstation.scad
        //   - multichannel_cameramount.scad
        //   - bom_multichannel_syringe.scad
        //   - bom_camera.scad
        //   - xyendstop.scad
        //
        // Include Dependencies:
        //   - tslot.inc.scad (T-slot extrusion library)
        //
        // Source Dependencies (STLs imported by .scad files):
        //   - lineux_backplate_for_linearactuator.stl
        //   - ebb36_brd.stl
        //   - Ebb36_sherpa_micro_spacer.stl
        //   - Ebb36_sherpa_micro_spacer_1.stl
        //   - sherpa_micro_ebb_mount.stl
        //   - Sherpa_Micro_Ebb_Mount_.stl
        //   - sled_cap.stl
        //   - sled_bottom_no_limit_switch_protrusion.stl
        //   - carriage_assy.stl
        //   - holder_half_bottom.stl
        //   - holder_half_top.stl
        //   - pinion.stl
        //
        // Subdirectory Dependencies:
        //   - luerlock_components/ (Luer lock fittings library)
        //   - pipetting/ (Pipetting components library)
        //
        // Generated STLs:
        //   (All components below from various .scad sources)
        // =====================================================================
        
        
        translate([0,31,5]){

        // Dock and backplate
        import("stls/LiquidDispenserTool0/dock_body_linearactuator_10mmlonger_3.stl");
        import("stls/LiquidDispenserTool0/lineux_backplate_for_linearactuator_modified.stl");
        import("stls/LiquidDispenserTool0/lineux_backplate_for_linearactuator_modified001.stl");
        
        // Holder components
        import("stls/LiquidDispenserTool0/holder_half_bottom.stl");
        import("stls/LiquidDispenserTool0/holder_half_top.stl");
        
        // Pipette system
        import("stls/LiquidDispenserTool0/pipette_loading_module_rack.stl");
        import("stls/LiquidDispenserTool0/pipettes_rack.stl");
        
        // Linear actuator components
        import("stls/LiquidDispenserTool0/servo_linear_actuator_rack_toolchanger_4channel.stl");
        import("stls/LiquidDispenserTool0/servo_linearactuator.stl");
        import("stls/LiquidDispenserTool0/pinion.stl");
        
        // Sled and cap
        import("stls/LiquidDispenserTool0/sled_bottom_no_limit_switch_protrusion.stl");
        import("stls/LiquidDispenserTool0/tubing_straight_sledcap.stl");
        
        // Tubing and umbilical
        translate([0,-30,-5])import("stls/LiquidDispenserTool0/tubing_to_pipettes_valve_side_umbilical.stl");

	//pipette tubing fix
	import("stls/LiquidDispenserTool0/pipette_tubing_liquidhandler.stl");

        import("stls/LiquidDispenserTool0/umbilical_cord.stl");
        import("stls/LiquidDispenserTool0/umbilical_extrusion_1.stl");
        
        // Tip removal and loading
        translate([-47,-31,0]){
        import("stls/PipetteRemoval/piezo_dispenser_assy_remover.stl");
        import("stls/PipetteRemoval/singlechannel_tipremoval_base.stl");
        }
        // LED components
        translate([-90,-250,-5])color("white"){
        import("stls/LiquidDispenserTool0/led_diffuser_back.stl");
        import("stls/LiquidDispenserTool0/led_diffuser.stl");
        }

       
        }
        
       


        // =====================================================================
        // PEEK NOZZLE 4-CHANNEL (Liquid dispenser nozzle assembly)
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/peek_nozzle/
        //   (Source files TBD - add when identified)
        //
        // Generated STLs:
        //   PEEK nozzle components and tubing connections
        // =====================================================================
        // PEEK nozzle parts
        import("stls/peek_nozzle_4channel/peek_nozzle_part1_4channel.stl");
        import("stls/peek_nozzle_4channel/peek_nozzle_part2_4channel.stl");
        
        import("stls/peek_nozzle_4channel/peek_nozzle_part3_4channel.stl");
        import("stls/peek_nozzle_4channel/peek_nozzle.stl");
        
        
        // Connectors
        import("stls/peek_nozzle_4channel/plastic_polypropylene_connector.stl");
        
        // Silicon tubing components (2mm OD x 1mm ID)
        import("stls/peek_nozzle_4channel/silicon_tubing_od_2mm_id_1mm.stl");
        import("stls/peek_nozzle_4channel/silicon_tubing_od_2mm_id_1mm_stretched.stl");
        import("stls/peek_nozzle_4channel/silicon_tubing_od_2mm_id_1mm_stretched_part.stl");
        
        // Silicon tubing components (4mm OD x 2mm ID)
        import("stls/peek_nozzle_4channel/silicon_tubing_od_4mm_id_2mm.stl");
        import("stls/peek_nozzle_4channel/silicon tubing_od_4mm_id_2mm_stretched_part.stl");
        import("stls/peek_nozzle_4channel/silicon_tubing_od_4mm_id_2mm_stretched_part.stl");
        
        // =====================================================================
        // TIP CASE SYSTEM (Pipette tip storage)
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/tipcase/
        //   (Source files TBD - add when identified)
        //
        // Generated STLs:
        //   Bayonet-style tip case holders and T-slot mounts
        // =====================================================================
        
        // Bayonet tip case components
        import("stls/TipCase/bayonet_pipette_tipcase_clamp.stl");
        import("stls/TipCase/bayonet_pipette_tipcase_holder.stl");
        import("stls/TipCase/bayonet_pipette_tipcase_holder_1.stl");
        import("stls/TipCase/bayonet_pipette_tipcase_makesquare.stl");
        import("stls/TipCase/bayonet_pipette_tipcase_makesquare_1.stl");
        
        // T-slot 20mm tip case mounts (100mm length)
        import("stls/TipCase/tipcase_tslot20_100_A.stl");
        import("stls/TipCase/tipcase_tslot20_100_B.stl");


        // =====================================================================
        // RASPBERRY PI CAMERA TOOL
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/camera_tool/
        //   (Source files TBD - add when identified)
        //
        // Generated STLs:
        // =====================================================================
        // Camera mounts
        import("stls/RaspiCameraTool/arducam_adjuster.stl");
        import("stls/RaspiCameraTool/arducam_lineux.stl");
        import("stls/RaspiCameraTool/arducam_rotate_2mount_adjuster_nut.stl");
        
        // Dock and backplate
        import("stls/RaspiCameraTool/dock.stl");
        import("stls/RaspiCameraTool/lineux_backplate_for_raspberrypi.stl");
        
        // Raspberry Pi case
        import("stls/RaspiCameraTool/raspberrypi_bottom_mod.stl");
        import("stls/RaspiCameraTool/raspberrypi_case_top.stl");
        
        // LED diffusers
        import("stls/RaspiCameraTool/led_diffuser_2.stl");
        import("stls/RaspiCameraTool/led_diffuser_back_2.stl");
        
        // Umbilical
        import("stls/RaspiCameraTool/umbilical_extrusion.stl");

        // =====================================================================
        // EXTRUDER TOOL 0 (Sherpa Micro + Bambu hotend)
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/extruder_tool/
        //   (Source files TBD - add when identified)
        //
        // Generated STLs:
        //   Complete Sherpa Micro extruder with Bambu hotend
        // =====================================================================
        
        // Dock and backplate
        import("stls/ExtruderTool0/dock_body_linearactuator_10mmlonger.stl");
        import("stls/ExtruderTool0/back_plate_positioned.stl");
        
        // Sherpa Micro extruder components
        import("stls/ExtruderTool0/sherpa_micro_bambu_positioned.stl");
        import("stls/ExtruderTool0/sherpa_housing_positioned.stl");
        import("stls/ExtruderTool0/sherpa_cover_positioned.stl");
        import("stls/ExtruderTool0/sherpa_lever_positioned.stl");
        import("stls/ExtruderTool0/sherpa_gear_positioned.stl");
        import("stls/ExtruderTool0/housing_positioned.stl");
        import("stls/ExtruderTool0/lever_arm_positioned.stl");
        
        // Drive cores
        import("stls/ExtruderTool0/shaftdrive_core_positioned.stl");
        import("stls/ExtruderTool0/shimdrive_core_positioned.stl");
        
        // Gears and encoder
        import("stls/ExtruderTool0/filament_gear_positioned.stl");
        import("stls/ExtruderTool0/idler_gear_positioned.stl");
        import("stls/ExtruderTool0/idler_pin_positioned.stl");
        import("stls/ExtruderTool0/Encoder_Left.stl");
        import("stls/ExtruderTool0/Encoder_Right.stl");
        import("stls/ExtruderTool0/[o]_Encoder_Slotted_Wheel.stl");
        
        // Hardware inserts
        import("stls/ExtruderTool0/insert_1_positioned.stl");
        import("stls/ExtruderTool0/insert_2_positioned.stl");
        import("stls/ExtruderTool0/insert_3_positioned.stl");
        import("stls/ExtruderTool0/insert_4_positioned.stl");
        import("stls/ExtruderTool0/insert_5_positioned.stl");
        
        // Bearings
        import("stls/ExtruderTool0/mr85_bearing_1_positioned.stl");
        import("stls/ExtruderTool0/mr85_bearing_2_positioned.stl");
        
        // Fasteners
        import("stls/ExtruderTool0/m3_20mm_bhcs_positioned.stl");
        import("stls/ExtruderTool0/m3_30mm_shcs_1_positioned.stl");
        import("stls/ExtruderTool0/m3_30mm_shcs_2_positioned.stl");
        import("stls/ExtruderTool0/m3_30mm_shcs_3_positioned.stl");
        import("stls/ExtruderTool0/m3_set_screw_positioned.stl");
        import("stls/ExtruderTool0/button_screw_1_positioned.stl");
        import("stls/ExtruderTool0/thumbscrew_positioned.stl");
        
        // Electronics
        import("stls/ExtruderTool0/ebb36_board_positioned.stl");
        import("stls/ExtruderTool0/ebb36_spacer_1_positioned.stl");
        import("stls/ExtruderTool0/ebb36_spacer_2_positioned.stl");
        import("stls/ExtruderTool0/micro_switch_positioned.stl");
        
        // Hotend and cooling
        import("stls/ExtruderTool0/bambu_hotend_positioned.stl");
        import("stls/ExtruderTool0/fan_3010_positioned.stl");
        import("stls/ExtruderTool0/cowl_exo_klicky_positioned.stl");
        import("stls/ExtruderTool0/diffuser.stl");
        
        // Mounts and accessories
        import("stls/ExtruderTool0/sherpa_micro_ebb_mount_ribbon.stl");
        import("stls/ExtruderTool0/sherpa_micro_mount_positioned.stl");
        import("stls/ExtruderTool0/klicky_mount_mod_pcb_clone.stl");
        import("stls/ExtruderTool0/Nozzle_Blocker_Mount_R2_tube_block.stl");
        import("stls/ExtruderTool0/Umbilical_Extrusion_Mount_ribboncable_filamentsensor.stl");


        // =====================================================================
        // EXTRUDER TOOL 1 (Sherpa Micro + Bambu hotend - duplicate)
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/extruder_tool/
        //   (Same sources as ExtruderTool0)
        //
        // Generated STLs:
        //   Duplicate of ExtruderTool0 with _1 suffix
        // =====================================================================

        // Dock and backplate
        import("stls/ExtruderTool1/dock_body_linearactuator_10mmlonger_1.stl");
        import("stls/ExtruderTool1/back_plate_positioned_1.stl");
        
        // Sherpa Micro extruder components
        import("stls/ExtruderTool1/sherpa_micro_bambu_positioned_1.stl");
        import("stls/ExtruderTool1/sherpa_housing_positioned_1.stl");
        import("stls/ExtruderTool1/sherpa_cover_positioned_1.stl");
        import("stls/ExtruderTool1/sherpa_lever_positioned_1.stl");
        import("stls/ExtruderTool1/sherpa_gear_positioned_1.stl");
        import("stls/ExtruderTool1/housing_positioned_1.stl");
        import("stls/ExtruderTool1/lever_arm_positioned_1.stl");
        
        // Drive cores
        import("stls/ExtruderTool1/shaftdrive_core_positioned_1.stl");
        import("stls/ExtruderTool1/shimdrive_core_positioned_1.stl");
        
        // Gears and encoder
        import("stls/ExtruderTool1/filament_gear_positioned_1.stl");
        import("stls/ExtruderTool1/idler_gear_positioned_1.stl");
        import("stls/ExtruderTool1/idler_pin_positioned_1.stl");
        import("stls/ExtruderTool1/Encoder_Left_1.stl");
        import("stls/ExtruderTool1/Encoder_Right_1.stl");
        import("stls/ExtruderTool1/[o]_Encoder_Slotted_Wheel_1.stl");
        
        // Hardware inserts
        import("stls/ExtruderTool1/insert_1_positioned_1.stl");
        import("stls/ExtruderTool1/insert_2_positioned_1.stl");
        import("stls/ExtruderTool1/insert_3_positioned_1.stl");
        import("stls/ExtruderTool1/insert_4_positioned_1.stl");
        import("stls/ExtruderTool1/insert_5_positioned_1.stl");
        
        // Bearings
        import("stls/ExtruderTool1/mr85_bearing_1_positioned_1.stl");
        import("stls/ExtruderTool1/mr85_bearing_2_positioned_1.stl");
        
        // Fasteners
        import("stls/ExtruderTool1/m3_20mm_bhcs_positioned_1.stl");
        import("stls/ExtruderTool1/m3_30mm_shcs_1_positioned_1.stl");
        import("stls/ExtruderTool1/m3_30mm_shcs_2_positioned_1.stl");
        import("stls/ExtruderTool1/m3_30mm_shcs_3_positioned_1.stl");
        import("stls/ExtruderTool1/m3_set_screw_positioned_1.stl");
        import("stls/ExtruderTool1/button_screw_1_positioned_1.stl");
        import("stls/ExtruderTool1/thumbscrew_positioned_1.stl");
        
        // Electronics
        import("stls/ExtruderTool1/ebb36_board_positioned_1.stl");
        import("stls/ExtruderTool1/ebb36_spacer_1_positioned_1.stl");
        import("stls/ExtruderTool1/ebb36_spacer_2_positioned_1.stl");
        import("stls/ExtruderTool1/micro_switch_positioned_1.stl");
        
        // Hotend and cooling
        import("stls/ExtruderTool1/bambu_hotend_positioned_1.stl");
        import("stls/ExtruderTool1/fan_3010_positioned_1.stl");
        import("stls/ExtruderTool1/cowl_exo_klicky_positioned_1.stl");
        import("stls/ExtruderTool1/diffuser_1.stl");
        
        // Mounts and accessories
        import("stls/ExtruderTool1/sherpa_micro_ebb_mount_ribbon_1.stl");
        import("stls/ExtruderTool1/sherpa_micro_mount_positioned_1.stl");
        import("stls/ExtruderTool1/Nozzle_Blocker_Mount_R2_tube_block_1.stl");
        import("stls/ExtruderTool1/Umbilical_Extrusion_Mount_ribboncable_filamentsensor_1.stl");



        // =====================================================================
        // SYRINGE PUMP & VALVE SYSTEM (Microfluidics control)
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/syringe_pump/
        //   (Source files TBD - add when identified)
        //
        // Generated STLs:
        //   Complete syringe pump system with 4-channel valve control
        //   Includes peristaltic pumps, wash station, and pressure compensation
        // =====================================================================
        
        // Syringe pump assembly - 4-channel system
        color("lime")translate([0,32,0])import("stls/Syringepump_valve/tyco_multichannel_syringe1ml_clamp.stl");
        color("lime")translate([0,32,0])import("stls/Syringepump_valve/tyco_multichannel_syringe1ml_clamp_luerlock.stl");
        import("stls/Syringepump_valve/multichannel_syringe1ml_clamp_extrusion_connect_1.stl");
        import("stls/Syringepump_valve/multichannel_syringe1ml_clamp_extrusion_connect_2.stl");
        import("stls/Syringepump_valve/multichannel_plunger_clamp.stl");
        import("stls/Syringepump_valve/syringe_1ml_stack_1piece_multichannel.stl");
        import("stls/Syringepump_valve/syringe_1ml_stack_1piece_multichannel_clamp.stl");


	color("lime")translate([0,0,0])import("stls/Syringepump_valve/syringe_1m_4units.stl");
	color("lime")translate([0,32,0])import("stls/Syringepump_valve/oneml_syringe_stepper_linear_m8nut_coupler.stl");

        //import("stls/Syringepump_valve/syringe_1m_4units.stl");
        //color("lime")translate([640,591,306])import("tuberculin_syringe_1ml.stl");
	//color("orange")translate([600,659+1,228-4.5])rotate([90,0,90])import("iverntech_pump_slider_plate.stl");

	//import("multichannel_syringeshuttle_clipbracket.stl");

        // Linear motion system
        import("stls/Syringepump_valve/mgn12_rail_300mm.stl");
        import("stls/Syringepump_valve/mgn12_shuttle.stl");
        import("stls/Syringepump_valve/MGN12_slider_mount.stl");
        import("stls/Syringepump_valve/MGN12_slider_mount_motormount_screws.stl");
        import("stls/Syringepump_valve/multichannel_syringeshuttle_clipbracket.stl");
        import("stls/Syringepump_valve/m8_threaded_rod_200mm.stl");
 
        // Motor and frame
        import("stls/Syringepump_valve/nema_multichannel.stl");
        import("stls/Syringepump_valve/HFSB5-2020-350.stl");
        
        // Valve system (4 channels: 0-3)
        import("stls/Syringepump_valve/servo_0.stl");
        import("stls/Syringepump_valve/servo_1.stl");
        import("stls/Syringepump_valve/servo_2.stl");
        import("stls/Syringepump_valve/servo_3.stl");
        import("stls/Syringepump_valve/stopcock_0.stl");
        import("stls/Syringepump_valve/stopcock_1.stl");
        import("stls/Syringepump_valve/stopcock_2.stl");
        import("stls/Syringepump_valve/stopcock_3.stl");
        
        // Valve mounting and connections
        import("stls/Syringepump_valve/smallsyringe_valvesupportmodule_plate_4valve.stl");
        import("stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_0.stl");
        import("stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_1.stl");
        import("stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_2.stl");
        import("stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_3.stl");
        import("stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_vertical_attach_0.stl");
        import("stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_vertical_attach_1.stl");
        import("stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_vertical_attach_2.stl");
        import("stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_vertical_attach_3.stl");
        import("stls/Syringepump_valve/valveconnect_part_0.stl");
        import("stls/Syringepump_valve/valveconnect_part_1.stl");
        import("stls/Syringepump_valve/valveconnect_part_2.stl");
        import("stls/Syringepump_valve/valveconnect_part_3.stl");

        
        // Tubing and connections
        translate([0,0,0]){
        import("stls/Syringepump_valve/syringe_pump_tubing_to_valves.stl");
        import("stls/Syringepump_valve/valve_tubing_0.stl");
        import("stls/Syringepump_valve/valve_tubing_1.stl");
        import("stls/Syringepump_valve/valve_tubing_2.stl");
        import("stls/Syringepump_valve/valve_tubing_3.stl");

	//openscad conduit tubing fix
	import("stls/LiquidDispenserTool0/conduit.stl");

        }

        // Wash station components
        import("stls/Syringepump_valve/washbowl_1tip001.stl");
        import("stls/Syringepump_valve/washbowl_stilt001.stl");
        import("stls/Syringepump_valve/washbowl_watervacinput_tpu001.stl");
        import("stls/Syringepump_valve/wash_dry_pressure_plate_rj45_connector.stl");
        import("stls/Syringepump_valve/drypad001.stl");
        
        // Peristaltic pumps
        import("stls/Syringepump_valve/peristaltic_pump_1.stl");
        import("stls/Syringepump_valve/peristaltic_pump_1_tubing.stl");
        import("stls/Syringepump_valve/peristaltic_pump_2.stl");
        import("stls/Syringepump_valve/peristaltic_pump_2_tubing.stl");
        import("stls/Syringepump_valve/peristaltic_waste_bottle_tubing.stl");
        
        // Bottles and containers
        import("stls/Syringepump_valve/bottle.stl");
        import("stls/Syringepump_valve/bottle_lid.stl");
        import("stls/Syringepump_valve/waterbottle.stl");
        import("stls/Syringepump_valve/waterbottle_tubing.stl");
        import("stls/Syringepump_valve/wastebottle.stl");
        import("stls/Syringepump_valve/nalgene_250ml_bottle_holder_liquid_level_sensor.stl");
        import("stls/Syringepump_valve/pcv_bottle_tubing.stl");
        
        // Sensors and electronics housing
        import("stls/Syringepump_valve/TaidacentNon-ContactLiquidSensor.stl");
        import("stls/Syringepump_valve/keystone-box-1_box.stl");
        import("stls/Syringepump_valve/keystone-box-1_lid.stl");
       
 
        // =====================================================================
        // WASH STATION (Tip cleaning and drying)
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/washstation/
        //   (Source files TBD - add when identified)
        //
        // Generated STLs:
        //   Wash bowl assembly for pipette tip cleaning
        // =====================================================================

        import("stls/Washstation/drypad.stl");
        import("stls/Washstation/washbowl_stilt.stl");
        import("stls/Washstation/washbowl_watervacinput_tpu.stl");
        
        //
        //=====================================================================
        // CABLING SYSTEM (Cable management and connections)
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/cabling/
        //   (Source files TBD - add when identified)
        //
        // Generated STLs:
        //   Voron-style keystone jacks for cable management
        //   XT60 power connectors
        // =====================================================================
 
        // Keystone jacks - Inside mounting (5 units)
        import("stls/Cabling/voron_keystone_inside.stl");
        import("stls/Cabling/voron_keystone_inside_1.stl");
        import("stls/Cabling/voron_keystone_inside_2.stl");
        import("stls/Cabling/voron_keystone_inside_3.stl");
        import("stls/Cabling/voron_keystone_inside_4.stl");

        // Keystone jacks - Outside mounting (5 units)
        import("stls/Cabling/voron_keystone_outside.stl");
        import("stls/Cabling/voron_keystone_outside_1.stl");
        import("stls/Cabling/voron_keystone_outside_2.stl");
        import("stls/Cabling/voron_keystone_outside_3.stl");
        import("stls/Cabling/voron_keystone_outside_4.stl");

        // Power connector
        import("stls/Cabling/XT60_v2.stl");


 
        // =====================================================================
        // KLICKY PROBE SYSTEM
        // =====================================================================
        // OpenSCAD Sources: openscad_sources/klicky/
        //   (Source files TBD - add when identified)
        //
        // Generated STLs:
        //   Klicky probe dock and magnetic probe components
        // =====================================================================
        
        // Dock mount
        import("stls/Klicky/Dock_mount_fixed_v3.stl");
        import("stls/Klicky/dock-front_insert.stl");
        
        // Magnetic probe
        import("stls/Klicky/mag_probe_screw_mod.stl");
        
       
    }
}

// =============================================================================
// PARAMETRIC EXTRUSIONS
// =============================================================================

module parametric_extrusions() {
    translate(PARAMETRIC_OFFSET) {
        // X gantry rail (parametric tslot20)
        color("silver")
        translate([X_GANTRY_X, X_GANTRY_Y - 15, X_GANTRY_Z + 15])
        rotate([0, 90, 0])
        tslot20(X_GANTRY_LENGTH);
    }
}

// =============================================================================
// COMPLETE ASSEMBLY
// =============================================================================

module complete_assembly() {
    if (USE_FREECAD_STLS) {
        freecad_assembly();
    }
    
    if (USE_PARAMETRIC_EXTRUSIONS) {
        parametric_extrusions();
    }
}

// =============================================================================
// BUILD
// =============================================================================

complete_assembly();

// Coordinate axes for reference
color("red") cylinder(r=0.5, h=50);        // X-axis
color("green") rotate([0,90,0]) cylinder(r=0.5, h=50);   // Y-axis
color("blue") rotate([90,0,0]) cylinder(r=0.5, h=50);    // Z-axis
