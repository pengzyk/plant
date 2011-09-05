/*
  Interactive Tree project by Ziyun Peng and Paul Adams.
  pengzyk@gmail.com & nihaopaul@gmail.com - All rights reserved

  TODO: finish the lights section
  
*/

#include <AikoEvents.h>
using namespace Aiko;

#include <Wire.h> //need this for communication

float MOOD = 0; //0 - 100% (should be 100% but we have added an additional state.. angry)
long MOODDECREASE = 200; // 
long MOODINCREASE = 50; /*  in milliseconds, we need to set this and adjust as needed.. 
                            since we know we're calling it every 50ms but also doing sample smoothing..
                            Trial by error
                        */
int SENSITIVITY = 100; //adjust this for setting people limits.
int MAX_BRIGHTNESS = 60; //0-100%  - we've had heat problems.




static boolean pauselights = false;
/*mega has lots of ram :) */
byte stack[200][6] = {0}; //60 instructions in this order {light, red,green,blue,intensity,delay} bit of a ram pig though.
byte stackptr = 0;
byte stackDrv = 0;

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


//
#include <CapSense.h> //sensor
CapSense   plantSensor = CapSense(38,28);  //i found a cheat or a work around for this one

const int numReadings = 30;
long readings[numReadings] = {0};  
int index = 0;                  // the index of the current reading
long total = 0;                  // the running total
long average = 0;                // the average
long calibration = 0; //offset
long plantActivity;


void setup() {
  Serial.begin(9600);

//  Events.addHandler(setColor, 30); //removed as it's not used now, almost impossible to be used with the timing callback
  Events.addHandler(sadly, MOODDECREASE); //get sad function 
  Events.addHandler(smoothing, MOODINCREASE); //get happy function
  Events.addHandler(printout, 1000);
  
  //could be needy this next part
  Wire.begin(2);               
  Wire.onRequest(requestEvent); 
  
  //sensor data..
  plantSensor.set_CS_AutocaL_Millis(0xFFFFFFFF); 
  /*
  for (int thisReading = 0; thisReading < numReadings; thisReading++) {
    readings[thisReading] = 0;    
  }
  */
}

void loop() {  
  
  Events.loop();
}

void smoothing() {

  total= total - readings[index];         
  readings[index] = plantSensor.capSense(1); 
  total= total + readings[index];       
  index = index + 1;                    
  static long i=0;

  if (index >= numReadings) {        
    index = 0;               
  }    

  long oldreading = average;
  average = total / numReadings; 
  
  
  /* filter some noise and auto-calibrate ourselves */
  
  if (average - calibration > 20 || average - calibration < -20) {
   i++;
   /* arbitary number which has no relative meaning, this stops us from always calibrating */
   if (i > 3600) {
    Serial.println("\t - Calibration in progress -");
    calibration = oldreading;
    Serial.print("\t OFFSET: \t \t");
    Serial.println(calibration);
    i = 0;
     Serial.println("if you see this oftern, adjust the limits in the outer IF statement");
   }
  } else {
  /* we need to stop peoples occasional touch from starting the calibration */
    if (i > 0) { 
      i--; 
    };
  }


  plantActivity = average - calibration;
  
  moodstatus(plantActivity);
  //Serial.println(plantActivity); // debugging only

}




/*
  the mood changer, very simple.
*/
void sadly() {
  if (MOOD >0) {
    MOOD = MOOD - 0.1;
  }
}

/* 
  set which light you want to call 
  light = 0 - 2 (we have 3 lights)
  red = 0 - 255
  green = 0 - 255
  blue = 0 - 255
  intensity = 0 - 100 
*/
void color(byte light, byte red, byte green, byte blue, byte intensity) {
  if (intensity > MAX_BRIGHTNESS) { intensity = MAX_BRIGHTNESS; }
  if (red > 0) { red = (red/100)*intensity; }
  if (green > 0) { green = (green/100)*intensity; }
  if (blue > 0) { blue = (blue/100)*intensity;  }
    
  LEDTARGET[light][0] = red; 
  LEDTARGET[light][1] = green;
  LEDTARGET[light][2] = blue;
  LEDTARGET[light][3] = intensity;
}

// comment out after testing, uses ram
void printout() {
  
  int i = MOOD/10;
  Serial.println("==MOOD Adjustment====");
  Serial.print("0% ");
  for (int j=0; j< i; j++) {
    Serial.print("=");
  }
  Serial.print(" ");
   Serial.print(MOOD);
  Serial.println("%");
  Serial.println("");

}
void moodstatus(long moodAdjustment) {
  static long jump = 0;
  if (moodAdjustment > 60 && MOOD <120) {
    MOOD= MOOD + 0.2;
  }
  
   //need this here
  /* too many people detector */
  if (moodAdjustment - jump > SENSITIVITY) {
    MOOD = 130;
  }
  jump = moodAdjustment;
}

/*
void setColor() {
   
   // fades between the colours set by color() function, this function is run by Aiko..
  //  this is only here for reference only, not used anymore
  
 if (pauselights) {
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
 
}
*/


