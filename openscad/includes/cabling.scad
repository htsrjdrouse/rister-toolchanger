// CABLING SYSTEM (Cable management and connections)
// Voron-style keystone jacks and XT60 power connectors

module cabling_system() {
    // Keystone jacks - Inside mounting (5 units)
    import("../stls/Cabling/voron_keystone_inside.stl");
    import("../stls/Cabling/voron_keystone_inside_1.stl");
    import("../stls/Cabling/voron_keystone_inside_2.stl");
    import("../stls/Cabling/voron_keystone_inside_3.stl");
    import("../stls/Cabling/voron_keystone_inside_4.stl");
    
    // Keystone jacks - Outside mounting (5 units)
    import("../stls/Cabling/voron_keystone_outside.stl");
    import("../stls/Cabling/voron_keystone_outside_1.stl");
    import("../stls/Cabling/voron_keystone_outside_2.stl");
    import("../stls/Cabling/voron_keystone_outside_3.stl");
    import("../stls/Cabling/voron_keystone_outside_4.stl");
    
    // Power connector
    import("../stls/Cabling/XT60_v2.stl");
}
