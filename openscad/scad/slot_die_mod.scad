//import("Slot_Die.stl");
include <ParametricSlotDie.scad>

//eppendorf_1pt5ml_holder();


//pipette_holder_4tip_luerlock_lid_18mm_slotdie();


/*
translate([0,0,-4])
//projection(cut=false)
linearactuator_rack_adjuster_milledpart();
*/
//linearactuator_rack_adjuster();

//translate([0,0,-1])p200_lts_diamondpositemp();
//slotdie_tipcase_holder_18mm();
//slotdie_assy_petg_lid_p200_DiamondPosiStop();

//translate([357,432,260])rotate([0,0,90])slotdie_assy_pp_single();
slotdie_assy_pp_single_placeholder();

//translate([357,432,260])rotate([0,0,90])slotdie_assy_pp();
//translate([357,432,260+2])rotate([0,0,90])slotdie_assy_petg_lid_p200();
//translate([0,0,-2.])color("pink")rotate([0,0,0])slotdie_assy_petg_p200();

//p200_lts();

//p20_lts_complete();

//translate([357,432,260])rotate([0,0,90])slotdie_assy_alum();

//translate([357,432,260])rotate([0,0,90])slotdie_assy();


//translate([357,432,260])rotate([0,0,90])slotdie_assy_petg_lid();
//translate([357,432,260])rotate([0,0,90])slotdie_assy_petg();


//import("slotdie_assy_pp_20_bottom_doubleA.stl");


/*
difference(){
translate([357,432,260])rotate([0,0,90])slotdie_assy_pp();
//translate([357+20-20,432,260-50-7.5-0+2])rotate([0,0,90])translate([-20+9,-18+4,-28.7+14+1])cube([22,80,50]);
translate([357-10,432,260-50-7.5+30])rotate([0,0,90])translate([-20+9,-18+4,-28.7+14+1])cube([22,40,50]);
}
*/

/*
translate([0,40,0])difference(){
translate([357,432,260])rotate([0,0,90])slotdie_assy_pp();
translate([357+20-20,432,260-50-7.5-0+2+50])rotate([0,0,90])translate([-20+9,-18+4,-28.7+14+1])cube([22,80,50]);
}
*/

//translate([357,432,260])rotate([0,0,90])slotdie_assy();

/*
translate([-5,0,-14.6])difference(){
translate([357-21,432-20,260-14.1])rotate([0,0,90])cube([40,2,0.5]);
//translate([357+10+1,432-8+7,260-14.1])rotate([0,0,90])cube([2,30,0.4]);
}


translate([-5,0,-14.6])difference(){
translate([357+10,432,260-14.1])rotate([0,0,90])cylinder(d=35,h=0.4,$fn=300);
translate([357+10+1,432-8+7,260-14.1])rotate([0,0,90])cube([2,30,0.4]);
}
translate([-5+10,0,-14.6])difference(){
translate([357+10,432,260-14.1])rotate([0,0,90])cylinder(d=55,h=0.4,$fn=300);
translate([357+10+1,432-8+7,260-14.1])rotate([0,0,90])cube([2,30,0.4]);
}


translate([-70,0,-14.6])difference(){
translate([357+10,432,260-14.1])rotate([0,0,90])cylinder(d=35,h=0.4,$fn=300);
translate([357+11+17.5,432-8+7,260-14.1])rotate([0,0,90])cube([2,20,0.4]);
}
translate([-70-10,0,-14.6])difference(){
translate([357+10,432,260-14.1])rotate([0,0,90])cylinder(d=55,h=0.4,$fn=300);
translate([357+11+17.5,432-8+7,260-14.1])rotate([0,0,90])cube([2,20,0.4]);
}

*/


//translate([357,432,260])rotate([0,0,90])slotdie_assy_pp_top();



/*
color("lime")linearactuator_rack_adjuster();
pipette_holder_4tip_luerlock_lid_18mm_slotdie();
linearactuator_pipette_holder_4pipette_luerlock_18mm_slotdie();
translate([0,0,9]){
compression_washer();
translate([-38*2,0,0])compression_washer();
}
translate([0,0,9]){
m3_screw_rackadjuster();
translate([-38*2,0,0])m3_screw_rackadjuster();
}
translate([0,0,7])for(i=[0:3]){
color("pink")translate([357-(18*i),431.5,290])pipette_10g_slotdie();
}
translate([302.5,432,300]){
for(i=[0:3]){
translate([0+(i*18),0,20])color("lightblue")cylinder(d=3,h=100,$fn=100);
color("white")translate([(i*18),0,0])luerlock_connector_slotdie();
}
}
translate([357,432,260])rotate([0,0,90])slotdie_assy();

translate([357,431.5,255])rotate([0,0,90])translate([0.7,17.3,-30-5+17])
difference(){
slotdie_tipcase_holder_18mm();
//translate([0,-50,0])cube([30,200,50]);
//translate([-20,-50,0])cube([40,40,50]);
}
*/


/*
translate([462,-450+147.4,-300+6])rotate([0,0,90]){
     translate([0,31,6])import("/Users/richard/Documents/voron/Trident/lineux_toolchanger/rister-toolchanger-4dispenser-mod/rister-toolchanger/openscad/stls/luerlock_pipette_assy/luer_lock_case_lid_18mm.stl");
     translate([0,31,6])import("/Users/richard/Documents/voron/Trident/lineux_toolchanger/rister-toolchanger-4dispenser-mod/rister-toolchanger/openscad/stls/luerlock_pipette_assy/luerlock_nozzle_case_18mm.stl");
     translate([0,31,6])import("/Users/richard/Documents/voron/Trident/lineux_toolchanger/rister-toolchanger-4dispenser-mod/rister-toolchanger/openscad/stls/luerlock_pipette_assy/luerlock_nozzle_bottom_18mm.stl");
}
*/

//translate([357,432,260])rotate([0,0,90])slotdie_assy();



module eppendorf_1pt5ml_holder(){


difference(){
translate([-10,-10,-5])cube([75,20,14]);

for(i=[0:3]){
translate([i*18,0,0])cylinder(d1=6,d2=9.5,h=14, $fn=80);
translate([i*18,0,0])sphere(d=6, $fn=80);

}

}

}


