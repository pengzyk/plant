#include <CapSense.h>

/*
 * CapitiveSense Library Demo Sketch
 * Paul Badger 2008
 * Uses a high value resistor e.g. 10 megohm between send pin and receive pin
 * Resistor effects sensitivity, experiment with values, 50 kilohm - 50 megohm. Larger resistor values yield larger sensor values.
 * Receive pin is the sensor pin - try different amounts of foil/metal on this pin
 * Best results are obtained if sensor foil and wire is covered with an insulator such as paper or plastic sheet
 */


CapSense   cs_4_2 = CapSense(24,26);        // 10 megohm resistor between pins 4 & 2, pin 2 is sensor pin, add wire, foil
//CapSense   cs_4_5 = CapSense(4,5);        // 10 megohm resistor between pins 4 & 6, pin 6 is sensor pin, add wire, foil
//CapSense   cs_4_8 = CapSense(4,8);        // 10 megohm resistor between pins 4 & 8, pin 8 is sensor pin, add wire, foil


//
    
    int _depth = 50; //if you change this, you need to change the one in Field.h
   int  index = 0;
   int total = 0;
    int avg = 0;
    int _array[50];
    
void setup()                    
{

   cs_4_2.set_CS_AutocaL_Millis(0xFFFFFFFF);     // turn off autocalibrate on channel 1 - just as an example
   Serial.begin(9600);
   //

    
    for (int i=0; i < _depth; i++) {
          _array[i] = 0;
    }
}

void loop()                    
{
    long start = millis();
    long total1 =  cs_4_2.capSense(30);
 
    Serial.print(millis() - start);        // check on performance in milliseconds
    Serial.print("\t");                    // tab character for debug windown spacing

    Serial.print(smoothing(total1));                  // print sensor output 1
    Serial.println("\t");


    delay(10);                             // arbitrary delay to limit data to serial port 
}
int smoothing(int number) {
    total = total - _array[index];         
    _array[index] = number;
    if ( _array[index] >= 0 && _array[index] <= 1023) { //stop some weird things. 
        total= total + _array[index];
    }
    index = index + 1;                    
    
    if (index >= _depth)              
        index = 0;                           
    
    avg = total / _depth;         
    
    return avg;
}