int eventMagic() {
  if (MOOD < 20) {
    return 0;
  }
  if (MOOD < 40) {
    return 2;
  }
  if (MOOD < 60) {
    return 4;
  }
  if (MOOD < 80) {
    return 6;
  }
  if (MOOD < 100) {
    return 8;
  }
  if (MOOD < 110) {
    return 10;
  }
  if (MOOD < 120) {
    return 11;
  }
  return 12;

}
void requestEvent() {
/* one way communication to the arduino :) */
 static byte i = 0;
 byte e = eventMagic();
 Wire.send(i); 

//we dont want to call the light show too many times as it's on a loop anyway.
if (i != e) {
  switch (e) {
    case 0:
      light_0();
    break;
    case 2:
      light_20();
    break;
    case 4:
      light_40();
    break;
    case 6: 
      light_60();
    break;
    case 8:
      light_80();
    break;
    case 10:
      light_100();
    break;
    case 11:
      light_110();
    break;
    case 12:
      light_120();
    break;
  }
  i = e;
}
 
  
}

/* adds objects to the light show and moves the pointer */
void lightShowData(byte light, byte red, byte green, byte blue, byte intensity, byte callDelay) {
  stack[stackptr][0] = light;
  stack[stackptr][1] = red;
  stack[stackptr][2] = green;
  stack[stackptr][3] = blue;
  stack[stackptr][4] = intensity;
  stack[stackptr][5] = callDelay;
  stackptr++;
}
void lightShow() {
  byte light = stack[stackDrv][0];
  byte red = stack[stackDrv][1];
  byte green = stack[stackDrv][2];
  byte blue = stack[stackDrv][3];
  byte intensity = stack[stackDrv][4];
  byte calldelay = stack[stackDrv][5];
  
  if (intensity > MAX_BRIGHTNESS) { intensity = MAX_BRIGHTNESS; }
  
  if (red > 0) { red = (red/100)*intensity; }
  if (green > 0) { green = (green/100)*intensity; }
  if (blue > 0) { blue = (blue/100)*intensity;  }
  
  analogWrite(LED[light][0], red);
  analogWrite(LED[light][1], green);
  analogWrite(LED[light][2], blue);
  if (stackDrv < stackptr) {
    Events.addOneShotHandler(lightShow, calldelay);
    stackDrv++;
  } else {
    stackDrv = 0;
  }
}

/* light shows */
void light_0() {
  /* breathing in white */
 stackDrv,stackptr = 0;
 for (byte j=0; j < 4; j++) {
   for (byte i=0; i<3; i++) {
     lightShowData(i,255,255,255,j*10,50);
   }
 }
 lightShowData(0,255,255,255,100,1000);
 lightShowData(1,255,255,255,100,1000);
 lightShowData(2,255,255,255,100,1000);
 for (byte j=4; j > 0; j--) {
   for (byte i=0; i<3; i++) {
     lightShowData(i,255,255,255,j*10,50);
   }
 }
 /* run it */
 lightShow();
}
void light_20() {
  /* blink a few dull colours */
  stackDrv,stackptr = 0;
}
void light_40() {
  /* flash + increase intensity */
  stackDrv,stackptr = 0;
}
void light_60() {
  /* r/g/b rise */
  stackDrv,stackptr = 0;
}
void light_80() {
  stackDrv,stackptr = 0;
}
void light_100() {
  stackDrv,stackptr = 0;
}
void light_110() {
  stackDrv,stackptr = 0;
  /* super bright colours */
   for (byte i=0; i<3; i++) {
     lightShowData(i,255,0,0,100,50);
     lightShowData(i,0,255,0,100,50);
     lightShowData(i,0,0,255,100,50);
   }
  for (byte i=0; i<3; i++) {
     lightShowData(i,0,0,255,100,50);
     lightShowData(i,255,0,0,100,50);
     lightShowData(i,0,255,0,100,50);
   }
    for (byte i=0; i<3; i++) {
     lightShowData(i,0,255,0,100,50);
     lightShowData(i,0,0,255,100,50);
     lightShowData(i,255,0,0,100,50);
   }
      for (byte i=0; i<3; i++) {
     lightShowData(i,255,255,0,100,50);
     lightShowData(i,0,255,255,100,50);
     lightShowData(i,255,0,255,100,50);
   }
  for (byte i=0; i<3; i++) {
     lightShowData(i,255,0,255,100,50);
     lightShowData(i,255,255,0,100,50);
     lightShowData(i,0,255,255,100,50);
   }
    for (byte i=0; i<3; i++) {
     lightShowData(i,0,255,255,100,50);
     lightShowData(i,255,0,255,100,50);
     lightShowData(i,255,255,0,100,50);
   }
   lightShow();
}
void light_120() {
  /* spiral red */
 stackDrv,stackptr = 0;
 for (byte j=0; j < 9; j++) {
     lightShowData(0,255,0,0,j*10,100);
     lightShowData(1,255,0,0,j*10,100);
     lightShowData(2,255,0,0,j*10,100);
 }
  for (byte j=9; j > 0; j--) {
     lightShowData(0,255,0,0,j*10,50);
     lightShowData(1,255,0,0,j*10,50);
     lightShowData(2,255,0,0,j*10,50);
 }
 /* run it */
 lightShow();
}
