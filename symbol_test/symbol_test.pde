import com.pi4j.catalog.components.base.I2CDevice;
import com.pi4j.catalog.components.LcdDisplay;
import com.pi4j.Pi4J;
import com.pi4j.context.Context;
import com.pi4j.io.i2c.I2C;

LcdDisplay lcd;
int i2cBus = 1;
int lcdAddress = 0x27;

void setup() {
  size(200, 200);
  Context pi4j = Pi4J.newAutoContext();
  lcd = new LcdDisplay(pi4j, 4, 20);
  lcd.clearDisplay();

  for (int i = 0; i < 256; i++) {
    int charCode = i;
    lcd.writeCharacter((char) charCode, 1, 20);
    delay(1000);
    println("Charcode: ", charCode);
  }
}

void draw() {
}
