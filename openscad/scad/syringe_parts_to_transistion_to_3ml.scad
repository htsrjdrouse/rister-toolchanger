

eight_channel_1ml_syringe_assy();

module eight_channel_1ml_syringe_assy(){
tyco_eight_multichannel_assay();
translate([0,90,0])multichannel_syringe1ml_clamp_extrusion_connect();
translate([0,90+60,0])multichannel_syringe1ml_clamp_extrusion_connect();
translate([0,-4,0])multichannel_plunger_clamp();
syringe_1ml_stack_1piece_multichannel_clamp_rework_partb();
syringe_1ml_stack_1piece_multichannel_clamp_rework();
translate([0,90,0])syringe_1ml_set();
color("silver")translate([-34,3,-4.6]){
translate([0,-1,0])mgn12_shuttle();
mgn12_rail();
}
translate([-121.8-1,54.1+3,3])rotate([0,0,0])oneml_syringe_stepper_linear_m8nut_coupler();
translate([-100,160,0])translate([-25.75,123+3,-30])rotate([90,-90,0])multichannel_syringeshuttle_clipbracket();
translate([-100,176,0])iverntech_pump_slider_plate();
translate([0,135,0]){
translate([-98,0,0.5])translate([-62,-60,25])rotate([-90,0,0])color("silver")cylinder(r=8/2,h=200,$fn=30);
translate([-160,-80,25.5])rotate([-90,0,0])nema17();
translate([-98,0,0]){
iverntech_slidermount_motormount();
translate([-22,-90,4])rotate([90,-90,0])motormount_screws();
}
}
translate([-98,20,0])translate([-25-6.5,320,-4.6])rotate([90,0,0])tslot20(300);
}





module multichannel_syringeshuttle_clipbracket(){
translate([46.25,-57,300-4])rotate([180,0,90])difference(){
union(){
translate([64.7-5,14.4-3-3,155.75-10])cube([25,15+3+3,10+11+10-3-15]);
translate([64.7-5,14.4-3-3,155.75-10])cube([25,15+3+3-9.75-4,10+11+10-3]);
}
translate([65.2+0.75,14.4+7.5,155.75+20-1.5-4])cube([14-1.5,14,24]);
translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([0,0,-100])cylinder(r=2.7/2, h=200);
translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([-9,0,-100])cylinder(r=2.7/2, h=200);
translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([90,0,0])cylinder(r=2.7/2, h=200);
translate([64.7-5,14.4-3-0.87,155.75])translate([17.25,5.8,-10])translate([-9+15-2-17.5,30,23])rotate([90,0,0])cylinder(r=2.7/2, h=200);
}
}


module iverntech_pump_slider_plate(){
translate([0,0,1])difference(){
union(){
translate([-110+55.5+3,-81.5+1.5+40-24+10,16])cube([22+5-3.5,11,7+5.8]);
translate([-110+55.5,-81.5+1.5+40,16])cube([22+5,28.5,7]);
translate([-110+55.5,-81.5+1.5+40+6.6+3.5-14.5,16])cube([22+5,6.5,35]);
}   
translate([-110+59+5.3-1.6,-81.5+1.5+20+11,36-3.4-17])rotate([0,0,0]){cylinder(r=2.8/2,h=20);}//cylinder(r=6.8/2,h=9,$fn=6);}
translate([-110+59+5.3-1.6+13,-81.5+1.5+20+11,36-3.4-17])rotate([0,0,0]){cylinder(r=2.8/2,h=20);}//cylinder(r=6.8/2,h=9,$fn=6);}
translate([-110+59+5.3+4.5-1,-81.5+1.5+146,36-3.4+10.25+2])rotate([90,90,0])cylinder(r=3.7/2,h=200);
translate([-110+59+5.3+4.5-1-4.5,-81.5+1.5+146,36-3.4+10.25+2-6])rotate([90,90,0])cylinder(r=3.7/2,h=200);
translate([-110+59+5.3+4.5-1+4.5,-81.5+1.5+146,36-3.4+10.25+2-6])rotate([90,90,0])cylinder(r=3.7/2,h=200);
translate([-110+59,-81.5+1.5+46,16-8]){cylinder(r=3.7/2,h=12+1);translate([0,0,12])cylinder(r=8/2,h=3.5);}
translate([-110+59+20,-81.5+1.5+46,16-8]){cylinder(r=3.7/2,h=12+1);translate([0,0,12])cylinder(r=8/2,h=3.5);}
translate([-110+59+20,-81.5+1.5+46+20,16-8]){cylinder(r=3.7/2,h=12+1);translate([0,0,12])cylinder(r=8/2,h=3.5);}
translate([-110+59,-81.5+1.5+46+20,16-8]){cylinder(r=3.7/2,h=12+1);translate([0,0,12])cylinder(r=8/2,h=3.5);}
}
}



