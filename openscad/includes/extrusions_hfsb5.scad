// MISUMI EXTRUSIONS - HFSB5 (20x20mm standard)
// Standard duty aluminum extrusions

module extrusions_hfsb5() {
    color("silver") {
        import("../stls/HFSB5-2020-480.stl");
        //import("../stls/HFSB5-2020-510.stl");
        
        // 500mm extrusions with accessories
        import("../stls/HFSB5-2020-500-LCP-RCP-AV360.stl");
        import("../stls/HFSB5-2020-500-LCP-RCP-AV360_1.stl");
        import("../stls/HFSB5-2020-500-LCP-RCP-AV360_2.stl");
        import("../stls/HFSB5-2020-500-LCP-RCP-AV360_3.stl");
        
        // 550mm extrusions
        import("../stls/HFSB5-2020-550.stl");
        import("../stls/HFSB5-2020-550_1.stl");
        import("../stls/HFSB5-2020-550_2.stl");
        import("../stls/HFSB5-2020-550_3.stl");
        
        // 660mm extrusions with accessories
        import("../stls/HFSB5-2020-660.stl");
        import("../stls/HFSB5-2020-660_7.stl");
        import("../stls/HFSB5-2020-660_8.stl");
        import("../stls/HFSB5-2020-660-AV335.stl");
        import("../stls/HFSB5-2020-660-AV335_1.stl");
    }
}
