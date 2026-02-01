# Endstop Accuracy Test Module for Klipper
# Similar to PROBE_ACCURACY but for X, Y, Z endstops
#
# Installation:
#   1. Copy to ~/klipper/klippy/extras/endstop_accuracy.py
#   2. Add to printer.cfg:
#      [endstop_accuracy]
#   3. Restart Klipper
#
# Usage:
#   ENDSTOP_ACCURACY AXIS=X SAMPLES=10 RETRACT=10 SPEED=5

import math
import logging

class EndstopAccuracy:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.gcode = self.printer.lookup_object('gcode')

        # Register command
        self.gcode.register_command(
            'ENDSTOP_ACCURACY',
            self.cmd_ENDSTOP_ACCURACY,
            desc="Test endstop accuracy/repeatability (like PROBE_ACCURACY)"
        )

        # Get config options with defaults
        self.default_samples = config.getint('samples', 10)
        self.default_retract = config.getfloat('retract_dist', 10.0)
        self.default_speed = config.getfloat('speed', 5.0)
        self.default_retract_speed = config.getfloat('retract_speed', 50.0)

    def cmd_ENDSTOP_ACCURACY(self, gcmd):
        """Handler for ENDSTOP_ACCURACY command"""
        axis = gcmd.get('AXIS', 'X').upper()
        if axis not in ['X', 'Y', 'Z']:
            raise gcmd.error("AXIS must be X, Y, or Z")

        samples = gcmd.get_int('SAMPLES', self.default_samples, minval=1)
        retract = gcmd.get_float('RETRACT', self.default_retract, above=0.)
        speed = gcmd.get_float('SPEED', self.default_speed, above=0.)
        retract_speed = gcmd.get_float('RETRACT_SPEED',
                                       self.default_retract_speed, above=0.)

        toolhead = self.printer.lookup_object('toolhead')
        axis_idx = {'X': 0, 'Y': 1, 'Z': 2}[axis]
        axis_lower = axis.lower()

        # Must be homed first
        curtime = self.printer.get_reactor().monotonic()
        kin = toolhead.get_kinematics()
        kin_status = kin.get_status(curtime)
        if axis_lower not in kin_status['homed_axes']:
            raise gcmd.error("Must home %s axis first" % axis)

        # Find the rail and endstop for this axis
        rail = None
        for r in kin.get_rails():
            steppers = r.get_steppers()
            if steppers:
                name = steppers[0].get_name()
                if name == 'stepper_' + axis_lower:
                    rail = r
                    break

        if rail is None:
            raise gcmd.error("Could not find rail for axis %s" % axis)

        # Get endstop and homing info
        endstops = rail.get_endstops()
        if not endstops:
            raise gcmd.error("No endstop found for axis %s" % axis)

        homing_info = rail.get_homing_info()
        hi_speed = homing_info.speed
        hi_speed2 = homing_info.second_homing_speed

        gcmd.respond_info("ENDSTOP_ACCURACY: Testing %s axis" % axis)
        gcmd.respond_info("Samples: %d, Retract: %.2fmm, Speed: %.1fmm/s" %
                         (samples, retract, speed if speed else hi_speed2))

        # Use second homing speed if speed not specified (more accurate)
        probe_speed = speed if speed else hi_speed2

        # Get homing module
        homing = self.printer.lookup_object('homing')

        # Collect samples
        positions = []

        for i in range(samples):
            # Get current position
            pos = toolhead.get_position()

            # Retract away from endstop
            retract_pos = list(pos)
            if homing_info.positive_dir:
                retract_pos[axis_idx] = pos[axis_idx] - retract
            else:
                retract_pos[axis_idx] = pos[axis_idx] + retract

            # Clamp to axis limits
            axis_min, axis_max = rail.get_range()
            retract_pos[axis_idx] = max(axis_min,
                                        min(axis_max, retract_pos[axis_idx]))

            toolhead.move(retract_pos, retract_speed)
            toolhead.wait_moves()

            # Probe toward endstop using homing move
            try:
                # Calculate target position (beyond endstop)
                probe_pos = list(toolhead.get_position())
                if homing_info.positive_dir:
                    probe_pos[axis_idx] = axis_max + 5.0
                else:
                    probe_pos[axis_idx] = axis_min - 5.0

                # Do the probing move
                trigger_pos = self._probe_endstop(
                    toolhead, homing, rail, endstops,
                    probe_pos, probe_speed, axis_idx
                )

                positions.append(trigger_pos)
                gcmd.respond_info("Sample %d/%d: %s = %.4fmm" %
                                 (i + 1, samples, axis, trigger_pos))

            except self.printer.command_error as e:
                gcmd.respond_info("Sample %d/%d: FAILED - %s" %
                                 (i + 1, samples, str(e)))
                # Re-home to recover
                gcmd.respond_info("Re-homing %s axis..." % axis)
                self._home_axis(axis_lower)

        if len(positions) < 2:
            raise gcmd.error("Not enough successful samples (need at least 2)")

        # Calculate statistics
        mean = sum(positions) / len(positions)
        min_val = min(positions)
        max_val = max(positions)
        range_val = max_val - min_val

        # Standard deviation
        variance = sum((x - mean) ** 2 for x in positions) / len(positions)
        std_dev = math.sqrt(variance)

        # Report results
        gcmd.respond_info("")
        gcmd.respond_info("=" * 50)
        gcmd.respond_info("%s ENDSTOP ACCURACY RESULTS" % axis)
        gcmd.respond_info("=" * 50)
        gcmd.respond_info("Samples: %d" % len(positions))
        gcmd.respond_info("Mean: %.4fmm" % mean)
        gcmd.respond_info("Min: %.4fmm, Max: %.4fmm" % (min_val, max_val))
        gcmd.respond_info("Range: %.4fmm" % range_val)
        gcmd.respond_info("Std Dev: %.4fmm" % std_dev)
        gcmd.respond_info("")

        # Quality assessment (same thresholds as PROBE_ACCURACY)
        if range_val <= 0.0025:
            gcmd.respond_info("Result: EXCELLENT (range <= 0.0025mm)")
        elif range_val <= 0.01:
            gcmd.respond_info("Result: GOOD (range <= 0.01mm)")
        elif range_val <= 0.025:
            gcmd.respond_info("Result: ACCEPTABLE (range <= 0.025mm)")
        else:
            gcmd.respond_info("Result: POOR (range > 0.025mm) - Check endstop")

        gcmd.respond_info("=" * 50)

        # Retract to safe position
        pos = toolhead.get_position()
        if homing_info.positive_dir:
            pos[axis_idx] -= retract
        else:
            pos[axis_idx] += retract

        axis_min, axis_max = rail.get_range()
        pos[axis_idx] = max(axis_min, min(axis_max, pos[axis_idx]))

        toolhead.move(pos, retract_speed)
        toolhead.wait_moves()

    def _probe_endstop(self, toolhead, homing, rail, endstops,
                       probe_pos, speed, axis_idx):
        """
        Perform a probing move toward the endstop and return trigger position
        """
        # Get starting position
        start_pos = toolhead.get_position()

        # Build the homing move
        # endstops is a list of (mcu_endstop, name) tuples
        hmove = homing.HomingMove(self.printer, endstops)

        # Execute the probing move
        try:
            trigpos = hmove.homing_move(probe_pos, speed,
                                        triggered=True,
                                        check_triggered=True)
            return trigpos[axis_idx]
        except self.printer.command_error:
            # Move failed - endstop may not have triggered
            raise

    def _home_axis(self, axis):
        """Home a single axis"""
        self.gcode.run_script_from_command("G28 %s" % axis.upper())


def load_config(config):
    return EndstopAccuracy(config)
