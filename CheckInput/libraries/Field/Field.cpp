/*
 Field.cpp - Library for FieldSensor Shield 
 Created by Chaos Studio - Paul Adams 2011
 paul@chaos-studio.com
 
 With 50 levels of smoothing based on average.
 
 */

#include "WProgram.h"
#include "Field.h"


Field::Field(int pin)
{
    _pin = pin;
    _depth = 50; //if you change this, you need to change the one in Field.h
    index = 0;
    total = 0;
    avg = 0;
    
    pinMode(pin, INPUT);
    
    for (int i=0; i < _depth; i++) {
        _array[i] = 0;
    }
}

int Field::sensor()
{
    total = total - _array[index];         
    _array[index] = analogRead(_pin);
    if ( _array[index] >= 0 && _array[index] <= 1023) { //stop some weird things. 
        total= total + _array[index];
    }
    index = index + 1;                    
    
    if (index >= _depth)              
        index = 0;                           
    
    avg = total / _depth;         
    
    return avg;
    
}

