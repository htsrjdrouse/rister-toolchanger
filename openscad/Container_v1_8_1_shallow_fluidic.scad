// 'Container with Knurled Lid' by wstein 
// is licensed under the Attribution - Non-Commercial - Share Alike license. 
// (c) April 2015 - April 2018
// please refer the complete license here: http://creativecommons.org/licenses/by-nc-sa/3.0/legalcode

// Modified by Richard for shallow bubble trap containers with fluidic connections
// Version 1.8.1-shallow-fluidic
// - Removed minimum height constraint to allow very shallow containers
// - Added adjustable thread height for smooth wall sections for tube/pipette connections

// Version 1.8.1
// Fixed outside quality of the container and lid.

/* [Dimensions] */

// inner diameter (for outer dimension add 2x wall thickness) - minimum = 8.0mm
diameter=15;

// inner height (for outer dimension add 2x wall thickness) - for shallow bubble traps, set this to thread_height + desired clearance
height=3.0;

// Select how many compartments there should be in the container - default is 1.
compartments = 1; //[1:8]

/* [Thread Settings] */

// Thread height as a multiple of diameter. Default is diameter/6. Set lower (e.g., diameter/10 or diameter/12) for shorter threads and more smooth wall area
thread_height_divisor = 10; // [6:Standard, 8:Medium-Short, 10:Short, 12:Very Short, 15:Minimal]

// Lid height multiplier: Controls how tall the lid is relative to thread height. 1.0 = just covers threads, 1.5 = 50% taller, 2.0 = double height
lid_height_multiplier = 1.0; // [0.8:Minimal, 1.0:Thread Height Only, 1.2:Slightly Taller, 1.5:Standard, 2.0:Tall]

// Lid opening diameter offset from container diameter (e.g., 5 means opening is diameter-5). Set to 0 for solid lid top.
lid_opening_offset = 5; // [0:Solid Top, 3:Small Opening, 5:Medium Opening, 8:Large Opening, 10:Very Large Opening]

// Minimum lid wall height below threads (mm). This cuts away excess material below the threaded area. Set to thread_height to keep full cylinder.
lid_minimum_wall_height = 1.99; // [0:No Wall Below Threads, 0.5:Minimal, 1.0:Small, 1.5:Medium, 2.0:Standard]

/* [Appearance] */

// Container outside chamfer in percent of diameter. Use 0 for a flat outside bottom - default is 5% 
outside_chamfer=1.0; 

// Container inside chamfer in percent of diameter. Use 0 for a flat inner bottom - default is 2.5% 
inside_chamfer=2.5; 

/* [Thickness] */

// default value -1 means 2mm up to size 60, 2.5mm from 61 - 100. 3mm for larger.
wall_thickness=2.5;    //-1;

// default value -1 means take 1/2 of the container Wall Thickness
divider_wall_thickness=-1;

//thickness off container bottom. If you use the solid container model use the same value as setup in the slicer. default: -1 (use wall thickness)
container_bottom_thick=-1;

//thickness off lid top. Lid is always normal printing, so nothing special here, except reset the slicer to normal settings. default: -1 (use wall thickness)
lid_top_thick=-1;

/* [Expert] */

// to show? Only create once! You will get always all parts!
part = "container_"; // [container_:Container,lid_left_knurled_:Lid - Left Knurled, lid_right_knurled_:Lid - Right Knurled, lid_vertical_knurled_: Lid - Vertical Knurled, lid_double_knurled_:Lid - Double Knurled, lid_simple_non_knurled_:Lid - Simple Non Knurled]
//part = "lid_simple_non_knurled_"; // [container_:Container,lid_left_knurled_:Lid - Left Knurled, lid_right_knurled_:Lid - Right Knurled, lid_vertical_knurled_: Lid - Vertical Knurled, lid_double_knurled_:Lid - Double Knurled, lid_simple_non_knurled_:Lid - Simple Non Knurled]

// default value -1 means take 1/4 of Wall Thickness
backlash=-1;

