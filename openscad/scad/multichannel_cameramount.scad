//multichannel_cameramount.scad
//line 189 needs to be manually modified
//module pipette_p1000_noextrusion(dia,fl,arg,z){



//multichannel_pipette_holder_camera_example();

//multichannel_pipette_holder_linear_actuator_connect_cameramount();


//multichannel_pipette_holder_linear_actuator_connect_cameramount();



module multichannel_cameramount_tslot_part(){
multichannel_pipette_holder_linear_actuator_connect_cameramount();
}

module multichannel_cameramount_tipholder(z){
 translate([0,-17+15,0])difference(){
  translate([-65,29,60])rotate([-90,0,0]) multichannel_pipette_holder_camera_example(z);
  //translate([-65+19.4,29,60-40])cube([26-0.6,20,25]);
 }
}


module multichannel_pipette_holder_linear_actuator_connect_cameramount(){
 difference(){union(){
 //multichannel_cameramount_tipholder();
 translate([-8,30-6.5,28.2])rotate([0,180,90])color("")tslot_clamp_filament_linearactuator_shuttle_noextrusion();
 }
}
}







module pipette_p1000_noextrusion_pcrmon(dia,fl,arg){


translate([0,0,-65+41]){
if (fl == 1){
//this is for show pipette show
translate([0,0,200-100+80-80-11+15])rotate([0,180,0])%color("green",0.6)pipette_p300_lts_model();

//comment this out for printing
translate([0,0,9-10])p1000_model_eppendorf_pcrmon();
translate([0,0,9-10])translate([0,0,3])color("black")cylinder(r=8.6/2,h=1, $fn=30);
difference(){
color("lightblue")translate([0,0,-6.7-40])cylinder(r=5.5/2,h=102-13-40+20,$fn=30);
color("lightblue")translate([0,0,-6.7-40])cylinder(r=3/2,h=102-13-40+20,$fn=30);
}
/*
*/
//color("lightblue")translate([0,0,62-400+300-10])cylinder(r=2.5/2,h=333-300+10);

/*
color("lightblue")translate([0,0,62])cylinder(r=2.5/2,h=13);
color("lightblue")translate([0,0,52.3-10])cylinder(r2=2.5/2,r1=4.5/2,h=20);
color("lightblue")translate([0,0,-36.7])cylinder(r=7.5/2,h=20);
*/
/*
*/
//here is the luer lock comment out for printing
/*
color("white")translate([0,0,-6.7-5])cylinder(r=8/2,h=3);
color("white")translate([0,0,-6.7-3])cylinder(r=12/2,h=3);
//cylinder(r=12/2,h=3);
//end luer lock
*/
}
}
}





