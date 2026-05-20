// ═══════════════════════════════════════════════════════════════════
// HTS Resources — Syringe Pump Controller v2.9
// A4988 driver + 4× SG90 pinch valves, G-code style interface
//
// New in v2.9:
//   - D<n>  — number of dispense events (default 1)
//   - DT<ms> — delay between dispense events in ms (default 0)
//   - Total volume E is divided equally across D events
//   - Enables timed multi-drop dispensing during blade travel
//   - Example: E30 D3 DT500 → 3× 10µL dispenses, 500ms apart
//   - DD dwell applies after the LAST dispense event only
//
// New in v2.8:
//   - 4× SG90 pinch valves on D10–D13
//   - MOSFET power control for SG90s on A0
//   - Mask-controlled valve open/close (4-digit binary e.g. 1111)
//   - PO / PC tokens in DISPENSE/SDISPENSE sequence
//   - VALVEOPEN  MASK=1111  — open selected valves immediately
//   - VALVECLOSE MASK=1111  — close selected valves immediately
//   - VALVEPWR ON/OFF       — manual MOSFET control
//   - Valve settle time 200ms (SG90 90° travel ~150ms at 5V)
//
// Pinch valve:
//   Open  = 0°   (flow passes through)
//   Close = 90°  (pinch blocks flow)
//   Based on LibreValve MG90S design (printables.com/model/450132)
//
// Dispense sequence with pinch valves:
//   DISPENSE  MASK=1111 P20 PF10000 PD1000 PO E100 F14000 DD500 PC R60 RF8000 RD100
//   SDISPENSE MASK=1111 P20 PF10000 PD1000 PO E100 F14000 DD500 PC R60 RF8000 RD100
//
//   Sequence: prime → PO (open) → dispense → PC (close) → retract
//   PO and PC tokens can appear anywhere in the parameter string
//   PO before prime:  MASK=1111 PO P20 ...  (open first, then prime)
//   PO after prime:   MASK=1111 P20 ... PO E100 ... (prime first, then open)
//
// Pinch valve MASK:
//   1111 = all 4 valves
//   1010 = valves 1 and 3 only
//   0001 = valve 4 only
//
// All commands:
//   DISPENSE  [MASK=1111] P.. PF.. PD.. [PO] E.. F.. DD.. [D..] [DT..] [PC] R.. RF.. RD..
//   SDISPENSE [MASK=1111] P.. PF.. PD.. [PO] E.. F.. DD.. [D..] [DT..] [PC] R.. RF.. RD..
//   VALVEOPEN  MASK=1111  — open selected valves immediately
//   VALVECLOSE MASK=1111  — close selected valves immediately
//   VALVEPWR ON|OFF       — manual MOSFET power control
//   TRIGGERON / TRIGGEROFF
//   STORE E<vol> F<rate>
//   D1 E<vol> F<rate>
//   A1 E<vol> F<rate>
//   TD <ms>
//   SA <steps>
//   SETRD <value>
//   GETRD
//   MOTORON / MOTOROFF
//   P114
//   P0 / P999
//
// Wiring:
//   STEP -> D4    DIR  -> D3    EN   -> D5
//   TRIG -> D7    VDD  -> 5V   VMOT -> 12V
//   MS1  -> 5V    MS2  -> 5V   (1/16 microstepping, hardwired)
//   RST  -> 5V    SLP  -> 5V   (physical jumper required on A4988)
//   10uF cap across VMOT and GND
//   Vref = 0.05V (~125mA) for syringe pump load
//
//   Pinch valve servos (SG90):
//   D10 → valve 1    D11 → valve 2
//   D12 → valve 3    D13 → valve 4
//   A0  → MOSFET gate (100Ω series resistor)
//   MOSFET drain → all 4 SG90 red wires → 5V supply
//   MOSFET source → GND
// ═══════════════════════════════════════════════════════════════════

#include <Servo.h>

// ── Stepper pins ──────────────────────────────────────────────────
#define STEP_PIN   4
#define DIR_PIN    3
#define EN_PIN     5
#define TRIG_PIN   7

// ── Pinch valve servo pins ────────────────────────────────────────
#define VALVE1_PIN  10
#define VALVE2_PIN  11
#define VALVE3_PIN  12
#define VALVE4_PIN  13
#define VALVE_PWR   A0   // MOSFET gate — controls 5V to all SG90s

