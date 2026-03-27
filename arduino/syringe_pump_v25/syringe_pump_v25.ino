// ═══════════════════════════════════════════════════════════════════
// HTS Resources — Syringe Pump Controller v2.5
// A4988 driver, G-code style interface
//
// Matched to Klipper extruder2 config:
//   rotation_distance: 24.534  (1 E unit = 1 uL)
//   microsteps: 16 (A4988 1/16)
//   full_steps_per_rotation: 200
//   Calibration: 1 uL = 130.4 steps
//
// New in v2.5:
//   - Acceleration ramp in executeMoveUL
//     Ramps from START_DELAY_US down to target speed over ACCEL_STEPS
//     Enables F15000+ without skipping, reliable E50 and below
//   - SA <steps> command to set accel ramp steps at runtime
//   - P114 reports accel settings
//
// Carried forward from v2.4:
//   - STORE command — stores dispense without executing
//   - MOTORON / MOTOROFF — enable/disable driver current
//   - Single line P114 output — no buffer pollution
//   - Single line boot message
//   - E parameter parsed after first space — fixes STORE/TRIGGEROFF bug
//   - G1 removed — not used in decoupled trigger architecture
//   - Direction managed by caller — not inside executeMoveUL
//   - TRIG on D7 (interrupt capable on Micro)
//
// Commands:
//   TRIGGERON            Arm trigger listener
//   TRIGGEROFF           Disarm trigger listener
//   STORE E<vol> F<rate> Store dispense params without executing
//   D1 E<vol> F<rate>    Armed: store silently. Not armed: execute immediately
//   A1 E<vol> F<rate>    Always executes immediately (aspirate)
//   T1 F<rate>           Set triggered flow rate
//   TD <ms>              Set trigger delay in ms (default 50)
//   SA <steps>           Set accel ramp steps (default 500, 0=disable)
//   MOTORON              Enable driver (current flows)
//   MOTOROFF             Disable driver (no current, no heat)
//   P114                 Report state (single line)
//   P0                   Emergency stop
//   P999                 Reset estop
//
// Trigger behavior (when armed via TRIGGERON):
//   - Internal pullup on D7 — no external resistor needed
//   - Falling edge fires ISR (Klipper SET_PIN VALUE=0 triggers)
//   - Waits TD ms then executes stored dispense once
//   - Auto re-arms after each dispense
//   - Only TRIGGEROFF disarms
//
// Direction:
//   DIR HIGH = dispense (D1)
//   DIR LOW  = aspirate (A1)
//   Set by caller before executeMoveUL — NOT inside executeMoveUL
//
// Wiring:
//   STEP -> D4    DIR  -> D3    EN   -> D5
//   TRIG -> D7    VDD  -> 5V   VMOT -> 12V
//   MS1  -> 5V    MS2  -> 5V   (1/16 microstepping, hardwired)
//   RST  -> 5V    SLP  -> 5V   (physical jumper required on A4988)
//   10uF cap across VMOT and GND
//   Vref = 0.05V (~125mA) for syringe pump load
//
// Acceleration tuning:
//   ACCEL_STEPS = 500  — ramp over 500 steps (~3.8uL)
//   START_DELAY_US = 800 — starting half-step delay (~625 steps/sec)
//   For E50 (6520 steps): 500 accel + 5520 cruise + 500 decel
//   For E10 (1304 steps): 652 accel + 0 cruise + 652 decel (capped)
//   For E5  (652 steps):  326 accel + 0 cruise + 326 decel (capped)
// ═══════════════════════════════════════════════════════════════════

#define STEP_PIN   4
#define DIR_PIN    3
#define EN_PIN     5
#define TRIG_PIN   7

const float STEPS_PER_REV     = 200.0;
const float MICROSTEPS         = 16.0;
const float ROTATION_DISTANCE = 24.534;
const float STEPS_PER_UL      = (STEPS_PER_REV * MICROSTEPS) / ROTATION_DISTANCE;
// = 130.4 steps/uL

