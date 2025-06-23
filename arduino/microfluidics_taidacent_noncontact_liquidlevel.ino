#include <Servo.h>
Servo myservo;  // create servo object to control a servo

#include <Wire.h>
#include <SoftwareSerial.h>


const int sensorPin = A2;  // Sensor output connected to digital pin 2

#define THERMISTOR_PIN A0

int valveservo = 11;
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
  myservo.attach(valveservo, 500, 2500);
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

  else if (com.substring(0,10) == "valveservo") {
    myservo.write(com.substring(com.indexOf("valveservo")+11).toInt());
  }
   return currpos;
}
