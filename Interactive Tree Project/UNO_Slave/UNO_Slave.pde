

//////////////////////////////////// SETUP
void setup() 
{
  Serial.begin(9600);           // set up Serial library at 9600 bps for debugging
  
 attachInterrupt(0, receivedMsg, RISING);
}

//////////////////////////////////// LOOP
void loop() 
{ 
 

}



void receivedMsg() {
  Serial.println("got an interupt");
}
