include <scad/luerlock_syringe_dispenser_model_18mm.scad>


luer_lock_microwell();

/*
translate([0,0,-0.5+10]){
translate([400-70+3-10+70,426.5+3+124,330-3+50-124+19])rotate([0,0,-90])color("lime")luerlock_dispenser_assy_remover();
}
*/


module nonsense(){
    translate([0,31,5]) {

        //projection(cut=false)color("darkgrey")rotate([90,0,0])import("stls/LiquidDispenserTool0/pinion.stl");
	//translate([0,1,-5])rotate([90,0,0])import("stls/LiquidDispenserTool0/MG90S_4.stl");
        //color("black")rotate([90,0,0])import("stls/LiquidDispenserTool0/servo_linearactuator.stl");
	
        /*
	difference(){
        color("pink")translate([0,0,5])color("darkgrey")rotate([90,0,0])import("stls/LiquidDispenserTool0/linearactuator_pipette_holder_4pipette_luerlock_18mm.stl");
        color("pink")translate([320,-400,410])#cube([20,100,5]);
        color("pink")translate([290,-318,410])#cube([150,30,45]);
//color("darkgrey")rotate([90,0,0])import("stls/LiquidDispenserTool0/linearactuator_pipette_holder_4pipette_luerlock_18mm.stl");
}
*/


        projection(cut=false)
        // Tip removal and loading
        translate([-47+270,-31,0]) rotate([0,0,0]){
            //import("../stls/PipetteRemoval/piezo_dispenser_assy_remover.stl");
            translate([47,32,-4+17.6])import("stls/PipetteRemoval/luerlock_dispenser_assy_remover.stl");
            import("stls/PipetteRemoval/singlechannel_tipremoval_base.stl");
        }



}
}