// ── Acceleration parameters ───────────────────────────────────────
// START_DELAY_US: half-step delay at start of ramp (slow speed)
//   800us = ~625 steps/sec — safe starting speed for any stepper
// ACCEL_STEPS: number of steps over which to ramp up/down
//   500 steps = ~3.8uL — short enough for E50 volumes
//   Set to 0 to disable ramping entirely
long accelSteps    = 500;
const long START_DELAY_US = 800;

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
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN,  OUTPUT);
  pinMode(EN_PIN,   OUTPUT);
  pinMode(TRIG_PIN, INPUT_PULLUP);

  digitalWrite(EN_PIN,   HIGH);   // disable driver on boot — no heat
  digitalWrite(DIR_PIN,  HIGH);   // default dispense direction
  digitalWrite(STEP_PIN, LOW);

  attachInterrupt(digitalPinToInterrupt(TRIG_PIN), triggerISR, FALLING);

  Serial.begin(115200);
  Serial.println("ok");
}

// ── executeMoveUL ─────────────────────────────────────────────────
// Direction must be set by caller before calling this function
// Acceleration ramp: accelSteps up, cruise, accelSteps down
// For very small volumes ramp steps are capped at totalSteps/2
// so ramp + decel never exceeds total move length
void executeMoveUL(float volumeUL, float F) {
  if (estop) { Serial.println("error:estop"); return; }
  if (volumeUL <= 0) { Serial.println("ok"); return; }

  long totalSteps  = (long)(volumeUL * STEPS_PER_UL);
  long targetDelay = halfStepDelayUs(F);

  // Cap ramp steps at half total steps so small volumes still work
  long rampSteps = (accelSteps > 0) ? min(accelSteps, totalSteps / 2) : 0;

  digitalWrite(EN_PIN, LOW);

  for (long i = 0; i < totalSteps; i++) {
    if (estop) break;

    long dly;

    if (rampSteps > 0) {
      if (i < rampSteps) {
        // Accelerate — linear interpolation from START_DELAY_US to targetDelay
        dly = START_DELAY_US - ((START_DELAY_US - targetDelay) * i / rampSteps);
      } else if (i >= totalSteps - rampSteps) {
        // Decelerate — linear interpolation from targetDelay back to START_DELAY_US
        long j = totalSteps - i;
        dly = START_DELAY_US - ((START_DELAY_US - targetDelay) * j / rampSteps);
      } else {
        // Cruise at target speed
        dly = targetDelay;
      }
      // Never faster than target speed
      dly = max(dly, targetDelay);
    } else {
      // No ramp — constant speed
      dly = targetDelay;
    }

    digitalWrite(STEP_PIN, HIGH);
    delayMicroseconds(dly);
    digitalWrite(STEP_PIN, LOW);
    delayMicroseconds(dly);
  }
}

