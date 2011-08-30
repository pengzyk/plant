/* select the PWM pins */
int RedPin = 3;
int GreenPin = 5;
int BluePin = 6;
int color[] = {0,0,0}; //R,G,B

void setup() {
    pinMode(RedPin, OUTPUT);
    pinMode(GreenPin, OUTPUT);
    pinMode(BluePin, OUTPUT);
}

void loop() {

setColor(255,255,255,1);
delay(2000);

setColor(255,255,255,20);
delay(1000);

breathing();

}

void breathing () {
  setColor(255,0,0,1);
  delay(200);
  setColor(255,0,0,100);
  delay(200);
  setColor(255,0,0,1);
  delay(200);
  setColor(255,0,0,100);
  delay(200);
  setColor(255,0,0,1);
  delay(200);
}
void setColor (int red, int green, int blue, int intensity) {
    /* 
      we shouldn't divide by zero.. 
      not sure what the microcontroller would do 
    */
    if (red == 0) { red = 1; }
    if (green == 0) { green = 1; }
    if (blue == 0) { blue = 1; }
    
    red = (red/100)*intensity;
    green = (green/100)*intensity;
    blue = (blue/100)*intensity;
    
  do {
    color[0] = red > color[0] ? color[0] + 1: color[0];
    color[0] = red < color[0] ? color[0] - 1: color[0];
    
    color[1] = green > color[1] ? color[1] + 1: color[1];
    color[1] = green < color[1] ? color[1] - 1: color[1];
    
    color[2] = blue > color[2] ? color[2] + 1: color[2];
    color[2] = blue < color[2] ? color[2] - 1: color[2];
    
    analogWrite(RedPin, color[0]);
    analogWrite(GreenPin, color[1]);
    analogWrite(BluePin, color[2]);
    /*  
      This delay could block other functions.. 
      but it's only on fade.. must test with audio shield
    */
    delay(30); 
  } while (red != color[0] || green != color[1] || blue != color[2]);


}