module iverntech_slider_pump_base(){
//guide TS-04-09-50
//carriage TW-04-09
translate([2,-30,0]){
translate([-45,-33-10,-6])difference(){
union(){
//color("pink")
translate([0-7.5,-40,0])cube([10+15+10+6,68+40+23+20,6+3]);
//color("yellow")
translate([0-7.5,-40-1.0,0])cube([10+15+13,10,6+3]);
//color("lime")
translate([0-7.5-5-5.5-22,-40-1.3-20+20.3+31-5,0])cube([12+22,53-42.8+10,6+3]);
}
translate([0-7.5+18,-40+18,3+3.4])cube([10+15+10+6-18+2,68+40+23+20-18+2,6]);
translate([5+20,20+(-5.5*10)-1.5,-10]){cylinder(r=3.7/2,h=40);translate([0,0,5+11])cylinder(r=6.7/2,h=3.5);}//cylinder(r=5.4/2,h=3+4,$fn=6);}
translate([0,-33,0])for(a=[2,3,4,5]){
//translate([2,10+(a*25),-5]){cylinder(r=3.7/2,h=40);translate([0,0,4])cylinder(r=6.8/2,h=3+4,$fn=6);}
translate([2,10+(a*25),-5]){cylinder(r=2.8/2,h=40);}
}
/*
translate([17.5,-33,0])for(a=[0,4,8,12]){
translate([5,20+(a*10),-0.1]){translate([0,0,2.4-4])cylinder(r=2.7/2,h=16);}//cylinder(r=5.5/2,h=2.5);}
}
*/
translate([17.5,-33,0])for(a=[4,8,12]){
translate([5+4,10+(a*10),-5]){translate([0,0,8.4+1])cylinder(r=4.7/2,h=8);translate([0,0,5])cylinder(r=8/2,h=4.5);}
}
//translate([15,-27+(0*10),0]){cylinder(r=3.7/2,h=100);translate([0,0,2.6])cylinder(r=6.7/2,h=3.5+12);}
//translate([5,-36+(0*10),0]){cylinder(r=3.7/2,h=10);translate([0,0,2.6])cylinder(r=6.7/2,h=6.5);}
/*
for(a=[0,4]){
translate([5,-26+(a*10),0]){cylinder(r=3.7/2,h=10);translate([0,0,2.6])cylinder(r=6.7/2,h=6.5);}
}
*/
}
}//end translate
}



module iverntech_pump_slider(){
//color("lightgrey")
bg = 0.5;
//color([bg,bg,bg])
//color("")
//igus_slidermount_encoder_TW_04_12();
iverntech_slider_pump_base();

/*
translate([1,0,0]){
//color("lightgrey")
//color([bg,bg,bg])
//color("")
//translate([-22,-90,4])rotate([90,-90,0])motormount();
//color([bg,bg,bg])
//color("")
//translate([-110+27,-81.5+1.5,-4])cube([42,8.5,10]);

//This is for display purposes
//translate([-70+8,-80,30-5])rotate([-90,0,0])nema17();
//rbg=0.85;color([rbg,rbg,rbg])
//color("")
//translate([-70+8,-80+40,30-5])rotate([-90,0,0])cylinder(r=8.7/2,h=200);
}
*/
}



