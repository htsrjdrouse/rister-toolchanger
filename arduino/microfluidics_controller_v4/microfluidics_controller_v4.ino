// ═══════════════════════════════════════════════════════════════════
// HTS Resources — Microfluidics Controller v4
// Arduino Micro
//
// Changes from v3:
//   - setvalves_angle no longer manages 5V internally
//   - 5V controlled explicitly via turnon5v / turnoff5v from Klipper
//   - All selected servos fire simultaneously (no stagger delay)
//   - settle_ms parameter retained (default 150ms, min 50ms)
//   - keep5v parameter removed — 5V managed by caller
//
// Valve switch timing from Klipper:
//   SEND_ARDUINO COMMAND="turnon5v"          → instant
//   G4 P50                                   → 50ms stabilize
//   SEND_ARDUINO COMMAND="setvalves_angle..." → 150ms settle
//   G4 P150                                  → wait for settle
//   SEND_ARDUINO COMMAND="turnoff5v"         → instant
//   Total: ~350ms
//
// Commands:
//   washon / washoff
//   dryon / dryoff
//   pcvon / pcvoff
//   manpcv / feedbackpcv
//   turnon5v / turnoff5v
//   setwashval <0-255>
//   setdryval <0-255>
//   setpcvval <0-255>
//   linearact <angle>
//   setvalves_angle <mask> <a> <b> <c> <d> [settle_ms]
//     mask      — 4 digit binary e.g. 1111 (1=move, 0=skip)
//     a b c d   — angles for servos 1-4
//     settle_ms — optional settle time ms (default 150, min 50)
//   readpin
//   info
//
// Valve angles (from variables.cfg):
//   bypass=35  output=90  input=0  flush=180
//
// Example commands:
//   turnon5v
//   setvalves_angle 1111 90 90 90 90        → output
//   setvalves_angle 1111 35 35 35 35        → bypass
//   setvalves_angle 1111 0 0 0 0            → input
//   setvalves_angle 1111 180 180 180 180    → flush
//   turnoff5v
// ═══════════════════════════════════════════════════════════════════

#include <Servo.h>
#include <Wire.h>
#include <SoftwareSerial.h>

Servo myservo1;   // valve 1 — D11
Servo myservo2;   // valve 2 — D13
Servo myservo3;   // valve 3 — D12
Servo myservo4;   // valve 4 — D8
Servo myservo5;   // linear actuator — D3

const int sensorPin   = A2;
#define THERMISTOR_PIN A0

int valveservo1 = 11;
int valveservo2 = 13;
int valveservo3 = 12;
int valveservo4 = 8;
int valveservo5 = 3;
int washpin     = 10;
int drypin      = 9;
int pcvpin      = 6;
int heatpin     = 5;
int turnon5vpin = 5;
int tempsensor  = A0;

int washval = 255;
int dryval  = 255;
int pcvval  = 255;

int fillflag = 1;

#define CMD_BUF_SIZE 80
char cmdBuf[CMD_BUF_SIZE];
int  cmdIdx = 0;

void setup() {
  Serial.begin(115200);

  myservo1.attach(valveservo1, 500, 2500);
  myservo2.attach(valveservo2, 500, 2500);
  myservo3.attach(valveservo3, 500, 2500);
  myservo4.attach(valveservo4, 500, 2500);
  myservo5.attach(valveservo5, 500, 2500);

  analogWrite(pcvpin,      0);
  analogWrite(washpin,     0);
  analogWrite(drypin,      0);
  analogWrite(heatpin,     0);
  analogWrite(turnon5vpin, 0);

  pinMode(sensorPin, INPUT_PULLUP);

  Serial.println("ok");
}

void loop() {
  if (fillflag == 0) {
    if (digitalRead(sensorPin) == LOW) {
      analogWrite(pcvpin, pcvval);
    } else {
      analogWrite(pcvpin, 0);
    }
  }

  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n' || c == '\r') {
      if (cmdIdx > 0) {
        cmdBuf[cmdIdx] = '\0';
        parseCommand(cmdBuf);
        cmdIdx = 0;
        cmdBuf[0] = '\0';
      }
    } else {
      if (cmdIdx < CMD_BUF_SIZE - 1) {
        cmdBuf[cmdIdx++] = c;
      }
    }
  }

  delay(30);
}

