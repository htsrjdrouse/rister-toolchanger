include <syringe_pump_typco.scad>
include <pipette_tip_case_p20_LTS.scad>
include <pipette_process.scad>
include <washstation.scad>

//translate([0,3,-22])color("pink")translate([337-12.5,427,300-15+0.2+0.8])rotate([0,180,90])luer_lock_case_lid();

//include <organized_openscad.scad>
luerlock_nozzle_case();
//translate([400-70+3-210,426.5+3+124,330-3+50-124])rotate([0,0,-90])color("lime")luerlock_dispenser_assy_remover();
//luer_lock_microwell();
//luer_lock_alignment_key();

//translate([0,3,-1])luerlock_pipette_assy();
//linearactuator_pipette_holder_4pipette_luerlock();
//pipette_assembly();
//tuberculin_syringe_015ml();

//luerlock_connector();
//pipette_13g();


//translate([0,0,0])luerlock_nozzle_bottom();
//luer_lock_case_lid();
//luerlock_nozzle_case();

//linearactuator_pipette_holder_4pipette_luerlock();
//pipette_holder_4tip_luerlock_lid();
//translate([-0.5-1,-0.7,0])rotate([0,180,180])pipette_holder_4tip_luerlock();

//import("linearactuator_rack_stub.stl");
//import("linearactuator_rack_stub.stl");


module pipette_assembly(){
translate([339,430+1,295+6])rotate([0,180,90])color("lightgreen")translate([0,-1.9,10.5+12+1]){
for(i=[0:3]){
translate([0,-5.7+(i*11.5),-17-8-4])rotate([0,180,0]){
luerlock_connector();
pipette_13g();
cylinder(d=3,h=60,$fn=100);
if(i==0){
translate([0,0,60])rotate([-25,-4,0])cylinder(d=3,h=35,$fn=100);
translate([-2.3,3.5+10,60+28])rotate([0,0,0])cylinder(d=3,h=70,$fn=100);
translate([-2.3,3.5+10,60+28+69])rotate([0,-50,0])cylinder(d=3,h=80,$fn=100);
}
if(i==1){
translate([0,0,60])rotate([-10,-4,0])cylinder(d=3,h=50,$fn=100);
translate([-3.4,8.6,60+48.5])rotate([0,0,0])cylinder(d=3,h=46,$fn=100);
translate([-2.5,8.6,60+50+44])rotate([0,-48,0])cylinder(d=3,h=82,$fn=100);
}
if(i==2){
translate([0,0,60])rotate([0,-4,0])cylinder(d=3,h=50,$fn=100);
translate([-3.5,0,60+50])rotate([0,0,0])cylinder(d=3,h=47,$fn=100);
translate([-3.5,0,60+50+47])rotate([2,-50,0])cylinder(d=3,h=80,$fn=100);
}
if(i==3){
translate([0,0,60])rotate([0,-4,0])cylinder(d=3,h=50,$fn=100);
translate([-3.5,0,60+50])rotate([9,0,0])cylinder(d=3,h=47,$fn=100);
translate([-3.5,-7.2,60+50+46])rotate([3,-50,0])cylinder(d=3,h=82,$fn=100);
}

}
}
}
}


module pipette_25g(){
translate([0,0,8]){
cylinder(d=8,h=3,$fn=100);
translate([0,0,-29])cylinder(d2=5,d1=1,h=29,$fn=100);
}
}


module pipette_13g(){
translate([0,0,8]){
cylinder(d=8,h=3,$fn=100);
translate([0,0,-29])cylinder(d2=5,d1=3.5,h=29,$fn=100);
}
}


module pipette_holder_4tip_luerlock_lid(){
difference(){
pre_pipette_holder_4tip_luerlock_lid();
for(i=[-2:2]){
for(j=[-2:2]){
translate([i*0.2,j*0.2,0])import("linearactuator_rack_stub.stl");
}
}
}
}