module linearactuator_rack_adjuster_milledpart(){

difference(){
union(){
#translate([280+5,420,323.5+1.5])cube([100-10,8+2,3]);
translate([280+45.25,420,323.5+1.5])cube([8,20,3]);
translate([280+4,420,323.5+1.5])cube([13,20,3]);
translate([280+4+78,420,323.5+1.5])cube([13,20,3]);
}
translate([280+4+78+5.3,430,323.5+1.5-80])cylinder(d=3.5,h=100,$fn=100);
translate([280+4+78+5.3-38*2,430,323.5+1.5-80])cylinder(d=3.5,h=100,$fn=100);
#translate([280+5+41,420,323.5+1.5])cube([7,4.8,4]);

}
}



module slotdie_assy(){
/*
for(i=[0:3]){
translate([-0,0+i*18,10])rotate([0,0,0])p200_lts_holder();
}
*/
difference(){
union(){
slot_die_4channel();
}
//translate([-20,18,-28.7+14])cube([50,50,50]);
//translate([-20,18,-35])cube([50,50,50]);
//translate([-20+20.6,18-30,-50])cube([50,150,100]);
}
}

/*

*/

/*
translate([0.7,17.3,-30-5+17])
difference(){
slotdie_tipcase_holder_18mm();
//translate([0,-50,0])cube([30,200,50]);
//translate([-20,-50,0])cube([40,40,50]);
}
*/


module slotdie_assy_alum(){
/*
for(i=[0:3]){
translate([-0,0+i*18,10])rotate([0,0,0])p200_lts_holder();
}
*/
difference(){
union(){
slot_die_4channel();
}
translate([0,0,1])for(i=[0:3]){
translate([6.8,0+i*18,-15-4-5])cylinder(d=3.1,h=8+5+5,$fn=100);
translate([6.8,0+i*18,-30-3])cylinder(d=5.2,h=11,$fn=100);
translate([6.8-13.7,0+i*18,-15-4-5])cylinder(d=3.1,h=8+5+5,$fn=100);
translate([6.8-13.7,0+i*18,-30-3])cylinder(d=5.2,h=11,$fn=100);
}

translate([-20+9,-18+4,-28.7+14+1+5])cube([22,80,50]);
//translate([-20,18+9.05,-35])cube([60,17.95+40,50]);
//translate([-20,18+9.05-(17.95*2),-35])cube([60,17.95,50]);
//translate([-20,18+9.05-(36.0498825)+17.90,-35])cube([60,17.95+80,50]);

//translate([-20,18+9.05-(36.0498825)+17.90+18.1+0.1,-35])cube([60,17.95+18.05-0.1+1,50]); //A
//translate([-20,18+9.05-(36.0498825)+17.90+18.1-36+0.1-0.20-0.1,-35])cube([60,17.95+18.05+0.4,50]); //B

//translate([-20+20.6,18-30,-50])cube([50,150,100]);
}
}



module slotdie_assy_pp_single(){
difference(){
union(){
slot_die_4channel_p200_dispenser_single();

}
translate([0,0,1])for(i=[0:0]){
translate([6.8,0+i*18,-15-4-5])cylinder(d=3.8,h=8+5+5,$fn=100);
translate([6.8,0+i*18,-30-3])cylinder(d=5.2,h=11,$fn=100);
translate([6.8-13.7,0+i*18,-15-4-5])cylinder(d=3.8,h=8+5+5,$fn=100);
translate([6.8-13.7,0+i*18,-30-3])cylinder(d=5.2,h=11,$fn=100);
}

translate([-20+9,-18+4,-28.7+14+1+5])cube([22,80,50]);
}
}


module slotdie_assy_pp_single_placeholder(){
difference(){
union(){
slot_die_4channel_p200_dispenser_single_placeholder();

}
#translate([0,0,1])for(i=[0:0]){
translate([6.8,0+i*18,-15-4-5])cylinder(d=2.5,h=8+5+5,$fn=100);
translate([6.8,0+i*18,-30-3])cylinder(d=4,h=11,$fn=100);
translate([6.8-13.7,0+i*18,-15-4-5])cylinder(d=2.5,h=8+5+5,$fn=100);
translate([6.8-13.7,0+i*18,-30-3])cylinder(d=4,h=11,$fn=100);
}

translate([-20+9,-18+4,-28.7+14+1+5])cube([22,80,50]);
}
}





module slotdie_assy_pp(){
/*
for(i=[0:3]){
translate([-0,0+i*18,10])rotate([0,0,0])p200_lts_holder();
}
*/
difference(){
union(){
slot_die_4channel_p200_dispenser();
//slot_die_4channel();
}
translate([0,0,1])for(i=[0:3]){
translate([6.8,0+i*18,-15-4-5])cylinder(d=3.8,h=8+5+5,$fn=100);
translate([6.8,0+i*18,-30-3])cylinder(d=5.2,h=11,$fn=100);
translate([6.8-13.7,0+i*18,-15-4-5])cylinder(d=3.8,h=8+5+5,$fn=100);
translate([6.8-13.7,0+i*18,-30-3])cylinder(d=5.2,h=11,$fn=100);
}

translate([-20+9,-18+4,-28.7+14+1+5])cube([22,80,50]);
//translate([-20,18+9.05,-35])cube([60,17.95+40,50]);
//translate([-20,18+9.05,-35])cube([60,17.95+40,17]);
//translate([-20,18+9.05-(17.95*2),-35])cube([60,17.95,50]);
//translate([-20,18+9.05-(36.0498825)+17.90,-35])cube([60,17.95+80,50]);

//translate([-20,18+9.05-(36.0498825)+17.90+18.1+0.1,-35])cube([60,17.95+18.05-0.1+1+2,50]); //A
//translate([-20,18+9.05-(36.0498825)+17.90+18.1-36+0.1-0.20-0.1-3,-35])cube([60,17.95+18.05+0.4+3,50]); //B
//translate([-20,18+9.05-(36.0498825)+17.90+18.1-36+0.1-0.20-0.1,-35])cube([60,17.95+18.05+0.4+20,50]); //B tmp

//translate([-20+20.6,18-30,-50])cube([50,150,100]);
}
}




