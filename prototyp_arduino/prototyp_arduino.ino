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

// #include "sevenSeg.h"


// ----
// INPUTS
// ----

// ENCODERS
RotEncoder rotEnc1(0, 1, 1);  // pin1, pin2, CC
//RotEncoder rotEnc2(2, 3, 2);

// POTENCIOMETERS
Potenciometer pot1(A0, 3);  // pin, CC
Potenciometer pot2(A1, 4);
Potenciometer slider1(A2, 5);
// Potenciometer slider2(A3, 6);

// BUTTONS
Switch button1(16, 10);  // pin, CC
Switch button2(17, 11);


// ----
// OUTPUTS
// ----


int tempTens = -8;
int tempOnes = 65;

Bargraph b1 = Bargraph(0);

void setup() {

  // randomSeed(analogRead(A5) + millis());
  SR_init();

  updateDisplayValues(tempTens, tempOnes);


  b1.update(5);
}

// Main loop
void loop() {
  // pot1.update();
  // pot2.update();
  // slider1.update();

  // rotEnc1.update();
  // //rotEnc2.update();

  // button1.update();
  // button2.update();


  // Process incoming MIDI messages
  midiEventPacket_t rx = MidiUSB.read();
  if (rx.header != 0) {  // If a MIDI message is received
    handleIncomingMidi(rx);
  }

  MidiUSB.flush();


  // while (true) {
  //   // Keep all LEDs on indefinitely
  //   delay(100);
  // }
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
    if (control == 1 && value == 1) {
      pot1.sendData();
      pot2.sendData();
      slider1.sendData();
    } else if (control == 10) {
      tempTens = value;
      updateDisplayValues(tempTens, tempOnes);
    } else if (control == 11) {
      tempOnes = value;
      updateDisplayValues(tempTens, tempOnes);
    }
  }
}
