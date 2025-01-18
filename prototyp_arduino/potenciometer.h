class Potenciometer {
private:
  int pin, lastMidiValue, midiNumber, midiValue;
public:
  Potenciometer(int p, int n)
    : pin(p), midiNumber(n), lastMidiValue(-1) {}
  void begin() {
    pinMode(pin, INPUT);
    update();
  }

  void update() {
    int value = analogRead(pin);
    midiValue = map(value, 0, 1023, 0, 127);
    if (lastMidiValue != midiValue) {
      sendData();
      // controlChange(0, midiNumber, midiValue);  // Channel 1, CC number 2
      lastMidiValue = midiValue;
    }
  }

  void sendData() {
    Serial.println("sending pot " + midiNumber);
    midiEventPacket_t event = { 0x0B, 0xB0 | 0, midiNumber, midiValue };
    MidiUSB.sendMIDI(event);
  }
};