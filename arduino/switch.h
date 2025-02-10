
class Switch {
private:
  int pin, midiNumber, position, lastPosition;

public:
  Switch(int p, int n)
    : pin(p), midiNumber(n), lastPosition(-1) {
    pinMode(pin, INPUT_PULLUP);
  }

  void update() {
    position = digitalRead(pin);
    if (position != lastPosition) {
      sendData();
      lastPosition = position;
    }
  }

  void sendData() {
    midiEventPacket_t event = { 0x0B, 0xB0 | 0, midiNumber, position};
    MidiUSB.sendMIDI(event);
  }
};
