class Bargraph {

private:
  int index;

public:
  Bargraph(int i)
    : index(i) {}

  void update(int val) {
    setMultiBit(index, 10, ((1 << val) - 1) << (10 - val));
}
};




// class Switch {
// private:
//   int pin, midiNumber, lastPosition;

// public:
//   Switch(int p, int n)
//     : pin(p), midiNumber(n), lastPosition(-1) {}

//   void begin() {
//     pinMode(pin, INPUT);
//   }

//   void update() {
//     int position = digitalRead(pin);

//     if (position != lastPosition) {
//       setSingleBit(5, position);
//       // setSingleBit(2, position);


//       midiEventPacket_t event = { 0x0B, 0xB0 | 0, midiNumber, position };
//       MidiUSB.sendMIDI(event);

//       lastPosition = position;
//     }
//   }
// };
