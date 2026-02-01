// RASPBERRY PI CAMERA TOOL

module camera_tool() {
    // Camera mounts
    import("../stls/RaspiCameraTool/arducam_adjuster.stl");
    import("../stls/RaspiCameraTool/arducam_lineux.stl");
    import("../stls/RaspiCameraTool/arducam_rotate_2mount_adjuster_nut.stl");
    
    // Dock and backplate
    import("../stls/RaspiCameraTool/dock.stl");
    import("../stls/RaspiCameraTool/lineux_backplate_for_raspberrypi.stl");
    
    // Raspberry Pi case
    import("../stls/RaspiCameraTool/raspberrypi_bottom_mod.stl");
    import("../stls/RaspiCameraTool/raspberrypi_case_top.stl");
    
    // LED diffusers
    import("../stls/RaspiCameraTool/led_diffuser_2.stl");
    import("../stls/RaspiCameraTool/led_diffuser_back_2.stl");
    
    // Umbilical
    import("../stls/RaspiCameraTool/umbilical_extrusion.stl");
}
