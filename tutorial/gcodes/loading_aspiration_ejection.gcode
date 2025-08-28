; Combined G-code Sequence
; Generated: 2025-08-27T20:00:55.117Z
; Combined from: load_pipette_row1_col1, WATERWELL, ASPIRATE_PIPETTE_1mlSYRINGE
; Ready to execute in Mainsail console

; --- Sequence 1: load_pipette_row1_col1 ---
; --- Sequence 1: PIPETTE_TIP_BOX_ROW1_COL1 ---
; Move to pipette_tip_box well A1
G90  ; Absolute positioning
G1 Z90 F500
G1 X299.00 Y72.00 F3000  ; Move to well position
G4 P500  ; Pause 500ms for stabilization
ENABLE_LINEARACTUATOR_SERVO_L0
SET_SERVO SERVO=linearactuator_servo_l0 ANGLE=140
G4 P1500  ; Pause 500ms for stabilization
SET_SERVO SERVO=linearactuator_servo_l0 ANGLE=0
G4 P1500  ; Pause 500ms for stabilization
DISABLE_LINEARACTUATOR_SERVO_L0
G4 P500  ; Pause 500ms for stabilization
G1 Z120 F500

; --- Sequence 2: WATERWELL ---
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

; --- Sequence 3: ASPIRATE_PIPETTE_1mlSYRINGE ---
VALVE_OUTPUT
G4 P1000
;load syringe
;170 steps for 100ul at a time
M83
;This is about 0.76ml but it needs to be calibrated
G1 E-1300 F3000
;For 100ul its E-170 for a 1ml pipette
;G1 E-170 F3000
;M83
G4 P2000
VALVE_BYPASS
SET_SERVO SERVO=linearactuator_servo_l0 ANGLE=0
G4 P2000
M117 Before eject command
EJECT_PIPETTE
M117 After eject command
G4 P2000
