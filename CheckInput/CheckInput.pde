
//#include <Field.h>

//Field field('A0', 20);

void setup()
{
    Serial.begin(9600); 
}

void loop() {
      Serial.print("SensorDebug: \t");
    Serial.println(analogRead(A0), DEC);
          
     //field.Debug(); 
delay(100);     
}


