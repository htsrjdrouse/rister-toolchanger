$fn=50;
//slotdie(60,40,12,3,10,0.2,12.5,20);


//Slot Die Parameters
module slotdie (l,w,h,innerrad,tankwidth,slit,block2,internalshift)

// "l" corresponds to the length of the die (x-direction)
// "w" corresponds to the width of the die (y-direction)
// "h" corresponds to the height of the die (z-direction)   
// "innerrad" corresponds to the radius of the internal geometries
// "tankwidth" corresponds to the length of the feed slot
// "slit" correspndes to the thickness of the feed slot
// "block2" corresponds to the positioning of screw holes (y-direction)
// "internal shift corresponds to the shitf of the internal geometries

// NOTE: If internal geometries begin to protrude through the die's body, alter the "internalshift" and "l" values
// This code is optimized for "tankwidths" between 5 & 30mm
{
//difference(){
flat=1.3;
screw=1.55;
M1length=3;
syringel=1;
syringe1=2.60;
syringe2=2.30;
syringediameter=3.5;
tolerence=4;
 
// "flat" corresponds to the area of the die's flat tip 
// "screw" corresponds to the radius of the screw holes
// "M1length" corresponds to the length screw hole
// "syringel" corresponds to the length of the tapered cylender
// "syringe1" corresponds to the largest end of the tapered internal geometry 
// "syringe2" corresponds to the smallest end of the tapered internal geometry 
// "syringediameter" corresponds to the diameter the input cylender
// "tolerence" corresponds to the amount of plastic in the neck
  

difference(){
   
//Body & Tip Angle
    cube([l,w,h],true);
    
            translate([l/2,-w/2,]) rotate([0,140,0]) cube([l/4,w,h/2],false);
        mirror([0,0,2]) translate([l/2,-w/2,]) rotate([0,140,0]) cube([l/4,w,h/2],false);
            translate([l/2-flat,-w/2,-h/2]) cube([l/4,w,h],false);
    
//Neck curvature
        union(){
            translate([0,l/3+syringediameter+tolerence,-h/2-.005])  
            difference(){ 
                cylinder(h+.01,l/3,l/3,false);
                translate([-l,-w/2,]) cube([l,w,h],false);          
                        }  
                         
        mirror([0,1,0])  translate([0,0,0]) 
        union(){
            translate([0,l/3+syringediameter+tolerence,-h/2-.005]) 
            difference(){
                cylinder(h+.01,l/3,l/3,false);
                translate([-l,-w/2,0]) cube([l,w,h],false);
      }
      
      //tip taper
      
     translate([l/2-flat,-tankwidth/2-4,-h/2]) rotate([0,0,225]) cube([l/4,w/3,h],false);
        mirror([0,1,0]) translate([l/2-flat,-tankwidth/2-4,-h/2]) rotate([0,0,225]) cube([l/4,w/3,h],false);
                }
    }
        
//width
        
        translate([l/8,tankwidth/2+8,-h/2-.005]) cube([l/2,w/2,h+.1],false);
    mirror([0,1,0]) 
        translate([l/8,tankwidth/2+8,-h/2-.005]) cube([l/2,w/2,h+.1],false);
    
//Internal Geometries
        translate([internalshift,0,0])  
        union(){
            
                translate([0,-tankwidth/2,0]) sphere(innerrad);
                translate([0,tankwidth/2,0]) sphere(innerrad);
    
        //Tapered    
                hull(){
                    translate([0,0,0]) rotate([90,0,0]) cylinder(tankwidth,innerrad,innerrad,true);
                    translate([l/14,0,0]) #cube([slit,tankwidth,slit],true); 
                       }
    
                //translate([-l/20-internalshift+syringel,0,0]) rotate([0,90,0]) cylinder(l/20+internalshift-syringel,syringe2,syringe2,false);
                translate([-l/20-internalshift+syringel,0,0]) rotate([0,90,0]) cylinder(h=l/20+internalshift-syringel,d=syringe2,false);
		echo(l/20+internalshift-syringel);
		echo(syringe2);
		translate([0,0,0]){
		hull(){
                translate([l/4-12.5-5+4,0,-0.035]) cube([l/2-25,tankwidth,slit*2],true); 
                translate([l/4-2.5-10+1,0,0]) cube([l/2-19.5-2,tankwidth,slit],true); 
		}
                #translate([l/4-4,0,0]) cube([l/2-19.5,tankwidth,slit],true); 
		}
               }

// Neck
            translate([-l/2+M1length,syringediameter+tolerence+.01,-h/2-.005])
                    cube([l/2-M1length+.01,w/2-tolerence-syringediameter+.01,h+.01],false);
            mirror([0,1,0]) 
            translate([-l/2+M1length,syringediameter+tolerence+.01,-h/2-.005]) cube([l/2-M1length+.01,w/2-tolerence-syringediameter+.01,h+.01],false);

//Screw Holes
        translate([-l/2-.005,w/2-block2/2+1,0]) rotate([0,90,0]) cylinder(M1length+.01,screw,screw,false);
    mirror([0,1,0]) 
        translate([-l/2-.005,w/2-block2/2+1,0]) rotate([0,90,0]) cylinder(M1length+.01,screw,screw,false);


//Tapered Cylinder
    translate([-l/28,0,0]) rotate([0,90,0]) cylinder(syringel,syringe1,syringe2,false);

    /*
    hull(){       
        translate([-l/20,0,0]) rotate([0,90,0]) cylinder(4,syringe1,syringe2,false);

    //Syringe Cylinder
        translate([-l/2-.01,0,0]) rotate([0,90,0]) cylinder(l/2-l/20+.01,syringediameter,syringediameter,false);
           }
     */

//Nut Imprint
        translate([-l/2+M1length-2,w/2-block2/2+1,0]) rotate([0,90,0]) cylinder(2+.01,3.05,3.05,false,$fn=6);
    mirror([0,1,0]) 
        translate([-l/2+M1length-2,w/2-block2/2+1,0]) rotate([0,90,0]) cylinder(2+.01,3.4,3.4,false,$fn=6);

}

//Rounded Edges
        difference(){
        translate([-l/2+M1length+2,syringediameter+tolerence+2,]) cube([4,4,h],true);
        translate([-l/2+M1length+4,syringediameter+tolerence+4,-h/2]) cylinder(h,4,4,false);
                }
    mirror([0,1,0])
        difference(){
        translate([-l/2+M1length+2,syringediameter+tolerence+2,]) cube([4,4,h],true);
        translate([-l/2+M1length+4,syringediameter+tolerence+4,-h/2]) cylinder(h,4,4,false);
   
}



//translate([-l/2,-w/2,]) cube([60,40,10],false);
//}

}


