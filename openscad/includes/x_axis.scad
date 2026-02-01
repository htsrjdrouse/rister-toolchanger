// X-AXIS COMPONENTS
// MGN9H carriage, X gantry extrusion, and MGN9 rail

module x_axis_components() {
    // MGN9H shuttle/carriage (X-axis)
    color("silver") import("../stls/mgn9H_shuttle.stl");
    
    // X gantry extrusion (from FreeCAD)
    color("silver") import("../stls/HFSB5-2020-510_freecad.stl");
    
    // MGN9 450mm rail assembly (X-axis)
    color("silver") import("../stls/rister_multi-modal_toolchanger-mgn9_450.stl");
}