module iverntech_slidermount_motormount(){
//color("lightgrey")
bg = 0.5;
//color([bg,bg,bg])
//color("")
difference(){
iverntech_pump_slider();
translate([-54,-75.5,-50])cylinder(r=3.7/2,h=100);
translate([-54-14,-75.5,-50])cylinder(r=3.7/2,h=100);
translate([-54,-75.5,-50])cylinder(r=8.5/2,h=48);
translate([-54-14,-75.5,-50])cylinder(r=8.5/2,h=48);
}
translate([1,0,0]){
//color("lightgrey")
//color([bg,bg,bg])
//color("")
//translate([-22,-90,4])rotate([90,-90,0])motormount_screws();
//color([bg,bg,bg])
//color("")
//translate([-110+27,-81.5+1.5,-4])cube([42,8.5,10]);

//This is for display purposes
//translate([-70+8,-80,30-5])rotate([-90,0,0])nema17();
//rbg=0.85;color([rbg,rbg,rbg])
//color("")
//translate([-70+8,-80+40,30-5])rotate([-90,0,0])cylinder(r=8.7/2,h=200);
}
}

module motormount_screws(){
 mmx = 42;
 mmy = 42;
 mmz = 8.5;
 mmposx = 0;
 mmposy = 19;
 mmposz = -18.5;
 m6rad = 6.5/2;
 m3rad = 4.5/2;
 motrad = 11.5;
 //motrad = 4;
 difference(){
  translate([mmposx-1,mmposy,mmposz])
  cube([mmx+1,mmy,mmz]);
  translate([mmposx+mmx/2,mmposy+mmy/2,mmposz-0.1])
  cylinder(r=motrad, h=10);
  translate([mmposx+mmx/2,mmposy+mmy/2,mmposz-0.1])
  translate([0,0,-100])
  cylinder(r=4.3, h=400);
  //m3 motor screws
  translate([mmposx+mmx/2-15.5,mmposy+mmy/2-15.5,mmposz-0.1])
  cylinder(r=m3rad, h=9);
  translate([mmposx+mmx/2-15.5,mmposy+mmy/2+15.5,mmposz-0.1])
  cylinder(r=m3rad, h=9);
  translate([mmposx+mmx/2+15.5-1.5,mmposy+mmy/2+15.5,mmposz-0.1])
  cylinder(r=m3rad, h=90);
  translate([mmposx+mmx/2+15.5-1.5,mmposy+mmy/2+15.5,mmposz-0.1])
  translate([0,-2,0])
  cube([8,4.5,90]);
  translate([mmposx+mmx/2+15.5-1.5,mmposy+mmy/2-15.5,mmposz-0.1])
  cylinder(r=m3rad, h=90);
  translate([mmposx+mmx/2+15.5-1.5,mmposy+mmy/2-15.5,mmposz-0.1])
  translate([0,-2.25,0])
  cube([8,4.5,90]);
  translate([-60,32,-14.5])rotate([0,90,0])cylinder(r=2.7/2,h=80);
  translate([-60,32+14,-14.5])rotate([0,90,0])cylinder(r=2.7/2,h=80);
  translate([-60,32,-14.5])rotate([0,90,0])cylinder(r=8/2,h=56);
  translate([-60,32+14,-14.5])rotate([0,90,0])cylinder(r=8/2,h=56);
 }
}








module mgn12_rail(){
translate([-113,122.8-60,7.5])cube([12,300,8]);
}

module mgn12_shuttle(){

translate([-120.5,122.8,12.50])cube([27,45,9]);

}


