#include <FatReader.h>
#include <SdReader.h>
#include <avr/pgmspace.h>
#include "WaveUtil.h"
#include "WaveHC.h"

#include <Wire.h>


SdReader card;    // This object holds the information for the card
FatVolume vol;    // This holds the information for the partition on the card
FatReader root;   // This holds the information for the filesystem on the card
FatReader f;      // This holds the information for the file we're play

WaveHC wave;      // This is the only wave (audio) object, since we will only play one at a time


 
 
void setup() {
  // set up serial port
  Serial.begin(9600);

  
  putstring("Free RAM: ");       // This can help with debugging, running out of RAM is bad
  Serial.println(freeRam());      // if this is under 150 bytes it may spell trouble!
  
  // Set the output pins for the DAC control. This pins are defined in the library
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
 
 
  //  if (!card.init(true)) { //play with 4 MHz spi if 8MHz isn't working for you
  if (!card.init()) {         //play with 8 MHz spi (default faster!)  
    putstring_nl("Card init. failed!");  // Something went wrong, lets print out why
    sdErrorCheck();
    while(1);                            // then 'halt' - do nothing!
  }
  
  // enable optimize read - some cards may timeout. Disable if you're having problems
  card.partialBlockRead(true);
 
// Now we will look for a FAT partition!
  uint8_t part;
  for (part = 0; part < 5; part++) {     // we have up to 5 slots to look in
    if (vol.init(card, part)) 
      break;                             // we found one, lets bail
  }
  if (part == 5) {                       // if we ended up not finding one  :(
    putstring_nl("No valid FAT partition!");
    sdErrorCheck();      // Something went wrong, lets print out why
    while(1);                            // then 'halt' - do nothing!
  }
  
  // Lets tell the user about what we found
  putstring("Using partition ");
  Serial.print(part, DEC);
  putstring(", type is FAT");
  Serial.println(vol.fatType(),DEC);     // FAT16 or FAT32?
  
  // Try to open the root directory
  if (!root.openRoot(vol)) {
    putstring_nl("Can't open root dir!"); // Something went wrong,
    while(1);                             // then 'halt' - do nothing!
  }
  
  // Whew! We got past the tough parts.
  putstring_nl("Ready!");
  
 Wire.begin();                


}

void loop() {
 
  /* we're going to poll for events */

   Wire.requestFrom(2, 1); 
   while(Wire.available())  {
     int data = Wire.receive();       
     audio(data);
   }

  delay(10);

}

