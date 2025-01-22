class GameState {

  int temperature = -124;
  int powerUsage = 0;

  float battery = 100;
  int sampleCount = 1;


  GameState() {
    turnOnLed(2);
    sendTemperature(temperature);
    sendBattery(battery);
    sendPowerUsage(powerUsage);
  }


  void update() {
    battery = constrain(battery, 0, 100);
    powerUsage = constrain(powerUsage, 0, 100);




    //if (frameCount % 120 == 0) {
    //  temperature = (int) random(-999, 999);

    //  temperature = temperature > 999 ? -999 : temperature;
    //  temperature = temperature < -999 ? 999 : temperature;

    //  sendTemperature(temperature);
    //}

    if (frameCount % 60 == 0) {
      battery -= 1.0;
      sendBattery(battery);

      sendPowerUsage(powerUsage);
    }
  }
}



void sendTemperature(int t) {
  int tens = abs(t / 100);
  int units = abs(t % 100);
  boolean isNegative = t < 0;
  mb.sendControllerChange(1, 10, tens);
  mb.sendControllerChange(1, 11, units);
  mb.sendControllerChange(1, 12, int(isNegative));
}

void sendBattery(float battery) {
  int batteryUnit = (int) battery / 10;
  mb.sendControllerChange(1, 15, batteryUnit);
}

void sendPowerUsage(float powerUsage) {
  int powerUnit = (int) powerUsage / 10;
  mb.sendControllerChange(1, 16, powerUnit);
}

void turnOnLed(int index) {
  mb.sendControllerChange(2, index, 1);
}

void turnOffLed(int index) {
  mb.sendControllerChange(2, index, 0);
}