void parseCommand(String line) {
  line.trim();
  if (line.length() == 0) { Serial.println("ok"); return; }

  String lu = line;
  lu.toUpperCase();

  // Extract command word
  String cmd = "";
  int i = 0;
  while (i < lu.length() && lu[i] != ' ') cmd += lu[i++];

  // Extract E parameter — search AFTER command word to avoid
  // matching letters in command itself (e.g. E in STORE, TRIGGEROFF)
  float E = 0.0;
  bool  hasE = false;
  int   firstSpace = lu.indexOf(' ');
  if (firstSpace >= 0) {
    int eIdx = lu.indexOf('E', firstSpace);
    if (eIdx >= 0) { E = lu.substring(eIdx + 1).toFloat(); hasE = true; }
  }

  // Extract F parameter — search AFTER command word
  float F = 4000.0;
  if (firstSpace >= 0) {
    int fIdx = lu.indexOf('F', firstSpace);
    if (fIdx >= 0) F = lu.substring(fIdx + 1).toFloat();
  }

  // ── TRIGGERON ─────────────────────────────────────────────────
  if (cmd == "TRIGGERON") {
    triggerArmed = true;
    triggerFired = false;
    Serial.println("ok");
  }

  // ── TRIGGEROFF ────────────────────────────────────────────────
  else if (cmd == "TRIGGEROFF") {
    triggerArmed = false;
    triggerFired = false;
    Serial.println("ok");
  }

  // ── MOTORON ───────────────────────────────────────────────────
  else if (cmd == "MOTORON") {
    digitalWrite(EN_PIN, LOW);
    Serial.println("ok");
  }

  // ── MOTOROFF ──────────────────────────────────────────────────
  else if (cmd == "MOTOROFF") {
    digitalWrite(EN_PIN, HIGH);
    Serial.println("ok");
  }

  // ── STORE E<vol> F<rate> — store without executing ────────────
  else if (cmd == "STORE") {
    if (!hasE) { Serial.println("error:E required"); return; }
    storedDispenseVol  = E;
    storedDispenseRate = F;
    Serial.println("ok");
  }

  // ── A1 E<vol> F<rate> — Aspirate (always immediate) ───────────
  else if (cmd == "A1" || cmd == "A") {
    if (!hasE) { Serial.println("error:E required"); return; }
    digitalWrite(DIR_PIN, LOW);    // aspirate direction
    executeMoveUL(E, F);
    Serial.println("ok");
  }

  // ── D1 E<vol> F<rate> — Dispense ──────────────────────────────
  // Armed: store silently. Not armed: execute immediately.
  else if (cmd == "D1" || cmd == "D") {
    if (!hasE) { Serial.println("error:E required"); return; }
    if (triggerArmed) {
      storedDispenseVol  = E;
      storedDispenseRate = F;
      Serial.println("ok");
    } else {
      digitalWrite(DIR_PIN, HIGH);  // dispense direction
      executeMoveUL(E, F);
      Serial.println("ok");
    }
  }

  // ── T1 F<rate> — Set triggered flow rate ──────────────────────
  else if (cmd == "T1") {
    storedDispenseRate = F;
    Serial.println("ok");
  }

  // ── TD <ms> — Set trigger delay ───────────────────────────────
  else if (cmd == "TD") {
    float val = 0.0;
    if (hasE) {
      val = E;
    } else {
      int spaceIdx = lu.indexOf(' ');
      if (spaceIdx >= 0) val = lu.substring(spaceIdx + 1).toFloat();
    }
    trigDelayMs = max(val, 0.0f);
    Serial.println("ok");
  }

  // ── SA <steps> — Set accel ramp steps ─────────────────────────
  // SA 0   = disable ramp (constant speed, original behavior)
  // SA 500 = ramp over 500 steps (default, good for F10000+)
  // SA 200 = shorter ramp (for very small volumes E5-E20)
  // SA 1000 = longer ramp (for very high speeds F15000+)
  else if (cmd == "SA") {
    long val = 0;
    int spaceIdx = lu.indexOf(' ');
    if (spaceIdx >= 0) val = lu.substring(spaceIdx + 1).toInt();
    accelSteps = max(val, 0L);
    Serial.println("ok");
  }

  // ── P114 — Report state (single line for Klipper plugin) ──────
  else if (cmd == "P114") {
    Serial.print("vol=");       Serial.print(storedDispenseVol, 2);
    Serial.print(" rate=");     Serial.print(storedDispenseRate, 0);
    Serial.print(" delay=");    Serial.print(trigDelayMs, 0);
    Serial.print(" armed=");    Serial.print(triggerArmed ? "1" : "0");
    Serial.print(" motor=");    Serial.print(digitalRead(EN_PIN) == LOW ? "1" : "0");
    Serial.print(" dir=");      Serial.print(digitalRead(DIR_PIN) == HIGH ? "disp" : "asp");
    Serial.print(" estop=");    Serial.print(estop ? "1" : "0");
    Serial.print(" accel=");    Serial.print(accelSteps);
    Serial.print(" steps_ul="); Serial.print(STEPS_PER_UL, 1);
    Serial.println(" ok");
  }

  // ── P0 — Emergency stop ───────────────────────────────────────
  else if (cmd == "P0") {
    estop        = true;
    triggerArmed = false;
    triggerFired = false;
    digitalWrite(EN_PIN, HIGH);
    Serial.println("estop");
  }

  // ── P999 — Clear estop ────────────────────────────────────────
  else if (cmd == "P999") {
    estop = false;
    digitalWrite(EN_PIN, LOW);
    Serial.println("ok");
  }

  // ── Unknown ───────────────────────────────────────────────────
  else {
    Serial.println("ok");
  }
}

void loop() {
  // Serial input
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

  // Triggered dispense — falling edge on TRIG_PIN
  if (triggerFired && triggerArmed && !estop) {
    triggerFired = false;
    if (storedDispenseVol > 0) {
      if (trigDelayMs > 0) {
        delay((unsigned long)trigDelayMs);
      }
      digitalWrite(DIR_PIN, HIGH);   // dispense direction
      executeMoveUL(storedDispenseVol, storedDispenseRate);
      Serial.println("ok");
    }
  }
}
