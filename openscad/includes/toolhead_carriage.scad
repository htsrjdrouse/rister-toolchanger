// TOOLHEAD CARRIAGE (rides on MGN9 X-axis)
// OpenSCAD Sources: openscad_sources/carriage/
//   - carriage_v2_3dify.scad (current version)
//   - carriage_v2.scad (previous iteration)
//   - carriage.scad (original)
//   - assembly.scad (assembly reference)

module toolhead_carriage() {
    // Carriage body components
    import("../stls/Carriage/carriage_body_bottom_trident_v2.stl");
    color("lime")import("../stls/Carriage/carriage_body_middle_trident_v2.stl");
    import("../stls/Carriage/carriage_body_rear_trident_v2.stl");
    import("../stls/Carriage/carriage_body_top.stl");
    import("../stls/Carriage/CarriageBodyFront_editable_belt_holes.stl");
    
    // Cooling system
    //import("../stls/Carriage/5015AdapterRister_longer.stl");
    //import("../stls/Carriage/duct_trident_v2_nozzle_10mm_longer.stl");
    //import("../stls/Carriage/radial_cooling_5015.stl");
    
    // Toolchanger components
    color("pink")import("../stls/Carriage/locking_plate_lineux_one.stl");
    import("../stls/Carriage/slider.stl");


}
