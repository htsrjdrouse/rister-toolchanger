// HTS Resources — Syringe Pump Controller v2.1
// A4988 driver, G-code style interface
//
// rotation_distance: 24.534  (1 E unit = 1 uL)
// microsteps: 32 (DRV8825 1/32)
// full_steps_per_rotation: 200
// Calibration: 1 uL = 260.9 steps
//
// Commands:
//   TRIGGERON            Arm trigger listener
//   TRIGGEROFF           Disarm trigger listener
//   D1 E<vol> F<rate>    Armed: store silently. Not armed: execute immediately
//   A1 E<vol> F<rate>    Always executes immediately
//   TD <ms>              Set trigger delay
//   P114                 Report state
//   P0                   Emergency stop
//   P999                 Reset estop
//
// Wiring:
//   STEP->D3  DIR->D4  EN->D5
//   MODE0->D8  MODE1->D9  MODE2->D10
//   RST->5V  SLP->5V (physical jumper required)
//   TRIG->D2 (internal pullup, no resistor needed)
//   Klipper: SET_PIN VALUE=0 triggers, VALUE=1 is idle

#define STEP_PIN   3
#define DIR_PIN    4
#define EN_PIN     5

#define TRIG_PIN   2

const float STEPS_PER_REV     = 200.0;
const float MICROSTEPS         = 16.0;
const float ROTATION_DISTANCE = 24.534;
const float STEPS_PER_UL      = (STEPS_PER_REV * MICROSTEPS) / ROTATION_DISTANCE;

volatile bool triggerFired    = false;
bool          triggerArmed    = false;

float storedDispenseVol  = 0.0;
float storedDispenseRate = 4000.0;
float trigDelayMs        = 50.0;

String inputBuffer = "";
bool   estop       = false;

long halfStepDelayUs(float F_mmPerMin) {
  float mmPerSec    = F_mmPerMin / 60.0;
  float stepsPerSec = STEPS_PER_UL * mmPerSec;
  long  halfDelay   = (long)(500000.0 / stepsPerSec);
  return max(halfDelay, 2L);
}

void triggerISR() {
  if (triggerArmed && !estop) {
    triggerFired = true;
  }
}

void setup() {
  pinMode(STEP_PIN,  OUTPUT);
  pinMode(DIR_PIN,   OUTPUT);
  pinMode(EN_PIN,    OUTPUT);


  pinMode(TRIG_PIN, INPUT_PULLUP);

  digitalWrite(EN_PIN,   LOW);
  digitalWrite(DIR_PIN,  HIGH);
  digitalWrite(STEP_PIN, LOW);

  attachInterrupt(digitalPinToInterrupt(TRIG_PIN), triggerISR, FALLING);

  Serial.begin(115200);
  Serial.println("ok");
  Serial.println("HTS Resources Syringe Pump v2.1");
  Serial.print("steps/uL:    "); Serial.println(STEPS_PER_UL, 2);
  Serial.print("trig delay:  "); Serial.print(trigDelayMs, 0); Serial.println(" ms");
  Serial.println("Trigger: DISARMED");
  Serial.println("Ready. Commands: TRIGGERON | TRIGGEROFF | A1/D1 E<vol> F<rate> | TD <ms> | P114 | P0 | P999");
}

void executeMoveUL(float volumeUL, float F, bool dispense) {
  if (estop) {
    Serial.println("error: estop — send P999");
    return;
  }
  if (volumeUL <= 0) {
    Serial.println("ok");
    return;
  }

  long totalSteps = (long)(volumeUL * STEPS_PER_UL);
  long dly        = halfStepDelayUs(F);

  digitalWrite(DIR_PIN, dispense ? HIGH : LOW);
  digitalWrite(EN_PIN,  LOW);

  for (long i = 0; i < totalSteps; i++) {
    if (estop) break;
    digitalWrite(STEP_PIN, HIGH);
    delayMicroseconds(dly);
    digitalWrite(STEP_PIN, LOW);
    delayMicroseconds(dly);
  }

  if (!dispense) {
    delayMicroseconds(100);
    digitalWrite(DIR_PIN, HIGH);
  }
}