module oneml_syringe_stepper_linear_m8nut_coupler(){
mirror([0,1,0]){
translate([0,-20-9,0])difference(){
union(){
translate([-38.25+14-13.9,-70+30-5,22.5])rotate([-90,0,0])cylinder(r=17.5/2,h=23+3);
translate([-38.25+14-13.9,-70+30.-5,22.5+3.8])cube([31,11+5,3.7+1.25]);
}
//cylinder(r=7.4,h=sl+4,$fn=6);
//translate([-38.25+14-13.9,-70+30,22.5])rotate([-90,0,0])cylinder(r=11.4/2,h=41,$fn=6);
translate([-38.25+14-13.9,-70+30-10+8,22.5])rotate([-90,0,0])cylinder(r=7.25,h=28,$fn=6);
translate([-38.25+14-13.9,-70+30-30,22.5])rotate([-90,0,0])cylinder(r=8.7/2,h=241);
translate([-38.25+14-13.9+13.7,-70+34-4.8,22.5+3.8-30])cylinder(r=3.7/2,h=120);
translate([-38.25+14-13.9+13.7+13,-70+34-4.8,22.5+3.8-30])cylinder(r=3.7/2,h=120);
}
}
}




module syringe_1ml_stack_1piece_multichannel_clamp_rework_partb(){
difference(){
union(){
translate([-193.5,189.4,39.2])cube([120.8,6.5,4+9]);
}
for(i=[-1:7]){
hull(){
translate([-193.5+10.5+i*14,166+24.9,54])rotate([90,0,0])cylinder(d=10.5,h=20,$fn=100);
translate([-193.5+10.5+i*14,166+24.9,44])rotate([90,0,0])cylinder(d=10.5,h=20,$fn=100);
}
hull(){
translate([-193.5+10.5+i*14,166+35.3,53])rotate([90,0,0])cylinder(d=4.5,h=20,$fn=100);
translate([-193.5+10.5+i*14,166+35.3,44])rotate([90,0,0])cylinder(d=4.5,h=20,$fn=100);
}
translate([-193.5+10.5+i*14+7,166+7.3+25,46])rotate([90,0,0])cylinder(d=2.75,h=20,$fn=100);
}
}
}



module syringe_1ml_stack_1piece_multichannel_clamp_rework(){
difference(){
union(){
translate([-193.5,166,36])cube([120,23,4]);
translate([-193.5,184.3,36])cube([120.5,5,4+12]);
}
for(i=[-1:7]){
translate([-193.5+10.5+i*14,166+7.3,36-5])cylinder(d=3.7,h=20,$fn=100);
translate([-193.5+10.5+i*14+7,166+7.3+25,46])rotate([90,0,0])cylinder(d=3.7,h=20,$fn=100);
}
}
}

module syringe_1ml_plungerclip_1piece(){
difference(){
union(){
translate([0-4+10,-5+2.5,-8])cube([5,10+5,16]);
translate([0-4+10,-5+2.5,-8])cube([14+15-10+4,10+5-1,4]);
}
translate([18+4,0,-8])cylinder(r=3.7/2,h=40);
/*
for(i=[0:10]){
translate([-5,0,0+i])rotate([90,-0,90])cylinder(r=4/2,h=10);
translate([5,0,0+i])rotate([90,-0,90])cylinder(r=10.2/2,h=1.75);
}
*/
translate([2.5-2,40,4])rotate([90,0,0])cylinder(r=2.8/2,h=100);
}
}


module syringe_1ml_set(){
for(i=[0:7]){
color("")translate([-85-(i*14),105.5,44])rotate([-0,0,-90])syringe_1ml_plungerclip_1piece();
translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
}
}


