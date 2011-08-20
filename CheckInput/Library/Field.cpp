/*
 Field.cpp - Library for FieldSensor Shield 
 Created by Chaos Studio - Paul Adams 2011
 paul@chaos-studio.com
*/

#include "WProgram.h"
#include "Field.h"

Field::Field(int myPin, int Depth)
{
    Index = 0;
    Average = 0;
    Readings[Depth];
    Average = 0;
    Total = 0;
    myPin = myPin;
    Depth = Depth;

    for (int thisReading = 0; thisReading < Depth; thisReading++) {
        Readings[Depth] = 0;  
    }

}

long Field::Sensor()
{
  
    Total = Total - Readings[Index];         
    Readings[Index] = analogRead(myPin); 
    Total= Total + Readings[Index];       
    Index = Index + 1;                    
    
    if (Index >= Depth)              
        Index = 0;                           
    
    Average = Total / Depth;  
    return Average;
}



