# Camera dock calibration module for Dakash toolchanger
#
# This module has been adapted from the dock_calibrate.py script

import logging

class CameraDockCalibrate:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.name = config.get_name()
        self.xy_resolution = config.getfloat('xy_resolution')
        self.dock_extra_offset_x_unlock = config.getfloat('dock_extra_offset_x_unlock')
        self.dock_extra_offset_y_unlock = config.getfloat('dock_extra_offset_y_unlock')
        self.dock_extra_offset_x_lock = config.getfloat('dock_extra_offset_x_lock')
        self.dock_extra_offset_y_lock = config.getfloat('dock_extra_offset_y_lock')
        self.gcode = self.printer.lookup_object('gcode')
        gcode_macro = self.printer.load_object(config, 'gcode_macro')
        
        # G-Code macros - use the same template structure as dock_calibrate.py
        self.camera_dock_calibrate_move_1_template = gcode_macro.load_template(
            config, 'camera_dock_calibrate_move_1_gcode', '')
        self.camera_dock_calibrate_move_2_template = gcode_macro.load_template(
            config, 'camera_dock_calibrate_move_2_gcode', '')
        self.camera_dock_test_template = gcode_macro.load_template(
            config, 'camera_dock_test_gcode', '')
        self.camera_rod_install_msg_template = gcode_macro.load_template(
            config, 'camera_rod_install_msg_gcode', '')
        
        # Register commands
        self.gcode.register_command('CALC_CAMERADOCK_LOCATION', 
                                   self.cmd_CALC_CAMERADOCK_LOCATION,
                                   desc=self.cmd_CALC_CAMERADOCK_LOCATION_help)
        
        self.gcode.register_command('CAMERA_DOCK_TEST', 
                                   self.cmd_CAMERA_DOCK_TEST,
                                   desc=self.cmd_CAMERA_DOCK_TEST_help)
    
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

    cmd_CALC_CAMERADOCK_LOCATION_help = "Automatically Calculate Camera Dock Location"
    def cmd_CALC_CAMERADOCK_LOCATION(self, gcmd):
        cameratool = gcmd.get("CAMERATOOL", "0")  # Default to 0 if not specified
        toolhead = self.printer.lookup_object('toolhead')

        # Get initial position at the camera dock
        initial_res = self.get_mcu_position()
        logging.info("Camera dock calibration - initial position: %s", initial_res)
        
        # First movement - identical to dock_calibrate.py approach
        self.camera_dock_calibrate_move_1_template.run_gcode_from_command()
        self.gcode.run_script_from_command('G4 P2000')
        move_1_res = self.get_mcu_position()
        logging.info("Camera dock calibration - move 1 position: %s", move_1_res)
        
        # Second movement - home Y then X
        self.camera_dock_calibrate_move_2_template.run_gcode_from_command()
        self.gcode.run_script_from_command('G4 P2000')
        move_2_res = self.get_mcu_position()
        logging.info("Camera dock calibration - move 2 position: %s", move_2_res)
        
        # Calculate dock positions using the same formulas as dock_calibrate.py
        dx2 = move_2_res['x'] - move_1_res['x']
        dy2 = move_2_res['y'] - move_1_res['y']

        unlock_x = -(((dx2 + dy2)/2) * self.xy_resolution) + self.dock_extra_offset_x_unlock
        unlock_y = -(((dx2 - dy2)/2) * self.xy_resolution) + self.dock_extra_offset_y_unlock

        dx1 = move_2_res['x'] - initial_res['x']
        dy1 = move_2_res['y'] - initial_res['y']
        
        lock_x = -(((dx1 + dy1)/2) * self.xy_resolution) + self.dock_extra_offset_x_lock
        lock_y = -(((dx1 - dy1)/2) * self.xy_resolution) + self.dock_extra_offset_y_lock
        
        # Save the camera dock positions to variables
        save_variables = self.printer.lookup_object('save_variables')

        save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
            "SAVE_VARIABLE", "SAVE_VARIABLE", 
            {"VARIABLE": 'camera_dock_lock_x', 'VALUE': round(lock_x, 2)}))
        save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
            "SAVE_VARIABLE", "SAVE_VARIABLE", 
            {"VARIABLE": 'camera_dock_lock_y', 'VALUE': round(lock_y, 2)}))
        save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
            "SAVE_VARIABLE", "SAVE_VARIABLE", 
            {"VARIABLE": 'camera_dock_unlock_x', 'VALUE': round(unlock_x, 2)}))
        save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
            "SAVE_VARIABLE", "SAVE_VARIABLE", 
            {"VARIABLE": 'camera_dock_unlock_y', 'VALUE': round(unlock_y, 2)}))
        
        # Report results
        self.gcode.respond_info(
            "Camera dock calibration complete\n"
            "Lock position: (%.2f, %.2f)\n"
            "Unlock position: (%.2f, %.2f)"
            % (lock_x, lock_y, unlock_x, unlock_y))
            
    cmd_CAMERA_DOCK_TEST_help = "Test Camera Dock Position"
    def cmd_CAMERA_DOCK_TEST(self, gcmd):
        self.camera_rod_install_msg_template.run_gcode_from_command()
        self.camera_dock_test_template.run_gcode_from_command()
                        
def load_config(config):
    return CameraDockCalibrate(config)
