//import("arducam-camera-holder.stl");

//arducam_case();
//arducam_case();

//arducam_basecase();




module m12lens_screwshim_spacer(h,w){
//best is 21.95
difference(){
union(){
cylinder(r=(28.5)/2,h=h);
translate([-22.5-2,-7.5,0])cube([49,15,5]);
}
cylinder(r=(w)/2,h=h+0.3);

rotate([0,0,0]){
translate([20,0,-0.1])cylinder(r=(4.7)/2,h=h+3);
translate([-20,0,-0.1])cylinder(r=(4.7)/2,h=h+3);
}
for(i=[-45,45]){
rotate([0,0,i]){
translate([18-18,0+20,7])rotate([90,0,0])cylinder(r=(3.1)/2,h=h+13+50);
translate([18-18,0+20,7])rotate([90,0,0])cylinder(r=(3.1)/2,h=h+13+50);
}
}
}
}


module m12lens_screwshim(h,w){
//works with this cylinder(r=(28.5)/2,h=30);
difference(){
cylinder(r=(w)/2,h=h);
cylinder(r=(12)/2,h=h+0.3);
}
}
module m12lens_stubb(h){
//works with this cylinder(r=(28.5)/2,h=30);
difference(){
cylinder(r=(21.25)/2,h=h);
cylinder(r=(17.5)/2,h=h+0.3);
}
}






module arducam_case_standoff_shim(){
color("lightblue")translate([30-40,-12.5+38-38.5,0-20])difference(){
union(){
translate([0,12,0])cube([15,10,2]);
//translate([9,8,-0])cube([20,18,4]);
}
//translate([23,17,-10])cylinder(r=4.7/2,h=130,$fn=30);
translate([23-15.5,17,-30])cylinder(r=3.8/2,h=130,$fn=30);
}
}






module arducam_case_standoff(){
color("purple")translate([30-40,-12.5+38-38.5,0-20])difference(){
union(){
translate([0,12,0])cube([15,10,24]);
translate([9,8,-0])cube([20,18,4]);
}
translate([23,17,-10])cylinder(r=4.7/2,h=130,$fn=30);
translate([23-15.5,17,-30])cylinder(r=3.3/2,h=130,$fn=30);
}
}




module arducam_case_lid(){

color("lightblue")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
translate([-2,-2,-2])cube([30+4,34+4,5]);
}
translate([-0.2,-0.2,-2])cube([30.4,34.4,3]);
translate([15,2.75+10.5+2,-0.5])rotate([0,0,45])cylinder(r=13.5/2,h=10,$fn=4);
translate([4.5,12.5+4,-0.5])cylinder(r=2.8/2,h=10,$fn=30);
translate([4.5,12.5+4+12.5,-0.5])cylinder(r=2.8/2,h=10,$fn=30);
translate([4.5+21,12.5+4,-0.5])cylinder(r=2.8/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,-0.5])cylinder(r=2.8/2,h=10,$fn=30);
}
}



