void parseCommand(String line) {
  line.trim();
  if (line.length() == 0) { Serial.println("ok"); return; }

  String lu = line;
  lu.toUpperCase();

  String cmd = "";
  int i = 0;
  while (i < lu.length() && lu[i] != ' ') cmd += lu[i++];

  float E = 0.0;
  bool  hasE = false;
  int   eIdx = lu.indexOf('E');
  if (eIdx >= 0) { E = lu.substring(eIdx + 1).toFloat(); hasE = true; }

  float F = 4000.0;
  int   fIdx = lu.indexOf('F');
  if (fIdx >= 0) F = lu.substring(fIdx + 1).toFloat();

  if (cmd == "TRIGGERON") {
    triggerArmed = true;
    triggerFired = false;
    Serial.println("Trigger: ARMED — watching D2 falling edge (SET_PIN VALUE=0)");
    if (storedDispenseVol > 0) {
      Serial.print("Loaded: E"); Serial.print(storedDispenseVol, 2);
      Serial.print(" F"); Serial.println(storedDispenseRate, 0);
    } else {
      Serial.println("No dispense loaded — send D1 E<vol> F<rate> to load");
    }
    Serial.println("ok");
  }

  else if (cmd == "TRIGGEROFF") {
    triggerArmed = false;
    triggerFired = false;
    Serial.println("Trigger: DISARMED — serial commands only");
    Serial.println("ok");
  }

  else if (cmd == "A1" || cmd == "A") {
    if (!hasE) { Serial.println("error: E required e.g. A1 E10 F2000"); return; }
    Serial.print("Aspirating "); Serial.print(E, 2);
    Serial.print(" uL at F"); Serial.println(F, 0);
    executeMoveUL(E, F, false);
    Serial.println("ok");
  }

  else if (cmd == "D1" || cmd == "D") {
    if (!hasE) { Serial.println("error: E required e.g. D1 E5 F4000"); return; }
    if (triggerArmed) {
      storedDispenseVol  = E;
      storedDispenseRate = F;
      Serial.print("Dispense loaded: E"); Serial.print(E, 2);
      Serial.print(" F"); Serial.println(F, 0);
      Serial.println("ok");
    } else {
      Serial.print("Dispensing "); Serial.print(E, 2);
      Serial.print(" uL at F"); Serial.println(F, 0);
      executeMoveUL(E, F, true);
      Serial.println("ok");
    }
  }

  else if (cmd == "G1") {
    if (!hasE) { Serial.println("ok"); return; }
    if (triggerArmed) {
      storedDispenseVol  = E;
      storedDispenseRate = F;
      Serial.print("Dispense loaded: E"); Serial.print(E, 2);
      Serial.print(" F"); Serial.println(F, 0);
      Serial.println("ok");
    } else {
      Serial.print("Dispensing "); Serial.print(E, 2);
      Serial.print(" uL at F"); Serial.println(F, 0);
      executeMoveUL(E, F, true);
      Serial.println("ok");
    }
  }

  else if (cmd == "TD") {
    float val = 0.0;
    if (hasE) {
      val = E;
    } else {
      int spaceIdx = lu.indexOf(' ');
      if (spaceIdx >= 0) val = lu.substring(spaceIdx + 1).toFloat();
    }
    trigDelayMs = max(val, 0.0f);
    Serial.print("Trigger delay: "); Serial.print(trigDelayMs, 0);
    Serial.println(" ms");
    Serial.println("ok");
  }

  else if (cmd == "P114") {
    Serial.println("--- Syringe Pump State ---");
    Serial.print("steps/uL:      "); Serial.println(STEPS_PER_UL, 2);
    Serial.print("microsteps:    "); Serial.println((int)MICROSTEPS);
    Serial.print("rot_distance:  "); Serial.println(ROTATION_DISTANCE, 3);
    Serial.print("trigger armed: "); Serial.println(triggerArmed ? "YES" : "no");
    Serial.print("trigger delay: "); Serial.print(trigDelayMs, 0); Serial.println(" ms");
    Serial.print("stored vol:    ");
    if (storedDispenseVol > 0) {
      Serial.print(storedDispenseVol, 2); Serial.println(" uL");
      Serial.print("stored rate:   F"); Serial.println(storedDispenseRate, 0);
    } else {
      Serial.println("none");
    }
    Serial.print("estop:         "); Serial.println(estop ? "YES" : "no");
    Serial.println("ok");
  }

  else if (cmd == "P0") {
    estop        = true;
    triggerArmed = false;
    triggerFired = false;
    digitalWrite(EN_PIN, HIGH);
    Serial.println("ESTOP — driver disabled. Send P999 to reset.");
  }

  else if (cmd == "P999") {
    estop = false;
    digitalWrite(EN_PIN, LOW);
    Serial.println("estop cleared");
    Serial.println("ok");
  }

  else {
    Serial.println("ok");
  }
}

void loop() {
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n' || c == '\r') {
      if (inputBuffer.length() > 0) {
        parseCommand(inputBuffer);
        inputBuffer = "";
      }
    } else {
      inputBuffer += c;
    }
  }

  if (triggerFired && triggerArmed && !estop) {
    triggerFired = false;

    if (storedDispenseVol > 0) {
      if (trigDelayMs > 0) {
        delay((unsigned long)trigDelayMs);
      }
      Serial.print("Trigger fired — dispensing ");
      Serial.print(storedDispenseVol, 2);
      Serial.print(" uL at F");
      Serial.println(storedDispenseRate, 0);
      executeMoveUL(storedDispenseVol, storedDispenseRate, true);
      Serial.println("ok");
    } else {
      Serial.println("Trigger fired — no dispense loaded, ignoring");
    }
  }
}
