// #define ENCODER_OPTIMIZE_INTERRUPTS
// external libs
#include <Encoder.h>
#include <MIDIUSB.h>

// MY FILES
#include "shiftRegister.h"

#include "potenciometer.h"
#include "switch.h"
#include "rot_encoder.h"
#include "bargraph.h"
#include "led.h"

// #include "sevenSeg.h"


// ----
// INPUTS
// ----

// ENCODERS
RotEncoder rotEnc1(0, 1, 1);  // pin1, pin2, CC
RotEncoder rotEnc2(2, 3, 2);

// POTENCIOMETERS
Potenciometer pot1(A0, 3);  // pin, CC
Potenciometer pot2(A1, 4);

Potenciometer slider1(A2, 5);
// Potenciometer slider2(A3, 6);

// BUTTONS
Switch button1(A5, 10);  // pin, CC
Switch button2(15, 11);

Switch switch1(8, 20);
Switch switch2(9, 21);
Switch switch3(10, 22);
Switch switch4(14, 23);

// ----
// OUTPUTS
// ----

Bargraph battery = Bargraph(0);
Bargraph power = Bargraph(10);

int ledIndexes[] = { 40, 41, 42, 43, 45, 46, 47, 48, 49, 50, 51, 52, 54, 55 };  // Array of indexes
const int numLeds = sizeof(ledIndexes) / sizeof(ledIndexes[0]);
Led leds[numLeds];

int tempTens = 6;
int tempOnes = 66;
bool isNegative = true;



void setup() {
  // randomSeed(analogRead(A5) + millis());
  SR_init();

  for (int i = 0; i < numLeds; i++) {
    leds[i] = Led(ledIndexes[i]);
  }
}

int lastPosition = -1;

// Main loop
void loop() {
  pot1.update();
  pot2.update();
  slider1.update();

  rotEnc1.update();
  rotEnc2.update();

  button1.update();
  button2.update();

  switch1.update();
  switch2.update();
  switch3.update();
  switch4.update();



  for (int i = 0; i < numLeds; i++) {
    leds[i].update();
  }


  // Process incoming MIDI messages
  midiEventPacket_t rx = MidiUSB.read();
  if (rx.header != 0) {  // If a MIDI message is received
    handleIncomingMidi(rx);
  }

  MidiUSB.flush();
}

// Function to send MIDI Control Change messages
void controlChange(byte channel, byte control, byte value) {
  midiEventPacket_t event = { 0x0B, 0xB0 | channel, control, value };
  MidiUSB.sendMIDI(event);
}

// Function to log received MIDI messages
void handleIncomingMidi(midiEventPacket_t rx) {
  Serial.print("Received MIDI Message: ");
  Serial.print("Type: 0x");
  Serial.print(rx.header, HEX);
  Serial.print(", Channel: ");
  Serial.print(rx.byte1 & 0x0F);
  Serial.print(", Control: ");
  Serial.print(rx.byte2);
  Serial.print(", Value: ");
  Serial.println(rx.byte3);

  int channel = rx.byte1 & 0x0F;
  int control = rx.byte2;
  int value = rx.byte3;

  if (channel == 1) {
    if (control == 1 && value == 1) {  // REQUEST FROM PROCESSING TO SEND ANALOG VALUES
      pot1.sendData();
      pot2.sendData();
      slider1.sendData();
      // slider2.sendData();

      switch1.sendData();
      switch2.sendData();
      switch3.sendData();
      switch4.sendData();
    } else if (control == 10) {  // SEVEN SEGMENT DISPLAY DATA
      tempTens = value;
      updateDisplayValues(tempTens, tempOnes, isNegative);
    } else if (control == 11) {  // SEVEN SEGMENT DISPLAY DATA
      tempOnes = value;
      updateDisplayValues(tempTens, tempOnes, isNegative);
    } else if (control == 12) {  // SEVEN SEGMENT DISPLAY DATA
      isNegative = value;
      updateDisplayValues(tempTens, tempOnes, isNegative);
    } else if (control == 15) {  // battery bargraph data
      battery.update(value);
    } else if (control == 16) {  // power usage bargraph data
      power.update(value);
    }
  } else if (channel == 2) {
    if (value == 0) {
      leds[control].off();
    } else {
      leds[control].on();
    }
  }
}
