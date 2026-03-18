import serial
import logging

class ArduinoSerial:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.name = config.get_name().split()[-1]  # e.g. 'pump_arduino' or 'arduino_serial'
        self.serial_port = config.get('serial_port', '/dev/ttyACM1')
        self.baud_rate = config.getint('baud_rate', 115200)
        self.serial = None
        self.gcode = self.printer.lookup_object('gcode')

        # Register command based on name:
        # [arduino_serial]            → SEND_ARDUINO
        # [arduino_serial pump_arduino] → SEND_PUMP_ARDUINO
        if self.name == 'arduino_serial':
            cmd_name = 'SEND_ARDUINO'
        else:
            cmd_name = 'SEND_' + self.name.upper()

        self.gcode.register_command(
            cmd_name,
            self.cmd_send_arduino,
            desc="Send command to Arduino ({})".format(self.name)
        )

        # Connect to serial port
        try:
            self.serial = serial.Serial(self.serial_port, self.baud_rate, timeout=1)
            logging.info("ArduinoSerial [{}]: connected to {}".format(self.name, self.serial_port))
        except Exception as e:
            logging.error("ArduinoSerial [{}]: failed to connect to {}: {}".format(
                self.name, self.serial_port, str(e)))

    def cmd_send_arduino(self, gcmd):
        command = gcmd.get('COMMAND', default='info')
        if self.serial is None:
            gcmd.respond_info("ArduinoSerial [{}]: not connected".format(self.name))
            return
        try:
            self.serial.write("{}\n".format(command).encode())
            response = self.serial.readline().decode().strip()
            gcmd.respond_info("Arduino [{}] response: {}".format(self.name, response))
        except Exception as e:
            gcmd.respond_info("ArduinoSerial [{}] error: {}".format(self.name, str(e)))

    def get_status(self, eventtime):
        return {}

def load_config(config):
    return ArduinoSerial(config)

def load_config_prefix(config):
    return ArduinoSerial(config)