module pre_pipette_holder_4tip_luerlock_lid(){
translate([400-70+4.5,426.5,330-3])rotate([0,0,-90]){
translate([0,0,-13]){
translate([-0.5-1,-0.7,0])rotate([0,180,180])
difference(){
translate([0+0.5,4.5,-3])rounded_box_minkowski(size = [10+4+5, 20+2+6.5+6+10+5+5, 13], radius = 2, center = true);
translate([0,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+10+5, 10], radius = 2, center = true);
translate([0+1,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+10+5, 10], radius = 2, center = true);
for(i=[-2:2]){
for(j=[-2:2]){
translate([i*0.2,j*0.2,-0.25]){
translate([0,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+10+5, 10], radius = 2, center = true);
translate([0+1,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+10+5, 10], radius = 2, center = true);
}
}
}
translate([14,0-2,17.8-18])rotate([0,90,0]){
l = 6+12;
for(i=[0:3]){
translate([0,-5.8+11.5*i-4.9,-21.4-12])cylinder(d=2.5,h=l,$fn=100);
}
}
translate([0,-2,17.8]){
l = 7.2;
for(i=[0:3]){
translate([0,-5.8+11.5*i-4.9,-21.4-3.5-20])cylinder(d1=7.5,d2=7.5,h=63,$fn=30);
}
}
}
}
}
}
//linearactuator_pipette_holder_4pipette_luerlock();


//translate([220.,578,230])color("pink")rotate([0,180,90])washbowl_4tip_luerlock();

//color("lime")linearactuator_pipette_holder_4pipette_luerlock();
//luerlock_pipette_tips_p200LTS();
//pipette_assy_for_peek_nozzle_4channel();


//translate([0,0,0])luerlock_pipette_tipcase();
//translate([110,-12,-50])luerlock_pipette_assy();


//translate([400-70+3-210,426.5+3+124,330-3+50-124])rotate([0,0,-90])color("lime")luerlock_dispenser_assy_remover();

//luerlock_tipcase_makesquare();

//linearactuator_pipette_holder_4pipette_luerlock();

//linearactuator_pipette_holder_p200LTS();

//luerlock_4dispenser_reagent_reservoir_larger();
/*
difference(){
import("../stls/LiquidDispenserTool0/pipette_loading_module_rack.stl");
translate([330-0.7,430-2,314.2-0.2])rotate([0,0,90])rounded_box_minkowski(size = [10+4+2, 20+2+6.5+6+2, 7+0.3], radius = 2, center = true);
//}
*/

module luerlock_pipette_assy(){
//translate([0,0,0])luerlock_nozzle_bottom();
translate([0,0,0]){
translate([0,0,14]){

/*
translate([0,0,-36])color("pink")translate([337-12.5,427,300-15+0.2+0.8])rotate([0,180,90])luer_lock_case_lid();
translate([0,0,-36])color("lime")luerlock_nozzle_case();
translate([0,0,-36])luerlock_nozzle_bottom();
*/
/*
for(i=[0:3]){
translate([324-10.6+i*10.2,427,280])rotate([0,-90,0])import("SyringeNeedleWithLuerYellow20Gauge002.stl");
}
*/


}

//tuberculin_assay
translate([-5.5-0.7-1.3,0,0-4+6.5-24]){
for(i=[0:3]){
//translate([319+i*11.5,427,309])rotate([0,180,0])tuberculin_syringe_015ml();
translate([319+i*11.5,427,309-30])rotate([0,0,0])pipette_25g();
}
}
/*
*/


}
}

/*

*/

//luerlock_pipette_tipcase_holder();
//luerlock_pipette_tipcase_holder();

//translate([345.5-1-37,439,250+20])rotate([0,180,90])washbowl_4tip_luerlock();


//translate([336,438,430])rotate([0,0,90])luerlock_pipette_tipcase();




//translate([337-12.5,427,300])rotate([0,180,90])peek_nozzle_part1_4channel_p20LTS(); 
//translate([337-12.5,427,300-15])rotate([0,180,90])peek_nozzle_part2_4channel_p20LTS(); //nozzle end

//translate([337-12.5,427,300-15+0.2])rotate([0,180,90])peek_nozzle_part3_4channel_p20LTS();
//peek_nozzle_part1and2_4channel_p20LTS();

//translate([337-12.5,427,300-15])rotate([0,180,90])luerlock_nozzle_case();


/*
difference(){
union(){
//translate([337-12.5,427,300-15])rotate([0,180,90])luerlock_nozzle_case_pre();
//color("pink")translate([337-12.5,427,300-15+0.2+0.8])rotate([0,180,90])luer_lock_case_lid();
}

translate([319+10.2-3,427-10,309-15])cube([30,30,40]);
translate([-5.5,0,0-4+6.5]){
//translate([319+30.2,427,309])cylinder(d=6.5+0.3,h=20,$fn=30);
translate([319,427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d2=7.2,d1=6.4,h=6.5,$fn=50);
translate([319+10.2,427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d2=7.2,d1=6.4,h=6.5,$fn=50);
translate([319+20.4,427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d2=7.2,d1=6.4,h=6.5,$fn=50);
translate([319+30.6,427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d2=7.2,d1=6.4,h=6.5,$fn=50);
translate([319,427,309])rotate([0,180,0])tuberculin_syringe_015ml();
translate([319+10.2,427,309])rotate([0,180,0])tuberculin_syringe_015ml();
translate([319+20.4,427,309])rotate([0,180,0])tuberculin_syringe_015ml();
translate([319+30.6,427,309])rotate([0,180,0])tuberculin_syringe_015ml();
}
}
*/


