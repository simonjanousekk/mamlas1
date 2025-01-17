class RotEncoder {
private:
  int pin1, pin2;     // Pins for the rotary encoder
  int midiNumber;     // MIDI CC number
  long lastPosition;  // Last encoder position
  Encoder enc;        // Encoder instance

public:
  RotEncoder(int p1, int p2, int n)
    : pin1(p1), pin2(p2), midiNumber(n), lastPosition(0), enc(p1, p2) {}

  void begin() {
    // pinMode(pin1, INPUT);
    // pinMode(pin2, INPUT);
  }

  void update() {
    long newPosition = enc.read() / 4;
    if (newPosition != lastPosition) {
      if (newPosition > lastPosition) {
        midiEventPacket_t event = { 0x0B, 0xB0 | 0, midiNumber, 1 };
        MidiUSB.sendMIDI(event);
      } else {
        midiEventPacket_t event = { 0x0B, 0xB0 | 0, midiNumber, 0 };
        MidiUSB.sendMIDI(event);
      }
      lastPosition = newPosition;
    }
  }
};