module p1000_model_eppendorf_pcrmon(){
//color("lightblue")
//translate([0,0,-190])cylinder(r=2/2,h=180);
rotate([0,0,0]){
difference(){
union(){
color("lightblue")
cylinder(r=8.5/2,h=17, $fn=30);
//translate([0,0,3])color("black")cylinder(r=8.6/2,h=1, $fn=30);
}
translate([0,0,-0.1])cylinder(r=(8.5-1.5)/2,h=5.12, $fn=30);
translate([0,0,2])cylinder(r=(8.5-1)/2,h=2, $fn=30);
translate([0,0,5])cylinder(r=(8.5-2)/2,h=2, $fn=30);
translate([0,0,6.9])cylinder(r=(8.5-1.5)/2,h=4.11+6.6, $fn=30);
}
color("lightblue")translate([0,0,11])
difference(){
cylinder(r1=7.5/2,r2=7.5/2,h=16.5, $fn=30);
translate([0,0,-0.1])cylinder(r1=(7.5-1)/2,r2=(7.5-1)/2,h=16.85+2, $fn=30);
}
color("lightblue")translate([0,0,11+16.5])
difference(){
cylinder(r1=7.25/2,r2=7/2,h=4, $fn=30);
translate([0,0,-0.1])cylinder(r1=(7.25-1)/2,r2=(7-1)/2,h=4.15, $fn=30);
}
translate([0,0,11+16.5+4])
difference(){
union(){
color("lightblue")cylinder(r1=7/2,r2=4/2,h=15, $fn=30);
color("lightblue")translate([0,0,15-2-12.5])cylinder(r2=7/2,r1=7/2,h=5, $fn=30);
translate([0,0,15-2-7.5])difference(){
union(){
color("lightblue")cylinder(r2=4.5/2,r1=7/2,h=9.5, $fn=30);
color("lightblue")translate([0,0,9])cylinder(r2=2.5/2,r1=4.5/2,h=9.5, $fn=30);
color("blue")translate([0,0,10])cylinder(r2=3.5/2,r1=5/2,h=5, $fn=30);
}
//need to put this back 
//translate([0,0,7.5-3])cylinder(r=7/2,h=0.6);
}
}
translate([0,0,-0.1])cylinder(r1=(7-1)/2,r2=(4-1)/2,h=15+.2);
}
/*
//this is for show
color("")translate([0,0,11+16.5+4])
difference(){
union(){
translate([0,0,15-2-7.5])difference(){
cylinder(r2=4.5/2,r1=7/2,h=9.5);
translate([0,0,7.5-3])cylinder(r=7/2,h=0.6);
}
}
translate([0,0,-0.1])cylinder(r1=(7-1)/2,r2=(4-1)/2,h=15+.2);
}
//end for show
*/
//translate([0,0,11+16.5+4+15-10])cylinder(r1=7/2,r2=6/2,h=8);
}
}


















module pipette_p1000_noextrusion(dia,fl,arg,z){
color("")difference(){
union(){
//translate([0,0,4])cylinder(r2=4.5/2,r1=5.5/2,h=8);
color("pink"){
translate([0,2,-4])rotate([0,0,45])cylinder(r=13/2,h=12,$fn=4);
translate([0,-2,-4])rotate([0,0,45])cylinder(r=13/2,h=12,$fn=4);
translate([0,0,-4])rotate([0,0,45])cylinder(r=13/2,h=12,$fn=4);
translate([2,2,-4])rotate([0,0,45])cylinder(r=13/2,h=12,$fn=4);
translate([2,-2,-4])rotate([0,0,45])cylinder(r=13/2,h=12,$fn=4);
translate([2,0,-4])rotate([0,0,45])cylinder(r=13/2,h=12,$fn=4);
}
if (arg == "y"){
color("")translate([-4,-40/2+13.4+12,-4+8-3-2-8])cube([10,40-13+4-12-4.5-7.5,4+3+2+8]);
}
//the other side for solenoid
//translate([-5,-40/2-4,-4])cube([10,40-13+4,4]);
}
/*
translate([-5,9.45,-15])cylinder(r=6/2,h=40,$fn=300);
translate([-4,9.45,-15])cylinder(r=6/2,h=40,$fn=300);
translate([-3,9.45,-15])cylinder(r=6/2,h=40,$fn=300);
*/

translate([1,0,-50.2+46])cylinder(r=dia/2,h=100,$fn=30);
translate([1,0+50-50,-50.2+46+8])rotate([90,0,0])cylinder(r=1.7/2,h=30,$fn=30);

/* for screwing holes
if (arg == "y"){
translate([0,0+50-50+23-3,-50.2+46+8])rotate([90,0,0])cylinder(r=2.8/2,h=15,$fn=30);
}
*/
//translate([0,0,-50.2+46])cylinder(r=dia/2,h=100);
//translate([0,0,-50.2+46])cylinder(r=(dia+0.2)/2,h=2);
}
translate([0,0,-65+41]){
if (fl == 1){
//this is for show pipette show
translate([0,0,200-100+80-80-11])rotate([0,180,0])color("lightgreen")pipette_p300_lts_model();

//comment this out for printing
//The p20 or p1000 cap assay has the tube
//translate([0,0,200-100+80-80-11-42])rotate([0,0,0])pipette_p20_cap_assy();
//translate([0,0,200-100+80-80-11-42])rotate([0,0,0])pipette_p1000_cap_assy();

translate([0,0,9-10+4])p1000_model_eppendorf();
color("lightblue")translate([0,0,-6.7])cylinder(r=5.5/2,h=102-13-40,$fn=30);
/*
*/

color("lightblue")translate([0,0,62-400+300-10-z*0.7-8+15])rotate([0,0,0])cylinder(r=2.5/2,h=333-300+10+z*0.7-12+20-20);
/*
*/
color("lightblue")translate([0,0,62])cylinder(r=2.5/2,h=13);
color("lightblue")translate([0,0,52.3-10])cylinder(r2=2.5/2,r1=4.5/2,h=20);
//color("lightblue")translate([0,0,-36.7+10])cylinder(r=7.5/2,h=20);
/*
*/
//here is the luer lock comment out for printing
color("white")translate([0,0,-6.7-5])cylinder(r=8/2,h=3);
color("white")translate([0,0,-6.7-3])cylinder(r=12/2,h=3);
/*
*/
//cylinder(r=12/2,h=3);
//end luer lock
/*
*/
}
}
}







