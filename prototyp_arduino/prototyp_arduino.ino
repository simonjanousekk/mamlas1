#define ENCODER_OPTIMIZE_INTERRUPTS
// external libs
#include <Encoder.h>
#include <MIDIUSB.h>

// my includes
#include "potenciometer.h"
#include "rot_encoder.h"

// Encoder pins
RotEncoder rotEnc1(0, 1, 1);
// RotEncoder rotEnc2(2, 3, 2);

Potenciometer pot1(A0, 3);
Potenciometer pot2(A1, 4);

// Potenciometer slider1(A2, 5);
// Potenciometer slider2(A3, 6);

// Variables
long oldPosition = -999;
int pot1_last_midi_value;

void setup() {
  Serial.begin(9600);
  Serial.println("START");
}

// Main loop
void loop() {
  pot1.update();
  pot2.update();

  rotEnc1.update();
  rotEnc2.update();

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