module p200_lts(){
//translate([0,0,13.0])color("lightgreen")cylinder(d2=7.5,d1=7.1,h=8,$fn=30); //this part I cut out to assemble
difference(){union(){
color("pink")cylinder(d2=7.1,d1=6.1,h=13,$fn=30);
color("lime")translate([0,0,-9.])cylinder(d2=5,d1=4.8,h=9,$fn=30);
color("lightblue")translate([0,0,-9.-6.0])cylinder(d2=4.5,d1=4,h=6,$fn=30);
color("peru")translate([0,0,-9.-6.0-10])cylinder(d2=3.85,d1=2.85,h=10,$fn=30);
//color("")translate([0,0,-9.-6.0-10-10])cylinder(d2=2.6,d1=1,h=10,$fn=30);
}
cylinder(d2=7.1-0.4,d1=6.1-0.4,h=13.1,$fn=30);
translate([0,0,-9.])cylinder(d2=5-0.4,d1=4.8-0.4,h=9.1,$fn=30);
translate([0,0,-9.-6.0])cylinder(d2=4.5-.4,d1=4-0.4,h=6.1,$fn=30);
translate([0,0,-9.-6.0-10.1])cylinder(d2=3.85-0.4,d1=2.85-0.4,h=10.2,$fn=30);
}
}


module luerlock_pipette_tips_p200LTS(){
translate([400-70+4.5-13,428,330-5])rotate([0,0,-90]){
translate([0,0,-13]){
color("lightpink")translate([0,-1.9,10.5+12+1]){
for(i=[0:3]){
translate([0,-5.7+(i*10.2),-17-8+2])cylinder(d=4/2,h=70,$fn=30);
translate([0,-5.7+(i*10.2),-17-8+2])p200_lts();
}
translate([0,-5.7+(0*10.2),-17-8+2+70])rotate([-5,0,0])cylinder(d=4/2,h=80,$fn=30);
translate([0,-5.7+(0*10.2)+7,-17-8+2+70+80])rotate([-4,48,0])cylinder(d=4/2,h=80,$fn=30);

translate([0,-5.7+(1*10.2),-17-8+2+70])rotate([-0,0,0])cylinder(d=4/2,h=80,$fn=30);
translate([0,-5.7+(1*10.2),-17-8+2+70+80])rotate([-2,48,0])cylinder(d=4/2,h=80,$fn=30);

translate([0,-5.7+(2*10.2),-17-8+2+70])rotate([5,0,0])cylinder(d=4/2,h=80,$fn=30);
translate([0,-5.7+(2*10.2)-7,-17-8+2+70+79])rotate([0,48,0])cylinder(d=4/2,h=80,$fn=30);

translate([0,-5.7+(3*10.2),-17-8+2+70])rotate([19,0,0])cylinder(d=4/2,h=40,$fn=30);
translate([0,-5.7+(3*10.2)-13,-17-8+2+70+38])rotate([0,0,0])cylinder(d=4/2,h=40,$fn=30);
translate([0,-5.7+(3*10.2)-13,-17-8+2+70+38+40])rotate([0,48,0])cylinder(d=4/2,h=82,$fn=30);
}

}
}
}


module luerlock_4dispenser_reagent_reservoir_larger(){
translate([300,410,250])difference(){
translate([2,0,0])cube([55,20,17]);
for(x=[0:3]){
translate([14+x*10.2,10,2])cylinder(d1=1.5,d2=10,$fn=30,h=16);
}
}
}





module luerlock_4dispenser_reagent_reservoir(){
translate([300,410,250])difference(){
translate([2,0,0])cube([55,20,10]);
for(x=[0:3]){
translate([14+x*10.2,10,2])cylinder(d1=1.5,d2=6,$fn=30,h=8.3);
}
}
}



