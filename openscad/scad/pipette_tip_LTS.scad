// =============================================================================
// LTS PIPETTE TIP MODELS WITH INNER DIAMETER
// Wall thickness: 0.15mm per side (0.3mm total)
// =============================================================================

// -----------------------------------------------------------------------------
// P20 LTS PIPETTE TIP
// -----------------------------------------------------------------------------
module p20_lts_complete(){
    difference(){
        // OUTER PROFILE
        union(){
            translate([0,0,9])color("lightgreen")cylinder(d2=6,d1=5.8,h=6.2,$fn=30);
            color("pink")cylinder(d2=5.8,d1=5.5,h=9,$fn=30);
            color("lime")translate([0,0,-5.5])cylinder(d2=4.5,d1=2,h=5.5,$fn=30);
            color("lightblue")translate([0,0,-5.5-8])cylinder(d2=2,d1=1.8,h=8,$fn=30);
            color("peru")translate([0,0,-5.5-8-13])cylinder(d2=1.6,d1=1.1,h=13,$fn=30);
            color("white")translate([0,0,-5.5-8-13-8])cylinder(d2=1,d1=0.6,h=8,$fn=30);
        }
        
        // INNER PROFILE (wall thickness = 0.3mm total)
        union(){
            translate([0,0,9])cylinder(d2=5.7,d1=5.5,h=6.3,$fn=30);
            cylinder(d2=5.5,d1=5.2,h=9.1,$fn=30);
            translate([0,0,-5.5])cylinder(d2=4.2,d1=1.7,h=5.6,$fn=30);
            translate([0,0,-5.5-8])cylinder(d2=1.7,d1=1.5,h=8.1,$fn=30);
            translate([0,0,-5.5-8-13])cylinder(d2=1.3,d1=0.8,h=13.1,$fn=30);
            translate([0,0,-5.5-8-13-8])cylinder(d2=0.7,d1=0.3,h=8.1,$fn=30);
        }
    }
}

// -----------------------------------------------------------------------------
// P200 LTS PIPETTE TIP
// -----------------------------------------------------------------------------
module p200_lts_complete(){
    difference(){
        // OUTER PROFILE
        union(){
            translate([0,0,13.0])color("lightgreen")cylinder(d2=7.5,d1=7.1,h=8,$fn=30);
            color("pink")cylinder(d2=7.1,d1=6.1,h=13,$fn=30);
            color("lime")translate([0,0,-9])cylinder(d2=5,d1=4.8,h=9,$fn=30);
            color("lightblue")translate([0,0,-9-6.0])cylinder(d2=4.5,d1=4,h=6,$fn=30);
            color("peru")translate([0,0,-9-6.0-10])cylinder(d2=3.85,d1=2.85,h=10,$fn=30);
            color("white")translate([0,0,-9-6.0-10-10])cylinder(d2=2.6,d1=1,h=10,$fn=30);
        }
        
        // INNER PROFILE (wall thickness = 0.3mm total)
        union(){
            translate([0,0,13.0])cylinder(d2=7.2,d1=6.8,h=8.1,$fn=30);
            cylinder(d2=6.8,d1=5.8,h=13.1,$fn=30);
            translate([0,0,-9])cylinder(d2=4.7,d1=4.5,h=9.1,$fn=30);
            translate([0,0,-9-6.0])cylinder(d2=4.2,d1=3.7,h=6.1,$fn=30);
            translate([0,0,-9-6.0-10])cylinder(d2=3.55,d1=2.55,h=10.1,$fn=30);
            translate([0,0,-9-6.0-10-10])cylinder(d2=2.3,d1=0.7,h=10.1,$fn=30);
        }
    }
}

// -----------------------------------------------------------------------------
// HELPER MODULES FOR CUTTING AT DIFFERENT HEIGHTS
// -----------------------------------------------------------------------------
module p20_cut_at_height(cut_z){
    difference(){
        p20_lts_complete();
        translate([0,0,cut_z])cylinder(d=10,h=50,$fn=30);
    }
}

module p200_cut_at_height(cut_z){
    difference(){
        p200_lts_complete();
        translate([0,0,cut_z])cylinder(d=12,h=60,$fn=30);
    }
}

// =============================================================================
// VISUALIZATION
// =============================================================================