module tslot_clamp_filament_linearactuator_shuttle_noextrusion(){
translate([2,-5,-13])difference(){
union(){
//translate([0,0,-3.5])cube([16,60,4+3.5]);
translate([0-15.5,17.4,0-3.4])cube([16+15.5+4,25,4+5+3.5]);
//translate([0-15.5+15-15,17.4-15-7.5-1,0-3.4+5])cube([12+20+7-2,25+15+15+15+2,4+5+3.5-5]);
//translate([0-15.5+15-15,17.4-15-7.5-1,0-3.4+5])cube([12+20+7-2-10,25+15+15+15+2,4+5+3.5-5]);
translate([0-15.5+15-15-3-14,17.4-15-7.5-1,0-3.4+5-5])cube([12+20+7-2-10+14-8,25+15+15+15+2,4+5+3.5-5+5]);
translate([0-15.5+15-15-3-14+2.95+0.25,17.4-15-7.5-1,0-3.4+5-5-2+0.3])cube([3,25+15+15+15+2,5]);
translate([0-15.5+15-15-3-14+2.95+0.25+12.1,17.4-15-7.5-1,0-3.4+5-5-2+0.3])cube([3,25+15+15+15+2,5]);

//translate([0-15.5+15-15+12.5,17.4-15-7.5-1+49.5,0-3.4+5-8])cube([12+20+7-2-10-15+2.5,25+15+15+15+2-35+4,4+5+3.5-5+8]);
translate([0-15.5,17.4,0-3.4+7.5])cube([16+15.5+4+20,25,4+5+3.5-7.5]);
}
/*
translate([-100,84-3-6.5,-0.7])rotate([0,90,0])cylinder(r=2.8/2,h=500,$fn=30);
translate([-100,84-3-6.5-18,-0.7])rotate([0,90,0])cylinder(r=2.8/2,h=500,$fn=30);
*/
translate([0.35+0.75+40+6-83-2-0.1-7.5-0.3-14,75-1-5.35-38-1,-25-2.5+10])rotate([0,0,90]){
//for(i=[0,1,6,7]){
for(i=[1,6]){
for(y=[1.8:1.8]){
translate([-38.25+14-13.9+6.5+i*9,-70+30-10+8+5-16+1.5+y*9-3,22.5+8-8-2.5-4-50])rotate([-0,0,0])cylinder(r=4.8/2,h=112,$fn=35);
translate([-38.25+14-13.9+6.5+i*9,-70+30-10+8+5-16+1.5+y*9-3,22.5+8-8-2.5-4-2+4])rotate([-0,0,0])cylinder(r=9/2,h=30,$fn=35);
}
}
}


translate([0.35+0.75+40+6-83-2-0.1,75-1-5.35,-25-2.5])rotate([0,0,90]){

translate([-38.25+14-13.9+6.5-7.5,-70+30-10+8+5-16+1.5+6.5-6.5,22.5+8-8+1.5])rotate([-0,0,0])cylinder(r=8.2/2,h=3,$fn=35);
translate([-38.25+14-13.9+6.5-7.5,-70+30-10+8+5-16+1.5+6.5-6.5,22.5+8-8])rotate([-0,0,0])cylinder(r=3.7/2,h=36,$fn=35);


translate([-38.25+14-13.9+6.5,-70+30-10+8+5-16+1.5+6.5,22.5+8-8+1.5])rotate([-0,0,0])cylinder(r=8.2/2,h=3,$fn=35);
translate([-38.25+14-13.9+6.5,-70+30-10+8+5-16+1.5+6.5,22.5+8-8])rotate([-0,0,0])cylinder(r=3.7/2,h=36,$fn=35);


translate([-38.25+14-13.9+6.5-15,-70+30-10+8+5-16+1.5+6.5,22.5+8-8+1.5])rotate([-0,0,0])cylinder(r=8.2/2,h=3,$fn=35);
translate([-38.25+14-13.9+6.5-15,-70+30-10+8+5-16+1.5+6.5,22.5+8-8])rotate([-0,0,0])cylinder(r=3.7/2,h=36,$fn=35);

/*
translate([-38.25+14-13.9+6.5,-70+30-10+8+5-16+1.5,22.5+8-8-2.5])rotate([-0,0,0])cylinder(r=4.5/2,h=11.8,$fn=35);
translate([-38.25+14-13.9+6.5,-70+30-10+8+5-16+1.5,22.5+8-8])rotate([-0,0,0])cylinder(r=2.5/2,h=36,$fn=35);
translate([-38.25+14-13.9+6.5-15,-70+30-10+8+5-16+1.5,22.5+8-8-2.5])rotate([-0,0,0])cylinder(r=4.5/2,h=11.8,$fn=35);
translate([-38.25+14-13.9+6.5-15,-70+30-10+8+5-16+1.5,22.5+8-8])rotate([-0,0,0])cylinder(r=2.5/2,h=36,$fn=35);
translate([-38.25+14-13.9+6.5,-70+30-10+8+5-16+1.5+13,22.5+8-8-2.5])rotate([-0,0,0])cylinder(r=4.5/2,h=11.8,$fn=35);
translate([-38.25+14-13.9+6.5,-70+30-10+8+5-16+1.5+13,22.5+8-8])rotate([-0,0,0])cylinder(r=2.5/2,h=36,$fn=35);
translate([-38.25+14-13.9+6.5-15,-70+30-10+8+5-16+1.5+13,22.5+8-8-2.5])rotate([-0,0,0])cylinder(r=4.5/2,h=11.8,$fn=35);
translate([-38.25+14-13.9+6.5-15,-70+30-10+8+5-16+1.5+13,22.5+8-8])rotate([-0,0,0])cylinder(r=2.5/2,h=36,$fn=35);
*/

}
/*
translate([8,30-6,-1])cylinder(r=3.7/2,h=20);
translate([8,30-6,0-3.6])cylinder(r=6.5/2,h=3.6);
translate([8,30+6,-1])cylinder(r=3.7/2,h=20);
translate([8,30+6,0-3.6])cylinder(r=6.5/2,h=3.6);
*/
//translate([8,30-22,-1])cylinder(r=5.9/2,h=20);
//translate([8,30+22,-1])cylinder(r=5.9/2,h=20);
//translate([8,30-22,-1])cylinder(r=5.9/2,h=20);

translate([8+22,30-15+8,-1-6])cylinder(r=2.8/2,h=50,$fn=30);
translate([8+22,30-15+8+13,-1-6])cylinder(r=2.8/2,h=50,$fn=30);
/*
translate([8,30+15,-1-6])cylinder(r=5.9/2,h=50);
translate([8,30-15,4-3.5])cylinder(r=10/2,h=20);
translate([8,30+15,4-3.5])cylinder(r=10/2,h=20);
*/
}
}



