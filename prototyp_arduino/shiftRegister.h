#define DATA_PIN 6   // SER = DATA PIN
#define LATCH_PIN 5  // RCLK = LATCH PIN
#define CLOCK_PIN 4  // SRCLK = SHIFT CLOCK PIN
// uint8_t shiftRegisterBuffer[7] = { 0 };
uint8_t shiftRegisterBuffer[7] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };

const uint8_t number[] = {
  0b00010001,  // 0
  0b11011101,  // 1
  0b00111000,  // 2
  0b10011000,  // 3
  0b11010100,  // 4
  0b10010010,  // 5
  0b00010010,  // 6
  0b11011001,  // 7
  0b00010000,  // 8
  0b10010000,  // 9
  0b11111111,  // 10 nothing
  0b11111110,  // 11 -
  0b11110000,  // 12 °
  0b00110011,  // 13 C
};
const uint8_t digit[] = {
  0b00000100,  // D1
  0b00001000,  // D2
  0b00010000,  // D3
  0b00100000,  // D4
  0b01000000,  // D5
  0b10000000   // D6
};


volatile uint8_t displayValues[6] = { 10, 10, 10, 10, 12, 13 };
volatile uint8_t currentDigit = 0;

// Timer settings
const uint32_t targetFrequency = 300;  // 200 Hz frequency for the ISR
const uint32_t timerPrescaler = 64;    // Timer prescaler


void setSingleBit(uint8_t bitIndex, bool value) {
  uint8_t byteIndex = bitIndex / 8;    // Determine the byte index
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
    setSingleBit(currentBitIndex, bitValue);   // Set the bit in the buffer
  }
}



// Function to update the buffer with current data
void updateBuffer() {
  // Update bargraph data (first two bytes)
  // shiftRegisterBuffer[0] = 0b10100111;
  // shiftRegisterBuffer[1] = 0b11010011;
  // shiftRegisterBuffer[2] = 0b10110111;

  // 7-Segment display data will be handled by the ISR (last two bytes)
}


void updateDisplayValues(int tens, int ones) {
  // Clear displayValues
  for (int i = 0; i < 4; i++) {
    displayValues[i] = 10;  // Set to "nothing" initially
  }

  // Handle tens place
  if (tens < 0) {
    displayValues[0] = 11;     // Display '-' for negative sign
    displayValues[1] = -tens;  // Map the absolute value of tens
    // displayValues[1] = 8;  // Map the absolute value of tens
  } else {
    displayValues[1] = tens;  // Map the tens directly
    // displayValues[1] = 8;  // Map the tens directly
  }

  // Handle ones place
  // displayValues[2] = 7;  // Extract and map the first digit of ones
  // displayValues[3] = 6;  // Extract and map the second digit of ones
  displayValues[2] = (ones / 10);  // Extract and map the first digit of ones
  displayValues[3] = (ones % 10);  // Extract and map the second digit of ones
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
  uint32_t timerPeriod = F_CPU / (prescaler * frequency) - 1;  // F_CPU is 16MHz

  TCCR1A = 0;  // Disable the timer and clear configuration
  TCCR1B = 0;

  TCCR1B |= (1 << WGM12);  // CTC mode
  TCCR1B |= (prescaler == 1 ? (1 << CS10) : prescaler == 8  ? (1 << CS11)
                                          : prescaler == 64 ? (1 << CS11) | (1 << CS10)
                                                            : 0);  // Prescaler selection

  OCR1A = timerPeriod;

  TIMSK1 |= (1 << OCIE1A);  // Enable Timer1 compare match A interrupt
  sei();
}


// Timer1 ISR - Handles 7-segment display multiplexing
ISR(TIMER1_COMPA_vect) {
  // Clear the current digit
  shiftRegisterBuffer[3] = 0x00;  // Clear digits
  shiftRegisterBuffer[4] = 0x00;  // Clear segments

  // Move to the next digit
  currentDigit = (currentDigit + 1) % 6;

  // Update the buffer for the current digit
  shiftRegisterBuffer[3] = number[displayValues[currentDigit]];  // Set segment data

  shiftRegisterBuffer[4] = digit[currentDigit];  // Activate current digit

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