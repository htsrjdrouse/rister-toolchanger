// ═══════════════════════════════════════════════════════════════════
// HTS Resources — Microfluidics Controller
// Arduino Micro
//
// Changes from original:
//   - String replaced with char arrays (no heap fragmentation)
//   - Accepts both \n and \r as line terminator (works with screen)
//   - Added "ok" response to every command (Klipper compatibility)
//   - strtok used for setvalves_angle parsing (no substring allocations)
//   - parseCommand returns void (currpos was unused)
//   - setvalves_angle now turns on 5V before moving servos (fix)
//   - linearact now has 100ms delay after 5V on before moving servo
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
//   linearact <angle>         — servo5, linear actuator
//   setvalves_angle <mask> <a> <b> <c> <d>  — servos 1-4
//   readpin
//   info
// ═══════════════════════════════════════════════════════════════════

#include <Servo.h>
#include <Wire.h>
#include <SoftwareSerial.h>

Servo myservo1;   // valve 1
Servo myservo2;   // valve 2
Servo myservo3;   // valve 3
Servo myservo4;   // valve 4
Servo myservo5;   // linear actuator

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

// ── Fixed char buffer — no dynamic String allocation ──────────────
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
  // PCV feedback loop
  if (fillflag == 0) {
    if (digitalRead(sensorPin) == LOW) {
      analogWrite(pcvpin, pcvval);
    } else {
      analogWrite(pcvpin, 0);
    }
  }

  // Serial input — accepts \n or \r as terminator
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
      // silently drop chars if buffer full
    }
  }

  delay(30);
}

void parseCommand(char* com) {

  // ── washon ──────────────────────────────────────────────────────
  if (strcasecmp(com, "washon") == 0) {
    analogWrite(washpin, washval);
    delay(100);
    Serial.println("ok");
  }

  // ── washoff ─────────────────────────────────────────────────────
  else if (strcasecmp(com, "washoff") == 0) {
    analogWrite(washpin, 0);
    delay(100);
    Serial.println("ok");
  }

  // ── dryon ───────────────────────────────────────────────────────
  else if (strcasecmp(com, "dryon") == 0) {
    analogWrite(drypin, dryval);
    delay(100);
    Serial.println("ok");
  }

  // ── dryoff ──────────────────────────────────────────────────────
  else if (strcasecmp(com, "dryoff") == 0) {
    analogWrite(drypin, 0);
    delay(100);
    Serial.println("ok");
  }

  // ── pcvon ───────────────────────────────────────────────────────
  else if (strcasecmp(com, "pcvon") == 0) {
    if (fillflag == 1) analogWrite(pcvpin, pcvval);
    Serial.println("ok");
  }

  // ── pcvoff ──────────────────────────────────────────────────────
  else if (strcasecmp(com, "pcvoff") == 0) {
    if (fillflag == 1) analogWrite(pcvpin, 0);
    Serial.println("ok");
  }

  // ── manpcv ──────────────────────────────────────────────────────
  else if (strcasecmp(com, "manpcv") == 0) {
    fillflag = 1;
    analogWrite(pcvpin, 0);
    Serial.println("ok");
  }

  // ── feedbackpcv ─────────────────────────────────────────────────
  else if (strcasecmp(com, "feedbackpcv") == 0) {
    fillflag = 0;
    Serial.println("ok");
  }

  // ── turnon5v ────────────────────────────────────────────────────
  else if (strcasecmp(com, "turnon5v") == 0) {
    analogWrite(turnon5vpin, 255);
    Serial.println("ok");
  }

  // ── turnoff5v ───────────────────────────────────────────────────
  else if (strcasecmp(com, "turnoff5v") == 0) {
    analogWrite(turnon5vpin, 0);
    Serial.println("ok");
  }

  // ── readpin ─────────────────────────────────────────────────────
  else if (strcasecmp(com, "readpin") == 0) {
    Serial.println(digitalRead(sensorPin));
    Serial.println("ok");
  }

  // ── info ────────────────────────────────────────────────────────
  else if (strcasecmp(com, "info") == 0) {
    Serial.println("wash_dry_pcv_electrocaloric_kill_stepper_valve");
    Serial.println("ok");
  }

  // ── setwashval <0-255> ──────────────────────────────────────────
  else if (strncasecmp(com, "setwashval", 10) == 0) {
    washval = atoi(com + 11);
    Serial.print("washval: ");
    Serial.println(washval);
    Serial.println("ok");
  }

  // ── setdryval <0-255> ───────────────────────────────────────────
  else if (strncasecmp(com, "setdryval", 9) == 0) {
    dryval = atoi(com + 10);
    Serial.print("dryval: ");
    Serial.println(dryval);
    Serial.println("ok");
  }

  // ── setpcvval <0-255> ───────────────────────────────────────────
  else if (strncasecmp(com, "setpcvval", 9) == 0) {
    pcvval = atoi(com + 10);
    Serial.print("pcvval: ");
    Serial.println(pcvval);
    Serial.println("ok");
  }

  // ── linearact <angle> ───────────────────────────────────────────
  // servo5 — linear actuator
  else if (strncasecmp(com, "linearact", 9) == 0) {
    int angle = atoi(com + 10);
    analogWrite(turnon5vpin, 255);  // turn on 5V
    delay(100);                      // wait for rail to stabilize
    myservo5.write(angle);           // move linear actuator (servo5)
    Serial.print("linearact: ");
    Serial.println(angle);
    Serial.println("ok");
    delay(1200);                     // wait for servo to reach position
    analogWrite(turnon5vpin, 0);    // turn off 5V
  }

  // ── setvalves_angle <mask> <a> <b> <c> <d> ─────────────────────
  // Controls servos 1-4 (valve servos)
  // e.g. setvalves_angle 1010 0 90 35 180
  // mask digit 1 = move that servo, 0 = skip
  else if (strncasecmp(com, "setvalves_angle", 15) == 0) {
    // Work on a copy so strtok doesn't corrupt cmdBuf
    char tmp[CMD_BUF_SIZE];
    strncpy(tmp, com, CMD_BUF_SIZE - 1);
    tmp[CMD_BUF_SIZE - 1] = '\0';

    char* tok = strtok(tmp, " ");   // "setvalves_angle"
    tok = strtok(NULL, " ");        // mask e.g. "1010"

    char maskStr[5] = {0};
    if (tok) strncpy(maskStr, tok, 4);

    int angles[4] = {0, 0, 0, 0};
    for (int i = 0; i < 4; i++) {
      tok = strtok(NULL, " ");
      if (tok) angles[i] = atoi(tok);
    }

    analogWrite(turnon5vpin, 255);  // turn on 5V for all valve servos
    delay(100);                      // wait for rail to stabilize

    if (maskStr[0] == '1') { myservo1.write(angles[0]); delay(100); }
    if (maskStr[1] == '1') { myservo2.write(angles[1]); delay(100); }
    if (maskStr[2] == '1') { myservo3.write(angles[2]); delay(100); }
    if (maskStr[3] == '1') { myservo4.write(angles[3]); delay(100); }

    delay(1200);                    // wait for servos to reach position
    analogWrite(turnon5vpin, 0);   // turn off 5V
    Serial.println("ok");
  }

  // ── unknown command ─────────────────────────────────────────────
  else {
    Serial.print("unknown: ");
    Serial.println(com);
    Serial.println("ok");
  }
}