//build a solid container, this is the key for high quality prints and also spare filament. You must print it with special settings (no infill, no top layer, bottom layer 1mm, shell thickness 1mm - must be about half of wall thickness). Works fine with Slic3r but I failed to setup Cura correct. Don't forget to reactivate top layer and infill before printing lid!
solid_container=0; //[1:true, 0:false]

quality=150; // [80:good, 100:high, 120:very high,150:best]

/* [Hidden] */

// ensure some minimal values
function diameter()=max(8,diameter);

function wall_thickness()=( 
	wall_thickness!=-1 ? max(1.0,wall_thickness) : (
	diameter() <= 20 ? 1.5 : (
	diameter() <= 60 ? 2.0 : (
	diameter() <= 100 ? 2.5 : 
   3.0))));
   
function get_divider_wall_thickness()=(divider_wall_thickness==-1?wall_thickness()/2:divider_wall_thickness);

bottom_thick=(container_bottom_thick<0?wall_thickness()/-container_bottom_thick:container_bottom_thick);
top_thick=(lid_top_thick<0?wall_thickness()/-lid_top_thick:lid_top_thick);

   
function backlash()=backlash==-1?wall_thickness()/4:max(0.2,backlash);

// MODIFIED: Made thread height adjustable via thread_height_divisor parameter
// Original: thread_height=(diameter()>20?diameter()/6:20/6);
thread_height=(diameter()>20?diameter()/thread_height_divisor:20/thread_height_divisor);

// MODIFIED: Removed minimum height constraint to allow shallow containers
// Original: function height()=max(2*(thread_height+bottom_thick),height);
// New: just use the specified height with a very minimal safety check
function height()=max(thread_height+0.5,height);  // Allow shallow containers, minimum is just thread_height + 0.5mm

$fn=quality;

lid_r=diameter()/2+wall_thickness()/2+backlash();
lid_r0=(diameter()>=20?lid_r:20/2+wall_thickness()/2+backlash()); // virtual radius, for diameter() < 20

intersection()
{
	assign(offset=(part=="both"?diameter()*.6+2*wall_thickness():0))
	union()
	{
		if(part=="container_")
		translate([0,-offset,0])
		difference(){
		union(){
		container(diameter(),height());
		translate([0,0,-2])rotate([0,0,30])cylinder(d=23.3,h=2.2+2,$fn=6);
		}
		translate([-20,0,1.2-1])rotate([0,90,0])cylinder(d=1.5,h=50,$fn=300);
		hull(){
		translate([-4,-2,1.2+0.8])rotate([0,90,0])cylinder(d=1.5,h=8,$fn=300);
		translate([-4,2,1.2+0.8])rotate([0,90,0])cylinder(d=1.5,h=8,$fn=300);
		translate([-4,0,1.2+0.8])rotate([0,90,0])cylinder(d=1.5,h=8,$fn=300);
		translate([-4,0,1.2+0.8-1])rotate([0,90,0])cylinder(d=1.5,h=8,$fn=300);
		}
		}
		else
		translate([0,offset,(part=="cross"?height()-thread_height-wall_thickness()+bottom_thick+.1:thread_height*lid_height_multiplier+top_thick+wall_thickness())])
		rotate([0,(part=="cross"?0:180),0])
		lid(lid_r,lid_r0,thread_height+wall_thickness());
	}
	if(part=="cross")
	cube(200);
}

module lid(r,r0,h)
union()
{
	// Calculate adjusted lid height based on multiplier
	// Base height is thread_height + wall_thickness, then scaled by multiplier
	adjusted_h = wall_thickness() + thread_height * lid_height_multiplier;
	
	intersection()
	{
		translate([0,0,wall_thickness()])
		thread(r,thread_height,outer=true);

		cylinder(r=r+wall_thickness()/2,h=adjusted_h);
	}