module slotdie_assy_petg_lid(){
difference(){
union(){
slot_die_4channel_lid();
}
translate([0,0,1])for(i=[0:3]){
translate([6.8,0+i*18,-15-4])cylinder(d=1.6,h=15,$fn=100);
translate([6.8,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
translate([6.8-13.7,0+i*18,-15-4])cylinder(d=1.6,h=15,$fn=100);
translate([6.8-13.7,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
}

//translate([-20+9,-18+4,-28.7+14+1])cube([22,80,50]);
translate([-20+9,-18+4,-28.7+14+1-50+5])cube([22,80,50]);
//translate([-20,18,-35])cube([50,50,50]);
//translate([-20+20.6,18-30,-50])cube([50,150,100]);
}
}



module slotdie_assy_petg_lid_p200_DiamondPosiStop(){
difference(){
union(){
slot_die_4channel_lid_p200_diamondposistop();
}
}
/*
translate([0,0,1])for(i=[0:3]){
translate([6.8,0+i*18,-15-4])cylinder(d=3.6,h=15,$fn=100);
translate([6.8,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
translate([6.8-13.7,0+i*18,-15-4])cylinder(d=3.6,h=15,$fn=100);
translate([6.8-13.7,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
}
*/

//translate([-20+9,-18+4,-28.7+14+1])cube([22,80,50]);
//translate([-20+9,-18+4,-28.7+14+1])cube([22,30,50]);
//translate([-20+9,-18+4,-28.7+14+1-50+5])cube([22,80,50]);
//translate([-20,18,-35])cube([50,50,50]);
//translate([-20+20.6,18-30,-50])cube([50,150,100]);
}






module slotdie_assy_petg_lid_p200(){
difference(){
union(){
slot_die_4channel_lid_p200();
}
/*
translate([0,0,1])for(i=[0:3]){
translate([6.8,0+i*18,-15-4])cylinder(d=3.6,h=15,$fn=100);
translate([6.8,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
translate([6.8-13.7,0+i*18,-15-4])cylinder(d=3.6,h=15,$fn=100);
translate([6.8-13.7,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
}
*/

//translate([-20+9,-18+4,-28.7+14+1])cube([22,80,50]);
//translate([-20+9,-18+4,-28.7+14+1])cube([22,30,50]);
//translate([-20+9,-18+4,-28.7+14+1-50+5])cube([22,80,50]);
//translate([-20,18,-35])cube([50,50,50]);
//translate([-20+20.6,18-30,-50])cube([50,150,100]);
}
}





module slotdie_assy_petg(){
difference(){
union(){
slot_die_4channel();
}
translate([0,0,1])for(i=[0:3]){
translate([6.8,0+i*18,-15-4])cylinder(d=1.6,h=15,$fn=100);
translate([6.8,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
translate([6.8-13.7,0+i*18,-15-4])cylinder(d=1.6,h=15,$fn=100);
translate([6.8-13.7,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
}

//translate([-20+9,-18+4,-28.7+14+1])cube([22,80,50]);
translate([-20+9,-18+4,-28.7+14+1-50+5])cube([22,80,50]);
//translate([-20,18,-35])cube([50,50,50]);
//translate([-20+20.6,18-30,-50])cube([50,150,100]);
}
}

module slotdie_assy_petg_p200(){
difference(){
union(){
slot_die_4channel_p200();
}
translate([0,0,1])for(i=[0:3]){
translate([6.8,0+i*18,-15-4])cylinder(d=1.85,h=15,$fn=100);
translate([6.8,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
translate([6.8-13.7,0+i*18,-15-4])cylinder(d=1.85,h=15,$fn=100);
translate([6.8-13.7,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
}

//translate([-20+9,-18+4,-28.7+14+1])cube([22,80,50]);

//translate([-20+9,-18+4-20,-28.7+14+1-50+5])cube([22,80,50]);

//translate([-20,18,-35])cube([50,50,50]);
//translate([-20+20.6,18-30,-50])cube([50,150,100]);
}
}







module slotdie_assy_pp_top(){
/*
for(i=[0:3]){
translate([-0,0+i*18,10])rotate([0,0,0])p200_lts_holder();
}
*/
difference(){
union(){
slot_die_4channel();
}
translate([0,0,1])for(i=[0:3]){
translate([6.8,0+i*18,-15-4])cylinder(d=1.8,h=9,$fn=100);
translate([6.8,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
translate([6.8-13.7,0+i*18,-15-4])cylinder(d=1.8,h=9,$fn=100);
translate([6.8-13.7,0+i*18,-30])cylinder(d=5.2,h=11,$fn=100);
}

translate([-20,-18-50,-28.7+14+1-23.7])cube([100,150,23.7]);
//translate([-20,18,-35])cube([50,50,50]);
//translate([-20+20.6,18-30,-50])cube([50,150,100]);
}
}









module pipette_10g_slotdie(){
translate([0,0,8]){
cylinder(d=8,h=3,$fn=100);
translate([0,0,-11])cylinder(d2=7,d1=6.1,h=11,$fn=100);
translate([0,0,-11-18.5])cylinder(d2=5,d1=4,h=18.5,$fn=100);
//translate([0,0,-29])cylinder(d2=5,d1=1,h=29,$fn=100);
}
}


module pipette_18g_slotdie(){
translate([0,0,8]){
cylinder(d=8,h=3,$fn=100);
translate([0,0,-11])cylinder(d2=7,d1=6.1,h=11,$fn=100);
translate([0,0,-11-18.5])cylinder(d2=5,d1=1.5,h=18.5,$fn=100);
//translate([0,0,-29])cylinder(d2=5,d1=1,h=29,$fn=100);
}
}


module slot_die_4channel_lid(){
rotate([0,90,0]){
difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
difference(){
union(){
translate([-9-1+9-13.0,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 13], corner_radius);
//translate([-9-1+9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7], corner_radius);
}
//color("pink")
//translate([-9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14], corner_radius);
//color("pink")
//translate([-9,-11+3,10-3.5])rotate([0,90,0])rounded_cube([20-7, 76.5-6, 14], corner_radius);
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=4.5,h=43,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=4.5,h=43,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=4.5,h=43,$fn=100);
translate([0,0,12.5]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=4.5,h=43,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=4.5,h=43,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=4.5,h=43,$fn=100);
}
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=3.4,h=50,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=3.4,h=50,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=3.4,h=50,$fn=100);
translate([0,0,12.5]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=3.4,h=50,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=3.4,h=50,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=3.4,h=50,$fn=100);
}
}
}
translate([-2.2,0,0])for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.4,1.4,1])p20_lts_complete();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
}
translate([-2,0,0])for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.4,1.4,1])p20_lts_complete();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
}
translate([-2.25,0,0])for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.4,1.4,1])p20_lts_complete_toppartmod();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete_toppartmod();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete_toppartmod();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete_toppartmod();}
}
translate([5,-28-1,-20])cube([25,20,40]);
translate([5,62.5+1,-20])cube([25,20,40]);
}
}
}






