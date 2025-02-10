class RotEncoder {
private:
  int pin1, pin2;     // Pins for the rotary encoder
  int midiNumber;     // MIDI CC number
  long lastPosition;  // Last encoder position
  Encoder enc;        // Encoder instance

public:
  RotEncoder(int p1, int p2, int n)
    : pin1(p1), pin2(p2), midiNumber(n), lastPosition(0), enc(p1, p2) {
    pinMode(pin1, INPUT_PULLUP);
    pinMode(pin2, INPUT_PULLUP);
  }

  void begin() {
  }

  void update() {
    long newPosition = enc.read() / 4;
    if (newPosition != lastPosition) {
      midiEventPacket_t event;
      if (newPosition > lastPosition) {
        event = { 0x0B, 0xB0 | 0, midiNumber, 1 };
      } else {
        event = { 0x0B, 0xB0 | 0, midiNumber, 0 };
      }
      MidiUSB.sendMIDI(event);
      lastPosition = newPosition;
    }
  }
};
