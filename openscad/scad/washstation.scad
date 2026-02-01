include<tslot.inc.scad>


//import("BSPP_G14_5-7mm.stl");

//coolwashassembly();
//translate([0,-3,0])washbowl_watervacinput();
//translate([50-50,-3,1])rotate([0,0,180])drypad();
//washbowl_1tip();


module coolwashassembly(){

//translate([0,-70,35])rotate([0,90,0])tslot20(100);
//translate([0,-70+102.5,35+9])rotate([0,90,0])tslot20(100);
//translate([0,-3,0])washbowl_watervacinput();
//translate([50-50,-3,1])rotate([0,0,180])drypad();
washbowl_1tip();
//translate([0,-43,5])washbowl_9mm_shim();
}

module washbowl_9mm_shim(){
translate([0,100,0])difference(){translate([0,-21+2,5])cube([25,18,5+4]);
translate([6,-10,-5])cylinder(r=4.7/2,h=20);
translate([19,-10,-1])cylinder(r=4.7/2,h=20);
}
}

module washbowl_watervacinput(){
translate([7,2,10])cube([12,6,15]);
translate([0,0,3])difference(){
translate([25,-40,3])cube([12,14,27-3]);

/*
#translate([0,0,5]){
translate([30,-33,2])rotate([0,0,90])cylinder(r=7.2/2,h=3.5,$fn=6);
translate([26.75,-41,2])cube([6.5,7,3]);
}
*/
translate([30,-33,-20])cylinder(r=3.2/2,h=45, $fn=300);
}
translate([0,66,3])difference(){
translate([25,-40,3])cube([12,14,27-3]);
/*
translate([0,0,5]){
translate([30,-33,2])rotate([0,0,90])cylinder(r=7.2/2,h=3.5,$fn=6);
translate([26.75,-32,2])cube([6.5,7,3]);
}
*/
translate([30,-33,-20])cylinder(r=2.9/2,h=45, $fn=300);
}
difference(){
translate([0,-40,10])cube([25,80-78,20]);
difference(){
translate([12,-16,2])sphere(r=22);
translate([17.5,-35,-20])cube([15,40,50]);
translate([-7.5,-35,-20])cube([15,40,50]);
translate([-7.5,-45,-20])cube([45,15,50]);
}
/*
translate([0,40,0])difference(){
translate([0,-40,10])cube([25,80,15]);
*/
translate([30,-33,-20])cylinder(r=2.9/2,h=45,$fn=300);
}


/*
translate([0,40,0])difference(){
translate([0,-40,10])cube([25,80,15]);
*/

difference(){
translate([0,-40,10])cube([25,80,20]);
difference(){
translate([12,-16,2])sphere(r=22);
translate([17.5,-35,-20])cube([15,40,50]);
translate([-7.5,-35,-20])cube([15,40,50]);
translate([-7.5,-45,-20])cube([45,15,50]);
}

translate([0,38,0])difference(){
translate([12,-16,2])sphere(r=22);
translate([17.5,-35,-20])cube([15,40,50]);
translate([-7.5,-35,-20])cube([15,40,50]);
translate([-7.5,-45,-20])cube([45,15,50]);
translate([-7.5,-5,-20])cube([45,15,50]);
}
translate([7,-34,5])cube([11,68,15]);
//r=7.2
translate([4,4,6]){#cylinder(r=2.8/2,h=22,$fn=300);}//translate([0,0,15])rotate([0,0,90])cylinder(r=7.2/2,h=10,$fn=6);}
translate([25-4,4,6]){cylinder(r=2.8/2,h=22, $fn=300);}//translate([0,0,15])rotate([0,0,90])cylinder(r=7.2/2,h=10,$fn=6);}
translate([4,40-4,6]){cylinder(r=2.8/2,h=22, $fn=300);}//translate([0,0,15])rotate([0,0,90])cylinder(r=7.2/2,h=10,$fn=6);}
translate([25-4,40-4,6]){cylinder(r=2.8/2,h=22, $fn=300);}//translate([0,0,15])rotate([0,0,90])cylinder(r=7.2/2,h=10,$fn=6);}
translate([4,-30-4,6]){cylinder(r=2.8/2,h=22, $fn=300);}//translate([0,0,15])rotate([0,0,90])cylinder(r=7.2/2,h=10,$fn=6);}
translate([25-4,-30-4,6]){cylinder(r=2.8/2,h=22, $fn=300);}//translate([0,0,15])rotate([0,0,90])cylinder(r=7.2/2,h=10,$fn=6);}

translate([12.5,-17,0])cylinder(r=4.1/2,h=35, $fn=300);
translate([12.5,21,0])cylinder(r=4.1/2,h=35, $fn=300);
translate([-15.5,20,18])rotate([0,90,0])cylinder(r=4.1/2,h=30, $fn=300);

/*
translate([12.5,-17,0])cylinder(r=10.45/2,h=35, $fn=300);
translate([12.5,21,0])cylinder(r=10.45/2,h=35, $fn=300);
translate([-15.5,20,18])rotate([0,90,0])cylinder(r=10.4/2,h=30);
*/

}
}

module drypad(){
difference(){
union(){
translate([-75.5-5+23,-40-30,0])cube([55-23,81+60,3]);
translate([-75.5-5+45,-40,0])cube([10,81,5]);
}
translate([-30,33,-10]){
cylinder(r=3.7/2,h=30);translate([0,0,10])
cylinder(r=6.7/2,h=3.2);
}
translate([-30,33-66,-10]){
cylinder(r=3.7/2,h=30);
translate([0,0,10])cylinder(r=6.7/2,h=3.2);
}
/*
for(a=[0:1]){
#translate([-44-(a*10),-40+5,-1])cube([5,71,13]);
}
*/
}
}


module washbowl_1tip(){
xd=5.5;
xdd=1.5;
translate([0,-43,0])difference(){
union(){
/*
*/
translate([-20,2,0])rotate([0,0,90])difference(){
translate([0,-21,5])cube([25,20+13,5]);
translate([0,3,0])for(i=[0:15]){
translate([6,-13,5-3]){translate([0,i,-0])cylinder(r=10/2,h=4);translate([0,i,4])cylinder(r=4.7/2,h=10+6);}
translate([19,-13,5-3]){translate([0,i,-0])cylinder(r=10/2,h=4);translate([0,i,4])cylinder(r=4.7/2,h=10+6);}
}
}
cube([25,40,10]);
}
translate([10,32,0])cube([5,20,3]);
translate([8,12,-2])cube([10,26,20]);
translate([4,6,-5])cylinder(r=3.7/2,h=20);
translate([4,6,-0.1])cylinder(r=6.2/2,h=3.5);
translate([25-4,6,-5])cylinder(r=3.7/2,h=20);
translate([25-4,6,-0.1])cylinder(r=6.2/2,h=3.5);
}
translate([0,-3,0])difference(){
cube([25,40,10]);
translate([10,-10,0])cube([5,20,3]);
//translate([12,60,0])sphere(r=10);
for (y = [0:0]) // two iterations, z = -1, z = 1
{
    translate([0.5, y, 0])
    translate([12,27.5-(15.5*y)-8,0])sphere(r=10);
        translate([12.5,27.5-(15.*y)-8,2.5])sphere(r=5);
        translate([12.5,27.5-(15.5*y)-8,2])cylinder(r=3.5/2,h=10);
    cube(size = 1, center = false);
}
translate([4,4,-5])cylinder(r=3.7/2,h=20);
translate([4,4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([25-4,4,-5])cylinder(r=3.7/2,h=20);
translate([25-4,4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([4,40-4,-5])cylinder(r=3.7/2,h=20);
translate([4,40-4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([25-4,40-4,-5])cylinder(r=3.7/2,h=20);
translate([25-4,40-4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([4,-30-4,-5])cylinder(r=3.7/2,h=20);
translate([4,-30-4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([25-4,-30-4,-5])cylinder(r=3.7/2,h=20);
translate([25-4,-30-4,-0.1])cylinder(r=6.2/2,h=3.5);
}
}







module washbowl_1tip_p200_LTS(){
xd=5.5;
xdd=1.5;
translate([0,-43,0])difference(){
union(){
/*
*/
translate([-20,2,0])rotate([0,0,90])difference(){
translate([0,-21,5])cube([25,20+13,5]);
translate([0,3,0])for(i=[0:15]){
translate([6,-13,5-3]){translate([0,i,-0])cylinder(r=10/2,h=4);translate([0,i,4])cylinder(r=4.7/2,h=10+6);}
translate([19,-13,5-3]){translate([0,i,-0])cylinder(r=10/2,h=4);translate([0,i,4])cylinder(r=4.7/2,h=10+6);}
}
}
cube([25,40,10]);
}
translate([10,32,0])cube([5,20,3]);
translate([8,12,-2])cube([10,26,20]);
translate([4,6,-5])cylinder(r=3.7/2,h=20);
translate([4,6,-0.1])cylinder(r=6.2/2,h=3.5);
translate([25-4,6,-5])cylinder(r=3.7/2,h=20);
translate([25-4,6,-0.1])cylinder(r=6.2/2,h=3.5);
}
translate([0,-3,0])difference(){
cube([25,40,10]);
translate([10,-10,0])cube([5,20,3]);
//translate([12,60,0])sphere(r=10);
for (y = [0:0]) // two iterations, z = -1, z = 1
{
    translate([0.5, y, 0])
    scale([0.8,1.6,1])translate([12+3,27.5-(15.5*y)-8-7,0])sphere(r=10);
        //translate([12.5,27.5-(15.*y)-8,2.5])sphere(r=5);
        #translate([12.5,27.5-(15.5*y)-8,2])cylinder(r=3.5/2,h=10, $fn=30);
    cube(size = 1, center = false);
}
translate([4,4,-5])cylinder(r=3.7/2,h=20);
translate([4,4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([25-4,4,-5])cylinder(r=3.7/2,h=20);
translate([25-4,4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([4,40-4,-5])cylinder(r=3.7/2,h=20);
translate([4,40-4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([25-4,40-4,-5])cylinder(r=3.7/2,h=20);
translate([25-4,40-4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([4,-30-4,-5])cylinder(r=3.7/2,h=20);
translate([4,-30-4,-0.1])cylinder(r=6.2/2,h=3.5);
translate([25-4,-30-4,-5])cylinder(r=3.7/2,h=20);
translate([25-4,-30-4,-0.1])cylinder(r=6.2/2,h=3.5);
}
}