module slot_die_4channel_lid_p200(){
rotate([0,90,0]){
difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
difference(){
union(){
translate([-9-1+9-13.0-2,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 13+2+2], corner_radius);
//translate([-9-1+9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7], corner_radius);
}
//color("pink")
//translate([-9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14], corner_radius);
//color("pink")
//translate([-9,-11+3,10-3.5])rotate([0,90,0])rounded_cube([20-7, 76.5-6, 14], corner_radius);

translate([-6,0,0]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
translate([0,0,12.5]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
}
}

translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
translate([0,0,12.5]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
}
}
}
translate([-2+4,0,0])for(i=[0:3]){
translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts();
translate([-10+10-15.15-1,0+18*i,0])rotate([0,-90,0])cylinder(d2=12,d1=4,h=2.2,$fn=30);
translate([-10+10-15,0+18*i,0])rotate([0,-90,0])cylinder(d2=7.8,d1=7.8,h=0.2+1,$fn=30);
translate([-10+10-15+3.2+12,0+18*i,0])rotate([0,-90,0])cylinder(d2=7.2,d1=7.2,h=3.2+12,$fn=30);
/*
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts();translate([-10+10-5,0+18*i,0])rotate([0,-90,0])cylinder(d2=7,d1=6,h=5,$fn=30);}

if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts();translate([-10+10-14.9,0+18*i,0])rotate([0,-90,0])cylinder(d2=12,d1=6,h=3.2,$fn=30);}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts();translate([-10+10,0+18*i,0])rotate([0,-90,0])cylinder(d2=7,d1=6,h=5,$fn=30);}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts();translate([-10+10,0+18*i,0])rotate([0,-90,0])cylinder(d2=7,d1=6,h=5,$fn=30);}
*/
}
//translate([5,-28-1,-20])cube([25,20,40]);
//translate([5,62.5+1,-20])cube([25,20,40]);
}
}
}


module slot_die_4channel_lid_p200_diamondposistop(){
//translate([0,0,-1])p200_lts_diamondpositemp();
rotate([0,90,0]){
difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
difference(){
union(){
md = 7.3;
translate([-9-1+9-13.0-2-1+md,-11+0,10])rotate([0,90,0])rounded_cube([20, 76.5, 13+2+2+1-md], corner_radius);
//translate([-9-1+9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7], corner_radius);
}
//color("pink")
//translate([-9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14], corner_radius);
//color("pink")
//translate([-9,-11+3,10-3.5])rotate([0,90,0])rounded_cube([20-7, 76.5-6, 14], corner_radius);

#translate([-6+5.3,0,0]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
translate([0,0,12.5]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=4.5,h=45,$fn=100);
}
}

translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
translate([0,0,12.5]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=3.4,h=60,$fn=100);
}
}
}
translate([-2+4,0,0])for(i=[0:3]){
//#translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts();
//translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts_diamondpositemp();

//translate([-10+10-15.15-1.2,0+18*i,0])rotate([0,-90,0])cylinder(d2=12,d1=6.5,h=2.2+0.5,$fn=30);
//translate([-10+10-15,0+18*i,0])rotate([0,-90,0])cylinder(d2=7.8,d1=7.8,h=0.2+1+0.2,$fn=30);
//#translate([-10+10-15+3.2+12,0+18*i,0])rotate([0,-90,0])cylinder(d2=7.5,d1=7.5,h=3.2+12,$fn=30);
translate([-0.2,0,0]){
translate([-10+10-15.15-1.2+7.5,0+18*i,0])rotate([0,-90,0])cylinder(d2=12,d1=4.5,h=2.2+0.5,$fn=30);
translate([-10+10-15+7.65,0+18*i,0])rotate([0,-90,0])cylinder(d2=6.55,d1=6.55,h=0.2+1+0.2,$fn=30);
}
translate([-10+10-15+3.2+12.1-0.22+0.1,0+18*i,0])rotate([0,-90,0])cylinder(d2=6.55,d1=6.55,h=3.2+12-6.05,$fn=30);
translate([-10+10-15+3.2+12.1-2,0+18*i,0])rotate([0,-90,0])#cylinder(d2=5.6,d1=5.6,h=3.2+12-6.05,$fn=30);
/*
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts();translate([-10+10-5,0+18*i,0])rotate([0,-90,0])cylinder(d2=7,d1=6,h=5,$fn=30);}

if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts();translate([-10+10-14.9,0+18*i,0])rotate([0,-90,0])cylinder(d2=12,d1=6,h=3.2,$fn=30);}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts();translate([-10+10,0+18*i,0])rotate([0,-90,0])cylinder(d2=7,d1=6,h=5,$fn=30);}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.1,1.1,1])p200_lts();translate([-10+10,0+18*i,0])rotate([0,-90,0])cylinder(d2=7,d1=6,h=5,$fn=30);}
*/
}
//translate([5,-28-1,-20])cube([25,20,40]);
//translate([5,62.5+1,-20])cube([25,20,40]);
}
}
}






