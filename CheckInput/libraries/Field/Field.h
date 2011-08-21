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
    Field(int pin);
    int sensor(); //because the pin can only measure up to 1023 as it's 10bit 
private:
    int _pin;
    int _depth;
    int _array[50]; //if you change this you need to change the one in Field.cpp
    int index;
    int total;
    int avg;
};

#endif

