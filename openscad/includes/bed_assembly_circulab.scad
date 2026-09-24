// BED ASSEMBLY

module bed_assembly() {
     {
	//cuttingboard_chute();

	/*
        // Bed frame extrusions (518mm)
        color("silver")import("../stls/Bed/HFSB5-2020-518.stl");
        color("silver")import("../stls/Bed/HFSB5-2020-518_1.stl");
        
        // Bed frame extrusions (548mm with accessories)
        color("silver")import("../stls/Bed/HFSB5-2020-548-AV103.5-BV444.5.stl");
        color("silver")import("../stls/Bed/HFSB5-2020-548-AV103.5-BV444.5_1.stl");
	*/
        
        // Build plate (Voron Trident 350mm)


	difference(){
        color("silver")import("../stls/Bed/voron_trident_350_buildplate.stl");
	translate([100,150,202])#cube([400,400,7]);
	//translate([245,260,180])cube([20,100,50]);
	//translate([245-40,260,180])cube([20,100,50]);
	translate([245-80,260,180])cube([100,100,50]);

	translate([158,375,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([158,245,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([220,375,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([220,245,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([280,375,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([280,245,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);

	translate([192,362.5,0]){
	translate([20+140,-18+20,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([20+140+25,-18+20-25,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([20+140+25,-18+20-70,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	
	translate([120+20,-18-90.5,-22])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([120+38.,-18-90.5-63,-22])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([20+140+101,-18+20-161,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([20+140+101-33,-18+20-161,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([20+140+101-1.5,-18+20-161+307,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);
	translate([20+140+101-1.5+15,-18+20-161+307,78])rotate([0,0,0])cylinder(d=2.8,h=300,$fn=50);

	/*

    */
	for(i=[-1:5]){
	  translate([9.5-1.7+235,4+60.5-(i*20),125])cylinder(d=2.8,h=230,$fn=50);
	}
	

	}
	}
    }
    
    // Bed Z mounts
    /*
    import("../stls/Bed/z_bed_left.stl");
    import("../stls/Bed/z_bed_left_1.stl");
    import("../stls/Bed/z_bed_right.stl");
    import("../stls/Bed/z_bed_right_1.stl");
    */
}



	module cuttingboard_chute(){
	difference(){translate([0,0,6.])color("red")union(){
	translate([278,260,204])cube([20,100,30]);
	translate([278-130,260-25,204])cube([150,150,4]);
	}
	
	translate([158,375,78])rotate([0,0,0])cylinder(d=3.8,h=300,$fn=50);
	translate([158,245,78])rotate([0,0,0])cylinder(d=3.8,h=300,$fn=50);
	translate([220,375,78])rotate([0,0,0])cylinder(d=3.8,h=300,$fn=50);
	translate([220,245,78])rotate([0,0,0])cylinder(d=3.8,h=300,$fn=50);
	translate([280,375,78])rotate([0,0,0])cylinder(d=3.8,h=300,$fn=50);
	translate([280,245,78])rotate([0,0,0])cylinder(d=3.8,h=300,$fn=50);

	translate([-0,0,0]){
	translate([245,260,180])cube([20,100,50]);
	translate([245-40,260,180])cube([20,100,50]);
	translate([245-80,260,180])cube([20,100,50]);
	}
	}
	}


