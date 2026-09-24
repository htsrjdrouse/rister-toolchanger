// BED ASSEMBLY

module bed_assembly() {
     {
        // Bed frame extrusions (518mm)
        color("silver")import("../stls/Bed/HFSB5-2020-518.stl");
        color("silver")import("../stls/Bed/HFSB5-2020-518_1.stl");
        
        // Bed frame extrusions (548mm with accessories)
        color("silver")import("../stls/Bed/HFSB5-2020-548-AV103.5-BV444.5.stl");
        color("silver")import("../stls/Bed/HFSB5-2020-548-AV103.5-BV444.5_1.stl");
        
        // Build plate (Voron Trident 350mm)
	color("red")translate([278,260,204])cube([20,100,30]);
	difference(){
        color("silver")import("../stls/Bed/voron_trident_350_buildplate.stl");
	translate([245,260,180])cube([20,100,50]);
	translate([245-40,260,180])cube([20,100,50]);
	translate([245-80,260,180])cube([20,100,50]);
	}
    }
    
    // Bed Z mounts
    import("../stls/Bed/z_bed_left.stl");
    import("../stls/Bed/z_bed_left_1.stl");
    import("../stls/Bed/z_bed_right.stl");
    import("../stls/Bed/z_bed_right_1.stl");
}