module linearactuator_pipette_holder_4pipette_luerlock(){

difference(){
import("linearactuator_rack_stub.stl");
a=[11.2,11.9,11.2,11.2];
translate([400-70+4.5-11.5,426.5,330-3-2])rotate([0,0,-90])translate([-0.5-1,-0.7,13])for(i=[0:3]){
translate([0,-5.8+11.5*i-4.9,-21.4-3.5])cylinder(d1=8,d2=8,h=13,$fn=30);
translate([0,-5.8+11.5*i-4.9,-21.4-3.5+2])cylinder(d=a[i],h=18,$fn=30);
}
}

translate([400-70+4.5,426.5,330-3])rotate([0,0,-90]){
translate([0,0,-13]){
translate([-0.5-1,-0.7,0])rotate([0,180,180])pipette_holder_4tip_luerlock();
}
}


}


module pipette_holder_4tip_luerlock(){
$fn = 50; // Increase $fn for smoother curves

/*
color("lightblue")translate([0,-1.9,10.5+12-20]){
for(i=[0:3]){
difference(){
translate([0,-5.7+(i*5.2),-17-8-4-80-60])cylinder(d=2,h=106+60,$fn=100);
translate([0,-5.7+(i*5.2),-17-8-4.1-80-60])cylinder(d=1,h=106+60,$fn=100);
}
}
}
*/
/*
color("lightgreen")translate([0,-1.9,10.5+12+1]){
for(i=[0:3]){
translate([0,-5.7+(i*11.5),-17-8-4])rotate([0,180,0]){
luerlock_connector();
pipette_13g();
}
}
}
*/

/*
color("lightgreen")translate([0,-1.9,10.5+12+1]){
for(i=[0:3]){
difference(){
translate([0,-5.7+(i*5.2),-17-8-4])cylinder(d1=5,d2=2.5,h=26,$fn=100);
translate([0,-5.7+(i*5.2),-17-8-4.1])cylinder(d1=3,d2=0.8,h=26,$fn=100);
}
}
}
//for set screws
color("silver")translate([0,-1.9,10.5+12]){
for(i=[0:3]){
translate([0-6.5,-5.7+(i*10.4),-17-5.5])rotate([0,90,0])cylinder(d=3.5,h=1.5,$fn=100);
}
}
*/
difference(){
union(){
translate([0-6,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+15, 10], radius = 2, center = true);
translate([0,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+15, 10], radius = 2, center = true);
translate([0+1,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+15, 10], radius = 2, center = true);
}
translate([0-4,-2,17.8]){
l = 7.2;
a=[11.2,11.2,11.2,11.2];
for(i=[0:3]){
translate([0,-5.8+11.5*i-4.9,-21.4-3.5])cylinder(d1=8,d2=8,h=13,$fn=30);
translate([0,-5.8+11.5*i-4.9,-21.4-3.5+2])cylinder(d=a[i],h=8,$fn=30);
}
}
translate([14-6,0-2,17.8-18])rotate([0,90,0]){
l = 6;
for(i=[0:3]){
translate([0,-5.8+11.5*i-4.9,-21.4])cylinder(d=1.8,h=l,$fn=100);
}
}
}
}









module washbowl_4tip_luerlock(){
xd=5.5;
xdd=1.5;
translate([0,-43,0])difference(){
union(){
translate([-20,2,0])rotate([0,0,90])difference(){
translate([0,-21,5])cube([25,20+13+18,5]);
translate([0,3,0])for(i=[0:30]){
translate([6,-13,5-3]){translate([0,i,-0])cylinder(r=10/2,h=4);translate([0,i,4])cylinder(r=4.7/2,h=10+6,$fn=30);}
translate([19,-13,5-3]){translate([0,i,-0])cylinder(r=10/2,h=4);translate([0,i,4])cylinder(r=4.7/2,h=10+6,$fn=30);}
}
}
translate([0,0,-3])cube([25,40,13]);
}
translate([10,32,-5])cube([5,20,7]);
translate([9,12-7,-2-3])cube([8,34,23]);
translate([4,6,-5])cylinder(r=3.7/2,h=20);
translate([4,6,-3.1])cylinder(r=6.2/2,h=6.5);
translate([25-4,6,-5])cylinder(r=3.7/2,h=20);
translate([25-4,6,-3.1])cylinder(r=6.2/2,h=6.5);
}
translate([0,-3,0])difference(){
translate([0,0,-3])cube([25,40,13]);
translate([10,-10,0])cube([5,20,3]);
//translate([12,60,0])sphere(r=10);
for (y = [0:0]) // two iterations, z = -1, z = 1
{
    translate([0.5, y, 0])
    translate([12,27.5-(15.5*y)-8-1,-1])rotate([-5,0,0])scale([0.7,2.1,1])sphere(r=10);
    //translate([12.5,27.5-(15.*y)-8,2.5])sphere(r=5);
    translate([12.5,27.5-(15.5*y)-8,2])cylinder(r=3.5/2,h=10);
    cube(size = 1, center = false);
}
translate([4,4,-5])cylinder(r=3.7/2,h=20);
translate([4,4,-3.1])cylinder(r=6.2/2,h=6.5);
translate([25-4,4,-5])cylinder(r=3.7/2,h=20);
translate([25-4,4,-3.1])cylinder(r=6.2/2,h=6.5);
translate([4,40-4,-5])cylinder(r=3.7/2,h=20);
translate([4,40-4,-3.1])cylinder(r=6.2/2,h=6.5);
translate([25-4,40-4,-5])cylinder(r=3.7/2,h=20);
translate([25-4,40-4,-3.1])cylinder(r=6.2/2,h=6.5);
translate([4,-30-4,-5])cylinder(r=3.7/2,h=20);
translate([4,-30-4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([25-4,-30-4,-5])cylinder(r=3.7/2,h=20);
translate([25-4,-30-4,-0.1])cylinder(r=6.2/2,h=3.5);
}
}














module luerlock_tipcase_makesquare(){
translate([0-0.5,0-2,-130]){
difference(){
translate([-9,-32,-14])cube([14,64+20,5]);
translate([0,0,0]){
translate([0,19,0]){
translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23,-11])cylinder(d=10.5,h=20,$fn=100);
}
translate([0,-46,0]){
translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23,-11])cylinder(d=10.5,h=20,$fn=100);
}
}
}
}
}





