import com.pi4j.catalog.components.base.I2CDevice;
import com.pi4j.catalog.components.LcdDisplay;
import com.pi4j.Pi4J;

import com.pi4j.context.Context;
import com.pi4j.io.i2c.I2C;
import com.pi4j.io.i2c.I2CConfig;
import com.pi4j.io.i2c.I2CProvider;

String[] story = new String[3];
LcdDisplay lcd;
int index = 0;
// I2C Bus and Address: is it needed ?
int i2cBus = 1; // Default I2C bus on Raspberry Pi
int lcdAddress = 0x27; // Replace with your LCD's I2C address
/*
// Configure I2C
 I2CConfig config = I2C.newConfigBuilder(pi4j)
 .id("lcd")
 .name("LCD Display")
 .bus(i2cBus)
 .device(lcdAddress)
 .build();
 
 // Get I2C instance
 I2C ctx = pi4j.create(config);
 
 LcdDisplay lcd = new LcdDisplay(pi4j, 4, 20);
 
 lcd.displayText("CRA!!");
 
 delay(1000);
 */
void setup() {
  size(240, 240);
  // Initialize Pi4J context
  Context pi4j = Pi4J.newAutoContext();

  lcd = new LcdDisplay(pi4j, 4, 20);
  lcd.clearDisplay();

  lcd.displayText("Initialize....");
  story[0] = "It is morning on a faraway planet";
  story[1] = "WARNING: A storm is coming";
  story[2] = "You must collect sample";
}

void draw() {
  fill(255, 0, 0);
  noStroke();
  rect(width/2, height/2, 20,20);


}

void mousePressed() {
  println("Debug");
  lcd.displayText(story[index]);
  if (index == 2) {
    index = 0;
  } else {
    index+=1;
  }
}
