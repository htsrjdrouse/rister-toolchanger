#include <Servo.h>
Servo myservo1;  // create servo object to control a servo
Servo myservo2;  // create servo object to control a servo
Servo myservo3;  // create servo object to control a servo
Servo myservo4;  // create servo object to control a servo


#include <Wire.h>
#include <SoftwareSerial.h>


const int sensorPin = A2;  // Sensor output connected to digital pin 2

#define THERMISTOR_PIN A0

int valveservo1 = 11;
int valveservo2 = 13;
int valveservo3 = 12;
int valveservo4 = 8;
int washpin = 10; 
int drypin = 9; 
int pcvpin = 6; 
int heatpin = 5; 
int turnon5vpin = 5;
int tempsensor = A0;
//int levelsensor = A1;
int washval = 255;
int dryval = 255;
int pcvval = 255;

String command;
float currpos;
int fillflag = 1;
int htcnt = 0;
int pumpdelayct = 0;
int pumpdelay = 0;
int pumponflag = 0;



void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  //myservo.attach(valveservo);
  myservo1.attach(valveservo1, 500, 2500);
  myservo2.attach(valveservo2, 500, 2500);
  myservo3.attach(valveservo3, 500, 2500);
  myservo4.attach(valveservo4, 500, 2500);
  analogWrite(pcvpin, 0); 
  analogWrite(washpin,0);
  analogWrite(drypin, 0);
  analogWrite(heatpin, 0);
  analogWrite(turnon5vpin, 0);

  pinMode(sensorPin, INPUT_PULLUP);
  //pinMode(pcvpin, OUTPUT);
  
  currpos = 0;
}

void loop() {

  if (fillflag == 0){

  if (digitalRead(sensorPin) == LOW) {  // Liquid detected
    analogWrite(pcvpin, pcvval);    // Turn on pump
  } else {
    analogWrite(pcvpin, 0);            // Turn off pump
  }
    
  }



 if(Serial.available())
 {
    char c = Serial.read();
    if (c== '\n')
    {
      currpos = parseCommand(command, currpos);
      command = "";
    }
    else 
    {
      command +=c;
    }
 }
 delay(30);
}

float parseCommand(String com, int currpos)
{

  if(com.equalsIgnoreCase("washon")){
    analogWrite(washpin, washval);
    delay(100);
  }  
  else if(com.equalsIgnoreCase("washoff")){
    analogWrite(washpin, 0);
    delay(100);
  }  
  else if(com.equalsIgnoreCase("dryon")){
    analogWrite(drypin, dryval);
    delay(100);
  }  
  else if(com.equalsIgnoreCase("dryoff")){
    analogWrite(drypin, 0);
    delay(100);
  } 
  else if(com.equalsIgnoreCase("readpin")){
  Serial.println(digitalRead(sensorPin));
  }
  else if(com.equalsIgnoreCase("info")){
    Serial.println("wash_dry_pcv_electrocaloric_kill_stepper_valve");
  }
  else if(com.equalsIgnoreCase("turnon5v")){
    analogWrite(turnon5vpin, 255);
  } 
  else if(com.equalsIgnoreCase("turnoff5v")){
    analogWrite(turnon5vpin, 0);
  }

  else if(com.equalsIgnoreCase("manpcv")){
    fillflag = 1;
    analogWrite(pcvpin, 0);
  }
  else if(com.equalsIgnoreCase("feedbackpcv")){
    fillflag = 0;
  }  
  else if(com.equalsIgnoreCase("pcvon")){
    if (fillflag == 1){
     analogWrite(pcvpin, pcvval);
    }
  }  
  else if(com.equalsIgnoreCase("pcvoff")){
    if (fillflag == 1){
     analogWrite(pcvpin, 0);
    }
  } 
   else if (com.substring(0,10) == "setwashval") {
    washval = com.substring(11).toInt();
  }
   else if (com.substring(0,9) == "setdryval") {
    dryval = com.substring(10).toInt();
  }
   else if (com.substring(0,9) == "setpcvval") {
    pcvval = com.substring(10).toInt();
  }

else if (com.substring(0, 15).equalsIgnoreCase("setvalves_angle")) {
    // Parse: "setvalves_angle 1000 0 180 30 45"
    // Format: setvalves_angle MASK angle_a angle_b angle_c angle_d
    
    // Find all spaces
    int space1 = com.indexOf(' ');
    int space2 = com.indexOf(' ', space1 + 1);
    int space3 = com.indexOf(' ', space2 + 1);
    int space4 = com.indexOf(' ', space3 + 1);
    int space5 = com.indexOf(' ', space4 + 1);
    
    String maskStr = com.substring(space1 + 1, space2);
    int angle_a = com.substring(space2 + 1, space3).toInt();
    int angle_b = com.substring(space3 + 1, space4).toInt();
    int angle_c = com.substring(space4 + 1, space5).toInt();
    int angle_d = com.substring(space5 + 1).toInt();
    
    // Debug output
    /*
    Serial.print("Mask: ");
    Serial.println(maskStr);
    Serial.print("Angles: A=");
    Serial.print(angle_a);
    Serial.print(" B=");
    Serial.print(angle_b);
    Serial.print(" C=");
    Serial.print(angle_c);
    Serial.print(" D=");
    Serial.println(angle_d);
    */
    // Set each servo based on mask
    if (maskStr[0] == '1') {
        myservo1.write(angle_a);
        //Serial.println("Servo A moved");
        delay(100);
    }
    if (maskStr[1] == '1') {
        myservo2.write(angle_b);
        //Serial.println("Servo B moved");
        delay(100);
    }
    if (maskStr[2] == '1') {
        myservo3.write(angle_c);
        //Serial.println("Servo C moved");
        delay(100);
    }
    if (maskStr[3] == '1') {
        myservo4.write(angle_d);
        //Serial.println("Servo D moved");
        delay(100);
    }
    
    delay(1200); // Allow servos to fully move
    //Serial.println("Servo move complete");
}

   return currpos;
}