void parseCommand(char* com) {

  if (strcasecmp(com, "washon") == 0) {
    analogWrite(washpin, washval);
    delay(100);
    Serial.println("ok");
  }

  else if (strcasecmp(com, "washoff") == 0) {
    analogWrite(washpin, 0);
    delay(100);
    Serial.println("ok");
  }

  else if (strcasecmp(com, "dryon") == 0) {
    analogWrite(drypin, dryval);
    delay(100);
    Serial.println("ok");
  }

  else if (strcasecmp(com, "dryoff") == 0) {
    analogWrite(drypin, 0);
    delay(100);
    Serial.println("ok");
  }

  else if (strcasecmp(com, "pcvon") == 0) {
    if (fillflag == 1) analogWrite(pcvpin, pcvval);
    Serial.println("ok");
  }

  else if (strcasecmp(com, "pcvoff") == 0) {
    if (fillflag == 1) analogWrite(pcvpin, 0);
    Serial.println("ok");
  }

  else if (strcasecmp(com, "manpcv") == 0) {
    fillflag = 1;
    analogWrite(pcvpin, 0);
    Serial.println("ok");
  }

  else if (strcasecmp(com, "feedbackpcv") == 0) {
    fillflag = 0;
    Serial.println("ok");
  }

  // ── turnon5v — power up servo rail ────────────────────────────
  else if (strcasecmp(com, "turnon5v") == 0) {
    analogWrite(turnon5vpin, 255);
    Serial.println("ok");
  }

  // ── turnoff5v — power down servo rail ─────────────────────────
  else if (strcasecmp(com, "turnoff5v") == 0) {
    analogWrite(turnon5vpin, 0);
    Serial.println("ok");
  }

  else if (strcasecmp(com, "readpin") == 0) {
    Serial.println(digitalRead(sensorPin));
    Serial.println("ok");
  }

  else if (strcasecmp(com, "info") == 0) {
    Serial.println("wash_dry_pcv_electrocaloric_kill_stepper_valve");
    Serial.println("ok");
  }

  else if (strncasecmp(com, "setwashval", 10) == 0) {
    washval = atoi(com + 11);
    Serial.print("washval: "); Serial.println(washval);
    Serial.println("ok");
  }

  else if (strncasecmp(com, "setdryval", 9) == 0) {
    dryval = atoi(com + 10);
    Serial.print("dryval: "); Serial.println(dryval);
    Serial.println("ok");
  }

  else if (strncasecmp(com, "setpcvval", 9) == 0) {
    pcvval = atoi(com + 10);
    Serial.print("pcvval: "); Serial.println(pcvval);
    Serial.println("ok");
  }

  // ── linearact <angle> — servo5 linear actuator ────────────────
  // 5V managed internally since linearact is always a complete move
  else if (strncasecmp(com, "linearact", 9) == 0) {
    int angle = atoi(com + 10);
    analogWrite(turnon5vpin, 255);
    delay(100);
    myservo5.write(angle);
    delay(300);
    Serial.print("linearact: "); Serial.println(angle);
    Serial.println("ok");
    analogWrite(turnon5vpin, 0);
  }

  // ── setvalves_angle <mask> <a> <b> <c> <d> [settle_ms] ────────
  // 5V must be turned on BEFORE calling this command
  // 5V must be turned off AFTER this command completes
  // All selected servos fire simultaneously for fastest switching
  // settle_ms default 150ms — tuned for 55° bypass(35)↔output(90)
  // settle_ms minimum 50ms safety floor
  else if (strncasecmp(com, "setvalves_angle", 15) == 0) {
    char tmp[CMD_BUF_SIZE];
    strncpy(tmp, com, CMD_BUF_SIZE - 1);
    tmp[CMD_BUF_SIZE - 1] = '\0';

    char* tok = strtok(tmp, " ");   // "setvalves_angle"
    tok = strtok(NULL, " ");        // mask

    char maskStr[5] = {0};
    if (tok) strncpy(maskStr, tok, 4);

    int angles[4] = {0, 0, 0, 0};
    for (int i = 0; i < 4; i++) {
      tok = strtok(NULL, " ");
      if (tok) angles[i] = atoi(tok);
    }

    // Optional settle_ms (default 150, minimum 50)
    int settle_ms = 150;
    tok = strtok(NULL, " ");
    if (tok) settle_ms = atoi(tok);
    if (settle_ms < 50) settle_ms = 50;

    // Fire all selected servos simultaneously
    if (maskStr[0] == '1') myservo1.write(angles[0]);
    if (maskStr[1] == '1') myservo2.write(angles[1]);
    if (maskStr[2] == '1') myservo3.write(angles[2]);
    if (maskStr[3] == '1') myservo4.write(angles[3]);

    delay(settle_ms);
    Serial.println("ok");
  }

  else {
    Serial.print("unknown: ");
    Serial.println(com);
    Serial.println("ok");
  }
}
