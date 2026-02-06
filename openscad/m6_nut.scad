include <Nut_Job.scad>
/* [Component Type] */
type = "nut";                 // [nut,bolt,rod,washer]

/* [Nut Options] */
nut_type                  = "normal";     // [normal,wingnut]
nut_diameter              = 10;           // across flats
nut_height                = 5;            // thickness
nut_thread_outer_diameter = 6.6;          // increased slightly for more visible clearance/thread depth
nut_thread_step           = 1;            // M6 coarse pitch
nut_step_shape_degrees    = 45;           // or try 30 for sharper

/* [Extended Options] */
facets     = 6;
resolution = 0.2;             // lowered for finer threads (try 0.1 if still not visible)
