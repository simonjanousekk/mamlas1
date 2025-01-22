class GameState {


  // TIME PHASES STUFF
  int phaseIndex = 0;
  int dayLength = 1000 * 60 * 2;
  String[] timePhases = {"DAWN", "MORNING", "NOON", "AFTERNOON", "DUSK", "EVENING", "MIDNIGHT", "NIGHT"};
  String timePhase = timePhases[phaseIndex];
  int dayStart = 0;

  // TEMPERATURE STUFF
  int outTemperaturePhases[] = {-40, 40, 100, 20, -50, -100, -150, -80};
  float temperature = outTemperaturePhases[phaseIndex];
  //float temperatureChangeSpeed = .1;
  float outTemperature = outTemperaturePhases[phaseIndex];
  float outTemperatureChangeSpeed = .2;

  boolean heating;
  boolean cooling;
  float coolingStrength = .1;
  float heatingStrength = .1;


  // POWER STUFF
  int powerUsage = 0;
  float batteryDrain = 100/5;
  float battery = 100;






  GameState() {
    //handle arduino stuff
    turnAllLedOff();
    turnAllLedOn();



    sendTemperature(int(temperature));
    sendBattery(battery);
    sendPowerUsage(powerUsage);
  }


  void update() {

    updatePowerUsage();
    updateBattery();
    updateTimePhase();
    updateTemperature();

    battery = constrain(battery, 0, 100);
    powerUsage = constrain(powerUsage, 0, 100);
  }


  void updateTimePhase() {
    if (millis() > dayStart + dayLength) {
      dayStart = millis();
    }
    phaseIndex = (int) map(millis(), dayStart, dayStart+dayLength, 0, timePhases.length);
    timePhase = timePhases[phaseIndex];
  }

  void updateTemperature() {
    if (!isCloseEnough(outTemperature, outTemperaturePhases[phaseIndex], 2)) {
      if (outTemperature > outTemperaturePhases[phaseIndex]) {
        outTemperature -= outTemperatureChangeSpeed;
      } else if (outTemperature < outTemperaturePhases[phaseIndex]) {
        outTemperature += outTemperatureChangeSpeed;
      }
    }

    float temperatureChange = map(outTemperature-temperature, 0, 100, 0, .2);
    temperature += temperatureChange;
    
    if (heating) temperature += heatingStrength;
    if (cooling) temperature -= coolingStrength;
    
    //if (temperature > outTemperature) {
    //  temperature -= temperatureChangeSpeed;
    //} else if (temperature < outTemperature) {
    //  temperature += temperatureChangeSpeed;
    //}

    sendTemperature(int(temperature));
  }

  void updatePowerUsage() {
    int pu = 0;
    if (player.onTerrain != player.terrainSetting && player.moving) pu += batteryDrain;
    if (heating) pu += batteryDrain;
    if (cooling) pu += batteryDrain;

    powerUsage = pu;
    sendPowerUsage(powerUsage);
  }

  void updateBattery() {
    battery -= map(powerUsage, 0, 100, 0, 0.1);
    sendBattery(battery);
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

int lastBatteryUnit = -1;
void sendBattery(float battery) {
  int batteryUnit = (int) battery / 10;
  if (lastBatteryUnit != batteryUnit) {
    mb.sendControllerChange(1, 15, batteryUnit);
    lastBatteryUnit = batteryUnit;
  }
}

int lastPowerUnit = -1;
void sendPowerUsage(float powerUsage) {
  int powerUnit = (int) powerUsage / 10;
  if (lastPowerUnit != powerUnit) {
    mb.sendControllerChange(1, 16, powerUnit);
    lastPowerUnit = powerUnit;
  }
}
