//conduit_tubing();
//pipette_tubing_liquidhandler();

module conduit_tubing(){
        translate([640,576,635])cylinder(d=10,h=35,$fn=30);
        translate([640,576-4,635+35])rotate([-90,0,0])cylinder(d=10,h=190,$fn=30);
        translate([640,576-4+190-4,635+35])rotate([-180,0,0])cylinder(d=10,h=180,$fn=30);
        translate([640+5,576-4+190-4,635+35-180])rotate([90,0,-90])cylinder(d=10,h=240,$fn=30);
        translate([640+5-235,576-4+190-4,635+35-184])rotate([0,0,0])cylinder(d=10,h=262,$fn=30);
        translate([640+5-235,576-4+190,635+35-184+262])rotate([90,0,0])cylinder(d=10,h=378,$fn=30);
        translate([640+5-235,576-4+190-382+7,635+35-184+266])rotate([180,0,0])cylinder(d=10,h=60,$fn=30);
        translate([640+5-235,576-4+190-382+7,635+35-184+266-56])rotate([180,0,0])rotate([0,-40,0])cylinder(d=10,h=140,$fn=30);
        translate([640+5-323,576-4+190-382+7,635+35-184+266-160])rotate([180,0,0])rotate([0,-0,0])cylinder(d=10,h=67,$fn=30);
        translate([640+5-323,576-4+190-382+7,635+35-184+266-160-63])rotate([180,0,0])rotate([0,35,0])cylinder(d=10,h=23,$fn=30);

}





module pipette_tubing_liquidhandler(){
	color("lightblue")translate([337,427,315])difference(){cylinder(d=3,h=61,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-5.3,427,315])difference(){cylinder(d=3,h=60,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-10.6,427,315])difference(){cylinder(d=3,h=60,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-15.9,427,315])difference(){cylinder(d=3,h=60,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}

	color("lightblue")translate([337,427,315+60])rotate([0,-9,0])difference(){cylinder(d=3,h=40,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-6.15,427,315+60+38])rotate([0,0,0])difference(){cylinder(d=3,h=42,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-5.3,427,315+60])rotate([0,-4,0])difference(){cylinder(d=3,h=40,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-6.15-2,427,315+60+38])rotate([0,0,0])difference(){cylinder(d=3,h=42,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	
	color("lightblue")translate([337-5.3*2,427,315+60])rotate([0,0,0])difference(){cylinder(d=3,h=81,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-5.3*3,427,315+60])rotate([0,4,0])difference(){cylinder(d=3,h=40,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-5.3*3+2.8,427,315+60+40-1])rotate([0,0,0])difference(){cylinder(d=3,h=42,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-6.15,427,315+60+38+40])rotate([53,7,0])difference(){cylinder(d=3,h=90,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-6.15-2,427,315+60+38+40])rotate([53,6,0])difference(){cylinder(d=3,h=90,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-5.3*2,427,315+60+79])rotate([55,11,0])difference(){cylinder(d=3,h=88,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
	color("lightblue")translate([337-5.3*3+2.8,427,315+60+40-1+40])rotate([55,11,0])difference(){cylinder(d=3,h=88,$fn=30);translate([0,0,-25])cylinder(d=1.5,h=550,$fn=30);}
}

