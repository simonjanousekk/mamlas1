import processing.io.*;

// Define the SPI instance
SPI adc;

// GPIO pin mappings for the display
final int DC_PIN = 24; // Data/Command pin
final int CS_PIN = 8;  // Chip Select pin
final int RESET_PIN = 25; // Reset pin

void setup() {
  // Initialize SPI
  adc = new SPI();
  adc.begin(SPI.DEVICE_0, 8000000); // SPI channel 0 with 8 MHz clock

  // Set GPIO modes
  GPIO.pinMode(DC_PIN, GPIO.OUTPUT);
  GPIO.pinMode(CS_PIN, GPIO.OUTPUT);
  GPIO.pinMode(RESET_PIN, GPIO.OUTPUT);

  // Initialize the display
  initDisplay();
}

void draw() {
  // Example: Fill the screen with red color
  fillScreen(0xF800); // 16-bit color (RGB565) for red
}

void initDisplay() {
  // Reset the display
  GPIO.digitalWrite(RESET_PIN, GPIO.LOW);
  delay(10);
  GPIO.digitalWrite(RESET_PIN, GPIO.HIGH);
  delay(10);

  // Initialize display commands
  sendCommand(0x11); // Sleep out
  delay(120);
  
  sendCommand(0x36); // Memory Access Control
  sendData(0x48); // Set rotation (change for landscape/portrait)

  sendCommand(0x3A); // Interface Pixel Format
  sendData(0x55); // 16 bits per pixel
  
  sendCommand(0x29); // Display ON
}

void fillScreen(int color) {
  sendCommand(0x2A); // Column Address Set
  sendData(0x00);
  sendData(0x00);
  sendData(0x00);
  sendData(0xEF); // 240 pixels wide

  sendCommand(0x2B); // Page Address Set
  sendData(0x00);
  sendData(0x00);
  sendData(0x00);
  sendData(0xEF); // 240 pixels high

  sendCommand(0x2C); // Memory Write

  GPIO.digitalWrite(DC_PIN, GPIO.HIGH); // Data mode
  GPIO.digitalWrite(CS_PIN, GPIO.LOW);

  // Fill the screen with the color
  byte[] buffer = new byte[240 * 240 * 2]; // RGB565: 2 bytes per pixel
  for (int i = 0; i < buffer.length; i += 2) {
    buffer[i] = (byte)(color >> 8);   // High byte
    buffer[i + 1] = (byte)(color);   // Low byte
  }
  adc.transfer(buffer); // Send pixel data

  GPIO.digitalWrite(CS_PIN, GPIO.HIGH);
}

// Helper function to send a command
void sendCommand(int command) {
  GPIO.digitalWrite(DC_PIN, GPIO.LOW); // Command mode
  GPIO.digitalWrite(CS_PIN, GPIO.LOW);
  adc.transfer((byte)command);
  GPIO.digitalWrite(CS_PIN, GPIO.HIGH);
}

// Helper function to send data
void sendData(int data) {
  GPIO.digitalWrite(DC_PIN, GPIO.HIGH); // Data mode
  GPIO.digitalWrite(CS_PIN, GPIO.LOW);
  adc.transfer((byte)data);
  GPIO.digitalWrite(CS_PIN, GPIO.HIGH);
}