module slot_die_4channel(){
rotate([0,90,0]){
/*
//this is how it fits
translate([0+8-10,0,0])for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.4,1.4,1])p20_lts_complete();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
}
*/
difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
difference(){
translate([-9-1+9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7], corner_radius);
//color("pink")
//translate([-9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14], corner_radius);
//color("pink")
//translate([-9,-11+3,10-3.5])rotate([0,90,0])rounded_cube([20-7, 76.5-6, 14], corner_radius);
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
translate([0,0,12.5]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
}
}
difference(){
//color("lime")
translate([50,22.9,0])rotate([0,90,0])translate([-10,-30,-44])rounded_cube([20, 68.5, 19], corner_radius);
translate([-9-1-2,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7+4], corner_radius);
color("lime")translate([50,22.9,0])rotate([0,90,0])translate([-10+5,-30,-44])rounded_cube([20-10, 68.5, 19], corner_radius);
}
difference(){union(){
slotdie_t(0.98);
translate([0,18,0])slotdie_t(0.98);
translate([0,18*2,0])slotdie_t(0.98);
translate([0,18*3,0])slotdie_t(0.98);
translate([-10,4,-6])cube([20,10,12]);
translate([-10,4+18,-6])cube([20,10,12]);
translate([-10,4+36,-6])cube([20,10,12]);
}
translate([-9-1-2,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7+4], corner_radius);
}
}
for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.4,1.4,1])p20_lts_complete();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
}
translate([5,-28-1,-20])cube([25,20,40]);
translate([5,62.5+1,-20])cube([25,20,40]);
}
}
}








module slot_die_4channel_p200(){
rotate([0,90,0]){

/*
translate([0+8-10+16-15,0,0])for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts();}
}
*/

difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
difference(){
translate([-9-1+9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-8+6-4], corner_radius);
//color("pink")
//translate([-9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14], corner_radius);
//color("pink")
//translate([-9,-11+3,10-3.5])rotate([0,90,0])rounded_cube([20-7, 76.5-6, 14], corner_radius);
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=1.85,h=90,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=1.85,h=90,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=1.85,h=90,$fn=100);
translate([0,0,12.5]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=1.85,h=90,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=1.85,h=90,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=1.85,h=90,$fn=100);
}
}
/*
difference(){
//color("lime")
translate([50,22.9,0])rotate([0,90,0])translate([-10,-30,-44])rounded_cube([20, 68.5, 19], corner_radius);
translate([-9-1-2,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7+4], corner_radius);
color("lime")translate([50,22.9,0])rotate([0,90,0])translate([-10+5,-30,-44])rounded_cube([20-10, 68.5, 19], corner_radius);
}
*/

/*
difference(){union(){
slotdie_t(0.98);
translate([0,18,0])slotdie_t(0.98);
translate([0,18*2,0])slotdie_t(0.98);
translate([0,18*3,0])slotdie_t(0.98);
translate([-10,4,-6])cube([20,10,12]);
translate([-10,4+18,-6])cube([20,10,12]);
translate([-10,4+36,-6])cube([20,10,12]);
}
translate([-9-1-2,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7+4], corner_radius);
}
*/

}
/*
for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.4,1.4,1])p20_lts_complete();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.3,1.3,1])p20_lts_complete();}
}
*/
/*
translate([-4.8+4.8,0,0])for(i=[0:3]){
if(i==0){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=60,$fn=100);}
if(i==1){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=60,$fn=100);}
if(i==2){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=60,$fn=100);}
if(i==3){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=60,$fn=100);}
}
*/

translate([-4.8+4.8,0,0])for(i=[0:3]){
if(i==0){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=4.,h=60,$fn=100);}
if(i==1){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=4.,h=60,$fn=100);}
if(i==2){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=4.,h=60,$fn=100);}
if(i==3){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=4.,h=60,$fn=100);}
}
/*
*/

/*
for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts_holder();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts_holder();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts_holder();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts_holder();}
}
*/
translate([1.25+2.75-4,0,0])for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
}

//translate([5,-28-1,-20])cube([25,20,40]);
//translate([5,62.5+1,-20])cube([25,20,40]);
}
}
}






module slot_die_4channel_p200_dispenser_single_placeholder(){
difference(){union(){
rotate([0,90,0]){
difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
difference(){
translate([-9-1+9,-11+3,10])rotate([0,90,0])rounded_cube([20, 76.5-6-54, 14+4-8+6-4], corner_radius);
}
difference(){
//color("lime")
translate([50,22.9,0])rotate([0,90,0])translate([-10,-30-1.9,-44])rounded_cube([20, 68.5+3.5-54, 19], corner_radius);
translate([-9-1-2,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7+4], corner_radius);
color("lime")translate([50,22.9,0])rotate([0,90,0])translate([-10+5,-30,-44])rounded_cube([20-10, 68.5, 19], corner_radius);
}

difference(){
union(){
slotdie_t(0.98);
}
translate([-9-1-2+37,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7+4], corner_radius);
}
}
translate([-4.8+4.8,0,0])for(i=[0:0]){
translate([-10+10+13.5-3,0+18*i,0])rotate([0,-90,0])cylinder(d1=3.95,d2=4.3,h=2,$fn=100);
translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=3.95,h=5,$fn=100);
}

translate([-4.8+4.8,0,0])for(i=[0:3]){
if(i==0){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=3.75+4,$fn=100);}
if(i==1){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=7.75,$fn=100);}
if(i==2){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=7.75,$fn=100);}
if(i==3){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=7.75,$fn=100);}
}
}
}
}
translate([-10,8,-27])#cube([20,20,20]);
}

}



module slot_die_4channel_p200_dispenser_single(){
rotate([0,90,0]){

difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
difference(){
translate([-9-1+9,-11+3,10])rotate([0,90,0])rounded_cube([20, 76.5-6-54, 14+4-8+6-4], corner_radius);
}
difference(){
//color("lime")
translate([50,22.9,0])rotate([0,90,0])translate([-10,-30-1.9,-44])rounded_cube([20, 68.5+3.5-54, 19], corner_radius);
translate([-9-1-2,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7+4], corner_radius);
color("lime")translate([50,22.9,0])rotate([0,90,0])translate([-10+5,-30,-44])rounded_cube([20-10, 68.5, 19], corner_radius);
}

difference(){
union(){
slotdie_t(0.98);
}
translate([-9-1-2,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7+4], corner_radius);

}
}
translate([-4.8+4.8,0,0])for(i=[0:0]){
translate([-10+10+13.5-3,0+18*i,0])rotate([0,-90,0])cylinder(d1=3.95,d2=4.3,h=2,$fn=100);
translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=3.95,h=5,$fn=100);
}

