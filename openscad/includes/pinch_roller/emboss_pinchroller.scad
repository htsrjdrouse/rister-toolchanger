

//translate([200,240,230])mirror([1,0,0])rotate([-90,90,0])motorized_pinchroller_assy();
//color("silver")import("blanktap_mod_extend2.stl");
//translate([350,240,230+5])mirror([1,0,0])rotate([-90,90,0])motorized_pinchroller_assy();
//blanktap_mod();
//translate([1,0,0])blankdie_mod();
//emboss60notscrews_down_mod();

mirror([0,0,1])emboss60notscrews_down_mod();

module motorized_pinchroller_assy(){
emboss60notscrews_down_mod();
/*
difference(){
color("silver")import("blanktap_mod_extend2.stl");
//#translate([0,0,15])cylinder(d=40,h=100,$fn=50);
}
#translate([0,0,5+9.6])emboss60notscrews_up_mod();
emboss60notscrews_down_mod();
pinchroller_motormount();
color("lime")translate([1,0,0])import("blankdie_mod_extend.stl");
*/
/*
//translate([0,0,5+9.6])import("emboss60notscrews-up_mod.stl");
*/

}


module emboss60notscrews_up_mod(){
union(){
import("emboss60notscrews-up_mod.stl");
difference(){
translate([20,-8+20,43-40])color("")cube([5,20,25+40]);
translate([20+140,-18+20+25,78-25])rotate([0,-90,0])cylinder(d=3.5,h=300,$fn=50);
translate([20+140,-18+20+25,78-70])rotate([0,-90,0])cylinder(d=3.5,h=300,$fn=50);
}
/*
*/
}
}



/*
difference(){
color("pink")import("emboss60notscrews-down.stl");
translate([20,6,-30])#cylinder(d=3.7,h=30,$fn=50);
translate([20,-10,-30])#cylinder(d=3.7,h=30,$fn=50);
translate([20,-24,-30])#cylinder(d=3.7,h=30,$fn=50);
translate([0,0,-30])#cylinder(d=12,h=50,$fn=50);
}
*/

//translate([-15,20,1])cube([10,10,58]);


module blanktap_mod(){
union(){
color("lightblue")import("blanktap.stl");
difference(){
color("lightblue")union(){
translate([0,0,-23+83])rotate([0,0,0])cylinder(d=30,h=9+5.5,$fn=150);
translate([0,0,-23+10])rotate([0,0,0])cylinder(d=11,h=20+15,$fn=50);
translate([0,0,-23])rotate([0,0,0])cylinder(d=18,h=12,$fn=50);
}
translate([0,0,-23+83-1])rotate([0,0,0])cylinder(d=10.1,h=39,$fn=150);
#translate([0,0,-24])rotate([0,0,0])cylinder(d=5.1,h=23-3,$fn=50);
translate([0,0,-24+7])rotate([0,90,0])cylinder(d=2.6,h=23,$fn=50);
translate([0,0,-24+7])rotate([90,0,0])cylinder(d=2.6,h=23,$fn=50);
}
}
}


module blankdie_mod(){
difference(){
color("lime")union(){
translate([-30,0,0])color("lime")import("blankdie.stl");
translate([0-30,0,-23+83])rotate([0,0,0])cylinder(d=30,h=9+5.5,$fn=150);
}
translate([-30,0,-23+83-1-25])rotate([0,0,0])cylinder(d=10.1,h=75,$fn=150);
}
}






module emboss60notscrews_down_mod(){
union(){
difference(){
color("pink")import("emboss60notscrews-down_mod.stl");
translate([65-19,-0.0625-14.5,-10])translate([20-66.0,14.5,-6])#cylinder(d=19,h=20,$fn=50);
}
translate([0,-0.0625,0])difference(){
translate([20-66.0,14.5,-6])cylinder(d=10.2,h=20,$fn=50);
translate([20-66.0,14.5,-6])cylinder(d=5.15,h=35,$fn=50);
}

translate([65,-0.0625,0])difference(){
translate([20-66.0,14.5,-6])cylinder(d=10.2,h=20,$fn=50);
translate([20-66.0,14.5,-6])cylinder(d=5.15,h=35,$fn=50);
}
translate([65,-0.0625-54.105,0])difference(){
translate([20-66.0,14.5,-6])cylinder(d=10.2,h=20,$fn=50);
translate([20-66.0,14.5,-6])cylinder(d=5.15,h=35,$fn=50);
}
translate([0,-0.0625-28.875,0])difference(){
translate([20-66.0,14.5,-6])cylinder(d=10.2,h=20,$fn=50);
translate([20-66.0,14.5,-6])cylinder(d=5.15,h=35,$fn=50);
}
}
}

//color("lime")import("emboss60notscrews-knoob.stl");
/*
union(){
import("emboss60notscrews-up.stl");
translate([-29,0,60])#cylinder(d=12,h=8,$fn=50);
translate([-29,0,53])#cylinder(d=10,h=15,$fn=50);
}
*/


module pinchroller_motormount(){
translate([0,0,4]){
translate([17.5,17.5,-50-25])rotate([90,0,0])color("grey")import("NEMA14.stl");
difference(){
translate([-8,-35.5,-6.5])rotate([0,-90,0])nema14_mount();
translate([20,6,-30])cylinder(d=2.8,h=30,$fn=50);
translate([20,-10,-30])cylinder(d=2.8,h=30,$fn=50);
translate([20,-24,-30])cylinder(d=2.8,h=30,$fn=50);
translate([120,-18,-22])rotate([0,-90,0])cylinder(d=3.6,h=300,$fn=50);
translate([120,-0,-85])rotate([0,-90,0])cylinder(d=3.6,h=300,$fn=50);
}
}
}

/*
*/

module nema14_mount(){
translate([-100,22,-30])color("lightblue")difference(){
union(){
//#translate([12,0,0])cube([30,23,16.2]);
translate([7.5+20+43,7-7-4-20,0-3])cube([17+32+17-43,22+32,10]);
translate([7.5+20-10,7-7-4,0-3])cube([17+32+17+10,22+12,8]);
translate([7.5+64,7-7-4,0])cube([5,22+12,40]); 
}   
translate([7.5+63.3,7-7-4+17.4,22.3])rotate([0,90,0])cylinder(d=23.5,h=30,$fn=50);

translate([7.5+63.3-3+16.6,7-7-4+17.4-15-2.9,35.3-60])rotate([0,0,0])cylinder(d=3.8,h=130,$fn=50);
        
hull(){
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3+5])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
}   
translate([0,26,0])hull(){
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3+5])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
}   
translate([7.5+63.3-3,7-7-4+17.4-15+2.1,35.3-26])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);
translate([7.5+63.3-3,7-7-4+17.4-15+2.1+26,35.3-26])rotate([0,90,0])cylinder(d=3.8,h=30,$fn=50);


/*
#translate([12,0,0]){
translate([9.5,4,0])cylinder(d=3.5,h=30,$fn=50);
translate([9.5,4+15,0])cylinder(d=3.5,h=30,$fn=50);
translate([0,0,5]){
translate([9.5,4,0])cylinder(d=7.5,h=30,$fn=50);
translate([9.5,4+15,0])cylinder(d=7.5,h=30,$fn=50);
}   
}
*/


}
}

