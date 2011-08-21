#include <Field.h>

Field field(A0);

void setup()
{
    Serial.begin(9600); 
}

void loop() {

Serial.println(field.sensor());

delay(100);     
}