translate([-4.8+4.8,0,0])for(i=[0:3]){
if(i==0){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=3.75+4,$fn=100);}
if(i==1){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=7.75,$fn=100);}
if(i==2){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=7.75,$fn=100);}
if(i==3){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=7.75,$fn=100);}
}
}
}
}


























module slot_die_4channel_p200_dispenser(){
rotate([0,90,0]){
/*
translate([0+8-10+16-15,0,0])for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1,1,1])p200_lts();}
}
*/

difference(){
union(){
corner_radius = 1;  // Adjust this value to change roundness
difference(){
translate([-9-1+9,-11+3,10])rotate([0,90,0])rounded_cube([20, 76.5-6, 14+4-8+6-4], corner_radius);
//color("pink")
//translate([-9,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14], corner_radius);
//color("pink")
//translate([-9,-11+3,10-3.5])rotate([0,90,0])rounded_cube([20-7, 76.5-6, 14], corner_radius);
/*
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
translate([0,0,12.5]){
translate([-50,-7.5,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
translate([-50,-7.5+34.5,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
translate([-50,-7.5+69,-6])rotate([0,90,0])cylinder(d=1.8,h=90,$fn=100);
}
*/
}
difference(){
//color("lime")
translate([50,22.9,0])rotate([0,90,0])translate([-10,-30-1.9,-44])rounded_cube([20, 68.5+3.5, 19], corner_radius);
translate([-9-1-2,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7+4], corner_radius);
color("lime")translate([50,22.9,0])rotate([0,90,0])translate([-10+5,-30,-44])rounded_cube([20-10, 68.5, 19], corner_radius);
}
/*
*/

/*
*/
difference(){
union(){
slotdie_t(0.98);
translate([0,18,0])slotdie_t(0.98);
translate([0,18*2,0])slotdie_t(0.98);
translate([0,18*3,0])slotdie_t(0.98);
translate([-10,4,-6])cube([20,10,12]);
translate([-10,4+18,-6])cube([20,10,12]);
translate([-10,4+36,-6])cube([20,10,12]);
}
translate([-9-1-2,-11,10])rotate([0,90,0])rounded_cube([20, 76.5, 14+4-7+4], corner_radius);

/*
translate([1.25+2.75-4,0,0])for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
}
*/
}
}


translate([-4.8+4.8,0,0])for(i=[0:3]){
translate([-10+10+13.5-3,0+18*i,0])rotate([0,-90,0])cylinder(d1=3.95,d2=4.3,h=2,$fn=100);
translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=3.95,h=5,$fn=100);

/*
if(i==0){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=4.3,h=5,$fn=100);}
if(i==1){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=4.3,h=5,$fn=100);}
if(i==2){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=4.3,h=5,$fn=100);}
if(i==3){translate([-10+10+13.5,0+18*i,0])rotate([0,-90,0])cylinder(d=4.3,h=5,$fn=100);}
*/
}



translate([-4.8+4.8,0,0])for(i=[0:3]){
if(i==0){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=3.75+4,$fn=100);}
if(i==1){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=7.75,$fn=100);}
if(i==2){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=7.75,$fn=100);}
if(i==3){translate([-10+10+13.5+5,0+18*i,0])rotate([0,-90,0])cylinder(d=2.7,h=7.75,$fn=100);}
}


/*
translate([1.25+2.75-4,0,0])for(i=[0:3]){
if(i==0){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
if(i==1){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
if(i==2){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
if(i==3){translate([-10+10,0+18*i,0])rotate([0,-90,0])scale([1.05,1.05,1])p200_lts();}
}
*/

//translate([5,-28-1,-20])cube([25,20,40]);
//translate([5,62.5+1,-20])cube([25,20,40]);
}
}
}









































module slotdie_t(sc){
difference(){
union(){
//slotdie (l,w,h,innerrad,tankwidth,slit,block2,internalshift)
slotdie(60,18,12,3,(7.5+1.3),0.2,12.5,20);
}
//translate([-10,0,0])rotate([0,-90,0])scale([sc,sc,1])p200_lts_holder();
//translate([-50,-40,0])cube([100,60,40]);
translate([-110,-40,-20])cube([100,160,80]);
}
}


module p200_lts(){
//top part is cut out
color("lime")cylinder(d2=7,d1=6,h=15,$fn=30);
translate([0,0,-9.75])cylinder(d2=5,d1=4.5,h=9.75,$fn=30);
translate([0,0,-7])cylinder(d2=4.2,d1=3.8,h=7,$fn=30);
}

module p200_lts_diamondpositemp(){
//top part is cut out
//translate([0,0,7.5])color("pink")cylinder(d1=6.36,d2=7.1,h=7.8,$fn=30);
color("lime")cylinder(d1=5.9,d2=6.35,h=7.8,$fn=30);
translate([0,0,-17.46])cylinder(d2=4.85,d1=3.37,h=17.46,$fn=30);
//translate([0,0,-7])cylinder(d2=4.2,d1=3.8,h=7,$fn=30);
}




module p200_lts_holder(){
//scale([0.972,0.972,1]){
color("peru")
cylinder(d2=7.1,d1=6.1,h=13,$fn=30);
color("black")
translate([0,0,-9.])cylinder(d2=(5+1.6),d1=(4.8+1.6),h=9,$fn=30);
color("peru")
translate([0,0,-9.-6.0])cylinder(d2=(4.5+0.2),d1=(4+0.2),h=6,$fn=30);
//color("peru")
//translate([0,0,-9.-6.0-10])cylinder(d2=(3.85+0.2),d1=(2.85+0.2),h=10,$fn=30);
//}
}


module p20_lts_complete_toppartmod(){
            translate([0,0,9-0.1])color("lightgreen")cylinder(d2=(6+4.5),d1=(5.5),h=6.2,$fn=30);
}


