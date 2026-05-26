// EXTRUDER TOOL 0 (Sherpa Micro + Bambu hotend)

module extruder_tool0() {
    // Dock and backplate
    import("../stls/ExtruderTool0/dock_body_linearactuator_10mmlonger.stl");
    import("../stls/ExtruderTool0/back_plate_positioned.stl");
    
    // Sherpa Micro extruder components
    import("../stls/ExtruderTool0/sherpa_micro_bambu_positioned.stl");
    import("../stls/ExtruderTool0/sherpa_housing_positioned.stl");
    import("../stls/ExtruderTool0/sherpa_cover_positioned.stl");
    import("../stls/ExtruderTool0/sherpa_lever_positioned.stl");
    import("../stls/ExtruderTool0/sherpa_gear_positioned.stl");
    import("../stls/ExtruderTool0/housing_positioned.stl");
    import("../stls/ExtruderTool0/lever_arm_positioned.stl");
    
    // Drive cores
    import("../stls/ExtruderTool0/shaftdrive_core_positioned.stl");
    import("../stls/ExtruderTool0/shimdrive_core_positioned.stl");
    
    // Gears and encoder
    import("../stls/ExtruderTool0/filament_gear_positioned.stl");
    import("../stls/ExtruderTool0/idler_gear_positioned.stl");
    import("../stls/ExtruderTool0/idler_pin_positioned.stl");
    import("../stls/ExtruderTool0/Encoder_Left.stl");
    import("../stls/ExtruderTool0/Encoder_Right.stl");
    import("../stls/ExtruderTool0/[o]_Encoder_Slotted_Wheel.stl");
    
    // Hardware inserts
    import("../stls/ExtruderTool0/insert_1_positioned.stl");
    import("../stls/ExtruderTool0/insert_2_positioned.stl");
    import("../stls/ExtruderTool0/insert_3_positioned.stl");
    import("../stls/ExtruderTool0/insert_4_positioned.stl");
    import("../stls/ExtruderTool0/insert_5_positioned.stl");
    
    // Bearings
    import("../stls/ExtruderTool0/mr85_bearing_1_positioned.stl");
    import("../stls/ExtruderTool0/mr85_bearing_2_positioned.stl");
    
    // Fasteners
    import("../stls/ExtruderTool0/m3_20mm_bhcs_positioned.stl");
    import("../stls/ExtruderTool0/m3_30mm_shcs_1_positioned.stl");
    import("../stls/ExtruderTool0/m3_30mm_shcs_2_positioned.stl");
    import("../stls/ExtruderTool0/m3_30mm_shcs_3_positioned.stl");
    import("../stls/ExtruderTool0/m3_set_screw_positioned.stl");
    import("../stls/ExtruderTool0/button_screw_1_positioned.stl");
    import("../stls/ExtruderTool0/thumbscrew_positioned.stl");
    
    // Electronics
    import("../stls/ExtruderTool0/ebb36_board_positioned.stl");
    import("../stls/ExtruderTool0/ebb36_spacer_1_positioned.stl");
    import("../stls/ExtruderTool0/ebb36_spacer_2_positioned.stl");
    import("../stls/ExtruderTool0/micro_switch_positioned.stl");
    
    // Hotend and cooling
    import("../stls/ExtruderTool0/bambu_hotend_positioned.stl");
    import("../stls/ExtruderTool0/fan_3010_positioned.stl");
    import("../stls/ExtruderTool0/cowl_exo_klicky_positioned.stl");
    import("../stls/ExtruderTool0/diffuser.stl");
    
    // Mounts and accessories
    import("../stls/ExtruderTool0/sherpa_micro_ebb_mount_ribbon.stl");
    import("../stls/ExtruderTool0/sherpa_micro_mount_positioned.stl");
    #import("../stls/ExtruderTool0/klicky_mount_mod_pcb_clone.stl");
    import("../stls/ExtruderTool0/Nozzle_Blocker_Mount_R2_tube_block.stl");
    import("../stls/ExtruderTool0/Umbilical_Extrusion_Mount_ribboncable_filamentsensor.stl");
}