module luerlock_dispenser_assy_remover(){
difference(){
union(){
translate([-7+5-3,0,-.75])rounded_box_minkowski(size = [17+20, 20+2+6.5+30+15+16, 4], radius = 0.5, center = true);
translate([-18,0,-.75])rounded_box_minkowski(size = [10, 20+2+6.5+22, 4], radius = 0.5, center = true);
translate([-23,0,-.75])rounded_box_minkowski(size = [10, 20+2+6.5+22, 4], radius = 0.5, center = true);
translate([-23+3.5,0,-.75-7.5-5])rounded_box_minkowski(size = [15, 20+2+6.5+22+12, 4+25], radius = 0.5, center = true);
}
translate([-2+5,0,-.75])rounded_box_minkowski(size = [19+5, 20+2+6.5+12+10+16, 7], radius = 2, center = true);
translate([-18.8,17.5,-.75-5-45])cylinder(d=6,h=85,$fn=100);
translate([-18.8,-17.5,-.75-5-45])cylinder(d=6,h=85,$fn=100);
translate([-18.8,17.5,-.75-5-22+4])cylinder(d=11,h=85,$fn=100);
translate([-18.8,-17.5,-.75-5-22+4])cylinder(d=11,h=85,$fn=100);

}
}



module luerlock_substractor(){

corner_radius = 1;  // Adjust this value to change roundness
translate([337-12.5,427,300-15+0.2+0.8-20+14])rotate([0,180,90])translate([-4-2-2-2,-5-2-15-6-2,-2-16-16-4-2-4])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5, 7.5-1+4+2+6.5], corner_radius);
sub=9;
asub= 6;
translate([337-12.5-sub/2,427-asub/2,300-15+0.2+0.8-20])rotate([0,180,90])translate([-4-2-2-2,-5-2-15-6-2,-2-16-16-4-2-4])rounded_cube([8+4+4+4-asub, 10+4+15+10+4+8.5-sub, 7.5-1+4+2+6.5], corner_radius);

}

module luerlock_pipette_tipcase(){

translate([446,396,374])rotate([0,0,90]){
translate([0-0.5,0-2,-130]){

translate([-15-35,8+19,-9])rotate([0,90,0])tslot20(100);
translate([-15-35,8-46,-9])rotate([0,90,0])tslot20(100);
translate([20,0,0])luerlock_pipette_tipcase_holder();
translate([-15,0,0])luerlock_pipette_tipcase_holder();
translate([-30-164.5,2,-151.5+130])rotate([0,-90,0])luerlock_tipcase_makesquare();
translate([-30+223.5,2,-151.5-5+130])rotate([0,90,0])luerlock_tipcase_makesquare();
}
}

}


