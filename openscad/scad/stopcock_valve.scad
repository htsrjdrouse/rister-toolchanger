

//actualvalve_for_syringe();
//translate([1,232,61.3-0.5])rotate([0,0,90])valveconnectpart();

//color("")translate([52,190,63])rotate([-90,90,0])smallsyringe_valvesupportmodule_plate();
//color("")translate([36,295.5,18])rotate([90,0,0])valvemountplate_screwattach_smallersyringe_vertical_attach();

//color("")translate([36,295.5,18])rotate([0,-90,90])valvemountplate_screwattach_smallersyringe();
//smallsyringe_valvesupportmodule_plate();
//valve_assy();
//translate([1,232,61.3-0.5])rotate([0,0,90])valveconnectpart();
//translate([1,232,61.3-0.5])rotate([0,0,90])valveconnectpart();

module valve_assy(){

translate([7,585,-22])rotate([90,0,0]){
color("green")translate([4,34,363])rotate([0,90,90])servo();
color("white")translate([-6,83.5,353])rotate([0,90,90])actualvalve_for_syringe();
}
translate([1,232,61.3-0.5])rotate([0,0,90])valveconnectpart();
color("slateblue")translate([36,295.5,18])rotate([0,-90,90])valvemountplate_screwattach_smallersyringe_vertical_attach();
color("slateblue")translate([36,295.5,18])rotate([0,-90,90])valvemountplate_screwattach_smallersyringe();
//color("")translate([52,190,63])rotate([-90,90,0])smallsyringe_valvesupportmodule_plate();
}


//here is old BD Connecta valve
module origactualvalve_for_syringe(){
//valve arm part
translate([0,0,8-2.5])cylinder(r=9.5/2,h=10);
translate([-2.5/2,-6.8,8-2.5])cube([2.5,9.5+4.8,3.4]);
translate([6.8,-2.5/2,8-2.5])rotate([0,0,90])cube([2.5,9.5+4.8,3.4]);
translate([-3.8,-4.7/2,8-2.5])rotate([0,0,90])cube([4.7,9.5+4.8,3.4]);
translate([-3.8-8,-5/2,8-2.5])rotate([0,0,90])cube([5,2,3.4]);
translate([-3.8-9.7,-6/2,8-2.5])rotate([0,0,90])cube([6,2,3.4]);
translate([0,0,10])valvesupport();
}

//Tomopal
//Stopcocks (Per Pack 100), 3-Way Nylon Stopcocks with Clear PC Lock Rotating Ring or Tomopal Nylon Stopcock with Clear PC Lock Rotating Ring for Industrial and Laboratory uses. P/N: 100-1140-X100
//https://www.amazon.com/gp/product/B072KXXTBT/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1



module actualvalve_for_syringe(){
translate([0,0,0+7.9-10]){
translate([0,0,8-2.5])cylinder(r=9.5/2,h=8,$fn=30);
translate([-3.8,-3/2,8-2.5])rotate([0,0,90])cube([3,1+14,5]);
translate([-3.8-8,-5/2,8-2.5])rotate([0,0,90])cube([5,7,5]);
}
translate([0,0,10]){ 
translate([0,0,0-4.6+6])cylinder(r=9.4/2,h=14,$fn=30);
translate([-10,0,6.4])rotate([0,90,0])cylinder(r=6/2,h=20,$fn=30);
translate([0,0,6.4])rotate([0,90,90])cylinder(r=6/2,h=10,$fn=30);
}
}



module valvesupport(){
translate([0,0,3.8-8])cylinder(r=9.5/2,h=15,$fn=30);
for(i=[0:3]){
translate([0,0,4.4+i])rotate([0,90,0])cylinder(r=5.4/2,h=10,$fn=30);
}
for(i=[0:1]){
translate([-14.5-1.+3,0,5.4+i])rotate([0,90,0])cylinder(r=12/2,h=10,$fn=30);
translate([-10,0,5.4+i])rotate([0,90,0])cylinder(r=8.2/2,h=10,$fn=30);
translate([-10,0,6.4+i])rotate([0,90,0])cylinder(r=8.2/2,h=10,$fn=30);
}

for(i=[0:3]){
translate([0,0,4.4+i])rotate([0,90,90])cylinder(r=5.4/2,h=10,$fn=30);
}
}

