#define ENCODER_OPTIMIZE_INTERRUPTS
#include <Encoder.h>
#include <MIDIUSB.h>
#include "potenciometer.h"

// Encoder pins
Encoder myEnc(0, 1);

Potenciometer pot1(A0, 2);
Potenciometer pot2(A1, 3);

// Potenciometer slider1(A2, 4);
// Potenciometer slider2(A3, 5);

// Variables
long oldPosition = -999;
int pot1_last_midi_value;

void setup() {
  Serial.begin(9600);
  Serial.println("START");
}

// Main loop
void loop() {


  // Read encoder position and send MIDI CC
  long newPosition = myEnc.read() / 4;
  if (newPosition != oldPosition) {
    if (newPosition > oldPosition) {
      controlChange(0, 1, 1);  // Send CC with value 1 for clockwise
    } else {
      controlChange(0, 1, 0);  // Send CC with value 0 for counterclockwise
    }
    // MidiUSB.flush();
    oldPosition = newPosition;
  }

  pot1.update();
  pot2.update();

  // Process incoming MIDI messages
  midiEventPacket_t rx = MidiUSB.read();
  if (rx.header != 0) {  // If a MIDI message is received
    logMidiMessage(rx);
  }

MidiUSB.flush();
}

// Function to send MIDI Control Change messages
void controlChange(byte channel, byte control, byte value) {
  midiEventPacket_t event = { 0x0B, 0xB0 | channel, control, value };
  MidiUSB.sendMIDI(event);
}

// Function to log received MIDI messages
void logMidiMessage(midiEventPacket_t rx) {
  Serial.print("Received MIDI Message: ");
  Serial.print("Type: 0x");
  Serial.print(rx.header, HEX);
  Serial.print(", Channel: ");
  Serial.print(rx.byte1 & 0x0F);
  Serial.print(", Control: ");
  Serial.print(rx.byte2);
  Serial.print(", Value: ");
  Serial.println(rx.byte3);
}