module luerlock_pipette_tipcase_holder(){
difference(){
union(){
color("peru"){
translate([-17+10-1.5,13.5+25,-14])cube([10+3,13,10]);
translate([-17+5,13.5-3+23,-14])cube([23,10-0.5+3,10]);

translate([-17+5-2,13-36,-14])cube([5+18+4,10+36+20,33]);
//translate([-17+3+20,13-36,-14])cube([5,10+36+20,6]);

translate([-17+5,13-36,-14])cube([23,10+3,10]);
translate([-17+10-1.5,13-36-8,-14])cube([10+3,18,10]);
}
}
corner_radius = 1;  // Adjust this value to change roundness
translate([-2,0,5])
for(i=[-1:1]){
for(j=[-1:1]){
//translate([337-12.5,427,300-15+0.2+0.8-20+14])rotate([0,180,90])
//translate([-4-2-2-2,-5-2-15-6-2,-2-16-16-4-2-4])

translate([2,0,0]){
translate([-10.5+j/2,-16.5+i/2,5])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5, 7.5-1+4+2+6.5], corner_radius);
translate([-10.5+i/2,-16.5+j/2,5])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5, 7.5-1+4+2+6.5], corner_radius);

sub=9;
asub= 6;

translate([0,0,-13.5]){
translate([-10.5+j/2+asub/2,-16.5+i/2+sub/2,5])rounded_cube([8+4+4+4-asub, 10+4+15+10+4+8.5-sub, 7.5-1+4+2+6.5], corner_radius);
translate([-10.5+i/2+asub/2,-16.5+j/2+sub/2,5])rounded_cube([8+4+4+4-asub, 10+4+15+10+4+8.5-sub, 7.5-1+4+2+6.5], corner_radius);
translate([-10.5+i/2+asub/2,-16.5+j/2+sub/2,-5-2])rounded_cube([8+4+4+4-asub, 10+4+15+10+4+8.5-sub, 7.5-1+4+2+6.5], corner_radius);
}
}


/*
translate([-6.25+j/2,-5-2-7.5+2.7+i/2,-2-13])rounded_cube([12, 10+4+10, 7.5+10], corner_radius);
translate([-6.25+i/2,-5-2-7.5+2.7+j/2,-2-13])rounded_cube([12, 10+4+10, 7.5+10], corner_radius);
translate([-6.25+j/2,-5-2-7.5+i/2,-2-10])rounded_cube([8+4, 10+4+15, 7.5+10], corner_radius);
translate([-6.25+i/2,-5-2-7.5+j/2,-2-10])rounded_cube([8+4, 10+4+15, 7.5+10], corner_radius);
*/
}
}
translate([-2,23+19,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23+19,-11])cylinder(d=10.5,h=50,$fn=100);

translate([0,-46,0]){
translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23,-11])cylinder(d=10.5,h=50,$fn=100);
}
}
}









