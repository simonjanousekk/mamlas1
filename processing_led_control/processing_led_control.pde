import com.pi4j.Pi4J;
import com.pi4j.context.Context;
import com.pi4j.io.gpio.digital.DigitalOutput;

Context pi4j;
DigitalOutput ledPin;
boolean ledState = false; // Track LED state

void setup() {
  // Initialize Pi4J
  pi4j = Pi4J.newAutoContext();

  // Configure GPIO 17 as an output pin
  ledPin = pi4j.dout().create(17); // GPIO 17

  size(400, 200);
  textSize(20);
  fill(0);
  text("Press SPACE to toggle LED", 50, height / 2);
}

void draw() {
  // No continuous updates needed
}

void keyPressed() {
  if (key == ' ') {
    // Toggle LED state
    ledState = !ledState;
    if (ledState) {
      ledPin.high(); // Turn LED ON
    } else {
      ledPin.low(); // Turn LED OFF
    }
    println("LED State: " + (ledState ? "ON" : "OFF"));
  }
}

void exit() {
  // Turn off LED and clean up on exit
  ledPin.low();
  pi4j.shutdown();
  super.exit();
}