// Full tips side by side with cut height tables
p20_lts_complete();
translate([15,0,0])p200_lts_complete();

// P20 VOLUME TABLE - displayed as 3D text (facing Y direction, scrolling DOWN in Z)
translate([-25, 0, 0]) {
    rotate([90, 0, 0]) {
        // Header (at top)
        translate([0, 15, 0])
            text("P20 LTS", size=1.8, halign="left", font="Liberation Sans:style=Bold");
        
        // Column headers
        translate([0, 12, 0])
            text("Cut   ID   Line", size=1.2, halign="left", font="Liberation Mono");
        translate([0, 10.5, 0])
            text("(mm) (mm)  (mm)", size=1.0, halign="left", font="Liberation Mono");
        
        // Data rows - scrolling DOWN in Z (showing line width range)
        translate([0, 8, 0])
            text("-34.5 0.30 0.36-0.45", size=1.1, halign="left", font="Liberation Mono");
        translate([0, 5.5, 0])
            text("-30.0 0.45 0.54-0.68", size=1.1, halign="left", font="Liberation Mono");
        translate([0, 3, 0])
            text("-26.5 0.70 0.84-1.05", size=1.1, halign="left", font="Liberation Mono");
            /*
        translate([0, 0.5, 0])
            text("-20.0 1.00 1.20-1.50", size=1.1, halign="left", font="Liberation Mono");
        translate([0, -2, 0])
            text("-13.5 1.30 1.56-1.95", size=1.1, halign="left", font="Liberation Mono");
        translate([0, -4.5, 0])
            text("-10.0 1.50 1.80-2.25", size=1.1, halign="left", font="Liberation Mono");
        translate([0, -7, 0])
            text(" -5.5 1.70 2.04-2.55", size=1.1, halign="left", font="Liberation Mono");
        translate([0, -9.5, 0])
            text("  0.0 4.20 5.04-6.30", size=1.1, halign="left", font="Liberation Mono");
            */
    }
}

// P200 VOLUME TABLE - displayed as 3D text (facing Y direction, scrolling DOWN in Z)
translate([30, 0, 0]) {
    rotate([90, 0, 0]) {
        // Header (at top)
        translate([0, 15, 0])
            text("P200 LTS", size=1.8, halign="left", font="Liberation Sans:style=Bold");
        
        // Column headers
        translate([0, 12, 0])
            text("Cut   ID   Line", size=1.2, halign="left", font="Liberation Mono");
        translate([0, 10.5, 0])
            text("(mm) (mm)  (mm)", size=1.0, halign="left", font="Liberation Mono");
        
        // Data rows - scrolling DOWN in Z (showing line width range)
        translate([0, 8, 0])
            text("-35.0 0.70 0.84-1.05", size=1.1, halign="left", font="Liberation Mono");
        translate([0, 5.5, 0])
            text("-30.0 1.20 1.44-1.80", size=1.1, halign="left", font="Liberation Mono");
        translate([0, 3, 0])
            text("-25.0 2.55 3.06-3.83", size=1.1, halign="left", font="Liberation Mono");
         /*
        translate([0, 0.5, 0])
            text("-20.0 3.00 3.60-4.50", size=1.1, halign="left", font="Liberation Mono");

        translate([0, -2, 0])
            text("-15.0 3.70 4.44-5.55", size=1.1, halign="left", font="Liberation Mono");
        translate([0, -4.5, 0])
            text("-10.0 4.00 4.80-6.00", size=1.1, halign="left", font="Liberation Mono");
        translate([0, -7, 0])
            text(" -9.0 4.50 5.40-6.75", size=1.1, halign="left", font="Liberation Mono");
        translate([0, -9.5, 0])
            text("  0.0 5.80 6.96-8.70", size=1.1, halign="left", font="Liberation Mono");
            */
    }
}

// Cut height indicators on the tips themselves
// P20 cut markers
color("blue", 0.3) {
    translate([0, 0, -34.5]) cylinder(d=8, h=0.2, $fn=30); // Full length
    translate([0, 0, -26.5]) cylinder(d=8, h=0.2, $fn=30); // Popular cut
    translate([0, 0, -13.5]) cylinder(d=8, h=0.2, $fn=30); // Medium cut
}

