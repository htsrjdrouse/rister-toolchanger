// Y-AXIS COMPONENTS
// Y1 and Y2 rail assemblies with MGN12 carriages

module y_axis_components() {
    // Y1 rail assembly
    color("silver") import("../stls/HGSB5-2020-660.stl");
    color("silver") import("../stls/MGN12_600_y1.stl");
    color("silver") import("../stls/MGN12H_shuttle_y1.stl");
    
    // Y2 rail assembly
    color("silver") import("../stls/HGSB5-2020-660_5.stl");
    color("silver") import("../stls/MGN12_600_y2.stl");
    color("silver") import("../stls/MGN12H_shuttle_y2.stl");
}