module p20_lts_complete(){
    difference(){
        // OUTER PROFILE
        union(){
	    //p20_lts_complete_toppartmod();
            //translate([0,0,9])color("lightgreen")cylinder(d2=6,d1=5.8,h=6.2,$fn=30);
            color("pink")cylinder(d2=5.8,d1=5.5,h=9,$fn=30);
            color("lime")translate([0,0,-5.5])cylinder(d2=4.5,d1=2,h=5.5,$fn=30);
            color("lightblue")translate([0,0,-5.5-8])cylinder(d2=2,d1=1.8,h=8,$fn=30);
            //color("peru")translate([0,0,-5.5-8-13])cylinder(d2=1.6,d1=1.1,h=13,$fn=30);
            //color("white")translate([0,0,-5.5-8-13-8])cylinder(d2=1,d1=0.6,h=8,$fn=30);
        }
	/*
        // INNER PROFILE (wall thickness = 0.3mm total)
        union(){
            translate([0,0,9])cylinder(d2=5.7,d1=5.5,h=6.3,$fn=30);
            cylinder(d2=5.5,d1=5.2,h=9.1,$fn=30);
            translate([0,0,-5.5])cylinder(d2=4.2,d1=1.7,h=5.6,$fn=30);
            translate([0,0,-5.5-8])cylinder(d2=1.7,d1=1.5,h=8.1,$fn=30);
            translate([0,0,-5.5-8-13])cylinder(d2=1.3,d1=0.8,h=13.1,$fn=30);
            translate([0,0,-5.5-8-13-8])cylinder(d2=0.7,d1=0.3,h=8.1,$fn=30);
        }
	*/
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


module slotdie_tipcase_holder_18mm(){
difference(){
union(){
color("peru"){
translate([-17+10-1.5,13.5+25,-14])cube([10+3,13+16,10]);
translate([-17+5,13.5-3+23,-14])cube([23,10-0.5+3+12,10]);
translate([-17+5-2,13-36-4-4,-14])cube([5+18+4-0,10+36+20+8+8,33]);
//translate([-17+3+20,13-36,-14])cube([5,10+36+20,6]);
translate([-17+5,13-36-15,-14])cube([23,10+3,10]);
translate([-17+10-1.5,13-36-8-15,-14])cube([10+3,18+10,10]);
}
}
corner_radius = 1;  // Adjust this value to change roundness
translate([-2,0,5])
for(i=[-1:1]){
for(j=[-1:1]){
//translate([337-12.5,427,300-15+0.2+0.8-20+14])rotate([0,180,90])
//translate([-4-2-2-2,-5-2-15-6-2,-2-16-16-4-2-4])
translate([2,0,0]){
translate([0,-4.2,-15]){


translate([-10.5+j/2,-16.5+i/2-7.5,5])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5+17+8, 7.5-1+4+2+6.5+10], corner_radius);
translate([-10.5+i/2,-16.5+j/2-7.5,5])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5+17+8, 7.5-1+4+2+6.5+10], corner_radius);

//translate([-10.5+j/2,-16.5+i/2-7.5,5])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5+17, 7.5-1+4+2+6.5+10], corner_radius);
//translate([-10.5+i/2,-16.5+j/2-7.5,5])rounded_cube([8+4+4+4, 10+4+15+10+4+8.5+17, 7.5-1+4+2+6.5+10], corner_radius);

}
sub=9;
asub= 6;
translate([0,0,-13.5]){
translate([-10.5+j/2+asub/2,-16.5+i/2+sub/2-3-9+1.5,5-16])rounded_cube([8+4+4+4-asub, 10+4+15+10+4+8.5-sub+6+10+10-3, 7.5-1+4+3.1+16], corner_radius);
translate([-10.5+i/2+asub/2,-16.5+j/2+sub/2-3-9+1.5,5-16])rounded_cube([8+4+4+4-asub, 10+4+15+10+4+8.5-sub+6+10-3, 7.5-1+4+3.1+16], corner_radius);
translate([-10.5+i/2+asub/2,-16.5+j/2+sub/2-3-9+4+1.5,5-16])rounded_cube([8+4+4+4-asub, 10+4+15+10+4+8.5-sub+6+10-3, 7.5-1+4+3.1+16], corner_radius);

//for slot die blade
translate([-10.5+j/2+asub/2+1.2,-16.5+i/2+sub/2-4-11.5+1,5])rounded_cube([6+5.4, 10+4+15+10+4+8.5-sub+8+24-2, 7.5-1+4+2+16.5], corner_radius);
translate([-10.5+i/2+asub/2+1.2,-16.5+j/2+sub/2-4-11.5+1,5])rounded_cube([6+5.4, 10+4+15+10+4+8.5-sub+8+24-2, 7.5-1+4+2+6.5], corner_radius);
translate([-10.5+i/2+asub/2+1.2,-16.5+j/2+sub/2-4-11.5+1,-5-2])rounded_cube([6+5.4, 10+4+15+10+4+8.5-sub+8+24-2, 7.5-1+4+2+6.5], corner_radius);
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
translate([0,11.5,0]){
translate([-2,23+19+5,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23+19+5,-11])cylinder(d=10.5,h=50,$fn=100);
}
translate([0,-46-5-10.45,0]){
translate([-2,23,-22])cylinder(d=5.2,h=42,$fn=100);
translate([-2,23,-11])cylinder(d=10.5,h=50,$fn=100);
}
}
}


module linearactuator_rack_adjuster(){

import("linearactuator_rack_stub.stl");
difference(){
union(){
#translate([280+5,420,323.5+1.5])cube([100-10,8,7]);
#translate([280+45.25,420,323.5+1.5])cube([8,20,7]);
#translate([280+4,420,323.5+1.5])cube([13,20,7]);
#translate([280+4+78,420,323.5+1.5])cube([13,20,7]);
}

translate([280+4+78+5.3,430,323.5+1.5-80])cylinder(d=3.5,h=100,$fn=100);
translate([280+4+78+5.3-38*2,430,323.5+1.5-80])cylinder(d=3.5,h=100,$fn=100);
//translate([-2,4.5+38,-30])cylinder(d=3.2,h=100,$fn=100);

}

}

module m3_screw_rackadjuster(){
translate([367.3,430,323+3])color("silver")cylinder(d=9,h=3,$fn=100);
translate([367.3,430,323+4])rotate([0,180,0])color("silver")cylinder(d=3.3,h=30,$fn=100);
}


module compression_washer(){
translate([367.3,430,323])color("pink")difference(){
cylinder(d=10,$fn=100,h=3);
translate([0,0,-2])cylinder(d=3.5,$fn=100,h=6);
}
}


module linearactuator_pipette_holder_4pipette_luerlock_18mm_slotdie(){

difference(){
//import("linearactuator_rack_stub.stl");

//a=[11.2,11.9,11.2,11.2];

/*
a=[18,18,18,18];
translate([400-70+4.5-18,426.5,330-3-2])rotate([0,0,-90])translate([-0.5-1,-0.7,13])for(i=[0:3]){
translate([0,-5.8+18*i-4.9,-21.4-3.5])cylinder(d1=8,d2=8,h=13,$fn=30);
translate([0,-5.8+18*i-4.9,-21.4-3.5+2])cylinder(d=a[i],h=18,$fn=30);
}
*/
}
difference(){union(){
translate([400-70+4.5,426.5,330-3])rotate([0,0,-90]){
translate([0,0,-13]){
translate([-0.5-1,-0.7,0])rotate([0,180,180])pipette_holder_4tip_luerlock_slotdie();
}
}
}
//translate([0,0,-9])import("linearactuator_rack_stub.stl");

for(i=[-2:2]){
for(j=[-2:2]){
translate([i*0.2,j*0.2,-13.5])import("linearactuator_rack_stub.stl");
}
}



}
}



module pipette_holder_4tip_luerlock_slotdie(){
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
translate([0-6,4.5,3])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+15+19+20, 13], radius = 2, center = true);
translate([0,4.5,3])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+15+19+20, 13], radius = 2, center = true);
translate([0+1,4.5,3])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+15+19+20, 13], radius = 2, center = true);
//translate([-11,4.5-1.5,3-8])color("pink")cube([17,3,3]);
}

