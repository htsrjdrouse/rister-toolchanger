// RASPBERRY PI CAMERA TOOL

module camera_tool() {
    /*
    import("../stls/RaspiCameraTool/raspberrypi_case_top.stl");
    difference(){
    translate([180,636.5+2,313.2])color("lime")cube([37.5,7,8]);
    translate([183.3,636.5-10,313.2+3.1])rotate([-90,0,0])#cylinder(d=2.8,h=50,$fn=100);
    translate([183.3+31.9,636.5-10,313.2+3.1])rotate([-90,0,0])#cylinder(d=2.8,h=50,$fn=100);
    }
    */
    /* 

    translate([406.4-115+4.5,716.5,480])cube([9,2,255]);
    translate([406.4-115+4.5,716.5,480+255])rotate([90,0,0])cube([9,2,101]);
    translate([406.4-115+4.5,716.5-102,480])cube([9,2,255]);


    */
    color("lightsalmon"){
    translate([273,640,403])rotate([0,90,90])import("../stls/RaspiCameraTool/arducam_rotate_2mount_adjuster_nut.stl");
    translate([100,0,0]){
    // Klicky 
    translate([-72,-9,-23+6])import("../stls/RaspiCameraTool/klicky_mount_mod_pcb_clone.stl");
    // Camera mounts
    translate([-7,0,0]){
    import("../stls/RaspiCameraTool/arducam_adjuster.stl");
    translate([168.8,-3+700-22,330])rotate([-180,0,0])import("../stls/RaspiCameraTool/arducam_lineux.stl");
    }
    // Dock and backplate
    import("../stls/RaspiCameraTool/dock.stl");
    import("../stls/RaspiCameraTool/lineux_backplate_for_raspberrypi.stl");
    
    // Raspberry Pi case
    import("../stls/RaspiCameraTool/raspberrypi_bottom_mod.stl");
    translate([0,29.5,6.7])import("../stls/RaspiCameraTool/raspberrypi_case_top_klicky.stl");
    //#import("../stls/RaspiCameraTool/raspberrypi_case_top.stl");
    
    // LED diffusers
    import("../stls/RaspiCameraTool/led_diffuser_2.stl");
    import("../stls/RaspiCameraTool/led_diffuser_back_2.stl");
    
    // Umbilical
    translate([4.5,0,0])import("../stls/RaspiCameraTool/umbilical_extrusion.stl");
    translate([-100,32,0])import("../stls/RaspiCameraTool/umbilical_camera.stl");
    }
    }

}