module servo(){
 bcl = 0.4;
 color([bcl,bcl,bcl])
 cube([40.75,19.85,35]);
 difference(){
 color([bcl,bcl,bcl])translate([-(55.5-40.74)/2,0,35-8])cube([55.5,19.85,2.5]);
 translate([-(55.5-40.74)/2+3.8,0+4.5,35-8-10])cylinder(r=3.7/2,h=20);
 translate([-(55.5-40.74)/2+3.8,0+4.5+10,35-8-10])cylinder(r=3.7/2,h=20);
 translate([-(55.5-40.74)/2+3.8+49,0+4.5,35-8-10])cylinder(r=3.7/2,h=20);
 translate([-(55.5-40.74)/2+3.8+49,0+4.5+10,35-8-10])cylinder(r=3.7/2,h=20);
 }
 cl = 0.9;
 translate([0,0,0])color([cl,cl,cl]){
 translate([10,10,30])cylinder(r=8/2,h=12);
 translate([10,10,41])cylinder(r=30/2,h=5);
 }
}

//this one works with the cool feedback sensor servo
module valveconnectpart(){
 difference(){
 translate([0,0,-2-1.4-1.5+1.2-2+2+1])cylinder(r=15,h=10+1.4+1.5-1.2+2-2-1,$fn=30);
 translate([0,0,-17])cylinder(r=8.4/2,h=18);
 translate([0,0,8-4-1])cylinder(r=8.4/2,h=18,$fn=30);
 translate([-3.8,-3.4/2,8-2.5-1.5-1])rotate([0,0,90])cube([3.4,9.5+4.8,5.4]);
 translate([-3.8-8+0.5-1.5,-5.9/2,8-2.5-1.5-1])rotate([0,0,90])cube([5.9,4,5.4]);
 rotate([0,0,-5]){
 translate([0,0,-5])rotate([0,0,40])
 translate([16.3/2,0,-2])cylinder(r=2.3/2,h=118,$fn=30);
 translate([0,0,-5])rotate([0,0,40])
 translate([-16.3/2,0,-2])cylinder(r=2.3/2,h=118,$fn=30);
 }
 rotate([0,0,0]){
 translate([0,0,-5])rotate([0,0,40])translate([0,14/2,-2])cylinder(r=2.3/2,h=118,$fn=30);
 translate([0,0,-5])rotate([0,0,40])translate([0,-14/2,-2])cylinder(r=2.3/2, h=118,$fn=30);
 }
 rotate([0,0,-30]){
 translate([0,0,-5])rotate([0,0,40])translate([0,22/2,-2])cylinder(r=2.3/2,h=118,$fn=30);
 translate([0,0,-5])rotate([0,0,40])translate([0,-22/2,-2])cylinder(r=2.3/2,h=118,$fn=30);
 }
 rotate([0,0,-65]){
 translate([0,0,-5])rotate([0,0,40])translate([0,16/2,-2])cylinder(r=2.3/2,h=118,$fn=30);
 translate([0,0,-5])rotate([0,0,40])translate([0,-16/2,-2])cylinder(r=2.3/2,h=118,$fn=30);
 }
 }
}




