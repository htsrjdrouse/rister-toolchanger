// BED ASSEMBLY

module bed_assembly() {
    color("silver") {
        // Bed frame extrusions (518mm)
        import("../stls/Bed/HFSB5-2020-518.stl");
        import("../stls/Bed/HFSB5-2020-518_1.stl");
        
        // Bed frame extrusions (548mm with accessories)
        import("../stls/Bed/HFSB5-2020-548-AV103.5-BV444.5.stl");
        import("../stls/Bed/HFSB5-2020-548-AV103.5-BV444.5_1.stl");
        
        // Build plate (Voron Trident 350mm)
        import("../stls/Bed/voron_trident_350_buildplate.stl");
    }
    
    // Bed Z mounts
    import("../stls/Bed/z_bed_left.stl");
    import("../stls/Bed/z_bed_left_1.stl");
    import("../stls/Bed/z_bed_right.stl");
    import("../stls/Bed/z_bed_right_1.stl");
}