	difference()
	{
		assign(a=1.05,b=1.1)
		assign(ra=a*r+b*wall_thickness(),ra0=a*r0+b*wall_thickness(),h1=adjusted_h+top_thick)
 
        if(part=="lid_right_knurled_")
        knurled(ra,ra0,h1,[1]);
        else if(part=="lid_left_knurled_")
        knurled(ra,ra0,h1,[-1]);
        else if(part=="lid_vertical_knurled_")
        knurled(ra,ra0,h1,[0]);
        else if(part=="lid_double_knurled_")
        knurled(ra,ra0,h1,[-1,1]);
        else
        cylinder(r=ra,h=h1,$fn=6);

		translate([0,0,-.1])
		cylinder(r=r+wall_thickness()/2,h=adjusted_h+.1);
		
		// Cut opening in top of lid for filter access
		if(lid_opening_offset > 0)
		{
			translate([0,0,adjusted_h+top_thick-wall_thickness()/2-3])
			cylinder(r=(diameter()-lid_opening_offset)/2, h=wall_thickness()+10);
		}
		
		// Cut away excess material below threads, keeping only lid_minimum_wall_height
		if(lid_minimum_wall_height < thread_height)
		{
			translate([0,0,-1])
			cylinder(r=r*2, h=wall_thickness()+thread_height-lid_minimum_wall_height+1);
		}
	}
}


knurled_h=[
0,
0.1757073594,
0.5271220782,
0.7116148055,
0.9007198511,
1];
knurled_rdelta=[.2,0,0.1,.3,.6,1.0];
shape_n=5;

module knurled(r,r0,height,degs)
assign(n=round(sqrt(120*(r+2*wall_thickness())*2)/shape_n)*shape_n)
assign(h_steps=len(knurled_h)-1)
assign(r_delta=-1.6*wall_thickness()/2)
//translate([0,0,height])
//rotate([180,0,0])
intersection_for(a=degs)
for(i=[0:h_steps-1])
assign(hr0=knurled_h[i],hr1=knurled_h[i+1])
assign(hr=hr1-hr0)
assign(rr0=knurled_rdelta[i],rr1=knurled_rdelta[i+1])
assign(rr=rr1-rr0)
translate([0,0,hr0*height])
rotate([0,0,35*height/r*hr0*a])
linear_extrude(convexity=10,height=hr*height,twist=-35*height/r*hr*a,scale=(r+r_delta*rr1)/(r+r_delta*rr0))
for(j=[0:n/4-1])
rotate([0,0,360/n*j])
circle(r=r+r_delta*rr0,$fn=5);


module container(r,h)
union()
{
	difference()
	{
		union()
		{
			container_hull(diameter()/2+wall_thickness(),height()+bottom_thick,outside_chamfer,[wall_thickness()/2,thread_height+wall_thickness()/2]);

			translate([0,0,height()-thread_height-wall_thickness()/2+bottom_thick+1.2])
			thread(diameter()/2+wall_thickness(),thread_height,outer=false);
		}

		if(!solid_container)
			translate([0,0,bottom_thick])

		container_hull(diameter()/2,height()+bottom_thick,inside_chamfer);
	}

	if(compartments > 1)
	{
        echo(get_divider_wall_thickness());
		for(a = [0 : 1 : compartments])
		{
			rotate((360 / compartments) * a) 
            translate([-(get_divider_wall_thickness() / 2), 0, bottom_thick])
            cube([get_divider_wall_thickness(), diameter() / 2, height()]);
		}
	}
}

module container_hull(r,h,chamfer,thread_notch=[0,0])
{
	xn=thread_notch[0];
	yn=thread_notch[1];

	rotate_extrude(convexity=10)
	assign(x1=r*(50-chamfer)/50,x2=r,x3=r-xn,y1=r*chamfer/50,y2=h,y3=h-yn,y4=h-yn+xn)
	polygon([[0,0],[x1,0],[x2,y1],[x2,y3],[x3,y4],[x3,y2],[0,y2]]);
}

module thread(r,h,outer=false)
assign($fn=100)
{
	linear_extrude(height=h,twist=-250,convexity=10)
	for(a=[0:360/2:359])
	rotate([0,0,a])
	if(outer)
	{
		difference()
		{
			translate([0,-r])
			square(2*r);

			assign(offset=.8)
			translate([r*(1-1/offset),0])
			circle(r=1/offset*r);	
		}
	}
	else
	{
		assign(offset=.8)
		translate([(1-offset)*r,0,0])
		circle(r=r*offset);
	}
}
