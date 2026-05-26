// SYRINGE PUMP & VALVE SYSTEM (Microfluidics control)
// Complete syringe pump system with 4-channel valve control

module syringe_pump_system() {
    // Syringe pump assembly - 4-channel system
    color("lime") translate([0,32,0]) import("../stls/Syringepump_valve/tyco_multichannel_syringe1ml_clamp.stl");
    color("lime") translate([0,32,0]) import("../stls/Syringepump_valve/tyco_multichannel_syringe1ml_clamp_luerlock.stl");
    import("../stls/Syringepump_valve/multichannel_syringe1ml_clamp_extrusion_connect_1.stl");
    import("../stls/Syringepump_valve/multichannel_syringe1ml_clamp_extrusion_connect_2.stl");
    import("../stls/Syringepump_valve/multichannel_plunger_clamp.stl");
    import("../stls/Syringepump_valve/syringe_1ml_stack_1piece_multichannel.stl");
    import("../stls/Syringepump_valve/syringe_1ml_stack_1piece_multichannel_clamp.stl");
    
    color("lime") import("../stls/Syringepump_valve/syringe_1m_4units.stl");
    color("lime") translate([0,32,0]) import("../stls/Syringepump_valve/oneml_syringe_stepper_linear_m8nut_coupler.stl");
    
    // Linear motion system
    import("../stls/Syringepump_valve/mgn12_rail_300mm.stl");
    import("../stls/Syringepump_valve/mgn12_shuttle.stl");
    import("../stls/Syringepump_valve/MGN12_slider_mount.stl");
    import("../stls/Syringepump_valve/MGN12_slider_mount_motormount_screws.stl");
    import("../stls/Syringepump_valve/multichannel_syringeshuttle_clipbracket.stl");
    import("../stls/Syringepump_valve/m8_threaded_rod_200mm.stl");
    
    // Motor and frame
    import("../stls/Syringepump_valve/nema_multichannel.stl");
    import("../stls/Syringepump_valve/HFSB5-2020-350.stl");
    
    // Valve system (4 channels: 0-3)
    import("../stls/Syringepump_valve/servo_0.stl");
    import("../stls/Syringepump_valve/servo_1.stl");
    import("../stls/Syringepump_valve/servo_2.stl");
    import("../stls/Syringepump_valve/servo_3.stl");
    import("../stls/Syringepump_valve/stopcock_0.stl");
    import("../stls/Syringepump_valve/stopcock_1.stl");
    import("../stls/Syringepump_valve/stopcock_2.stl");
    import("../stls/Syringepump_valve/stopcock_3.stl");
    
    // Valve mounting and connections
    import("../stls/Syringepump_valve/smallsyringe_valvesupportmodule_plate_4valve.stl");
    import("../stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_0.stl");
    import("../stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_1.stl");
    import("../stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_2.stl");
    import("../stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_3.stl");
    import("../stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_vertical_attach_0.stl");
    import("../stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_vertical_attach_1.stl");
    import("../stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_vertical_attach_2.stl");
    import("../stls/Syringepump_valve/valvemountplate_screwattach_smallersyringe_vertical_attach_3.stl");
    import("../stls/Syringepump_valve/valveconnect_part_0.stl");
    import("../stls/Syringepump_valve/valveconnect_part_1.stl");
    import("../stls/Syringepump_valve/valveconnect_part_2.stl");
    import("../stls/Syringepump_valve/valveconnect_part_3.stl");
    
    // Tubing and connections
    import("../stls/Syringepump_valve/syringe_pump_tubing_to_valves.stl");
    import("../stls/Syringepump_valve/valve_tubing_0.stl");
    import("../stls/Syringepump_valve/valve_tubing_1.stl");
    import("../stls/Syringepump_valve/valve_tubing_2.stl");
    import("../stls/Syringepump_valve/valve_tubing_3.stl");
    import("../stls/LiquidDispenserTool0/conduit.stl");
   

    /* 
    // Wash station components
    import("../stls/Syringepump_valve/washbowl_1tip001.stl");
    import("../stls/Syringepump_valve/washbowl_stilt001.stl");
    import("../stls/Syringepump_valve/washbowl_watervacinput_tpu001.stl");
    import("../stls/Syringepump_valve/wash_dry_pressure_plate_rj45_connector.stl");
    import("../stls/Syringepump_valve/drypad001.stl");
    */
 
    // Peristaltic pumps
    import("../stls/Syringepump_valve/peristaltic_pump_1.stl");
    import("../stls/Syringepump_valve/peristaltic_pump_1_tubing.stl");
    import("../stls/Syringepump_valve/peristaltic_pump_2.stl");
    import("../stls/Syringepump_valve/peristaltic_pump_2_tubing.stl");
    import("../stls/Syringepump_valve/peristaltic_waste_bottle_tubing.stl");
    
    // Bottles and containers
    import("../stls/Syringepump_valve/bottle.stl");
    import("../stls/Syringepump_valve/bottle_lid.stl");
    import("../stls/Syringepump_valve/waterbottle.stl");
    import("../stls/Syringepump_valve/waterbottle_tubing.stl");
    import("../stls/Syringepump_valve/wastebottle.stl");
    import("../stls/Syringepump_valve/nalgene_250ml_bottle_holder_liquid_level_sensor.stl");
    import("../stls/Syringepump_valve/pcv_bottle_tubing.stl");
    
    // Sensors and electronics housing
    import("../stls/Syringepump_valve/TaidacentNon-ContactLiquidSensor.stl");
    import("../stls/Syringepump_valve/keystone-box-1_box.stl");
    import("../stls/Syringepump_valve/keystone-box-1_lid.stl");
}