// ── Pinch valve angles ────────────────────────────────────────────
#define VALVE_OPEN    0   // flow passes through
#define VALVE_CLOSED  180  // pinch blocks flow
#define VALVE_SETTLE  300 // ms — SG90 90° travel ~150ms, 200ms safe

Servo pinchValve[4];
const int valvePins[4] = { VALVE1_PIN, VALVE2_PIN, VALVE3_PIN, VALVE4_PIN };

// ── Stepper calibration ───────────────────────────────────────────
const float STEPS_PER_REV = 200.0;
const float MICROSTEPS     = 16.0;
float rotationDist         = 86.0;

inline float stepsPerUL() {
  return (STEPS_PER_REV * MICROSTEPS) / rotationDist;
}

// ── Acceleration ──────────────────────────────────────────────────
long accelSteps           = 500;
const long START_DELAY_US = 800;

// ── Simple dispense storage ───────────────────────────────────────
volatile bool triggerFired    = false;
bool          triggerArmed    = false;
float storedDispenseVol       = 0.0;
float storedDispenseRate      = 4000.0;
float trigDelayMs             = 50.0;

// ── Sequence storage ──────────────────────────────────────────────
bool  seqStored         = false;
float seqPrimeVol       = 0.0;
float seqPrimeRate      = 10000.0;
long  seqPrimeDelayMs   = 1000;
bool  seqPinchOpenAfterPrime  = false;  // PO token position
bool  seqPinchOpenBeforePrime = false;
float seqDispVol        = 0.0;
float seqDispRate       = 14000.0;
long  seqDispDelayMs    = 500;
bool  seqPinchClose     = false;        // PC token present
int   seqDispCount      = 1;            // D<n>  — number of dispense events
long  seqDispIntervalMs = 0;            // DT<ms> — delay between dispense events
float seqRetractVol     = 0.0;
float seqRetractRate    = 6000.0;
long  seqRetractDelayMs = 100;
char  seqMask[5]        = "1111";       // which valves to control

#define INPUT_BUF_SIZE 96
char inputBuffer[INPUT_BUF_SIZE];
int inputIdx = 0;
bool   estop       = false;

// ═══════════════════════════════════════════════════════════════════
// VALVE FUNCTIONS
// ═══════════════════════════════════════════════════════════════════

void valvePowerOn() {
  analogWrite(VALVE_PWR, 255);
  delay(50);  // let 5V rail stabilize before moving
}

void valvePowerOff() {
  delay(VALVE_SETTLE);  // ensure servo finishes move
  analogWrite(VALVE_PWR, 0);
}

// Move selected valves to angle, wait for settle, then cut power
void moveValves(const char* mask, int angle) {
  valvePowerOn();
  for (int i = 0; i < 4; i++) {
    if (mask[i] == '1') {
      pinchValve[i].write(angle);
    }
  }
  delay(VALVE_SETTLE);
  // Note: power stays on — caller decides when to cut
  // Use valvePowerOff() explicitly after moveValves() if needed
}

void openValves(const char* mask) {
  valvePowerOn();
  for (int i = 0; i < 4; i++) {
    if (mask[i] == '1') pinchValve[i].write(VALVE_OPEN);
  }
  delay(VALVE_SETTLE);
}

void closeValves(const char* mask) {
  for (int i = 0; i < 4; i++) {
    if (mask[i] == '1') pinchValve[i].write(VALVE_CLOSED);
  }
  delay(VALVE_SETTLE);
  valvePowerOff();
}

// ═══════════════════════════════════════════════════════════════════
// STEPPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════

long halfStepDelayUs(float F_mmPerMin) {
  float mmPerSec    = F_mmPerMin / 60.0;
  float stepsPerSec = stepsPerUL() * mmPerSec;
  long  halfDelay   = (long)(500000.0 / stepsPerSec);
  return max(halfDelay, 2L);
}

void triggerISR() {
  if (triggerArmed && !estop) triggerFired = true;
}

