# Generic dock calibration module for multi-tool 3D printer
#
# This module handles calibration for any tool by its ID:
# - e[number] = Extruder tools (e0, e1, e2, etc.)
# - c[number] = Camera tools (c0, c1, etc.)
# - l[number] = Liquid dispenser tools (l0, l1, etc.)
#
# Based on the original camera_dock_calibrate.py

import logging

class GenericDockCalibrate:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.name = config.get_name()
        self.xy_resolution = config.getfloat('xy_resolution', 0.003125)
        
        # Default offsets
        self.dock_extra_offset_x_unlock = config.getfloat('dock_extra_offset_x_unlock', 0.5)
        self.dock_extra_offset_y_unlock = config.getfloat('dock_extra_offset_y_unlock', 0.2)
        self.dock_extra_offset_x_lock = config.getfloat('dock_extra_offset_x_lock', 0.5)
        self.dock_extra_offset_y_lock = config.getfloat('dock_extra_offset_y_lock', 0.8)
        self.dock_z = config.getfloat('dock_z', 35)
            
        self.gcode = self.printer.lookup_object('gcode')
        gcode_macro = self.printer.load_object(config, 'gcode_macro')
        
        # G-Code macros - use configurable templates
        self.dock_calibrate_move_1_template = gcode_macro.load_template(
            config, 'dock_calibrate_move_1_gcode', '')
        self.dock_calibrate_move_2_template = gcode_macro.load_template(
            config, 'dock_calibrate_move_2_gcode', '')
        self.dock_install_msg_template = gcode_macro.load_template(
            config, 'dock_install_msg_gcode', '')
        
        # Register commands
        self.gcode.register_command('CALC_DOCK_LOCATION', 
                                   self.cmd_CALC_DOCK_LOCATION,
                                   desc=self.cmd_CALC_DOCK_LOCATION_help)
    
    def get_status(self, eventtime):        
        return {}
                
    def get_mcu_position(self):        
        toolhead = self.printer.lookup_object('toolhead')
        steppers = toolhead.kin.get_steppers()
        mcu_pos_x = None
        mcu_pos_y = None
        
        for s in steppers:
            if s.get_name() == "stepper_x":
                mcu_pos_x = s.get_mcu_position()
            
            if s.get_name() == "stepper_y":
                mcu_pos_y = s.get_mcu_position()
            
        return {'x': mcu_pos_x, 'y': mcu_pos_y}

    cmd_CALC_DOCK_LOCATION_help = "Automatically Calculate Tool Dock Location"
    def cmd_CALC_DOCK_LOCATION(self, gcmd):
        # Get tool ID directly as passed
        tool_id = gcmd.get("TOOL_ID", "e0").lower()  # Default to e0 if not specified
        
        # Tool ID should be like e0, e1, c0, l0, etc.
        if not tool_id[0].isalpha() or not tool_id[1:].isdigit():
            self.gcode.respond_info(
                f"Invalid tool ID format: {tool_id}. Expected format like e0, e1, c0, l0, etc.")
            return
            
        toolhead = self.printer.lookup_object('toolhead')

        # Get initial position at the dock
        initial_res = self.get_mcu_position()
        logging.info(f"Dock calibration for {tool_id} - initial position: {initial_res}")
        
        # First movement - unlock position calibration
        self.dock_calibrate_move_1_template.run_gcode_from_command()
        self.gcode.run_script_from_command('G4 P2000')
        move_1_res = self.get_mcu_position()
        logging.info(f"Dock calibration for {tool_id} - move 1 position: {move_1_res}")
        
        # Second movement - lock position calibration
        self.dock_calibrate_move_2_template.run_gcode_from_command()
        self.gcode.run_script_from_command('G4 P2000')
        move_2_res = self.get_mcu_position()
        logging.info(f"Dock calibration for {tool_id} - move 2 position: {move_2_res}")
        
        # Calculate dock positions
        dx2 = move_2_res['x'] - move_1_res['x']
        dy2 = move_2_res['y'] - move_1_res['y']

        unlock_x = -(((dx2 + dy2)/2) * self.xy_resolution) + self.dock_extra_offset_x_unlock
        unlock_y = -(((dx2 - dy2)/2) * self.xy_resolution) + self.dock_extra_offset_y_unlock

        dx1 = move_2_res['x'] - initial_res['x']
        dy1 = move_2_res['y'] - initial_res['y']
        
        lock_x = -(((dx1 + dy1)/2) * self.xy_resolution) + self.dock_extra_offset_x_lock
        lock_y = -(((dx1 - dy1)/2) * self.xy_resolution) + self.dock_extra_offset_y_lock
        
        # Try to save the dock positions using save_variables if available
        try:
            save_variables = self.printer.lookup_object('save_variables')
            
            # Save with tool prefix
            #save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
            #    "SAVE_VARIABLE", "SAVE_VARIABLE", 
            #    {"VARIABLE": f'{tool_id}_lock_x', 'VALUE': round(lock_x, 2)}))
            #save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
            #    "SAVE_VARIABLE", "SAVE_VARIABLE", 
            #    {"VARIABLE": f'{tool_id}_lock_y', 'VALUE': round(lock_y, 2)}))
            save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
                "SAVE_VARIABLE", "SAVE_VARIABLE", 
                {"VARIABLE": f'{tool_id}_unlock_x', 'VALUE': round(unlock_x, 2)}))
            save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
                "SAVE_VARIABLE", "SAVE_VARIABLE", 
                {"VARIABLE": f'{tool_id}_unlock_y', 'VALUE': round(unlock_y, 2)}))
            save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
                "SAVE_VARIABLE", "SAVE_VARIABLE", 
                {"VARIABLE": f'{tool_id}_dock_z', 'VALUE': self.dock_z}))
                
            # Also save simplified dock position for compatibility
            save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
                "SAVE_VARIABLE", "SAVE_VARIABLE", 
                {"VARIABLE": f'{tool_id}_dock_x', 'VALUE': round(lock_x, 2)}))
            save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
                "SAVE_VARIABLE", "SAVE_VARIABLE", 
                {"VARIABLE": f'{tool_id}_dock_y', 'VALUE': round(lock_y, 2)}))
            
            saved_to = "save_variables"
        except Exception as e:
            self.gcode.respond_info(
                f"Error saving positions to save_variables: {str(e)}\n"
                f"Please ensure save_variables is configured in your printer.cfg")
            return
        
        # Report results
        self.gcode.respond_info(
            f"Dock calibration complete for {tool_id}\n"
            #f"Lock position: ({lock_x:.2f}, {lock_y:.2f})\n"
            f"Unlock position: ({unlock_x:.2f}, {unlock_y:.2f})\n"
            f"Z height: {self.dock_z}\n"
            f"Positions saved to {saved_to}")

def load_config(config):
    return GenericDockCalibrate(config)
