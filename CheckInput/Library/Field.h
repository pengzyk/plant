/*
 Field.cpp - Library for FieldSensor Shield 
 Created by Chaos Studio - Paul Adams 2011
 paul@chaos-studio.com
*/


#ifndef Field_h
#define Field_h

#include "WProgram.h"

class Field
{
public:
  Field(int myPin, int Depth);
  long Sensor();

private:
  const int Depth;
  int Readings; //array
  int Index;
  int Total;
  int Average;
  int myPin; //pinmode
};


#endif


/*
const int numReadings = 20;

int readings[numReadings];      // the readings from the analog input
int index = 0;                  // the index of the current reading
int total = 0;                  // the running total
int average = 0;                // the average

int inputPin = A0;

*/