// P200 cut markers
color("green", 0.3) {
    translate([15, 0, -35]) cylinder(d=10, h=0.2, $fn=30); // Full length
    translate([15, 0, -25]) cylinder(d=10, h=0.2, $fn=30); // Popular cut
    translate([15, 0, -15]) cylinder(d=10, h=0.2, $fn=30); // Medium cut
}

// Uncomment to see cut examples:
/*
// P20 cut examples
translate([0,15,0])p20_cut_at_height(-34.5);  // 0.3mm ID
translate([10,15,0])p20_cut_at_height(-26.5); // 0.7mm ID
translate([20,15,0])p20_cut_at_height(-13.5); // 1.3mm ID
translate([30,15,0])p20_cut_at_height(-5.5);  // 1.7mm ID

// P200 cut examples
translate([0,30,0])p200_cut_at_height(-35);   // 0.7mm ID
translate([15,30,0])p200_cut_at_height(-25);  // 2.55mm ID
translate([30,30,0])p200_cut_at_height(-15);  // 3.7mm ID
translate([45,30,0])p200_cut_at_height(-9);   // 4.5mm ID
*/

// =============================================================================
// INNER DIAMETER & VOLUME REFERENCE TABLES
// =============================================================================

/*
═══════════════════════════════════════════════════════════════════════════════
P20 LTS PIPETTE TIP - INNER DIAMETER, VOLUME & DISPENSING SPECIFICATIONS
═══════════════════════════════════════════════════════════════════════════════

Standard Volume Range: 2-20µL (manufacturer specification)

┌──────────────┬────────────────┬────────────────┬──────────────┬─────────────┐
│ Cut Height   │ Length Cut Off │ Inner Diameter │ Line Width*  │ Est. Volume │
│ (z position) │ from Full Tip  │ at Orifice     │ @ 60°C       │ Range**     │
├──────────────┼────────────────┼────────────────┼──────────────┼─────────────┤
│  -34.5mm     │   0mm (FULL)   │   0.30mm       │  0.36-0.45mm │   2-20µL    │
│  -30.0mm     │   4.5mm        │   0.45mm       │  0.54-0.68mm │   3-25µL    │
│  -26.5mm     │   8.0mm        │   0.70mm       │  0.84-1.05mm │   5-35µL    │
│  -20.0mm     │  14.5mm        │   1.00mm       │  1.20-1.50mm │   8-50µL    │
│  -13.5mm     │  21.0mm        │   1.30mm       │  1.56-1.95mm │  12-70µL    │
│  -10.0mm     │  24.5mm        │   1.50mm       │  1.80-2.25mm │  15-90µL    │
│   -5.5mm     │  29.0mm        │   1.70mm       │  2.04-2.55mm │  20-110µL   │
│    0.0mm     │  34.5mm        │   4.20mm       │  5.04-6.30mm │  50-300µL   │
└──────────────┴────────────────┴────────────────┴──────────────┴─────────────┘

═══════════════════════════════════════════════════════════════════════════════
P200 LTS PIPETTE TIP - INNER DIAMETER, VOLUME & DISPENSING SPECIFICATIONS
═══════════════════════════════════════════════════════════════════════════════

Standard Volume Range: 20-200µL (manufacturer specification)

┌──────────────┬────────────────┬────────────────┬──────────────┬─────────────┐
│ Cut Height   │ Length Cut Off │ Inner Diameter │ Line Width*  │ Est. Volume │
│ (z position) │ from Full Tip  │ at Orifice     │ @ 60°C       │ Range**     │
├──────────────┼────────────────┼────────────────┼──────────────┼─────────────┤
│  -35.0mm     │   0mm (FULL)   │   0.70mm       │  0.84-1.05mm │  20-200µL   │
│  -30.0mm     │   5.0mm        │   1.20mm       │  1.44-1.80mm │  30-250µL   │
│  -25.0mm     │  10.0mm        │   2.55mm       │  3.06-3.83mm │  60-400µL   │
│  -20.0mm     │  15.0mm        │   3.00mm       │  3.60-4.50mm │  80-500µL   │
│  -15.0mm     │  20.0mm        │   3.70mm       │  4.44-5.55mm │ 120-650µL   │
│  -10.0mm     │  25.0mm        │   4.00mm       │  4.80-6.00mm │ 150-750µL   │
│   -9.0mm     │  26.0mm        │   4.50mm       │  5.40-6.75mm │ 180-850µL   │
│    0.0mm     │  35.0mm        │   5.80mm       │  6.96-8.70mm │ 300-1200µL  │
└──────────────┴────────────────┴────────────────┴──────────────┴─────────────┘

═══════════════════════════════════════════════════════════════════════════════
DISPENSING STRATEGY GUIDE FOR PEROVSKITE NANOSOLAR ARRAYS
═══════════════════════════════════════════════════════════════════════════════

┌──────────────────┬────────────────────┬─────────────────────┬──────────────┐
│ Target Feature   │ Recommended        │ Recommended         │ Application  │
│ Size (Line/Spot) │ P20 Cut Height     │ P200 Cut Height     │ Notes        │
├──────────────────┼────────────────────┼─────────────────────┼──────────────┤
│ 0.3-0.5mm        │ -34.5 to -30mm     │ N/A                 │ Fine lines,  │
│ (Ultra-fine)     │ (Full to 4.5mm)    │                     │ precise      │
│                  │                    │                     │ features     │
├──────────────────┼────────────────────┼─────────────────────┼──────────────┤
│ 0.7-1.0mm        │ -26.5 to -20mm     │ -35 to -30mm        │ Standard     │
│ (Fine)           │ (8-14.5mm cut)     │ (Full to 5mm)       │ array cells  │
├──────────────────┼────────────────────┼─────────────────────┼──────────────┤
│ 1.3-1.7mm        │ -13.5 to -5.5mm    │ N/A                 │ Medium cells │
│ (Medium)         │ (21-29mm cut)      │                     │              │
├──────────────────┼────────────────────┼─────────────────────┼──────────────┤
│ 2.5-3.0mm        │ N/A                │ -25 to -20mm        │ Large cells  │
│ (Large)          │                    │ (10-15mm cut)       │              │
├──────────────────┼────────────────────┼─────────────────────┼──────────────┤
│ 3.7-4.5mm        │ N/A                │ -15 to -9mm         │ Wide         │
│ (Extra-large)    │                    │ (20-26mm cut)       │ features     │
├──────────────────┼────────────────────┼─────────────────────┼──────────────┤
│ 5.0-8.7mm        │ N/A                │ 0mm                 │ Fill areas   │
│ (Fill)           │                    │ (35mm cut)          │              │
└──────────────────┴────────────────────┴─────────────────────┴──────────────┘

CALCULATION NOTES:
==================
*  Line Width @ 60°C: Calculated as 1.2-1.5x inner diameter
   - Lower value (1.2x): Fast dispensing, low viscosity ink
   - Upper value (1.5x): Slow dispensing, higher viscosity ink
   
** Volume Range Estimates: Based on typical dispensing parameters
   - Assumes flow rate of 0.5-5.0 µL/second
   - Minimum volume: ~2x the orifice cross-sectional area × 1mm
   - Maximum volume: Limited by tip capacity and pumping system
   - Actual volume depends on: ink viscosity, dispensing speed, 
     z-height, substrate wetting properties

USAGE NOTES:
============
- Inner diameter assumes 0.15mm wall thickness per side
- All measurements referenced to OpenSCAD model coordinate system
- Cut tips perpendicular to axis for best flow characteristics
- Deburr cut edges with fine sandpaper or blade before use
- For perovskite inks at 60°C, viscosity typically 5-20 cP
- Heated pipette operation reduces ink viscosity by ~40-60%
- Test dispense on waste substrate before production runs
- Consider substrate surface energy treatment for feature confinement

ARRAY DESIGN RECOMMENDATIONS:
==============================
- Minimum feature spacing: 2x the line width
- P20 optimal for: 0.5-2.0mm features, 1-3mm pitch
- P200 optimal for: 1.5-6.0mm features, 3-8mm pitch
- For mixed feature sizes: use multiple tips cut to different heights
- 4-channel configuration allows parallel multi-material deposition

PEROVSKITE INK COMPATIBILITY:
==============================
- Methylammonium lead iodide (MAPbI₃): Compatible
- Formamidinium lead iodide (FAPbI₃): Compatible  
- Mixed cation perovskites: Compatible
- Typical solvent: DMF, DMSO, GBL, or mixtures
- Recommended concentration: 30-45 wt%
- Operating temperature: 40-80°C (60°C optimal)
- Shelf life after heating: Use within 2-4 hours
*/