//pipette part 
module multichannel_pipette_holder_camera_example(z){
color(""){
//translate([-9,-6.6+8,-4])cube([6,13.2,12]);
//translate([-9+76.5-0.3+1,-6.6+8,-4])cube([5,13.2,12]);
//color("lime")translate([-7,3,30-15])pipettetip_aligner();
color("pink")translate([-9-9,-6.6+8,-4])cube([6,13.2,12]);
color("pink")translate([-9+76.5-0.3+1+9,-6.6+8,-4])cube([5,13.2,12]);
}
translate([1,0+8,0])difference(){
union(){
//for(i=[-1:8]){
for(i=[-1:8]){
if (i==-1){
 translate([i*(9),0,0])
  pipette_p1000_noextrusion(8.3,"n",z);
 }
else if (i==2){
 translate([i*(9),0,0])
  pipette_p1000_noextrusion(8.3,1,"y",z);
}
else if (i==3){
 translate([i*(9),0,0])
  pipette_p1000_noextrusion(8.3,1,"y",z);
}
else if (i==4){
 translate([i*(9),0,0])
  pipette_p1000_noextrusion(8.3,1,"y",z);
}
else if (i==5){
 translate([i*(9),0,0])
  pipette_p1000_noextrusion(8.3,1,"y",z);
}
else if (i==8){
 translate([i*(9),0,0])
  pipette_p1000_noextrusion(8.3,0,"n",z);
}
else if (i==1){
 translate([i*(9),0,0])
  pipette_p1000_noextrusion(8.3,1,"y",z);
}
else {
 translate([i*(9),0,0])pipette_p1000_noextrusion(8.3,1,"y",z);
}
/*
*/

/*
if (i==0){
 translate([i*(9),0,0])
  ///pipette_serological_1ml(5);
  //pipette_serological_1ml(7.5);
  pipette_p1000_noextrusion(8.1);
  //pipette_p200(5); 
}
else if (i==7){
 translate([i*9,0,0])
 //pipette_p200(5); 
 //pipette_serological_1ml(5.2);
 //pipette_serological_1ml(7.7);
 pipette_p1000_noextrusion(8.1);
}
else {
translate([i*9,0,0])
 //pipette_serological_1ml(5.3);
 //pipette_serological_1ml(7.8);
 pipette_p1000_noextrusion(8.1);
 //pipette_p200(5); 
}
*/
}
}
sh = 32;
translate([-4+11+2,sh/2-3+5,3.2])rotate([90,0,0])cylinder(r=2.8/2,h=13,$fn=30);
translate([-4+11+2+9*5,sh/2-3+5,3.2])rotate([90,0,0])cylinder(r=2.8/2,h=13,$fn=30);
//translate([-4+11,sh/2-3+5,-10])cylinder(r=5.5/2,h=80,$fn=30);
//translate([-4-11+(7*10),sh/2-3+5,-10])cylinder(r=5.5/2,h=80);
/*
translate([-4+11,-sh/2+3-5,-10])cylinder(r=5.5/2,h=80);
translate([-4-11+70,-sh/2+3-5,-10])cylinder(r=5.5/2,h=80);
*/
}
}

module stepper_linear_m8nut_endstopflag(thick){
translate([0,-20-9,0])difference(){
difference(){union(){
translate([-38.25+14-13.9+20,-70+30.-5+4,22.5+3.8-1.0])cube([44.5-20,11,thick]);
translate([-38.25+14-13.9+20-20,-70+30.-5-5+7,22.5+3.8-1.0])cube([44.5-20+20-23,5+10+5-7,thick]);
translate([-38.25+14-13.9+20-20-4,-70+30.-5-5-4+7,22.5+3.8-1.0])cube([44.5-20+20-23,5+10+5+4-7,thick+5]);
}
translate([-90,-40+4,29])rotate([0,90,0])cylinder(r=3.6/2,h=73,$fn=30);
}
for(i=[0:0]){
translate([-38.25+14-13.9+13.7+11.9-i,-70+34,22.5+3.8-50])cylinder(r=3.7/2,h=120);
translate([-38.25+14-13.9+13.7+13+11.9-i,-70+34,22.5+3.8-50])cylinder(r=3.7/2,h=120);
}
}
}






