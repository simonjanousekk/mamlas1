class Potenciometer {
private:
  int pin, lastMidiValue, midiNumber, midiValue;
  static const int arraySize = 20;  // Size of the array
  int values[arraySize];            // Array to store potentiometer readings
  int valueIndex = 0;               // Current index in the array
  bool isFilled = false;            // Flag to check if the array is filled

public:
  Potenciometer(int p, int n)
    : pin(p), midiNumber(n), lastMidiValue(-1) {
    memset(values, 0, sizeof(values)); // Initialize the array to 0
  }

  void begin() {
    pinMode(pin, INPUT);
    update();
  }

  void update() {
    int value = analogRead(pin);

    // Add the new value to the array
    values[valueIndex] = value;
    valueIndex = (valueIndex + 1) % arraySize;  // Wrap around the index

    // Check if the array is filled
    if (valueIndex == 0) {
      isFilled = true;
    }

    // Calculate the average if the array is filled
    if (isFilled) {
      int sum = 0;
      for (int i = 0; i < arraySize; i++) {
        sum += values[i];
      }
      int averageValue = sum / arraySize;

      // Map the averaged value to MIDI range
      midiValue = map(averageValue, 0, 1023, 0, 127);

      // Send MIDI data only if the value has changed
      if (lastMidiValue != midiValue) {
        sendData();
        lastMidiValue = midiValue;
      }
    }
  }

  void sendData() {
    midiEventPacket_t event = { 0x0B, 0xB0 | 0, midiNumber, midiValue };
    MidiUSB.sendMIDI(event);
  }
};
