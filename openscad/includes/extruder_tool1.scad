// EXTRUDER TOOL 1 (Sherpa Micro + Bambu hotend - duplicate)

module extruder_tool1() {
    // Dock and backplate
    import("../stls/ExtruderTool1/dock_body_linearactuator_10mmlonger_1.stl");
    import("../stls/ExtruderTool1/back_plate_positioned_1.stl");
    
    // Sherpa Micro extruder components
    import("../stls/ExtruderTool1/sherpa_micro_bambu_positioned_1.stl");
    import("../stls/ExtruderTool1/sherpa_housing_positioned_1.stl");
    import("../stls/ExtruderTool1/sherpa_cover_positioned_1.stl");
    import("../stls/ExtruderTool1/sherpa_lever_positioned_1.stl");
    import("../stls/ExtruderTool1/sherpa_gear_positioned_1.stl");
    import("../stls/ExtruderTool1/housing_positioned_1.stl");
    import("../stls/ExtruderTool1/lever_arm_positioned_1.stl");
    
    // Drive cores
    import("../stls/ExtruderTool1/shaftdrive_core_positioned_1.stl");
    import("../stls/ExtruderTool1/shimdrive_core_positioned_1.stl");
    
    // Gears and encoder
    import("../stls/ExtruderTool1/filament_gear_positioned_1.stl");
    import("../stls/ExtruderTool1/idler_gear_positioned_1.stl");
    import("../stls/ExtruderTool1/idler_pin_positioned_1.stl");
    import("../stls/ExtruderTool1/Encoder_Left_1.stl");
    import("../stls/ExtruderTool1/Encoder_Right_1.stl");
    import("../stls/ExtruderTool1/[o]_Encoder_Slotted_Wheel_1.stl");
    
    // Hardware inserts
    import("../stls/ExtruderTool1/insert_1_positioned_1.stl");
    import("../stls/ExtruderTool1/insert_2_positioned_1.stl");
    import("../stls/ExtruderTool1/insert_3_positioned_1.stl");
    import("../stls/ExtruderTool1/insert_4_positioned_1.stl");
    import("../stls/ExtruderTool1/insert_5_positioned_1.stl");
    
    // Bearings
    import("../stls/ExtruderTool1/mr85_bearing_1_positioned_1.stl");
    import("../stls/ExtruderTool1/mr85_bearing_2_positioned_1.stl");
    
    // Fasteners
    import("../stls/ExtruderTool1/m3_20mm_bhcs_positioned_1.stl");
    import("../stls/ExtruderTool1/m3_30mm_shcs_1_positioned_1.stl");
    import("../stls/ExtruderTool1/m3_30mm_shcs_2_positioned_1.stl");
    import("../stls/ExtruderTool1/m3_30mm_shcs_3_positioned_1.stl");
    import("../stls/ExtruderTool1/m3_set_screw_positioned_1.stl");
    import("../stls/ExtruderTool1/button_screw_1_positioned_1.stl");
    import("../stls/ExtruderTool1/thumbscrew_positioned_1.stl");
    
    // Electronics
    import("../stls/ExtruderTool1/ebb36_board_positioned_1.stl");
    import("../stls/ExtruderTool1/ebb36_spacer_1_positioned_1.stl");
    import("../stls/ExtruderTool1/ebb36_spacer_2_positioned_1.stl");
    import("../stls/ExtruderTool1/micro_switch_positioned_1.stl");
    
    // Hotend and cooling
    import("../stls/ExtruderTool1/bambu_hotend_positioned_1.stl");
    import("../stls/ExtruderTool1/fan_3010_positioned_1.stl");
    import("../stls/ExtruderTool1/cowl_exo_klicky_positioned_1.stl");
    import("../stls/ExtruderTool1/diffuser_1.stl");
    
    // Mounts and accessories
    import("../stls/ExtruderTool1/sherpa_micro_ebb_mount_ribbon_1.stl");
    import("../stls/ExtruderTool1/sherpa_micro_mount_positioned_1.stl");
    import("../stls/ExtruderTool1/Nozzle_Blocker_Mount_R2_tube_block_1.stl");
    import("../stls/ExtruderTool1/Umbilical_Extrusion_Mount_ribboncable_filamentsensor_1.stl");
}
