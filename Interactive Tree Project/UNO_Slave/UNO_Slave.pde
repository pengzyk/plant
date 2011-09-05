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


int c;  

 
 
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
  
 // Wire.begin();                


}

void loop() {
 
  /* we're going to poll for events */
  int data=0;
   Wire.requestFrom(2, 4); 
   while(Wire.available())  {
    data = Wire.receive();       
   }
  audio(data);
  delay(300);

}

void audio(int data) {
  static int previousData = 0;
  static boolean interuptable = true;
  static int track = 6;
  char* audiofiles[track];
  switch (data) {

     case 2:

        audiofiles[0] = "20_00";
        audiofiles[1] = "20_01";
        audiofiles[2] = "20_02";
        audiofiles[3] = "20_03";
        audiofiles[4] = "20_04";
        audiofiles[5] = "20_05";
     break;
     case 4:

        audiofiles[0] = "40_00";
        audiofiles[1] = "40_01";
        audiofiles[2] = "40_02";
        audiofiles[3] = "40_03";
        audiofiles[4] = "40_04";
        audiofiles[5] = "40_05";
     break;
     case 6: 

        audiofiles[0] = "60_00";
        audiofiles[1] = "60_01";
        audiofiles[2] = "60_02";
        audiofiles[3] = "60_03";
        audiofiles[4] = "60_04";
        audiofiles[5] = "60_05";
     break;
     case 8: 

        audiofiles[0] = "80_00";
        audiofiles[1] = "80_01";
        audiofiles[2] = "80_02";
        audiofiles[3] = "80_03";
        audiofiles[4] = "80_04";
        audiofiles[5] = "80_05";
     break;
     case 10:

        audiofiles[0] = "100_00";
        audiofiles[1] = "100_01";
        audiofiles[2] = "100_02";
        audiofiles[3] = "100_03";
        audiofiles[4] = "100_04";
        audiofiles[5] = "100_05";
     break;
     case 11:
    /* hyper happy */
        audiofiles[0] = "110_00";
        audiofiles[1] = "110_01";
        audiofiles[2] = "110_02";
        audiofiles[3] = "110_03";
        audiofiles[4] = "110_04";
        audiofiles[5] = "110_05";
     break;
     case 12:
     /* Angry */

        audiofiles[0] = "120_00";
        audiofiles[1] = "120_01";
        audiofiles[2] = "120_02";
        audiofiles[3] = "120_03";
        audiofiles[4] = "120_04";
        audiofiles[5] = "120_05";
     break;
     default:

        audiofiles[0] = "00_00";
        audiofiles[1] = "00_01";
        audiofiles[2] = "00_02";
        audiofiles[3] = "00_03";
        audiofiles[4] = "00_04";
        audiofiles[5] = "00_05";
  }



  if (data == previousData) {
    /* nothing has changed.. maybe play a random one.. */
    if (!wave.isplaying) {
      interuptable = true;
      if (random(10) == 0) {
        int rand = random(6);
        if (rand > 0) {
          interuptable = false;
        } 

       playfile(audiofiles[rand]);
      } 
      
    }
  } else {
    if (wave.isplaying && interuptable) {
      interuptable = true;
      if (random(10) == 0) {
        int rand = random(6);
        if (rand > 0) {
          interuptable = false;
        } 
        playfile(audiofiles[rand]);
      } 
    }
    if (wave.isplaying && !interuptable) {
      //nope cannot interupt the audio
    }
    if (!wave.isplaying) {
      interuptable = true;
      if (random(10) == 0) {
        int rand = random(6);
        if (rand > 0) {
          interuptable = false;
        } 

        playfile(audiofiles[rand]);
      } 
    }
  }
  free(audiofiles);
  previousData = data; //we want to compare.
}


void playfile(char *name) {
  /*
  TODO: lio says this is why it's eating ram and diing. fix it!
  */
  name = strcat( name,  (char*) ".WAV");


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

 
 
 