void audio(int data) {
  static int previousData = 0;
  static boolean interuptable = true;
  static int randomable = 0;
  char* audiofiles[6];
    if (data == 0) {
        if (data == 0) {
        audiofiles[0] = "00.WAV";
        audiofiles[1] = "01.WAV";
        audiofiles[2] = "02.WAV";
        audiofiles[3] = "03.WAV";
        audiofiles[4] = "04.WAV";
        audiofiles[5] = "02.WAV";
        audiofiles[6] = "03.WAV";
        randomable = 3200;
    }
    if (data == 2) {
        audiofiles[0] = "20.WAV";
        audiofiles[1] = "21.WAV";
        audiofiles[2] = "22.WAV";
        audiofiles[3] = "23.WAV";
        audiofiles[4] = "24.WAV";
        audiofiles[5] = "22.WAV";
        audiofiles[6] = "23.WAV";
        randomable = 250;
    }
    if (data == 4) {
        audiofiles[0] = "40.WAV";
        audiofiles[1] = "41.WAV";
        audiofiles[2] = "42.WAV";
        audiofiles[3] = "43.WAV";
        audiofiles[4] = "44.WAV";
        audiofiles[5] = "42.WAV";
        audiofiles[6] = "44.WAV";
        randomable = 200;
    }
    if (data ==6) {
        audiofiles[0] = "60.WAV";
        audiofiles[1] = "61.WAV";
        audiofiles[2] = "62.WAV";
        audiofiles[3] = "63.WAV";
        audiofiles[4] = "64.WAV";
        audiofiles[5] = "65.WAV";
        audiofiles[6] = "65.WAV";
        randomable = 150;
    }
    if(data == 8) {
        audiofiles[0] = "80.WAV";
        audiofiles[1] = "81.WAV";
        audiofiles[2] = "82.WAV";
        audiofiles[3] = "83.WAV";
        audiofiles[4] = "84.WAV";
        audiofiles[5] = "85.WAV";
        audiofiles[6] = "86.WAV";
        randomable = 100;
    }
    if (data == 10) {
        audiofiles[0] = "100.WAV";
        audiofiles[1] = "101.WAV";
        audiofiles[2] = "102.WAV";
        audiofiles[3] = "103.WAV";
        audiofiles[4] = "104.WAV";
        audiofiles[5] = "105.WAV";
        audiofiles[6] = "106.WAV";
        randomable = 50;
    }
    if (data == 11) {
        audiofiles[0] = "110.WAV";
        audiofiles[1] = "110.WAV";
        audiofiles[2] = "110.WAV";
        audiofiles[3] = "110.WAV";
        audiofiles[4] = "110.WAV";
        audiofiles[5] = "110.WAV";
        randomable = 10;
    }
    if (data >= 12) {
     // Angry 
        audiofiles[0] = "120.WAV";
        audiofiles[1] = "121.WAV";
        audiofiles[2] = "122.WAV";
        audiofiles[3] = "123.WAV";
        audiofiles[4] = "124.WAV";
        audiofiles[5] = "123.WAV";
        audiofiles[6] = "121.WAV";
        randomable = 0;
    }




  if (data == previousData) {
    /* nothing has changed.. maybe play a random one.. */
    if (!wave.isplaying) {
      interuptable = true;
      if (random(randomable) == 0) {
        byte rand = random(6);
        if (rand > 0) {
          interuptable = false;
        } 

       playfile(audiofiles[rand]);
      } 
      
    }
  } else {
    if (wave.isplaying && interuptable) {
      interuptable = true;
      if (random(randomable) == 0) {
        byte rand = random(6);
        if (rand > 0) {
          interuptable = false;
        } 
        playfile(audiofiles[rand]);
      } 
    }
    if (wave.isplaying && !interuptable && randomable == 0) {
      byte rand = random(6);
      playfile(audiofiles[rand]);
      interuptable = false;
    }
    if (!wave.isplaying) {
      interuptable = true;
      if (random(randomable) == 0) {
        byte rand = random(6);
        if (rand > 0) {
          interuptable = false;
        } 

        playfile(audiofiles[rand]);
      } 
    }
    previousData = data; //we want to compare.
  }
  //free(audiofiles);
  
}


void playfile(char *name) {
  Serial.println(name);
  // see if the wave object is currently doing something
  if (wave.isplaying) {// already playing something, so stop it!
    wave.stop(); // stop it
  }
  // look in the root directory and open the file
  if (!f.open(root, name)) {
    putstring("Couldn't open file "); Serial.println(name); return;
  }
  // OK read the file and turn it into a wave object
  if (!wave.create(f)) {
    putstring_nl("Not a valid WAV"); return;
  }
  
  // ok time to play! start playback
  wave.play();
}

/* borring stuff */
 
 
 // this handy function will return the number of bytes currently free in RAM, great for debugging!   
int freeRam(void){
  extern int  __bss_end; 
  extern int  *__brkval; 
  int free_memory; 
  if((int)__brkval == 0) {
    free_memory = ((int)&free_memory) - ((int)&__bss_end); 
  }
  else {
    free_memory = ((int)&free_memory) - ((int)__brkval); 
  }
  return free_memory; 
} 

void sdErrorCheck(void)
{
  if (!card.errorCode()) return;
  putstring("\n\rSD I/O error: ");
  Serial.print(card.errorCode(), HEX);
  putstring(", ");
  Serial.println(card.errorData(), HEX);
  while(1);
}

 
 
 