module arducam_case(){
sh= 1.7+2;
difference(){
union(){
translate([20,-3-sh-1,0])cube([12,34,4]);
//translate([-22+6,-3-sh-1+20-2,0])cube([12+9-13,14-1.5,4]);
//translate([-22+6,-3-sh-1+20-2,0])cube([12+9-13,14-1.5,4]);
//translate([-22+2+3-2,-3-sh-1+25,0])cube([12+9-10-0+5-5-1,7-1.5,4]);
translate([20-42,-3-sh-1,0])cube([12,34,4]);

translate([-22+2+3-2+37.5,-3-sh-1+25-20,0])cube([12+9-10-0+5-5-1,7-1.5,4]);
}
//translate([26-43+3-1.5+40.5,7.5-3-sh+21-2+0.20-20,-2-25])cylinder(r=3.3/2,h=50,$fn=30);
for(i=[-3:22]){
translate([26.5,7.5-3-sh+i,-2])cylinder(r=3.7/2,h=20,$fn=30);
translate([26-43,7.5-3-sh+i,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
/*
*/
}
color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("lime")translate([30-40+21,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([0,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([-1,1,0])rotate([0,0,45])cylinder(r=6/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([21,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([1,1,0])rotate([0,0,45])cylinder(r=6/2,h=4,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("peru")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,6]);
}
translate([3.5,3.5,0])cube([30-7,3.5,6]);
translate([2,2.5,1.5])cube([30-4,34-5,6]);
translate([4.5,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=10,$fn=30);
translate([4.5,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
}



module arducam_lineux(){
sh= 1.7+2;

difference(){
#translate([30-40+7,-12.5+38-38.5+32+2-2,0])cube([16,2,17]);
translate([30-40+10+5,-12.5+38-38.5+32+2+5,0+14])rotate([90,0,0])cylinder(r=3.2/2,h=30,$fn=300);
//#translate([30-40+20,-12.5+38-38.5+32+2+5,0+14])rotate([90,0,0])cylinder(r=3.2/2,h=30,$fn=300);

}
color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("lime")translate([30-40+21,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([0,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([-1,1,0])rotate([0,0,45])cylinder(r=6/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([21,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([1,1,0])rotate([0,0,45])cylinder(r=6/2,h=4,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("peru")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,6]);
}
translate([3.5,3.5,0])cube([30-7,3.5,6]);
translate([2,2.5,1.5])cube([30-4,34-5,6]);
translate([4.5,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=10,$fn=30);
translate([4.5,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
}





























module arducam_case_rtPCR(){
sh= 1.7+2;
difference(){
union(){
translate([20,-3-sh-1,0])cube([12,34,6]);
//translate([-22+6,-3-sh-1+20-2,0])cube([12+9-13,14-1.5,4]);
//translate([-22+6,-3-sh-1+20-2,0])cube([12+9-13,14-1.5,4]);
//translate([-22+2+3-2,-3-sh-1+25,0])cube([12+9-10-0+5-5-1,7-1.5,4]);
translate([20-42,-3-sh-1,0])cube([12,34,6]);
translate([20-42,-3-sh-1+24+3,0])cube([12+42,10-3,6]);
translate([20-42,-3-sh-1-6,0])cube([12+42-41,10,6]);
translate([20-42+41,-3-sh-1-6,0])cube([12+42-41,10,6]);
translate([20-42+9,-3-sh-1+8,0])cube([4,28/2,6+7.5]);
translate([20-42+9+32,-3-sh-1+8,0])cube([4,28/2,6+7.5]);

translate([-22+2+3-2+37.5,-3-sh-1+25-20,0])cube([12+9-10-0+5-5-1,7-1.5,4]);
}
//translate([26-43+3-1.5+40.5,7.5-3-sh+21-2+0.20-20,-2-25])cylinder(r=3.3/2,h=50,$fn=30);
for(i=[-3:22]){
translate([26.5,7.5-3-sh+i,-2])cylinder(r=3.7/2,h=20,$fn=30);
translate([26-43,7.5-3-sh+i,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
//translate([26.5-6,7.5-3-sh-5,-2])cylinder(r=2.2/2,h=20,$fn=30);
//translate([26.5-5-32,7.5-3-sh-5,-2])cylinder(r=2.2/2,h=20,$fn=30);
translate([26.5-6,7.5-3-sh+6,1])cylinder(r=2.2/2,h=20,$fn=30);
translate([26.5-5-32,7.5-3-sh+6,1])cylinder(r=2.2/2,h=20,$fn=30);
/*
*/
}
color("")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("")translate([30-40+21,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([0,12.5,0])color("")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([-1,1,0])rotate([0,0,45])cylinder(r=6/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([21,12.5,0])color("")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([1,1,0])rotate([0,0,45])cylinder(r=6/2,h=4,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,6]);
}
//translate([3.5,3.5,0])cube([30-7,3.5,6]);
translate([2,2.5,1.5])cube([30-4,34-5,6]);
translate([4.5,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=10,$fn=30);
translate([4.5,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
}






module arducam_case_rtPCR_filter(){
sh= 1.7+2;
difference(){
union(){
//translate([-22+6,-3-sh-1+20-2,0])cube([12+9-13,14-1.5,4]);
//translate([-22+6,-3-sh-1+20-2,0])cube([12+9-13,14-1.5,4]);
//translate([-22+2+3-2,-3-sh-1+25,0])cube([12+9-10-0+5-5-1,7-1.5,4]);
/*
translate([20-42,-3-sh-1,0])cube([12,34,6]);
translate([20-42,-3-sh-1+24+3,0])cube([12+42,10-3,6]);
translate([20-42,-3-sh-1-6,0])cube([12+42-41,10,6]);
translate([20-42+41,-3-sh-1-6,0])cube([12+42-41,10,6]);
translate([-22+2+3-2+37.5,-3-sh-1+25-20,0])cube([12+9-10-0+5-5-1,7-1.5,4]);
*/
translate([20-30,-3-sh-1+4,0])cube([12+20,34-6-8,9]);
translate([20-42+9,-3-sh-1+5,0])cube([4,28-10,9]);
translate([20-42+9+32,-3-sh-1+5,0])cube([4,28-10,9]);
}
//translate([26-43+3-1.5+40.5,7.5-3-sh+21-2+0.20-20,-2-25])cylinder(r=3.3/2,h=50,$fn=30);
/*
for(i=[-3:22]){
translate([26.5,7.5-3-sh+i,-2])cylinder(r=3.7/2,h=20,$fn=30);
translate([26-43,7.5-3-sh+i,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
*/
translate([26.5-5.5-32/2,7.5-3-sh-5+10+2.5,-2+6])cylinder(r=25.5/2,h=20,$fn=30);
translate([26.5-5.5-32/2,7.5-3-sh-5+10+2.5,-2])cylinder(r=18/2,h=20,$fn=30);

//translate([26.5-6,7.5-3-sh-5,-2])cylinder(r=4/2,h=20,$fn=30);
//translate([26.5-5-32,7.5-3-sh-5,-2])cylinder(r=4/2,h=20,$fn=30);
translate([26.5-6,7.5-3-sh+6,-2])cylinder(r=4/2,h=20,$fn=30);
translate([26.5-5-32,7.5-3-sh+6,-2])cylinder(r=4/2,h=20,$fn=30);

///translate([26.5-6,7.5-3-sh-5,2.5])cylinder(r=5.1/2,h=20,$fn=30);
//translate([26.5-5-32,7.5-3-sh-5,2.5])cylinder(r=5.1/2,h=20,$fn=30);
translate([26.5-6,7.5-3-sh+6,2.5])cylinder(r=5.1/2,h=20,$fn=30);
translate([26.5-5-32,7.5-3-sh+6,2.5])cylinder(r=5.1/2,h=20,$fn=30);




}
/*
color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("lime")translate([30-40+21,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([0,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([-1,1,0])rotate([0,0,45])cylinder(r=6/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([21,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([1,1,0])rotate([0,0,45])cylinder(r=6/2,h=4,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("peru")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,6]);
}
translate([3.5,3.5,0])cube([30-7,3.5,6]);
translate([2,2.5,1.5])cube([30-4,34-5,6]);
translate([4.5,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=10,$fn=30);
translate([4.5,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
*/
}























module arducam_labbot_mount(){
difference(){
union(){
translate([4,17,0])cube([10+4,20+15-8+12,3]);
translate([4,17-0.05-6,0])cube([10+4,20+15-8-10+6,3+7]);
translate([-10-4.5,10-3-10,0])cube([50,14+10,6]);
}
translate([-4.5,-13+13.5,-10]){
translate([4.5+21/2,12.5+4+6+5+20-5-3.5,-0.5])cylinder(r=3.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5+20+13-5-3.5,-0.5])cylinder(r=3.8/2,h=40,$fn=30);
}

translate([30-40+5.5,-12.5+38-38.5,0]){
translate([4.5+21/2-20,12.5+4.5,-0.5])cylinder(r=3.8/2,h=50,$fn=30);
translate([4.5+21/2-20+40,12.5+4.5,-0.5])cylinder(r=3.8/2,h=50,$fn=30);
}
}
}


module arducam_labbot_spacer(){
difference(){
union(){
//translate([4,17,0])cube([10+4,20+15-8,3]);
translate([-10-4.5,10-3-10,0])cube([50,14,45]);
}
/*
translate([-4.5,-13,-10]){
translate([4.5+21/2,12.5+4+6+5+20-5-3.5,-0.5])cylinder(r=2.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5+20+13-5-3.5,-0.5])cylinder(r=2.8/2,h=40,$fn=30);
}
*/
translate([30-40+5.5,-12.5+38-38.5,0]){
translate([4.5+21/2-20,12.5+4.5,-0.5])cylinder(r=2.8/2,h=50,$fn=30);
translate([4.5+21/2-20+40,12.5+4.5,-0.5])cylinder(r=2.8/2,h=50,$fn=30);
}
}
}

module arducam_labbot_octoprint(){
sh= 1.7+2;
color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){
#cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);
//translate([4,17,0])cube([10+4,20+15-8,3]);
}
cylinder(r=2/2,h=10,$fn=30);
translate([-4.5,-13,-10]){
translate([4.5+21/2,12.5+4+6+5+20-5-3.5,-0.5])cylinder(r=3.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5+20+13-5-3.5,-0.5])cylinder(r=3.8/2,h=40,$fn=30);
}
}
}
}
color("lime")translate([30-40+21,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([0,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([-1,1,0])rotate([0,0,45])cylinder(r=6/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([21,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([1,1,0])rotate([0,0,45])cylinder(r=6/2,h=4,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,6]);
//translate([30,10,0])cube([10,14,6]);
//translate([-10,10,0])cube([8,14,6+2]);
//translate([-10+42,10,0])cube([8,14,6+2]);
translate([-10,10,0])cube([50,14,6]);
}
translate([3.5,3.5,0])cube([30-7,3.5,6]);
translate([2,2.5,1.5])cube([30-4,34-5,16]);
translate([4.5,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=10,$fn=30);
translate([4.5+21/2-20,12.5+4.5,-0.5])cylinder(r=3.8/2,h=50,$fn=30);
translate([4.5+21/2-20+40,12.5+4.5,-0.5])cylinder(r=3.8/2,h=50,$fn=30);
translate([4.5,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
}











module arducam_labbot(){
sh= 1.7+2;
color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){
cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);
//translate([4,17,0])cube([10+4,20+15-8,3]);
}
cylinder(r=2/2,h=10,$fn=30);
translate([-4.5,-13,-10]){
translate([4.5+21/2,12.5+4+6+5+20-5-3.5,-0.5])cylinder(r=3.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5+20+13-5-3.5,-0.5])cylinder(r=3.8/2,h=40,$fn=30);
}
}
}
}
color("lime")translate([30-40+21,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([0,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([-1,1,0])rotate([0,0,45])cylinder(r=6/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([21,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([1,1,0])rotate([0,0,45])cylinder(r=6/2,h=4,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,6]);
//translate([30,10,0])cube([10,14,6]);
//translate([-10,10,0])cube([8,14,6+2]);
//translate([-10+42,10,0])cube([8,14,6+2]);
translate([-10,10,0])cube([50,14,6]);
}
translate([3.5,3.5,0])cube([30-7,3.5,6]);
translate([2,2.5,1.5])cube([30-4,34-5,16]);
translate([4.5,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=10,$fn=30);
translate([4.5+21/2-20,12.5+4.5,-0.5])cylinder(r=3.8/2,h=50,$fn=30);
translate([4.5+21/2-20+40,12.5+4.5,-0.5])cylinder(r=3.8/2,h=50,$fn=30);
translate([4.5,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
}










module arducam_labbot_lid(){
sh= 1.7+2;

color("")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,6]);
//translate([30,10,0])cube([10,14,6]);
//translate([-10,10,0])cube([8,14,6+2]);
//translate([-10+42,10,0])cube([8,14,6+2]);
translate([-10,10,0])cube([50,14,6]);
}
//translate([3.5,3.5,0])cube([30-7,3.5,6]);
translate([2,2.5,1.5])cube([30-4,34-5,16]);
translate([4.5+21/2,12.5+4,-0.5])rotate([0,0,45])cylinder(r=13.5/2,h=10,$fn=4);
translate([4.5+21/2-20,12.5+4.5,-0.5])cylinder(r=3.8/2,h=50,$fn=30);
translate([4.5+21/2-20+40,12.5+4.5,-0.5])cylinder(r=3.8/2,h=50,$fn=30);
//translate([4.5,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([4.5,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([4.5+21,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([4.5+21,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
}

























































module arducam_basecase(){
sh= 1.7+2;
color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("lime")translate([30-40+21,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([0,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([-1,1,0])rotate([0,0,45])cylinder(r=6/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([21,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([1,1,0])rotate([0,0,45])cylinder(r=6/2,h=4,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,6]);
}
translate([3.5,3.5,0])cube([30-7,3.5,6]);
translate([2,2.5,1.5])cube([30-4,34-5,6]);
translate([4.5,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=10,$fn=30);
translate([4.5,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
}








module arducam_basecase_attachstem(){
color("")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
//cube([30,34,3]);
//translate([10,23,0])cube([10,8,8]);
//translate([10,-6+5,0])cube([10,8,8]);
translate([10,23+20,-10])cube([10,10,10]);
translate([10,23+20+6,-30])cube([10,4,30]);
}
translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4-19+5,-0.5])cylinder(r=2.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5,-0.5])cylinder(r=2.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5+20,-17.5])cylinder(r=2.8/2,h=40,$fn=30);
for(i=[-2:2]){
translate([4.5+21/2,12.5+4+6+5+20+10,-17.5-5+i])rotate([90,0,0])cylinder(r=3.8/2,h=40,$fn=30);
}
translate([4.5,12.5+4,-0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5,12.5+4+12.5,-0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,-0.5])cylinder(r=2/2,h=10,$fn=30);
}
}

module arducam_basecase_cover(){
sh= 1.7+2;
color("")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,3]);
translate([10,23,0])cube([10,8,8]);
translate([10,-6+5,0])cube([10,8,8]);
translate([10,23+10,0])cube([10,20,3]);
}
translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5,-0.5])cylinder(r=2.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4-19+5,-0.5])cylinder(r=2.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5+20,-0.5])cylinder(r=3.8/2,h=40,$fn=30);
translate([4.5,12.5+4,-0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5,12.5+4+12.5,-0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,-0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,-0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
}


module arducam_basecase_cover_hd(){
sh= 1.7+2;
color("")translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,3]);
//translate([10,23,0])cube([10,8,8]);
//translate([10,-6+5,0])cube([10,8,8]);
translate([10-2,23+10,0])cube([10+4,20+15-8,3]);
}
translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5,-0.5])cylinder(r=2.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4-19+5,-0.5])cylinder(r=2.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5+20-5,-0.5])cylinder(r=3.8/2,h=40,$fn=30);
translate([4.5+21/2,12.5+4+6+5+20+13-5,-0.5])cylinder(r=3.8/2,h=40,$fn=30);
translate([4.5,12.5+4,-0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5,12.5+4+12.5,-0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,-0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,-0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
}


























module arducam_rotate_case(){
sh= 1.7+2;
difference(){
union(){
//translate([20,-3-sh-1,0])cube([12,34,6]);
//translate([-22+6,-3-sh-1+20-2,0])cube([12+9-13,14-1.5,4]);
//translate([-22+6,-3-sh-1+20-2,0])cube([12+9-13,14-1.5,4]);
//translate([-22+2+3-2,-3-sh-1+25,0])cube([12+9-10-0+5-5-1,7-1.5,4]);
//translate([20-42,-3-sh-1,0])cube([12,34,4]);
translate([20-42+4,-3-sh-1+11-14,0])cube([8,39,6]);

//translate([-22+2+3-2+37.5,-3-sh-1+25-20,0])cube([12+9-10-0+5-5-1,7-1.5,4]);
}
for(i=[-20:20]){
translate([26.5-43+2,10.5+i*0.5,-12])cylinder(r=3/2,h=120,$fn=30);
}
//translate([26-43+3-1.5+40.5,7.5-3-sh+21-2+0.20-20,-2-25])cylinder(r=3.3/2,h=50,$fn=30);

/*
for(i=[-3:22]){
translate([26.5,7.5-3-sh+i,-2])cylinder(r=3.7/2,h=20,$fn=30);
translate([26-43,7.5-3-sh+i,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
*/
}

translate([10,5,0])rotate([0,0,90]){
color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("lime")translate([30-40+21,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([0,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([-1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([-1,1,0])rotate([0,0,45])cylinder(r=6/2,h=5,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
translate([21,12.5,0])color("lime")translate([30-40,-12.5+38-38.5,0])difference(){
translate([4.5,16.5,0]){
difference(){union(){cylinder(r=5/2,h=5,$fn=30);translate([1,0,0])rotate([0,0,45])cylinder(r=5/2,h=5,$fn=4);translate([1,1,0])rotate([0,0,45])cylinder(r=6/2,h=4,$fn=4);}cylinder(r=2/2,h=10,$fn=30);}
}
}
color("")rotate([0,0,0])translate([30-40,-12.5+38-38.5,0])difference(){
union(){
cube([30,34,6]);
}
translate([3.5,3.5,0])cube([30-7,3.5,6]);
translate([2,2.5,1.5])cube([30-4,34-5,6]);
translate([4.5,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21/2,12.5+4,-0.5])cylinder(r=3.7/2,h=10,$fn=30);
translate([4.5,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4,0.5])cylinder(r=2/2,h=10,$fn=30);
translate([4.5+21,12.5+4+12.5,0.5])cylinder(r=2/2,h=10,$fn=30);
//translate([26.5-43/2,7.5-3-sh+4,-2])cylinder(r=3.7/2,h=20,$fn=30);
}
}
}