void executeMoveUL(float volumeUL, float F) {
  if (estop) { Serial.println(F("error:estop")); return; }
  if (volumeUL <= 0) return;

  long totalSteps  = (long)(volumeUL * stepsPerUL());
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

// ═══════════════════════════════════════════════════════════════════
// SEQUENCE EXECUTION
// ═══════════════════════════════════════════════════════════════════

void executeSequence() {
  if (estop) { Serial.println(F("error:estop")); return; }

  // Phase 1: Optional PO before prime
  if (seqPinchOpenBeforePrime) {
    openValves(seqMask);
    // power stays on — valve open for all subsequent phases
  }

  // Phase 2: Prime
  if (seqPrimeVol > 0) {
    digitalWrite(DIR_PIN, HIGH);
    executeMoveUL(seqPrimeVol, seqPrimeRate);
    if (seqPrimeDelayMs > 0) delay((unsigned long)seqPrimeDelayMs);
  }

  // Phase 3: Optional PO after prime
  if (seqPinchOpenAfterPrime) {
    openValves(seqMask);
    // power stays on for dispense phase
  }

  // Phase 4: Main dispense — split across D events
  if (seqDispVol > 0) {
    float volPerEvent = seqDispVol / (float)seqDispCount;
    for (int d = 0; d < seqDispCount; d++) {
      if (estop) break;
      digitalWrite(DIR_PIN, HIGH);
      executeMoveUL(volPerEvent, seqDispRate);
      // DT delay between events — skip after last event
      if (d < seqDispCount - 1 && seqDispIntervalMs > 0) {
        delay((unsigned long)seqDispIntervalMs);
      }
    }
    // DD dwell after final dispense event
    if (seqDispDelayMs > 0) delay((unsigned long)seqDispDelayMs);
  }

  // Phase 5: Optional PC after dispense
  if (seqPinchClose) {
    closeValves(seqMask);  // closes and cuts power
  } else if (seqPinchOpenBeforePrime || seqPinchOpenAfterPrime) {
    // PO was used but no PC — cut power anyway
    valvePowerOff();
  }

  // Phase 6: Retract
  if (seqRetractVol > 0) {
    digitalWrite(DIR_PIN, LOW);
    executeMoveUL(seqRetractVol, seqRetractRate);
    if (seqRetractDelayMs > 0) delay((unsigned long)seqRetractDelayMs);
    digitalWrite(DIR_PIN, HIGH);
  }
}

// ═══════════════════════════════════════════════════════════════════
// SEQUENCE PARAMETER PARSER
// ═══════════════════════════════════════════════════════════════════

void parseSequenceParams(String lu) {
  // Reset sequence flags
  seqPinchOpenBeforePrime = false;
  seqPinchOpenAfterPrime  = false;
  seqPinchClose           = false;
  seqPrimeVol             = 0.0;
  seqDispVol              = 0.0;
  seqRetractVol           = 0.0;
  seqDispCount            = 1;      // default: single dispense event
  seqDispIntervalMs       = 0;      // default: no inter-event delay
  strcpy(seqMask, "1111");

  // MASK= parameter
  int mIdx = lu.indexOf(" MASK=");
  if (mIdx >= 0) {
    String maskStr = lu.substring(mIdx + 6, mIdx + 10);
    maskStr.toCharArray(seqMask, 5);
  }

  // Determine PO position relative to P (prime) and E (dispense)
  int poIdx = lu.indexOf(" PO");
  int pIdx  = lu.indexOf(" P");
  // Make sure pIdx is the P<vol> token not PO, PF, PD
  while (pIdx >= 0) {
    char next = (pIdx + 2 < lu.length()) ? lu.charAt(pIdx + 2) : ' ';
    if (next != 'O' && next != 'F' && next != 'D') break;
    pIdx = lu.indexOf(" P", pIdx + 1);
  }
  int eIdx2 = lu.indexOf(" E");

  if (poIdx >= 0) {
    // PO is before prime P token OR before E token (no prime case)
    if (pIdx < 0 || poIdx < pIdx) {
      seqPinchOpenBeforePrime = true;
    } else {
      seqPinchOpenAfterPrime = true;
    }
  }

  // PC token
  if (lu.indexOf(" PC") >= 0) seqPinchClose = true;

  // P<vol> — prime volume
  int idx = lu.indexOf(" P");
  while (idx >= 0) {
    char next = (idx + 2 < lu.length()) ? lu.charAt(idx + 2) : ' ';
    if (next != 'F' && next != 'D' && next != 'O' && next != 'C') {
      seqPrimeVol = lu.substring(idx + 2).toFloat();
      break;
    }
    idx = lu.indexOf(" P", idx + 1);
  }

  // PF<rate>
  idx = lu.indexOf(" PF");
  if (idx >= 0) seqPrimeRate = lu.substring(idx + 3).toFloat();

  // PD<ms>
  idx = lu.indexOf(" PD");
  if (idx >= 0) seqPrimeDelayMs = lu.substring(idx + 3).toInt();

  // E<vol> — main dispense volume
  idx = lu.indexOf(" E");
  if (idx >= 0) seqDispVol = lu.substring(idx + 2).toFloat();

  // F<rate> — main dispense feedrate (not PF or RF)
  for (int i = 1; i < lu.length() - 1; i++) {
    if (lu.charAt(i) == ' ' && lu.charAt(i + 1) == 'F') {
      char prev = lu.charAt(i - 1);
      if (prev != 'P' && prev != 'R') {
        seqDispRate = lu.substring(i + 2).toFloat();
        break;
      }
    }
  }

  // DD<ms>
  idx = lu.indexOf(" DD");
  if (idx >= 0) seqDispDelayMs = lu.substring(idx + 3).toInt();

  // D<n> — number of dispense events (must not match DD or DT)
  idx = lu.indexOf(" D");
  while (idx >= 0) {
    char next = (idx + 2 < lu.length()) ? lu.charAt(idx + 2) : ' ';
    if (next != 'D' && next != 'T') {
      int val = lu.substring(idx + 2).toInt();
      if (val > 0) seqDispCount = val;
      break;
    }
    idx = lu.indexOf(" D", idx + 1);
  }

  // DT<ms> — inter-event delay
  idx = lu.indexOf(" DT");
  if (idx >= 0) seqDispIntervalMs = lu.substring(idx + 3).toInt();

  // R<vol> — retract volume (not RF or RD)
  idx = lu.indexOf(" R");
  while (idx >= 0) {
    char next = (idx + 2 < lu.length()) ? lu.charAt(idx + 2) : ' ';
    if (next != 'F' && next != 'D') {
      seqRetractVol = lu.substring(idx + 2).toFloat();
      break;
    }
    idx = lu.indexOf(" R", idx + 1);
  }

  // RF<rate>
  idx = lu.indexOf(" RF");
  if (idx >= 0) seqRetractRate = lu.substring(idx + 3).toFloat();

  // RD<ms>
  idx = lu.indexOf(" RD");
  if (idx >= 0) seqRetractDelayMs = lu.substring(idx + 3).toInt();

  seqStored = true;
}

// ═══════════════════════════════════════════════════════════════════
// SETUP
// ═══════════════════════════════════════════════════════════════════

void setup() {
  // Pinch valve MOSFET
  pinMode(VALVE_PWR, OUTPUT);
  analogWrite(VALVE_PWR, 0);
  // Stepper
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN,  OUTPUT);
  pinMode(EN_PIN,   OUTPUT);
  pinMode(TRIG_PIN, INPUT_PULLUP);
  digitalWrite(EN_PIN,   HIGH);
  digitalWrite(DIR_PIN,  HIGH);
  digitalWrite(STEP_PIN, LOW);


  // Attach pinch valve servos — start closed
  for (int i = 0; i < 4; i++) {
    pinchValve[i].attach(valvePins[i]);
    pinchValve[i].write(VALVE_CLOSED);
  }
  // Brief power pulse to set initial closed position
  digitalWrite(VALVE_PWR, HIGH);
  delay(300);
  digitalWrite(VALVE_PWR, LOW);

  attachInterrupt(digitalPinToInterrupt(TRIG_PIN), triggerISR, FALLING);

  Serial.begin(115200);
  Serial.print(F("ok rd="));
  Serial.print(rotationDist, 3);
  Serial.print(F(" steps_ul="));
  Serial.println(stepsPerUL(), 3);
}

