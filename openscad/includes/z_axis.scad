// Z-AXIS MOTORS & LEAD SCREWS

module z_axis() {
    // Z motors
    color("black") {
        import("../stls/Z/nema17001.stl");
        import("../stls/Z/nema17_1001.stl");
        import("../stls/Z/nema17_2.stl");
        import("../stls/Z/nema17_3.stl");
    }
    
    // Lead screws (300mm threaded rods)
    color("silver") import("../stls/Z/threaded_rod_300.stl");
    color("silver") import("../stls/Z/threaded_rod_300_1.stl");
    color("silver") import("../stls/Z/threaded_rod_300_2.stl");
    color("silver") import("../stls/Z/threaded_rod_300_3.stl");
    
    // Z stepper mounts
    import("../stls/Z/z_stepper_left.stl");
    import("../stls/Z/z_stepper_left_1.stl");
    import("../stls/Z/z_stepper_right.stl");
    import("../stls/Z/z_stepper_right_1.stl");
}

// Z-AXIS CARRIAGES
module z_carriages() {
    // Left Z carriages
    import("../stls/ZParts/z_carriage_left.stl");
    import("../stls/ZParts/z_carriage_left_1.stl");
    
    // Right Z carriages
    import("../stls/ZParts/z_carriage_right.stl");
    import("../stls/ZParts/z_carriage_right_1.stl");
}

// ENDSTOPS
module endstops() {
    import("../stls/Endstop/xyendstop_lineax.stl");
}
