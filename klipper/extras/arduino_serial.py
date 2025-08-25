import serial
import logging

class ArduinoSerial:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.serial_port = config.get('serial_port', '/dev/ttyACM1')
        self.baud_rate = config.getint('baud_rate', 115200)
        self.serial = serial.Serial(self.serial_port, self.baud_rate, timeout=1)
        self.gcode = self.printer.lookup_object('gcode')
        self.gcode.register_command('SEND_ARDUINO', self.cmd_send_arduino, desc="Send command to Arduino")

    def cmd_send_arduino(self, gcmd):
        command = gcmd.get('COMMAND', default='info')
        self.serial.write(f"{command}\n".encode())
        response = self.serial.readline().decode().strip()
        gcmd.respond_info(f"Arduino response: {response}")

    def get_status(self, eventtime):
        return {}

def load_config(config):
    return ArduinoSerial(config)
