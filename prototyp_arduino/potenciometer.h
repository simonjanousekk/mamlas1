class Potenciometer {
private:
  int pin, lastMidiValue, midiNumber;
public:
  Potenciometer(int p, int n)
    : pin(p), midiNumber(n), lastMidiValue(-1) {}
  void begin() {
    pinMode(pin, INPUT);
  }

  void update() {
    int value = analogRead(pin);
    int midiValue = map(value, 0, 1023, 0, 127);
    if (lastMidiValue != midiValue) {
      midiEventPacket_t event = { 0x0B, 0xB0 | 0, midiNumber, midiValue };
      MidiUSB.sendMIDI(event);
      // controlChange(0, midiNumber, midiValue);  // Channel 1, CC number 2
      lastMidiValue = midiValue;
    }
  }
};