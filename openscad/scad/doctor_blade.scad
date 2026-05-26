// =============================================
// Nanosolar TPU Blade + 18G Luer Lock Holder
// For Treela Luer Lock tips
// Print in TPU (85A-95A) for flexibility
// =============================================

$fn = 60;

// ============= PARAMETERS =============
luer_outer_dia = 7.5;     // Treela Luer lock outer diameter (adjust if needed)
luer_length = 12;         // How much of the tip you want gripped
blade_width = 30;         // Width of the spreading blade
blade_thickness = 0.8;    // Thin flexible edge (TPU)
blade_height = 15;        // How tall the blade is
blade_offset = 1.5;       // Distance behind nozzle tip
gap_adjust = 0.2;         // Extra clearance for blade flex

// ============= MAIN MODULE =============
difference() {
    union() {
        // Main body
        hull() {
            translate([0,0,8]) cylinder(d=18, h=12, center=true);
            translate([-10,0,0]) cube([30, blade_width, 8], center=true);
        }
        
        // Blade holder
        translate([blade_offset, 0, 0])
            cube([blade_thickness+2, blade_width, blade_height], center=true);
    }
    
    // Luer Lock hole (female)
    translate([0,0,5]) cylinder(d=luer_outer_dia, h=20, center=true);
    // Luer lock thread grip (simple friction)
    translate([0,0,10]) cylinder(d=luer_outer_dia-1.5, h=10, center=true);
}

// Flexible blade slot
translate([blade_offset+1, 0, blade_height/2 - 4])
    cube([blade_thickness, blade_width-4, blade_height-4], center=true);

// Mounting holes (adjust to your tool head)
translate([-12, 12, 0]) cylinder(d=3.5, h=20, center=true);  // M3 holes
translate([-12, -12, 0]) cylinder(d=3.5, h=20, center=true);

// Optional alignment tab
translate([10, 0, -4]) cube([8, 6, 3], center=true);

echo("Print in TPU 85A-95A");
echo("Blade gap controlled by Z-height (start at 150-250µm)");