module syringe_1ml_stack_1piece_multichannel_clamp(){
difference(){union(){
/*
*/
//clamp part
//translate([-0.3-14,0+146-2,-0.8])
//translate([-110+54.5+6-14,-81.5+1.5+40+6.6+3.5-14.5,16+15+6+3])cube([5,6.5,35-15-4-3]);
//translate([-0.3-14-(8*14)-3.5,0+146-2,-0.8])
//translate([-110+54.5+6-14,-81.5+1.5+40+6.6+3.5-14.5,16+15+6+3])cube([5,6.5,35-15-4-3]);
//attach part
translate([-0.3-14-(8.6*13),0+146-2-7.4,-1])translate([-110+54.5+6-14-3-1,-81.5+1.5+40+6.6+3.5-14.5+2.3,16+15+6])cube([5+3+1,6.5-1.5,35-15-4]);
translate([-85-(9*14),105.5,44])translate([0-4+10.5+10+1,-5+2.5-22.5-4,-8])cube([14+15-10-10-1+110,10+5+4,4]);
for(i=[0:7]){
color("")translate([-85-(i*14),105.5,44])rotate([-0,0,-90])syringe_1ml_plungerclip_1piece();
translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
//translate([0-42.5-(i*14),-4+230-80-2,0])iverntech_pump_slider_plate_connect_multichannel();
}
}
translate([-77.5-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
translate([-77.5-(8*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-(8*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
translate([-103,83.3,20])for(i=[0:7]){
translate([18-(i*14),0,-8])cylinder(r=3.7/2,h=40, $fn=100);

translate([-85-(i*14),105.5,44])rotate([-0,0,-90])
/*
for(i=[0:10]){
translate([-5,0,0+i])rotate([90,-0,90])cylinder(r=4/2,h=10);
translate([5,0,0+i])rotate([90,-0,90])cylinder(r=10.2/2,h=1.75);
}
*/
translate([-14,0,0]){
translate([-77.5-(i*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-(i*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
}
translate([-77.5-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
translate([-77.5-(8*14)-0.5,100-0.5,50-4])rotate([90,90,0])cylinder(r=3.8/2,h=100);
translate([-77.5-(8*14)-0.5,130,50-4])rotate([90,90,0])cylinder(r=2.8/2,h=100);
}
}
}





module multichannel_plunger_clamp(){
difference(){
translate([-183-13/2-5,170-13/2,30]){
union(){
translate([0,2+7.25-2,2])rotate([0,0,0])cube([120,13/2+7,4]);
translate([0+41.2,2+7.25-7-3-5,2])rotate([0,0,0])cube([25,10+5,4]);
}
}   
translate([-183-13/2-5,170-13/2,30]){
translate([64.7-5-36.15,14.4-3-0.87-50+8-0.08-5,-55.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([0,0,0])cylinder(r=3.7/2, h=200);
translate([64.7-5-36.15+17.5,14.4-3-0.87-50+8-0.08-5,-55.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([0,0,0])cylinder(r=3.7/2, h=200);
for(i=[0:7]){
translate([64.7-5-36.15+17.5-50.75+(i*14),14.4-3-0.87-50+8-0.08+9.75,-55.75])translate([17.25,5.8,-10])translate([-9+15-2,30,23])rotate([0,0,0])cylinder(r=2.7/2, h=200);
}
}
}
}


module multichannel_syringe1ml_clamp_extrusion_connect(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
//translate([0,2,0])rotate([0,0,0])cube([120,13,15]);
translate([69,2-15,-9.5])rotate([0,0,0])cube([18+8,23+20,9.48]);
}
}
translate([-120,220-60,0])cylinder(r=2.8/2,h=100);
translate([-120+15,220-60,0])cylinder(r=2.8/2,h=100);
translate([-120+7.5,220-60+23,0])cylinder(r=2.8/2,h=100);
translate([-120+7.5-4,220-60+23+7,0])cylinder(r=4.7/2,h=100);
translate([-120+7.5-4,220-60+23+7,26.5-2])cylinder(r=10.5/2,h=5.5);
translate([-120+7.5-4,220-60+23-28.5-1,26.5-2])cylinder(r=10.5/2,h=5.5);
translate([-120+7.5-4,220-60+23-28.5-1,0])cylinder(r=4.7/2,h=100);
}
}



module tyco_multichannel_syringe_module(){
tyco_eight_multichannel_assay();
translate([-100,160,0])nextgen_syringe1ml_multichannel_assy();
//translate([0,70,-0.1])multichannel_syringe1ml_clamp_luerlock();
multichannel_plunger_clamp();
translate([0,12,0]){
translate([-100,160,0]) 
//color("gainsboro")
translate([-25.75,123,-30])rotate([90,-90,0])multichannel_syringeshuttle_clipbracket();
}       
}


module tyco_eight_multichannel_assay(){
translate([0,20,0]){
difference(){
union(){
translate([0,70,-0.1])tyco_multichannel_syringe1ml_clamp();
translate([0,30-20,0])tyco_multichannel_syringe1ml_clamp_top_luerlock();
translate([0,70,-0.1])tyco_multichannel_syringe1ml_clamp_luerlock();
}
//translate([-160,220-60,0])cube([150,250,150]);
}
}
}


module tyco_multichannel_syringe1ml_clamp(){
difference(){
union(){
translate([-183-13/2-5,170-13/2,30]){
translate([0,2,0])rotate([0,0,0])cube([120,13.9,15]);
translate([69,2-15,0])rotate([0,0,0])cube([18+8,23+20,5]);
}
}
translate([-120,220-60,0])cylinder(r=3.7/2,h=100);
translate([-120+15,220-60,0])cylinder(r=3.7/2,h=100);
translate([-120+7.5,220-60+23,0])cylinder(r=3.7/2,h=100);
translate([-120,220-60,32])cylinder(r=9.7/2,h=10);
translate([-120+15,220-60,32])cylinder(r=9.7/2,h=10);
translate([-120+7.5,220-60+23,32])cylinder(r=9.7/2,h=10);
for(i=[0:7]){
//translate([-183+(i*14),170,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170,44])rotate([0,90,90])tuberculin_syringe_1ml();
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=6/2,h=100);
if(i>0){
translate([-77.5-(i*14)-0.5,175.6,0])cylinder(r=2.8/2,h=150);
}else{
translate([-77.5-(i*14),175.6,0])cylinder(r=2.8/2,h=150);
}
}
translate([-77.5-(8*14)-1.7,175.6,0])cylinder(r=2.8/2,h=150);
}
}


module tyco_multichannel_syringe1ml_clamp_top_luerlock(){
difference(){ 
union(){
translate([-183-13/2-5,170-13/2,30]){
translate([0,2+7.25+60-1,10/2+10])rotate([0,0,0])cube([120,13/2+1,15/2+2-3]);
}   
}   
for(i=[0:7]){
//translate([-183+(i*14),170+60,44])rotate([0,90,90])syringe_1ml();
translate([-183+(i*14),170-50+60,44])rotate([0,90,90])cylinder(r=(6.5+0.3)/2,h=100);
if(i>0){
translate([-77.5-(i*14)-0.5,175+60.6,0])cylinder(r=3.7/2,h=150);
}else{ 
translate([-77.5-(i*14),175.6+60,0])cylinder(r=3.7/2,h=150);
}   
}       
translate([-77.5-(8*14)-1.7,175.6+60,0])cylinder(r=3.7/2,h=150);
}           
} 



//BD syringe 
module syringe_1ml(){

//translate([0,0,4])rotate([0,0,45])cylinder(r=10,h=15,$fn=4);
//translate([0,0,74])rotate([0,0,45])cylinder(r=10,h=15,$fn=4);
union(){
color("lightblue")translate([0,0,100])cylinder(r=3/2,h=30);
color("white")cylinder(r=9.5/2,h=92);
color("white")cylinder(r2=5.5/2,r1=9.5/2,h=92+7);
color("white")translate([0,0,-12-(71-12)])cylinder(r=4/2,h=92);
color("white")translate([0,0,-12-(71-12)])cylinder(r=(10-0.2)/2,h=1.5);
color("white")translate([0,0,0])cylinder(r=(10.5)/2,h=10.5);
color("white")translate([-12.5,-13/2-1,0])cube([25,13+2,2.4]);

/*
//luerlock
color("white")translate([0,0,98])cylinder(r=12/2,h=3);
color("white")translate([0,0,98+3])cylinder(r=8/2,h=3);

//tubing
color("lightblue")translate([0,0,98+3+3])cylinder(r=3.175/2, h=200);
//sphere(r=3.175/2,$fn=30);
*/
}
}

module tyco_multichannel_syringe1ml_clamp_luerlock(){
difference(){
union(){
translate([-183-13/2-5,170-13/2+60,30]){
translate([0,2+6.9,0])rotate([0,0,0])cube([120,13.9-7,15]);
translate([69,2-15-1,0])rotate([0,0,0])cube([18+8,23+20+1,5]);
}
}
translate([-120,220-60+60,0])cylinder(r=3.7/2,h=100);
translate([-120+15,220-60+60,0])cylinder(r=3.7/2,h=100);
translate([-120+7.5,220-60+23+60,0])cylinder(r=3.7/2,h=100);
for(i=[0:7]){
//translate([-183+(i*14),170,44])rotate([0,90,90])tuberculin_syringe_1ml();
translate([-183+(i*14),170-50,44])rotate([0,90,90])cylinder(r=(6.5+0.3)/2,h=200);

/*
if(i>0){
translate([-77.5-(i*14)-0.5,175.6+60,0])cylinder(r=2.8/2,h=150);
}else{
translate([-77.5-(i*14),175.6+60,0])cylinder(r=2.8/2,h=150);
}
*/
}
//translate([-77.5-(8*14)-1.7,175.6+60,0])cylinder(r=2.8/2,h=150);
}
}


module tuberculin_syringe_1ml(
    total_length = 155,
    barrel_od = 6.5+0.3,
    barrel_id = 5.0,
    plunger_head_dia = 4.8,
    flange_length = 19,
    flange_width = 12,
    flange_thick = 2.2,
    luer_lock_male = true
) {

    barrel_length = 73; // Approximate active barrel length
    luer_length = 2;
    luer_od = 4;
    luer_taper_length = 6;
    color("lightblue")cylinder(d=3,h=130,$fn=30);
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
            cylinder(h=luer_taper_length, d1=9, d2=9, $fn=32);

            // Threaded luer lock (simplified external threads)
            translate([0, 0, luer_taper_length])
                cylinder(h=luer_length, d=luer_od, $fn=32);
        }

        // Finger flanges at base
        translate([0, 0, 0]) {
            difference() {
                hull() {
                    translate([-flange_length/2, -flange_width/2, 0])
                        cube([flange_length, flange_width, flange_thick]);
                    cylinder(h=2, d=barrel_od, $fn=32);
                }
                // Center hole for barrel
                translate([0, 0, -0.1])
                    cylinder(h=2.2, d=barrel_id, $fn=32);
            }
        }
    }


    // Plunger
    plunger_extension = total_length - barrel_length - 10-2.5;

    color("gray", 0.8) {
        translate([0, 0, -plunger_extension]) {
            // Plunger rod
            cylinder(h=plunger_extension, d=1.5, $fn=16);

            // Plunger head/seal
            translate([0, 0, plunger_extension])
                cylinder(h=8, d=plunger_head_dia, $fn=32);

            // Plunger thumb rest
            translate([0, 0, -1]) {
                cylinder(h=2, d=10.1, $fn=32);
            }
        }
    }
}


module nextgen_syringe1ml_multichannel_assy(){
/*  
*/
color("silver")translate([-70+8,-80+40-50,30-5])rotate([-90,0,0])cylinder(r=8.7/2,h=250);
color("silver")translate([-70+8,-80,30-5])rotate([-90,0,0])cylinder(r=16/2,h=18);
translate([-70+8,-80,30-5])rotate([-90,0,0])nema17();
igus_slidermount_encoder_TW_04_12_motormount_assy_m8();
translate([-25-6.5,320,-4.6])rotate([90,0,0])tslot20(400);
}


module nema17(has_back, is_cylinder){
  mplate = 42.67; //mounting plate width
  mplateH = 0; //mounting plate height

  ringR = 22 / 2; //ring radius, can be 21.95/2
  ringH = 2; //ring thickness

  shaftR = 5/2; //shaft radius, can be 4.988/2
  shaftH = 20.07;  //shaft lenght

  bodyL = 46.5; //25.3, 33.13, 34.7, 40.9, 47.0, ...

  holeR = 3.5/2; //M3 or M4 or #4-40
  holeL = 31.0/2; //distance between hole centres

  difference(){
    union(){
      //ring
      color([0.7,0.7,0.7]) translate(v=[0,0,ringH/2]) cylinder(r=ringR, h=ringH, center=true);
      //shaft front
      color([0.9,0.9,0.9]) translate(v=[0,0,ringH+shaftH/2])cylinder(r=shaftR, h=shaftH, center=true);
      if (has_back == 1){
        color([0.9,0.9,0.9]) translate(v=[0,0,0-bodyL-shaftH/2]) cylinder(r=shaftR, h=shaftH, center=true);
      }
      //body
      if (is_cylinder == 1){
        color([0.1,0.1,0.1]) translate(v=[0,0,0-bodyL/2]) cylinder(r=mplate/2*1.2, h=bodyL, center=true);
      }else{
        union(){
          color([0.1,0.1,0.1]) translate(v=[0,0,0-bodyL/2]) cube(size = [mplate, mplate, bodyL], center=true);
          color([0.1,0.1,0.1]) translate(v=[0,0,0-bodyL/2]) cube(size = [mplate, mplate, bodyL], center=true);
        }
      }
    }
    translate(v=[holeL,holeL,0-bodyL/2]) cylinder(r = holeR, h = bodyL+10, center=true);
    translate(v=[-holeL,holeL,0-bodyL/2]) cylinder(r = holeR, h = bodyL+10, center=true);
    translate(v=[-holeL,-holeL,0-bodyL/2]) cylinder(r = holeR, h = bodyL+10, center=true);
    translate(v=[holeL,-holeL,0-bodyL/2]) cylinder(r = holeR, h = bodyL+10, center=true);
  }

}


module tslot20(length,nut){
	tslot(size=20,gap=5.26,thickness=1.5,length=length,nut=nut);
}

module tslot(
	size=10,	//size of each side
	length=10,	//length. descriptive enough, no?
	thickness=3,	//thickness of the 'sheet'
	gap=0,		//gap, thickness of the lower part of the 'T'
	center=false,	//somewhat vague. todo.
	nut=false,	//set to true to make a fitting T-slot nut
){
	start=thickness/sqrt(2);
	if(nut){
		linear_extrude(height=10)
		intersection(){
			polygon([[size/2-gap/2,0],[size/2-gap/2,thickness],[thickness+start,thickness],[size/2,size/2-2],[size-thickness-start,thickness],[size/2+gap/2,thickness],[size/2+gap/2,0]]);
			square([size,size/2-(gap+thickness)/2]);
		}
	}	
	else{
		color([0.5,0.5,0.5])
		linear_extrude(height=length,center=center)
		translate([15,15])
		difference(){
			union(){
				for(d=[0:3]) rotate([0,0,d*90]) polygon(points=[
					[0,0],
					[0,start],[size/2-thickness-start,size/2-thickness],[gap/2,size/2-thickness],[gap/2,size/2],
					[size/2,size/2],[size/2,gap/2],[size/2-thickness,gap/2],[size/2-thickness,size/2-thickness-start],[start,0]
				]);
				square(gap+thickness,center=true);
			}
			circle(r=gap/2,center=true);
		}
	}
}

