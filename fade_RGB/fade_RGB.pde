/*
we need to simulate multitasked - hopefully it works

get the Aiko package on mac:
cd /Applications/Arduino.app/Contents/Resources/Java/libraries
git clone git://github.com/geekscape/aiko_arduino.git

*/

#include <AikoEvents.h>
using namespace Aiko;


/* select the PWM pins */
int RedPin = 3;
int GreenPin = 5;
int BluePin = 6;
int C1[] = {0,0,0}; //R(0-255),G(0-255),B(0-255) -- this is the current colour of the lamp
int C2[] = {0,0,0,0}; //R(0-255),G(0-255),B(0-255),Intensity(0-100) -- this is the colour we want the lamp to be


/*
  Upperlimit of 3,600 (1 hour countdown) 
  Based on a delay of 100ms in the loop.
*/

long mood = 0;
long cooldown = 1 * 60 *60; // 1 hour * 60 = 60 minutes * 60 seconds = time in seconds

void setup() {
    pinMode(RedPin, OUTPUT);
    pinMode(GreenPin, OUTPUT);
    pinMode(BluePin, OUTPUT);
    Serial.begin(9600);
    //
    Events.addHandler(sadness, 1000);  // Every 1000ms
    Events.addHandler(setColor, 30);  // Every 30ms
    //

}

void loop() {
   Events.loop();
   Serial.println("looping");
   //color(255,255,255,10);
}


void color(int red, int green, int blue, int intensity) {

  if (red > 0) { red = (red/100)*intensity; }
  if (green > 0) { green = (green/100)*intensity; }
  if (blue > 0) { blue = (blue/100)*intensity;  }
    
  C2[0] = red;
  C2[1] = green;
  C2[2] = blue;
  C2[3] = intensity;
}
void sadness() {
 // decrease
 Serial.print("Status: \t");
 Serial.println(mood);
 
 if (mood > 0) { 
   mood-- ;
 } else {
    Events.addOneShotHandler(hibernate,4000);
 }
 
 
}

void hibernate() {
  /* 
    We want it to appear to breathe
  */
  eventReset();
  color(0,0,110,20);
  Events.addHandler(fade_out, 40, 2000);
}

void fade_out(){

  C2[0] = C1[0] > 0 ? C1[0] - 1 : C1[0];
  C2[1] = C1[1] > 0 ? C1[1] - 1 : C1[1];
  C2[2] = C1[2] > 0 ? C1[2] - 1 : C1[2];
  if (C2[0] == 0 && C2[1] == 0 && C2[2] ==0) {
    eventReset();
    Events.addOneShotHandler(hibernate,3000);
  }
}
void setColor() {
    /* 
      we shouldn't divide by zero so need to do a reality check
      
      C2[0] = Red
      C2[1] = Green
      C2[2] = Blue
      C2[3] = Intensity 
    */
    int red = C2[0];
    int green = C2[1];
    int blue = C2[2];

    C1[0] = red > C1[0] ? C1[0] + 1: C1[0];
    C1[0] = red < C1[0] ? C1[0] - 1: C1[0];
    
    C1[1] = green > C1[1] ? C1[1] + 1: C1[1];
    C1[1] = green < C1[1] ? C1[1] - 1: C1[1];
    
    C1[2] = blue > C1[2] ? C1[2] + 1: C1[2];
    C1[2] = blue < C1[2] ? C1[2] - 1: C1[2];
    
    analogWrite(RedPin, C1[0]);
    analogWrite(GreenPin, C1[1]);
    analogWrite(BluePin, C1[2]);
 
}
/* 
  gives us a way to keep things 
  ticking since removeHandler doesn't 
  work in Aiko 
*/
void eventReset() {
  
  Events.reset();
  Events.addHandler(setColor, 30);
}