translate([-2,4.5+38,-30])cylinder(d=3.5,h=100,$fn=100);
translate([0,0,35]){
translate([-2,4.5+38,-30])rotate([0,0,30])cylinder(d=6.5,h=2.8+2,$fn=6);
}
translate([-2,4.5-38,-30])cylinder(d=3.5,h=100,$fn=100);
translate([0,0,35]){
translate([-2,4.5-38,-30])rotate([0,0,30])cylinder(d=6.5,h=2.8+2,$fn=6);
}


translate([0-4,-2,17.8]){
l = 7.2;
a=[11.2,11.2,11.2,11.2];
translate([0,-10,0])for(i=[0:3]){
//translate([0,-5.8+11.5*i-4.9,-21.4+6.5])cylinder(d1=6.6,d2=6.3,h=7,$fn=30);
//translate([0,-5.8+11.5*i-4.9,-21.4-3.5+2])cylinder(d=a[i],h=8,$fn=30);
translate([0,-5.8+18*i-4.9,-21.4+6.5])cylinder(d1=6.6,d2=6.3,h=7,$fn=30);
translate([0,-5.8+18*i-4.9,-21.4-3.5+2])cylinder(d=a[i],h=8,$fn=30);
}
}
translate([14-6,0-2,17.8-18])rotate([0,90,0]){
l = 26;
translate([0,-10,-13])for(i=[0:3]){
translate([0,-5.8+18*i-4.9,-21.4])cylinder(d=1.7,h=l,$fn=100);
}
}
}
}

module rounded_box_minkowski(size, radius, center = false) {
    // Adjust cube size to compensate for the Minkowski sum
    adjusted_size = size - [2*radius, 2*radius, 2*radius];
    
    // Calculate translation for centering if needed
    translate_vec = (center == true) ?
        [ -size[0]/2 + radius, -size[1]/2 + radius, -size[2]/2 + radius ] :
        [ radius, radius, radius ];

    translate(v = translate_vec) {
        minkowski() {
            cube(size = adjusted_size, center = false);
            sphere(r = radius);
        }
    }
}

module pipette_holder_4tip_luerlock_lid_18mm_slotdie(){
difference(){
pre_pipette_holder_4tip_luerlock_lid();
/*
*/
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
union(){
translate([0+0.5,4.5,-3])rounded_box_minkowski(size = [10+4+5, 20+2+6.5+6+10+5+5+19+20, 13], radius = 2, center = true);
translate([0+0.5-7,4.5,-3])rounded_box_minkowski(size = [10+4+5, 20+2+6.5+6+10+5+5+19+20, 13], radius = 2, center = true);
translate([-12,4.5-1.5+1.5,3-8-4.55])rotate([0,90,0]) cylinder(d=3, h=19);
//translate([-12,4.5-1.5,3-8-6])color("pink")cube([19,3,3]);
}

translate([-2,4.5+38,-30])cylinder(d=3.5,h=100,$fn=100);
translate([-2,4.5-38,-30])cylinder(d=3.5,h=100,$fn=100);


translate([0,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+10+5+19+20, 10], radius = 2, center = true);
translate([0-6.7,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+10+5+19+20, 10], radius = 2, center = true);
translate([0+1,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+10+5+19+20, 10], radius = 2, center = true);
for(i=[-2:2]){
for(j=[-2:2]){
translate([i*0.2,j*0.2,-0.25]){
translate([0-6.7,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+10+5+19+20, 10], radius = 2, center = true);
translate([0,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+10+5+19+20, 10], radius = 2, center = true);
translate([0+1,4.5,0])rounded_box_minkowski(size = [10+4, 20+2+6.5+6+10+5+19+20, 10], radius = 2, center = true);
}
}
}
translate([14,0-2,17.8-18])rotate([0,90,0]){
l = 6+12;
for(i=[0:3]){
translate([0,-5.8+18*i-4.9-10,-21.4-12])cylinder(d=2.5,h=l,$fn=100);
}
}
translate([0,-2,17.8]){
l = 7.2;
for(i=[0:3]){
#translate([0-4,-5.8+18*i-4.9-10,-21.4-3.5-20])cylinder(d1=8.8,d2=7.5,h=63,$fn=30);
}
}
}
}
}
}

module luerlock_connector_slotdie(
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



