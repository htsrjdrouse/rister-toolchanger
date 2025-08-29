; Combined G-code Sequence
; Generated: 2025-08-28T21:03:01.586Z
; Combined from: WATERWELL, ASPIRATE_PIPETTE_1ulSYRINGE, linearactuator_pos0, POSITION_WASH_INANDOUT
; Ready to execute in Mainsail console

; --- Sequence 1: WATERWELL ---
; Move to waterwell array A1
G90  ; Absolute positioning
SET_SERVO SERVO=linearactuator_servo_l0 ANGLE=0
G4 P1500  ; Pause 500ms for stabilization
G1 X218.00 Y94.00 F3000  ; Move to array position
G4 P500  ; Pause 500ms for stabilization
G1 Z90 F1000  ; Move to array position
G4 P500  ; Pause 500ms for stabilization
SET_SERVO SERVO=linearactuator_servo_l0 ANGLE=140
G4 P1500  ; Pause 500ms for stabilization

; --- Sequence 2: ASPIRATE_PIPETTE_1ulSYRINGE ---
VALVE_OUTPUT
G4 P1000
;load syringe
;170 steps for 100ul at a time
M83
;This is about 0.76ml but it needs to be calibrated
G1 E-170 F3000
;For 100ul its E-170 for a 1ml pipette
;G1 E-170 F3000
;M83
G4 P2000
VALVE_BYPASS

; --- Sequence 3: linearactuator_pos0 ---
SET_SERVO SERVO=linearactuator_servo_l0 ANGLE=140
G4 P1500  ; Pause 500ms for stabilization

; --- Sequence 4: POSITION_WASH_INANDOUT ---
; --- Sequence 1: WASHPOSITION_WASHING ---
WASH_POSITION
G4 P1000
WASH_ON
G4 P1000
WASH_OFF
G4 P1000
WASTE_ON
G4 P2000
WASTE_OFF
G4 P1000
; --- Sequence 2: LOAD_DISPENSE_200ulSYRINGE_SEQUENCE ---
; --- Sequence 1: LOAD_1mlSYRINGE ---
VALVE_INPUT
G4 P1000
;load syringe
;170 steps for 100ul at a time
M83
;This is about 0.76ml but it needs to be calibrated
G1 E-340 F6000
;For 100ul its E-170 for a 1ml pipette
;G1 E-170 F3000
;M83
G4 P2000
VALVE_BYPASS
; --- Sequence 2: DISPENSE_1mlSYRINGE ---
VALVE_OUTPUT
G4 P1000
;dispense syringe
;170 steps for 100ul at a time
M83
;This is about 0.76ml but it needs to be calibrated
G1 E340 F6000
;For 100ul its E-170 for a 1ml pipette
;G1 E170 F3000
;M83
G4 P2000
VALVE_BYPASS
G4 P1000
G4 P1000
WASH_ON
G4 P1000
WASH_OFF
G4 P1000
WASTE_ON
G4 P2000
WASTE_OFF
G4 P1000
G1 Z110 F1000
G4 P1000
SET_SERVO SERVO=linearactuator_servo_l0 ANGLE=100
G4 P1500  ; Pause 500ms for stabilization
