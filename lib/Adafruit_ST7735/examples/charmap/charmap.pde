//  st7735_character_map.ino - 6/22/2013 - Chris K, ckelley@ca-cycleworks.com
//
// Code snippets are based on various Adafruit examples
// Adafruit 1.8TFT w/joystick 160x128 in landscape (128x160)
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <SPI.h>
#include <TimerOne.h>
#include <ClickEncoder.h>

// ----------------------------------------------------------------------------
// display

#define LCD_CS   9
#define LCD_DC   7
#define LCD_RST  8
Adafruit_ST7735 tft = Adafruit_ST7735(LCD_CS, LCD_DC, LCD_RST);

// ----------------------------------------------------------------------------
// encoder

ClickEncoder Encoder(A0, A1, A2, 2);

uint32_t timerTicks;

void timerIsr(void) {
  timerTicks++;
  Encoder.service();
}

// ----------------------------------------------------------------------------

void setup() {         
  tft.initR(INITR_REDTAB);
  //tft.setTextWrap(false);
  tft.setTextSize(1);
  tft.setRotation(3);
  tft.setTextWrap(true);

  Timer1.initialize(1000);
  Timer1.attachInterrupt(timerIsr);

  pinMode(MISO, OUTPUT);
  pinMode(MOSI, OUTPUT);
  // enable pull up, otherwise display flickers
  PORTB |= (1 << MOSI) | (1 << MISO); 
}

// text size 1 "0123456789abcdef0123456789" » 16 lines of 0x20 (decimal 26) characters
// text size 2 "0123456789abc" » 8 lines of 13 characters

int page=0;
int lastpage=1; // make different for 1st time thru loop()
// used initializer to make the string long enough!
char lineText[0x22]="0x--- 0123 4567 89ab cdef\n";  

int16_t encMovement;


void loop() {
  char text[512];
  char fBuffer[10];
  float position;
  int _char = page * 15 * 0x10;

  if( page != lastpage ){
    tft.fillScreen(ST7735_BLACK);
    tft.setCursor(0,0);
    // print header
    tft.setTextColor(ST7735_BLUE);
    sprintf( fBuffer, "pg %-4d", page+1); // page 0 doesn't make sense...
    sprintf( lineText, "%6.6s 0123 4567 89ab cdef", fBuffer );
    tft.print(lineText);
    for( int line=0 ; line <= 15; line++ ) {
      if(_char%0x100 == 0 ) { // skip first rows of each char set
          tft.setTextColor(ST7735_RED);
          sprintf( fBuffer, "%#x", _char);
          sprintf( lineText, "%6.6s %c skip row with \\n ", fBuffer, 0x19 );
          tft.print(lineText);
          _char += 0x10;
        continue;
      }
      tft.setTextColor(ST7735_BLUE);
      sprintf( fBuffer, "%#x", _char);
      // sprintf( lineText, "%6.6s 0123 4567 89ab cdef\n", fBuffer );
      sprintf( lineText, "%6.6s", fBuffer );
      tft.print(lineText);
      tft.setTextColor(ST7735_WHITE);
      for( int block=0; block<4; block++){
        sprintf( lineText, " %c%c%c%c"
          , _char 
          , _char+1 
          , _char+2 
          , _char+3 
          );
        _char+=4;
        tft.print(lineText);
      }
      
      
    }
    lastpage=page;  
  }


  encMovement = Encoder.getValue();
  if (encMovement) {
    if(encMovement > 0) page++;
    else page--;
  }
}
