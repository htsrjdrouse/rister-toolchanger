// ═══════════════════════════════════════════════════════════════════
// HTS Resources — Syringe Pump Controller v2.6
// A4988 driver, G-code style interface
//
// New in v2.6:
//   - DISPENSE command — full prime→dispense→retract sequence in one command
//   - SDISPENSE command — stores full sequence for trigger firing
//   - Sequence stored params reported in P114
//
// Sequence command syntax:
//   DISPENSE P<vol> PF<rate> PD<ms> E<vol> F<rate> DD<ms> R<vol> RF<rate> RD<ms>
//   SDISPENSE P<vol> PF<rate> PD<ms> E<vol> F<rate> DD<ms> R<vol> RF<rate> RD<ms>
//
//   P<vol>   = prime volume (uL)
//   PF<rate> = prime feedrate
//   PD<ms>   = prime delay ms (settle after prime)
//   E<vol>   = main dispense volume (uL)
//   F<rate>  = main dispense feedrate
//   DD<ms>   = dispense delay ms (settle after main dispense)
//   R<vol>   = retract volume (uL)
//   RF<rate> = retract feedrate
//   RD<ms>   = retract delay ms (settle after retract)
//
// Example (matches calibration table test 5 — ~40uL / 4 nozzles):
//   DISPENSE P20 PF10000 PD1000 E50 F14000 DD500 R60 RF6000 RD100
//
// Example store for trigger:
//   SDISPENSE P20 PF10000 PD1000 E50 F14000 DD500 R60 RF6000 RD100
//   TRIGGERON
//   (trigger fires complete sequence on falling edge)
//
// Carried forward from v2.5:
//   - Acceleration ramp (SA command)
//   - STORE / D1 / A1 / T1 / TD / MOTORON / MOTOROFF
//   - Single line P114, single line boot
//   - E parameter parsed after first space
//   - TRIG on D7
//
// Wiring:
//   STEP -> D4    DIR  -> D3    EN   -> D5
//   TRIG -> D7    VDD  -> 5V   VMOT -> 12V
//   MS1  -> 5V    MS2  -> 5V   (1/16 microstepping, hardwired)
//   RST  -> 5V    SLP  -> 5V   (physical jumper required on A4988)
//   10uF cap across VMOT and GND
//   Vref = 0.05V (~125mA) for syringe pump load
// ═══════════════════════════════════════════════════════════════════

#define STEP_PIN   4
#define DIR_PIN    3
#define EN_PIN     5
#define TRIG_PIN   7

const float STEPS_PER_REV     = 200.0;
const float MICROSTEPS         = 16.0;
const float ROTATION_DISTANCE = 24.534;
const float STEPS_PER_UL      = (STEPS_PER_REV * MICROSTEPS) / ROTATION_DISTANCE;

// ── Acceleration parameters ───────────────────────────────────────
long accelSteps           = 500;
const long START_DELAY_US = 800;

// ── Simple dispense storage (legacy) ─────────────────────────────
volatile bool triggerFired    = false;
bool          triggerArmed    = false;
float storedDispenseVol       = 0.0;
float storedDispenseRate      = 4000.0;
float trigDelayMs             = 50.0;

// ── Sequence storage — full prime→dispense→retract ────────────────
bool  seqStored    = false;   // true if a sequence has been stored
float seqPrimeVol  = 0.0;     // prime volume uL (0 = skip prime)
float seqPrimeRate = 10000.0; // prime feedrate
long  seqPrimeDelayMs = 1000; // settle after prime ms
float seqDispVol   = 0.0;     // main dispense volume uL
float seqDispRate  = 14000.0; // main dispense feedrate
long  seqDispDelayMs = 500;   // settle after dispense ms
float seqRetractVol  = 0.0;   // retract volume uL (0 = skip retract)
float seqRetractRate = 6000.0;// retract feedrate
long  seqRetractDelayMs = 100;// settle after retract ms

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

  digitalWrite(EN_PIN,   HIGH);
  digitalWrite(DIR_PIN,  HIGH);
  digitalWrite(STEP_PIN, LOW);

  attachInterrupt(digitalPinToInterrupt(TRIG_PIN), triggerISR, FALLING);

  Serial.begin(115200);
  Serial.println("ok");
}

// ── executeMoveUL ─────────────────────────────────────────────────
// Direction must be set by caller before calling
void executeMoveUL(float volumeUL, float F) {
  if (estop) { Serial.println("error:estop"); return; }
  if (volumeUL <= 0) return;

  long totalSteps  = (long)(volumeUL * STEPS_PER_UL);
  long targetDelay = halfStepDelayUs(F);
  long rampSteps   = (accelSteps > 0) ? min(accelSteps, totalSteps / 2) : 0;

  digitalWrite(EN_PIN, LOW);

  for (long i = 0; i < totalSteps; i++) {
    if (estop) break;
    long dly;
    if (rampSteps > 0) {
      if (i < rampSteps) {
        dly = START_DELAY_US - ((START_DELAY_US - targetDelay) * i / rampSteps);
      } else if (i >= totalSteps - rampSteps) {
        long j = totalSteps - i;
        dly = START_DELAY_US - ((START_DELAY_US - targetDelay) * j / rampSteps);
      } else {
        dly = targetDelay;
      }
      dly = max(dly, targetDelay);
    } else {
      dly = targetDelay;
    }
    digitalWrite(STEP_PIN, HIGH);
    delayMicroseconds(dly);
    digitalWrite(STEP_PIN, LOW);
    delayMicroseconds(dly);
  }
}