module luerlock_nozzle_bottom(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
//translate([337-12.5,427,300-15+0.2+0.8])rotate([0,180,90])translate([-4-2-2,-5-2-15-6+0.2,-2-15-4-12])rounded_cube([8+4+4, 10+4+15+18.5-0.4, 6.5+1+16-6], corner_radius);
translate([337-12.5,427,300-15+0.2+0.8-20])rotate([0,180,90])translate([-4-2-2-2,-5-2-15-6-2,-2-16-16-4-2-4])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5, 7.5-1+4+2+6.5], corner_radius);
translate([337-12.5,427,300-15+0.2+0.8+16-16.65])rotate([0,180,90])translate([0,0,-15])scale([1.02,1.02,1]){
translate([-4-2-2,-5-15-7.5,-2-15-1-2+2.9])rounded_cube([8+4+4, 10+15+5+4+8.5+4.3, 17+5-5], corner_radius);
cylinder(d1=3,d2=2.5,h=5,$fn=50);
translate([0,0,-5])cylinder(d=5,h=5,$fn=50);

translate([0,0,15.3]){
translate([0,0,-15-12.5+1+9]){
translate([0,3.5+4+10-1.9,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5-15-7+2,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}
}
}

translate([-5.5,0,0-4+6.5]){


translate([-2,0,-24]){
translate([319,427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d=9.2,h=6,$fn=50);
translate([319+(11.5*1),427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d=9.2,h=6,$fn=50);
translate([319+(11.5*2),427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d=9.2,h=6,$fn=50);
translate([319+(11.5*3),427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d=9.2,h=6,$fn=50);
}

translate([-2,0,0]){
translate([319,427,309])rotate([0,180,0])tuberculin_syringe_015ml();
translate([319+(11.5*1),427,309])rotate([0,180,0])tuberculin_syringe_015ml();
translate([319+(11.5*2),427,309])rotate([0,180,0])tuberculin_syringe_015ml();
translate([319+(11.5*3),427,309])rotate([0,180,0])tuberculin_syringe_015ml();
}
}
}
}



module luerlock_nozzle_case(){
difference(){
translate([337-12.5,427,300-15])rotate([0,180,90])luerlock_nozzle_case_pre();
//translate([319+10.2-3,427-10,309-15])cube([30,30,40]);
translate([-5.5,0,0-4+6.5]){
//translate([319+30.2,427,309])cylinder(d=6.5+0.3,h=20,$fn=30);
/*
translate([319,427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d2=7.2,d1=6.4,h=6.5,$fn=50);
translate([319+10.2,427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d2=7.2,d1=6.4,h=6.5,$fn=50);
translate([319+20.4,427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d2=7.2,d1=6.4,h=6.5,$fn=50);
translate([319+30.6,427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d2=7.2,d1=6.4,h=6.5,$fn=50);
translate([319,427,309])rotate([0,180,0])tuberculin_syringe_015ml();
translate([319+10.2,427,309])rotate([0,180,0])tuberculin_syringe_015ml();
translate([319+20.4,427,309])rotate([0,180,0])tuberculin_syringe_015ml();
translate([319+30.6,427,309])rotate([0,180,0])tuberculin_syringe_015ml();
*/
translate([0-2,0,0])for(i=[0:3]){
//#translate([319+(11.5*i),427,309])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d2=7.2,d1=6.4,h=6.5,$fn=50);
#translate([319+(11.5*i),427,309-20])rotate([0,180,0])translate([0,0,0])rotate([0,180,0])color("pink")cylinder(d2=8.25,d1=8.25,h=6.5+22,$fn=50);
//#translate([319+(11.5*i),427,309])rotate([0,180,0])tuberculin_syringe_015ml();
}

}
}
}



module luer_lock_alignment_key(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
union(){
//translate([-4-2-2-2,-5-2-15-6-2-6,-2-16-16-4-2-4])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5+12, 7.5-1+4+2+6.5], corner_radius);
translate([-4-2-2-2,-5-2-15-6-2-6,-2-16-16-4-2-4])rounded_cube([20, 10+4+15+10+4+8.5+12, 4], corner_radius);
}
translate([0,0,-15-12.5+2]){
translate([0,3.5+4+10-1.5,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5-15-7+1.5,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}
translate([0,0,-15])scale([1.02,1.02,1]){
translate([-4-2-2,-5-15-7.5,-2-15-1-2+2.9])rounded_cube([8+4+4, 10+15+5+4+8.5+4.3, 17+5-5], corner_radius);
cylinder(d1=3,d2=2.5,h=5,$fn=50);
translate([0,0,-5])cylinder(d=5,h=5,$fn=50);
}
translate([0,2,0])for(i=[-1:2]){
translate([0,-i*11.5+0.8,-23-2.7])scale([1.05,1.05,1])rotate([0,180,0])p200_lts_holder();
translate([0,-i*11.5+0.8,-23-2.7-13])cylinder(d=7.5,h=20,$fn=30);
}
translate([0,2,0])for(i=[-1:2]){
//translate([0,-i*11.5+0.8,-40+2-2.01-4.3])cylinder(d1=9.25,d2=4,h=8,$fn=50);
translate([0,2,0])for(j=[0:12]){
translate([0+j,-i*11.5+0.8,-40+2-2.01-4.3-5])cylinder(d1=7.5,d2=7.5,h=15,$fn=50);
}
}
}
}










module luer_lock_case_lid(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4-2-2-2,-5-2-15-6-2-6,-2-16-16-4-2-4])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5+12, 7.5-1+4+2+6.5], corner_radius);
translate([0,0,-15-12.5+2]){
translate([0,3.5+4+10-1.5,-2])rotate([0,90,0])cylinder(d=2.5,h=40,$fn=50);
translate([0,-3.5-15-7+1.5,-2])rotate([0,-90,0])cylinder(d=2.5,h=40,$fn=50);
}
translate([0,0,-15])scale([1.02,1.02,1]){
translate([-4-2-2,-5-15-7.5,-2-15-1-2+2.9])rounded_cube([8+4+4, 10+15+5+4+8.5+4.3, 17+5-5], corner_radius);
cylinder(d1=3,d2=2.5,h=5,$fn=50);
translate([0,0,-5])cylinder(d=5,h=5,$fn=50);
}
translate([0,2-1.3,0])for(i=[-1:2]){
translate([0,-i*11.5+0.8,-23-2.7])scale([1.05,1.05,1])rotate([0,180,0])p200_lts_holder();
translate([0,-i*11.5+0.8,-23-2.7-13])cylinder(d=7.5,h=20,$fn=30);
}
translate([0,2-1.3,0])for(i=[-1:2]){
translate([0,-i*11.5+0.8,-40+2-2.01-4.3])cylinder(d1=9.25,d2=4,h=8,$fn=50);
}
}
}