module valvemountplate_screwattach_smallersyringe(){
 translate([41,12,0]){
 translate([33+10,28,34])rotate([-90,180,90])mirror([0,0,0])union(){
 difference(){union(){
 translate([-3+19,18+0.1+2.5,12])cube([19.5,16,7+6]);
 translate([-3+19+5,18+0.1+2.5-10-4,12])cube([19.5-5,16+20+4,7+6]);
 }
 translate([4,0,-40])#translate([30-5.5,10+1.5,40])cylinder(r=3.7/2,h=50,$fn=30);
 translate([4,0,-40])translate([30-5.5,10+1.5+30,40])cylinder(r=3.7/2,h=50,$fn=30);
 translate([4,0,-40])#translate([30-5.5,10+1.5,40])cylinder(r=8.7/2,h=25-4,$fn=30);
 translate([4,0,-40])translate([30-5.5,10+1.5+30,40])#cylinder(r=8.7/2,h=25-4,$fn=30);
 }
 }
 translate([30+1,28-12.75+1,60-2-6.88+1])rotate([-90,-90,90])mirror([0,0,0]){
 translate([1.4,0,0+2])difference(){
 translate([3,-4.6,0-2])cube([16-2,17-2.2+4.5+2,11+2]);
 translate([10,7,5-1.5])valvesupport();
 }
 }
 }
 }

 module valvemountplate_screwattach_smallersyringe_vertical_attach(){
 translate([41,12,0]){
 translate([33+10,28,34])rotate([-90,180,90])mirror([0,0,0])difference(){
  union(){
 translate([-3+19+5,18+0.1+2.5-4,12+13])cube([19.5-5,16+4,7+6+38.5-13]);
 translate([-3+19+5-3,18+0.1+2.5-4-10,12+13+27])cube([19.5-5+3,16+4+20,7+6+38.5-13-27]);
 translate([-3+19+5,18+0.1+2.5-4-10,12+13+0])cube([19.5-5,16+4+20,7+6+38.5-13-27-3]);
 }
 translate([30-5.5,10+1.5,40])cylinder(r=2.8/2,h=50,$fn=30);
 translate([30-5.5,10+1.5+30,40])cylinder(r=2.8/2,h=50);
 translate([4,0,-40]){
 translate([30-5.5,10+1.5,40]){cylinder(r=3/2,h=50,$fn=30);}
 translate([30-5.5,10+1.5+30,40]){cylinder(r=3/2,h=50,$fn=30);}
 }
 }
 } 
}


module smallsyringe_valvesupportmodule_plate(){
translate([45,15.5,0])difference(){
union(){
translate([0,0,-70])difference(){union(){
translate([-20-1.6+0.9,-32.5+5+17.5,83])cube([5,20+15,53+7]);
translate([-20-1.6+0.9,-32.5+5+17.5+20,83+5])cube([5,20+15,15]);
translate([-20-1.6+0.9,-32.5+5+17.5,83+5+39+8.5])cube([5,20,22]);
translate([-20-1.6+0.9,-32.5+5+17.5+20,83+5+39+15.5])cube([5,20+15,15]);}

translate([0,0,-70])translate([-20-1.6+0.9-0.1,-32.5+5+17.5-0.1,83+130])cube([5.5,20,53+7]);
translate([-30,0+16,90+10])rotate([90,0,90]){cylinder(r=3.7/2,h=20,$fn=30);}//translate([0,0,13])cylinder(r=6.8/2,h=3,$fn=6);}
translate([-30,0+16,90+40])rotate([90,0,90]){cylinder(r=3.7/2,h=20,$fn=30);}//translate([0,0,13])cylinder(r=6.8/2,h=3,$fn=6);}
translate([-30,0,90+12])rotate([90,0,90])cylinder(r=5.6/2,h=20,$fn=30);
translate([-30,0,90+38])rotate([90,0,90])cylinder(r=5.6/2,h=20,$fn=30);
translate([-30,0+20-5+15,96.9+1.7])rotate([90,0,90]){cylinder(r=3/2,h=20,$fn=30);}//translate([0,0,13])cylinder(r=6.8/2,h=3,$fn=6);}
translate([-30,0+20+5+15,96.9+1.7])rotate([90,0,90]){cylinder(r=3/2,h=20,$fn=30);}//translate([0,0,13])cylinder(r=6.8/2,h=3,$fn=6);}
translate([-30,0+20-5+15,147.7-0.5])rotate([90,0,90]){cylinder(r=3/2,h=20,$fn=30);}//translate([0,0,13])cylinder(r=6.8/2,h=3,$fn=6);}
translate([-30,0+20+5+15,147.7-0.5])rotate([90,0,90]){cylinder(r=3/2,h=20,$fn=30);}//translate([0,0,13])cylinder(r=6.8/2,h=3,$fn=6);}
}
}
translate([18.5+6,0,0])cylinder(r=9.5/2,h=200);
translate([0+18.5+6,0,0])difference(){union(){translate([0,0,33])cylinder(h = 2.5, d1 = 10, d2 = 16.5, center = false);translate([0,0,32+3])cylinder(r=16.5/2,h=25);}cylinder(r=9.5/2,h=200);}
}
}