// ── executeSequence ───────────────────────────────────────────────
// Runs stored prime→dispense→retract sequence
// Uses seqXxx variables — set by DISPENSE or SDISPENSE commands
void executeSequence() {
  if (estop) { Serial.println("error:estop"); return; }

  // 1. Prime
  if (seqPrimeVol > 0) {
    digitalWrite(DIR_PIN, HIGH);
    executeMoveUL(seqPrimeVol, seqPrimeRate);
    if (seqPrimeDelayMs > 0) delay((unsigned long)seqPrimeDelayMs);
  }

  // 2. Main dispense
  if (seqDispVol > 0) {
    digitalWrite(DIR_PIN, HIGH);
    executeMoveUL(seqDispVol, seqDispRate);
    if (seqDispDelayMs > 0) delay((unsigned long)seqDispDelayMs);
  }

  // 3. Retract
  if (seqRetractVol > 0) {
    digitalWrite(DIR_PIN, LOW);
    executeMoveUL(seqRetractVol, seqRetractRate);
    if (seqRetractDelayMs > 0) delay((unsigned long)seqRetractDelayMs);
    // Restore dispense direction after retract
    digitalWrite(DIR_PIN, HIGH);
  }
}

// ── parseSequenceParams ───────────────────────────────────────────
// Parses DISPENSE/SDISPENSE parameter string into seq variables
// Params: P<vol> PF<rate> PD<ms> E<vol> F<rate> DD<ms> R<vol> RF<rate> RD<ms>
// All parameters are optional — unspecified params keep current values
void parseSequenceParams(String lu) {
  // P<vol> — prime volume
  int idx = lu.indexOf(" P");
  while (idx >= 0) {
    // make sure its P not PF or PD
    char next = (idx + 2 < lu.length()) ? lu.charAt(idx + 2) : ' ';
    if (next != 'F' && next != 'D') {
      seqPrimeVol = lu.substring(idx + 2).toFloat();
      break;
    }
    idx = lu.indexOf(" P", idx + 1);
  }

  // PF<rate> — prime feedrate
  idx = lu.indexOf(" PF");
  if (idx >= 0) seqPrimeRate = lu.substring(idx + 3).toFloat();

  // PD<ms> — prime delay
  idx = lu.indexOf(" PD");
  if (idx >= 0) seqPrimeDelayMs = lu.substring(idx + 3).toInt();

  // E<vol> — main dispense volume
  idx = lu.indexOf(" E");
  if (idx >= 0) seqDispVol = lu.substring(idx + 2).toFloat();

  // F<rate> — main dispense feedrate (search after first space, avoid PF/RF)
  // Find F that is not preceded by P or R
  for (int i = 1; i < lu.length() - 1; i++) {
    if (lu.charAt(i) == ' ' && lu.charAt(i + 1) == 'F') {
      char prev = lu.charAt(i - 1);
      if (prev != 'P' && prev != 'R') {
        seqDispRate = lu.substring(i + 2).toFloat();
        break;
      }
    }
  }

  // DD<ms> — dispense delay
  idx = lu.indexOf(" DD");
  if (idx >= 0) seqDispDelayMs = lu.substring(idx + 3).toInt();

  // R<vol> — retract volume (R not followed by F or D)
  idx = lu.indexOf(" R");
  while (idx >= 0) {
    char next = (idx + 2 < lu.length()) ? lu.charAt(idx + 2) : ' ';
    if (next != 'F' && next != 'D') {
      seqRetractVol = lu.substring(idx + 2).toFloat();
      break;
    }
    idx = lu.indexOf(" R", idx + 1);
  }

  // RF<rate> — retract feedrate
  idx = lu.indexOf(" RF");
  if (idx >= 0) seqRetractRate = lu.substring(idx + 3).toFloat();

  // RD<ms> — retract delay
  idx = lu.indexOf(" RD");
  if (idx >= 0) seqRetractDelayMs = lu.substring(idx + 3).toInt();

  seqStored = true;
}