// ═══════════════════════════════════════════════════════════════════
// COMMAND PARSER
// ═══════════════════════════════════════════════════════════════════

void parseCommand(String line) {
  line.trim();
  if (line.length() == 0) { Serial.println(F("ok")); return; }

  String lu = line;
  lu.toUpperCase();

  String cmd = "";
  int i = 0;
  while (i < lu.length() && lu[i] != ' ') cmd += lu[i++];

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

  // ── DISPENSE — execute sequence immediately ────────────────────
  if (cmd == "DISPENSE") {
    parseSequenceParams(lu);
    executeSequence();
    Serial.println(F("ok"));
  }

  // ── SDISPENSE — store sequence for trigger ─────────────────────
  else if (cmd == "SDISPENSE") {
    parseSequenceParams(lu);
    Serial.println(F("ok"));
  }

  // ── VALVEOPEN MASK=1111 — open selected valves immediately ─────
  else if (cmd == "VALVEOPEN") {
    char mask[5] = "1111";
    int mIdx = lu.indexOf(" MASK=");
    if (mIdx >= 0) strncpy(mask, lu.c_str() + mIdx + 6, 4); mask[4] = '\0';
    openValves(mask);
    valvePowerOff();
    Serial.println(F("ok"));
  }

  // ── VALVECLOSE MASK=1111 — close selected valves immediately ────
  else if (cmd == "VALVECLOSE") {
    char mask[5] = "1111";
    int mIdx = lu.indexOf(" MASK=");
    if (mIdx >= 0) strncpy(mask, lu.c_str() + mIdx + 6, 4); mask[4] = '\0';
    valvePowerOn();
    closeValves(mask);
    Serial.println(F("ok"));
  }

  // ── VALVEPWR ON|OFF — manual MOSFET control ───────────────────
  else if (cmd == "VALVEPWR") {
    if (lu.indexOf("ON") > 0) {
      digitalWrite(VALVE_PWR, HIGH);
      Serial.println(F("ok"));
    } else if (lu.indexOf("OFF") > 0) {
      digitalWrite(VALVE_PWR, LOW);
      Serial.println(F("ok"));
    } else {
      Serial.println(F("error:use VALVEPWR ON or VALVEPWR OFF"));
    }
  }

  // ── SETRD <value> ─────────────────────────────────────────────
  else if (cmd == "SETRD") {
    float val = 0.0;
    int spaceIdx = lu.indexOf(' ');
    if (spaceIdx >= 0) val = lu.substring(spaceIdx + 1).toFloat();
    if (val <= 0) { Serial.println(F("error:SETRD value must be >0")); return; }
    rotationDist = val;
    Serial.print(F("ok rd="));
    Serial.print(rotationDist, 3);
    Serial.print(F(" steps_ul="));
    Serial.println(stepsPerUL(), 3);
  }

  // ── GETRD ─────────────────────────────────────────────────────
  else if (cmd == "GETRD") {
    Serial.print(F("ok rd="));
    Serial.print(rotationDist, 3);
    Serial.print(F(" steps_ul="));
    Serial.println(stepsPerUL(), 3);
  }

  // ── TRIGGERON ─────────────────────────────────────────────────
  else if (cmd == "TRIGGERON") {
    triggerArmed = true;
    triggerFired = false;
    Serial.println(F("ok"));
  }

  // ── TRIGGEROFF ────────────────────────────────────────────────
  else if (cmd == "TRIGGEROFF") {
    triggerArmed = false;
    triggerFired = false;
    Serial.println(F("ok"));
  }

  // ── MOTORON ───────────────────────────────────────────────────
  else if (cmd == "MOTORON") {
    digitalWrite(EN_PIN, LOW);
    Serial.println(F("ok"));
  }

  // ── MOTOROFF ──────────────────────────────────────────────────
  else if (cmd == "MOTOROFF") {
    digitalWrite(EN_PIN, HIGH);
    Serial.println(F("ok"));
  }

  // ── STORE E<vol> F<rate> ──────────────────────────────────────
  else if (cmd == "STORE") {
    if (!hasE) { Serial.println(F("error:E required")); return; }
    storedDispenseVol  = E;
    storedDispenseRate = F;
    Serial.println(F("ok"));
  }

  // ── A1 — Aspirate ─────────────────────────────────────────────
  else if (cmd == "A1" || cmd == "A") {
    if (!hasE) { Serial.println(F("error:E required")); return; }
    digitalWrite(DIR_PIN, LOW);
    executeMoveUL(E, F);
    Serial.println(F("ok"));
  }

  // ── D1 — Dispense ─────────────────────────────────────────────
  else if (cmd == "D1" || cmd == "D") {
    if (!hasE) { Serial.println(F("error:E required")); return; }
    if (triggerArmed) {
      storedDispenseVol  = E;
      storedDispenseRate = F;
      Serial.println(F("ok"));
    } else {
      digitalWrite(DIR_PIN, HIGH);
      executeMoveUL(E, F);
      Serial.println(F("ok"));
    }
  }

  // ── T1 F<rate> ────────────────────────────────────────────────
  else if (cmd == "T1") {
    storedDispenseRate = F;
    Serial.println(F("ok"));
  }

  // ── TD <ms> ───────────────────────────────────────────────────
  else if (cmd == "TD") {
    float val = 0.0;
    if (hasE) { val = E; }
    else {
      int spaceIdx = lu.indexOf(' ');
      if (spaceIdx >= 0) val = lu.substring(spaceIdx + 1).toFloat();
    }
    trigDelayMs = max(val, 0.0f);
    Serial.println(F("ok"));
  }

  // ── SA <steps> ────────────────────────────────────────────────
  else if (cmd == "SA") {
    long val = 0;
    int spaceIdx = lu.indexOf(' ');
    if (spaceIdx >= 0) val = lu.substring(spaceIdx + 1).toInt();
    accelSteps = max(val, 0L);
    Serial.println(F("ok"));
  }

  // ── P114 — Report full state ──────────────────────────────────
  else if (cmd == "P114") {
    Serial.print(F("vol="));        Serial.print(storedDispenseVol, 2);
    Serial.print(F(" rate="));      Serial.print(storedDispenseRate, 0);
    Serial.print(F(" delay="));     Serial.print(trigDelayMs, 0);
    Serial.print(F(" armed="));     Serial.print(triggerArmed ? "1" : "0");
    Serial.print(F(" motor="));     Serial.print(digitalRead(EN_PIN) == LOW ? "1" : "0");
    Serial.print(F(" dir="));       Serial.print(digitalRead(DIR_PIN) == HIGH ? "disp" : "asp");
    Serial.print(F(" estop="));     Serial.print(estop ? "1" : "0");
    Serial.print(F(" accel="));     Serial.print(accelSteps);
    Serial.print(F(" rd="));        Serial.print(rotationDist, 3);
    Serial.print(F(" steps_ul="));  Serial.print(stepsPerUL(), 3);
    Serial.print(F(" seq="));       Serial.print(seqStored ? "1" : "0");
    Serial.print(F(" mask="));      Serial.print(seqMask);
    Serial.print(F(" PO="));        Serial.print(seqPinchOpenAfterPrime ? "after" : (seqPinchOpenBeforePrime ? "before" : "none"));
    Serial.print(F(" PC="));        Serial.print(seqPinchClose ? "1" : "0");
    Serial.print(F(" P="));         Serial.print(seqPrimeVol, 1);
    Serial.print(F(" PF="));        Serial.print(seqPrimeRate, 0);
    Serial.print(F(" PD="));        Serial.print(seqPrimeDelayMs);
    Serial.print(F(" E="));         Serial.print(seqDispVol, 1);
    Serial.print(F(" F="));         Serial.print(seqDispRate, 0);
    Serial.print(F(" DD="));        Serial.print(seqDispDelayMs);
    Serial.print(F(" D="));         Serial.print(seqDispCount);
    Serial.print(F(" DT="));        Serial.print(seqDispIntervalMs);
    Serial.print(F(" R="));         Serial.print(seqRetractVol, 1);
    Serial.print(F(" RF="));        Serial.print(seqRetractRate, 0);
    Serial.print(F(" RD="));        Serial.print(seqRetractDelayMs);
    Serial.println(F(" ok"));
  }

  // ── HELP — print command reference ───────────────────────────
  else if (cmd == "HELP" || cmd == "?") {
    Serial.println(F("=== HTS Syringe Pump v2.9 Command Reference ==="));
    Serial.println(F(""));
    Serial.println(F("-- DISPENSE SEQUENCE --"));
    Serial.println(F("DISPENSE  [MASK=1111] [PO] [P<uL> PF<rate> PD<ms>] [PO] E<uL> F<rate> DD<ms> [D<n>] [DT<ms>] [PC] [R<uL> RF<rate> RD<ms>]"));
    Serial.println(F("SDISPENSE [MASK=1111] [PO] [P<uL> PF<rate> PD<ms>] [PO] E<uL> F<rate> DD<ms> [D<n>] [DT<ms>] [PC] [R<uL> RF<rate> RD<ms>]"));
    Serial.println(F("  P=prime vol  PF=prime rate  PD=prime delay ms"));
    Serial.println(F("  E=total disp vol  F=disp rate  DD=post-dispense delay ms"));
    Serial.println(F("  D=number of dispense events (default 1)"));
    Serial.println(F("  DT=delay between dispense events ms (default 0)"));
    Serial.println(F("  E is divided equally across D events"));
    Serial.println(F("  DD dwell applies after the LAST event only"));
    Serial.println(F("  R=retract vol RF=retract rate RD=retract delay ms"));
    Serial.println(F("  PO=open pinch valves  PC=close pinch valves"));
    Serial.println(F("  MASK=1111 (all) 1010 (1&3) 0001 (4 only)"));
    Serial.println(F("Example single: SDISPENSE MASK=1111 PD20 E30 F500 DD100"));
    Serial.println(F("Example multi:  SDISPENSE MASK=1111 PD20 E30 F500 DD100 D3 DT500"));
    Serial.println(F(""));
    Serial.println(F("-- PINCH VALVES --"));
    Serial.println(F("VALVEOPEN  MASK=1111  open selected valves (0=open 90=closed)"));
    Serial.println(F("VALVECLOSE MASK=1111  close selected valves"));
    Serial.println(F("VALVEPWR ON|OFF       manual MOSFET power control"));
    Serial.println(F(""));
    Serial.println(F("-- SIMPLE DISPENSE --"));
    Serial.println(F("D1 E<uL> F<rate>      dispense immediately (or store if armed)"));
    Serial.println(F("A1 E<uL> F<rate>      aspirate immediately"));
    Serial.println(F("STORE E<uL> F<rate>   store without executing"));
    Serial.println(F(""));
    Serial.println(F("-- TRIGGER --"));
    Serial.println(F("TRIGGERON             arm trigger on D7 falling edge"));
    Serial.println(F("TRIGGEROFF            disarm trigger"));
    Serial.println(F("TD <ms>               set trigger delay ms (default 50)"));
    Serial.println(F(""));
    Serial.println(F("-- MOTOR --"));
    Serial.println(F("MOTORON               enable driver (current flows)"));
    Serial.println(F("MOTOROFF              disable driver (no current no heat)"));
    Serial.println(F("SA <steps>            set accel ramp steps (0=off default=500)"));
    Serial.println(F(""));
    Serial.println(F("-- CALIBRATION --"));
    Serial.println(F("SETRD <value>         set rotation distance (default 86)"));
    Serial.println(F("GETRD                 report rotation distance and steps/uL"));
    Serial.println(F("  Formula: new_RD = current_RD x (actual_uL / commanded_uL)"));
    Serial.println(F(""));
    Serial.println(F("-- STATUS --"));
    Serial.println(F("P114                  full state report (single line)"));
    Serial.println(F("P0                    emergency stop"));
    Serial.println(F("P999                  clear estop"));
    Serial.println(F("HELP or ?             this menu"));
    Serial.println(F("ok"));
  }

  // ── P0 — Emergency stop ───────────────────────────────────────
  else if (cmd == "P0") {
    estop        = true;
    triggerArmed = false;
    triggerFired = false;
    digitalWrite(EN_PIN, HIGH);
    digitalWrite(VALVE_PWR, LOW);  // cut valve power too
    Serial.println(F("estop"));
  }

  // ── P999 — Clear estop ────────────────────────────────────────
  else if (cmd == "P999") {
    estop = false;
    digitalWrite(EN_PIN, LOW);
    Serial.println(F("ok"));
  }

  else {
    Serial.println(F("ok"));
  }
}

// ═══════════════════════════════════════════════════════════════════
// LOOP
// ═══════════════════════════════════════════════════════════════════

void loop() {
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n' || c == '\r') {
      if (inputIdx > 0) {
        inputBuffer[inputIdx] = '\0';
        parseCommand(String(inputBuffer));
        inputIdx = 0;
        inputBuffer[0] = '\0';
      }
    } else {
      if (inputIdx < INPUT_BUF_SIZE - 1) {
        inputBuffer[inputIdx++] = c;
      }
    }
  }

  if (triggerFired && triggerArmed && !estop) {
    triggerFired = false;
    if (trigDelayMs > 0) delay((unsigned long)trigDelayMs);

    if (seqStored && seqDispVol > 0) {
      executeSequence();
    } else if (storedDispenseVol > 0) {
      digitalWrite(DIR_PIN, HIGH);
      executeMoveUL(storedDispenseVol, storedDispenseRate);
    }
    Serial.println(F("ok"));
  }
}
