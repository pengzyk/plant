/*
  Interactive Tree project by Ziyun Peng and Paul Adams.
  pengzyk@gmail.com & nihaopaul@gmail.com - All rights reserved

  Get the Aiko package on mac:
  
  1. cd /Applications/Arduino.app/Contents/Resources/Java/libraries
  2. git clone git://github.com/geekscape/aiko_arduino.git

*/

#include <AikoEvents.h>
using namespace Aiko;

int MOOD = 0; //0 - 100%
long MOODDECREASE = 10; //in minutes, amount of time to get sad.
long MOODINCREASE = 1; //in minutes, the amount of interaction time needed
int SENSITIVITY = 100; //adjust this for setting people limits.
int MAX_BRIGHTNESS = 60; //0-100%  - we've had heat problems.

/*
  Helps to use a Mega 2650 - with a heatsink!
*/
int LED[3][3] = {
  {1,2,3},
  {4,5,6},
  {7,8,9}
}; // 3 lights - only PWM pins - R G B 

int LEDCOLOR[3][3] = {
   {0,0,0},
   {0,0,0},
   {0,0,0}
}; //R(0-255),G(0-255),B(0-255) -- this is the current colour of the lamp

int LEDTARGET[3][4] = {
   {0,0,0,0},
   {0,0,0,0},
   {0,0,0,0}
}; //R(0-255),G(0-255),B(0-255),Intensity(0-100) -- this is the colour we want the lamp to be

/* 
  PWM not needed for these pins
*/
int AudioInt = 20; //needs a digital pin, HIGH or LOW to interupt the slave
int AudioData = 21; //needs a pin to communicate things over, again digital

int SensorTX = 22;
int SensorRX = 23;

void setup() {
  Serial.begin(9600);
  Events.addHandler(setColor, 30); //this does the fading..see end of code.
}

void loop() {
  Events.loop();
}

/* 
  set which light you want to call 
  light = 0 - 2 (we have 3 lights)
  red = 0 - 255
  green = 0 - 255
  blue = 0 - 255
  intensity = 0 - 100 
*/
void color(int light, int red, int green, int blue, int intensity) {
  if (intensity > MAX_BRIGHTNESS) { intensity = MAX_BRIGHTNESS; }
  if (red > 0) { red = (red/100)*intensity; }
  if (green > 0) { green = (green/100)*intensity; }
  if (blue > 0) { blue = (blue/100)*intensity;  }
    
  LEDTARGET[light][0] = red; 
  LEDTARGET[light][1] = green;
  LEDTARGET[light][2] = blue;
  LEDTARGET[light][3] = intensity;
}









/* dont adjust this unless you know when you're doing */

void setColor() {
  /* 
    
    TODO: Codify this with 2 loops
    TODO: fix up the for loop
    lets draw this out the long way for now.. then codify it later 
  */

 for(int i=0; i< 3; i++) {
    int red = LEDTARGET[i][0];
    int green = LEDTARGET[i][1];
    int blue = LEDTARGET[i][2];
    
    LEDCOLOR[i][0] = red > LEDCOLOR[i][0] ? LEDCOLOR[i][0] + 1: LEDCOLOR[i][0];
    LEDCOLOR[i][0] = red < LEDCOLOR[i][0] ? LEDCOLOR[i][0] - 1: LEDCOLOR[i][0];
    
    LEDCOLOR[i][1] = green > LEDCOLOR[i][1] ? LEDCOLOR[i][1] + 1: LEDCOLOR[i][1];
    LEDCOLOR[i][1] = green < LEDCOLOR[i][1] ? LEDCOLOR[i][1] - 1: LEDCOLOR[i][1];
    
    LEDCOLOR[i][2] = blue > LEDCOLOR[i][2] ? LEDCOLOR[i][2] + 1: LEDCOLOR[i][2];
    LEDCOLOR[i][2] = blue < LEDCOLOR[i][2] ? LEDCOLOR[i][2] - 1: LEDCOLOR[i][2];
    
    analogWrite(LED[i][0], LEDCOLOR[i][0]);
    analogWrite(LED[i][1], LEDCOLOR[i][1]);
    analogWrite(LED[i][2], LEDCOLOR[i][2]);
  }
 
}

void eventReset() {
  Events.reset();
  Events.addHandler(setColor, 30);
}