module luer_lock_microwell(){
difference(){
corner_radius = 1;  // Adjust this value to change roundness
translate([-4-2-2-2,-5-2-15-6-2-1,-2-16-16-4-2-4])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5+6, 7.5-1+4+2+6.5], corner_radius);
translate([0,2,0])for(i=[-1:2]){
//translate([0,-i*11.5+0.8,-23-2.7])scale([1.05,1.05,1])rotate([0,180,0])p200_lts_holder();
translate([0,-i*11.5+0.8,-23-2.7-13])cylinder(d1=8.5,d2=2,h=10,$fn=30);
}
translate([0,2,0])for(i=[-1:2]){
translate([0,-i*11.5+0.8,-40+2-2.01-4.3])cylinder(d1=11.25,d2=4,h=8,$fn=50);
}
}
}



module luerlock_nozzle_case_pre(){
difference(){
corner_radius = 1;
union(){
// Main collar body
translate([-4-2-2+0.3,-5-2-15-6+0.2+0.2,-2-15-4-12])rounded_cube([8+4+4-0.6, 10+4+15+18.5-0.4-0.4, 6.5+1+16-6], corner_radius);
}
translate([0,0,-15-12.5+1]){
translate([0,3.5+4+10-1.5,-2])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,-3.5-15-7+1.5,-2])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
}
translate([0,0,-15-12.5+1+9]){
translate([0,3.5+4+10-1.5,-2])rotate([0,90,0])cylinder(d=1.7,h=40,$fn=50);
translate([0,-3.5-15-7+1.5,-2])rotate([0,-90,0])cylinder(d=1.7,h=40,$fn=50);
}
}
}




module tuberculin_syringe_015ml(
    total_length = 155,
    barrel_od = 7,
    barrel_id = 5.0,
    plunger_head_dia = 4.8,
    flange_length = 19,
    flange_width = 12,
    flange_thick = 2.2,
    luer_lock_male = true
) {
    barrel_id = 0;
    barrel_length = 11; // Approximate active barrel length
    luer_length = 2;
    luer_od = 4;
    luer_taper_length = 7;
    //p200_LTS_flexpart.stl
    difference(){
    translate([0,0,0])rotate([0,180,0])color("lightgreen")cylinder(d2=7.1,d1=6.1,h=13,$fn=30);
    translate([0,0,-0.1])rotate([0,180,0])color("lightgreen")cylinder(d2=7.1-0.4,d1=6.1-0.4,h=13.2,$fn=30);
    }
    /*
    */
    //tyco_syringe_barrel_luerlock
    color("white", 0.7) {
        // Main barrel
        difference() {
            cylinder(h=barrel_length, d=barrel_od, $fn=32);
            translate([0, 0, -0.1])
                cylinder(h=barrel_length+0.2, d=barrel_id, $fn=32);
        }
        // Luer lock connector
        translate([0, 0, barrel_length]) {
            // Tapered portion
            cylinder(h=luer_taper_length, d1=10, d2=10, $fn=32);
            
            // Threaded luer lock (simplified external threads)
            translate([0, 0, luer_taper_length])
                cylinder(h=luer_length, d=luer_od, $fn=32);
        }
    }
}

module luerlock_connector(
    total_length = 155,
    barrel_od = 7,
    barrel_id = 5.0,
    plunger_head_dia = 4.8,
    flange_length = 19,
    flange_width = 12,
    flange_thick = 2.2,
    luer_lock_male = true
) {
    barrel_id = 0;
    barrel_length = 11; // Approximate active barrel length
    luer_length = 2;
    luer_od = 4;
    luer_taper_length = 7;
    //p200_LTS_flexpart.stl

        // Luer lock connector
        translate([0, 0, barrel_length]) {
            // Tapered portion
            cylinder(h=luer_taper_length, d1=10, d2=10, $fn=32);
            
            // Threaded luer lock (simplified external threads)
            translate([0, 0, luer_taper_length])
                cylinder(h=luer_length, d=luer_od, $fn=32);
        }

}

// Helper module for rounded cube clearances
module rounded_cube(size, radius) {
    $fn=50;
    hull() {
        for(x = [radius, size[0]-radius])
            for(y = [radius, size[1]-radius])
                for(z = [radius, size[2]-radius])
                    translate([x, y, z])
                        sphere(r=radius);
    }
}

