#define DATA_PIN 6   // SER = DATA PIN
#define LATCH_PIN 5  // RCLK = LATCH PIN
#define CLOCK_PIN 4  // SRCLK = SHIFT CLOCK PIN
uint8_t shiftRegisterBuffer[7] = { 0 };

const uint8_t number[] = {
  0b11000000,  // 0
  0b11111001,  // 1
  0b10100100,  // 2
  0b10110000,  // 3
  0b10011001,  // 4
  0b10010010,  // 5
  0b10000010,  // 6
  0b11111000,  // 7
  0b10000000,  // 8
  0b10010000,  // 9
  0b10111111,  // -  10
  0b10011100,  // °  11
  0b11000110,  // C  12
  0b11111111,  // nothing  13
  0b10001100,  // P  14
  0b10000110,  // E  15
  0b11010100,  // N  16
};


const uint8_t digit[] = {
  0b00000001,  // D1
  0b00000010,  // D2
  0b00000100,  // D3
  0b00001000,  // D4
  0b00010000,  // D5
  0b00100000   // D6
};

volatile uint8_t displayValues[6] = { 13, 14, 15, 16, 1, 5 };  // Example: Display 012345
volatile uint8_t currentDigit = 0;                         // Keeps track of which digit to update

// Timer settings
const uint32_t targetFrequency = 300;  // 200 Hz frequency for the ISR
const uint32_t timerPrescaler = 64;    // Timer prescaler


void setSingleBit(uint8_t bitIndex, bool value) {
  uint8_t byteIndex = bitIndex / 8;  // Determine the byte index
  uint8_t bitPosition = bitIndex % 8;  // Determine the bit position within the byte
  if (value) {
    shiftRegisterBuffer[byteIndex] |= (1 << bitPosition);  // Set the bit
  } else {
    shiftRegisterBuffer[byteIndex] &= ~(1 << bitPosition);  // Clear the bit
  }
}


void setMultiBit(uint8_t startIndex, uint8_t numBits, uint16_t value) {
  for (uint8_t i = 0; i < numBits; i++) {
    uint8_t currentBitIndex = startIndex + i;  // Calculate the current bit position
    bool bitValue = (value & (1 << i)) != 0;   // Extract the corresponding bit from the value
    setSingleBit(currentBitIndex, bitValue);  // Set the bit in the buffer
  }
}






// Function to update the buffer with current data
void updateBuffer() {
  // Update bargraph data (first two bytes)
  shiftRegisterBuffer[0] = 0b10100111;
  shiftRegisterBuffer[1] = 0b11010011;
  shiftRegisterBuffer[2] = 0b10110111;

  // 7-Segment display data will be handled by the ISR (last two bytes)
}

// Function to update the shift register with the buffer
void updateShiftRegister() {
  digitalWrite(LATCH_PIN, LOW);
  for (int i = 6; i >= 0; i--) {  // Send all 7 bytes
    shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST, shiftRegisterBuffer[i]);
  }
  digitalWrite(LATCH_PIN, HIGH);
}













void setupTimerInterrupt(uint32_t frequency, uint32_t prescaler) {
  // Lower the target frequency to slow down multiplexing (e.g., 50 Hz)
  uint32_t timerPeriod = F_CPU / (prescaler * frequency) - 1; // F_CPU is 16MHz

  TCCR1A = 0;  // Disable the timer and clear configuration
  TCCR1B = 0;

  TCCR1B |= (1 << WGM12);              // CTC mode
  TCCR1B |= (prescaler == 1 ? (1 << CS10) :
             prescaler == 8 ? (1 << CS11) :
             prescaler == 64 ? (1 << CS11) | (1 << CS10) : 0); // Prescaler selection

  OCR1A = timerPeriod;

  TIMSK1 |= (1 << OCIE1A); // Enable Timer1 compare match A interrupt
  sei();
}


// Timer1 ISR - Handles 7-segment display multiplexing
ISR(TIMER1_COMPA_vect) {
  // Clear the current digit
  shiftRegisterBuffer[5] = 0x00;  // Clear digits
  shiftRegisterBuffer[6] = 0x00;  // Clear segments

  // Move to the next digit
  currentDigit = (currentDigit + 1) % 6;

  // Update the buffer for the current digit
  shiftRegisterBuffer[6] = number[displayValues[currentDigit]];  // Set segment data

  shiftRegisterBuffer[5] = digit[currentDigit];  // Activate current digit

  // Update shift registers with the new buffer
  updateShiftRegister();
}




void SR_init() {
  pinMode(DATA_PIN, OUTPUT);
  pinMode(LATCH_PIN, OUTPUT);
  pinMode(CLOCK_PIN, OUTPUT);

  setupTimerInterrupt(targetFrequency, timerPrescaler);

  updateBuffer();
  updateShiftRegister();
}