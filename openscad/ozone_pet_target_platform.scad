


plate();
//base();
//plate_template();

//prespot_template();

//plate_aligner();


module plate_aligner(){
    difference(){
      union(){ 
      translate([119,410,210])cube([10,35,20]);
      translate([128,410-50,210])cube([10+37,35+50,5]);
      translate([128,410-50,210])cube([10+100,10,5]);
      }
      translate([128+10,410-40,210])cube([10+17,35+30,5]);
      translate([109,417,220])rotate([0,90,0])#cylinder(d=4.8,h=20,$fn=100);
      translate([109,437,220])rotate([0,90,0])#cylinder(d=4.8,h=20,$fn=100);
    }
}


module prespot_template(){
difference(){
cube([100,18,2]);
}
}



module plate_template(){
difference(){
cube([100,100,2]);
#translate([20,20,-1])cube([60,60,20]);
}
}

module plate(){
difference(){
union(){
hull(){
translate([-4,-4-5,-2.5])cube([105+8,100+20+3+8+5,5]);
//translate([-4+25,-4+25,-2.5-25])cube([105+8-50,100+20+3+8-50,5]);
}
}
translate([0,-5-10,0])#cube([105,105+10,10]);
translate([0,100+3,0])cube([105,20,10]);
}
}

module base(){
difference(){
union(){
hull(){
translate([-4,-4,-2.5-5])cube([105+8,100+20+3+8,5]);
translate([-4+25,-4+25,-2.5-25])cube([105+8-50,100+20+3+8-50,5]);
}
}
hull(){
translate([-4+40,-4+40,-2.5-25])cube([105+8-80,100+20+3+8-80,50]);
translate([-4+10,-4+10,-2.5-5])cube([105+8-20,100+20+3+8-20,50]);
}
}
}