void parseCommand(String line) {
  line.trim();
  if (line.length() == 0) { Serial.println("ok"); return; }

  String lu = line;
  lu.toUpperCase();

  String cmd = "";
  int i = 0;
  while (i < lu.length() && lu[i] != ' ') cmd += lu[i++];

  // Extract E and F for simple commands (after first space)
  float E = 0.0;
  bool  hasE = false;
  int   firstSpace = lu.indexOf(' ');
  if (firstSpace >= 0) {
    int eIdx = lu.indexOf('E', firstSpace);
    if (eIdx >= 0) { E = lu.substring(eIdx + 1).toFloat(); hasE = true; }
  }
  float F = 4000.0;
  if (firstSpace >= 0) {
    int fIdx = lu.indexOf('F', firstSpace);
    if (fIdx >= 0) F = lu.substring(fIdx + 1).toFloat();
  }

  // ── DISPENSE — execute full prime→dispense→retract immediately ──
  // DISPENSE P20 PF10000 PD1000 E50 F14000 DD500 R60 RF6000 RD100
  if (cmd == "DISPENSE") {
    parseSequenceParams(lu);
    executeSequence();
    Serial.println("ok");
  }

  // ── SDISPENSE — store sequence for trigger, don't execute ───────
  // SDISPENSE P20 PF10000 PD1000 E50 F14000 DD500 R60 RF6000 RD100
  else if (cmd == "SDISPENSE") {
    parseSequenceParams(lu);
    Serial.println("ok");
  }

  // ── TRIGGERON ─────────────────────────────────────────────────
  else if (cmd == "TRIGGERON") {
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

  // ── STORE E<vol> F<rate> — store simple dispense ──────────────
  else if (cmd == "STORE") {
    if (!hasE) { Serial.println("error:E required"); return; }
    storedDispenseVol  = E;
    storedDispenseRate = F;
    Serial.println("ok");
  }

  // ── A1 — Aspirate immediately ─────────────────────────────────
  else if (cmd == "A1" || cmd == "A") {
    if (!hasE) { Serial.println("error:E required"); return; }
    digitalWrite(DIR_PIN, LOW);
    executeMoveUL(E, F);
    Serial.println("ok");
  }

  // ── D1 — Dispense immediately or store if armed ───────────────
  else if (cmd == "D1" || cmd == "D") {
    if (!hasE) { Serial.println("error:E required"); return; }
    if (triggerArmed) {
      storedDispenseVol  = E;
      storedDispenseRate = F;
      Serial.println("ok");
    } else {
      digitalWrite(DIR_PIN, HIGH);
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
    if (hasE) { val = E; }
    else {
      int spaceIdx = lu.indexOf(' ');
      if (spaceIdx >= 0) val = lu.substring(spaceIdx + 1).toFloat();
    }
    trigDelayMs = max(val, 0.0f);
    Serial.println("ok");
  }

  // ── SA <steps> — Set accel ramp steps ─────────────────────────
  else if (cmd == "SA") {
    long val = 0;
    int spaceIdx = lu.indexOf(' ');
    if (spaceIdx >= 0) val = lu.substring(spaceIdx + 1).toInt();
    accelSteps = max(val, 0L);
    Serial.println("ok");
  }

  // ── P114 — Report state (single line) ─────────────────────────
  else if (cmd == "P114") {
    Serial.print("vol=");        Serial.print(storedDispenseVol, 2);
    Serial.print(" rate=");      Serial.print(storedDispenseRate, 0);
    Serial.print(" delay=");     Serial.print(trigDelayMs, 0);
    Serial.print(" armed=");     Serial.print(triggerArmed ? "1" : "0");
    Serial.print(" motor=");     Serial.print(digitalRead(EN_PIN) == LOW ? "1" : "0");
    Serial.print(" dir=");       Serial.print(digitalRead(DIR_PIN) == HIGH ? "disp" : "asp");
    Serial.print(" estop=");     Serial.print(estop ? "1" : "0");
    Serial.print(" accel=");     Serial.print(accelSteps);
    Serial.print(" steps_ul=");  Serial.print(STEPS_PER_UL, 1);
    Serial.print(" seq=");       Serial.print(seqStored ? "1" : "0");
    Serial.print(" P=");         Serial.print(seqPrimeVol, 1);
    Serial.print(" PF=");        Serial.print(seqPrimeRate, 0);
    Serial.print(" PD=");        Serial.print(seqPrimeDelayMs);
    Serial.print(" E=");         Serial.print(seqDispVol, 1);
    Serial.print(" F=");         Serial.print(seqDispRate, 0);
    Serial.print(" DD=");        Serial.print(seqDispDelayMs);
    Serial.print(" R=");         Serial.print(seqRetractVol, 1);
    Serial.print(" RF=");        Serial.print(seqRetractRate, 0);
    Serial.print(" RD=");        Serial.print(seqRetractDelayMs);
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

  // Triggered dispense — falling edge on TRIG_PIN
  if (triggerFired && triggerArmed && !estop) {
    triggerFired = false;
    if (trigDelayMs > 0) delay((unsigned long)trigDelayMs);

    // Use full sequence if stored, otherwise fall back to simple dispense
    if (seqStored && seqDispVol > 0) {
      executeSequence();
    } else if (storedDispenseVol > 0) {
      digitalWrite(DIR_PIN, HIGH);
      executeMoveUL(storedDispenseVol, storedDispenseRate);
    }
    Serial.println("ok");
  }
}
