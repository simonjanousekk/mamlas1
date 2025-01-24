class GameState {


  // TIME PHASES STUFF
  int dayPhaseIndex = 0;
  int dayLength = 1000 * 60 * 8;
  String[] dayPhases = {"DAWN", "MORNING", "NOON", "AFTERNOON", "DUSK", "EVENING", "MIDNIGHT", "NIGHT"};
  String dayPhase = dayPhases[dayPhaseIndex];
  int dayStart = 0;
  int dayTime = 0;
  float phaseLength = dayLength / dayPhases.length;
  float currentPhaseTemp, nextPhaseTemp;

  // TEMPERATURE STUFF
  int outTemperaturePhases[][] = {{30, 60}, {80, 110}, {140, 160}, {70, 100}, {0, 40}, {-40, -80}, {-100, -120}, {-20, -70}};
  float temperature = 0;
  float outTemperature = 0;

  boolean heating;
  boolean cooling;
  float coolingStrength = .1;
  float heatingStrength = .1;


  // POWER STUFF
  int powerUsage = 0;
  float batteryDrain = 100/10;
  float battery = 100;



  GameState() {
    //handle arduino stuff
    turnAllLedOff();
    //turnAllLedOn();



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


  int prevDayPhaseIndex = -1;
  void updateTimePhase() {
    if (millis() >= dayStart + dayLength) {
      dayStart = millis();
    }
    dayTime = millis() - dayStart;
    dayPhaseIndex = (int) map(millis(), dayStart, dayStart+dayLength, 0, dayPhases.length);
    dayPhase = dayPhases[dayPhaseIndex];

    // generates random temperature for current and next phase
    if (prevDayPhaseIndex != dayPhaseIndex) {
      int cR[] = outTemperaturePhases[dayPhaseIndex];
      int nR[] = outTemperaturePhases[(dayPhaseIndex + 1) % outTemperaturePhases.length];
      currentPhaseTemp = random(cR[0], cR[1]);
      nextPhaseTemp = random(nR[0], nR[1]);
      prevDayPhaseIndex = dayPhaseIndex;
    }
  }

  void updateTemperature() {
    float progressInPhase = map(dayTime % phaseLength, 0, phaseLength, 0, 1);
    progressInPhase = applyEasing(progressInPhase, "easeInOutCubic");

    outTemperature = lerp(currentPhaseTemp, nextPhaseTemp, progressInPhase);


    float temperatureChange = (outTemperature - temperature) * 0.005; // Proportional to the difference
    temperature += temperatureChange;

    if (heating) temperature += heatingStrength;
    if (cooling) temperature -= coolingStrength;
    
    sendTemperature(int(temperature));
  }

  void updatePowerUsage() {
    int pu = 0;
    if (player.onTerrain != player.terrainSetting && player.moving) pu += batteryDrain;
    if (heating) pu += batteryDrain*2;
    if (cooling) pu += batteryDrain*2;
    if (screen2State == s2s.GPS) pu += batteryDrain*3;
    if (player.speed>0) { // player moving
      float s = map(player.speed, 0, player.max_speed, 0, 2); // speed drain
      pu += batteryDrain*s;
      float t = abs(player.onTerrain - player.terrainSetting);
      println(t);
      pu += batteryDrain*t;
    }
    if (player.scanning) pu += batteryDrain*1;

    powerUsage = pu;
    sendPowerUsage(powerUsage);
  }

  void updateBattery() {
    battery -= map(powerUsage, 0, 100, 0, 0.01);
    sendBattery(battery);
  }
}

int lastTemperature = -1000;
void sendTemperature(int t) {
  if (lastTemperature != t) {
    //println("sending temp: " + lastTemperature + " " + t);
    int tens = abs(t / 100);
    int units = abs(t % 100);
    boolean isNegative = t < 0;
    mb.sendControllerChange(1, 10, tens);
    mb.sendControllerChange(1, 11, units);
    mb.sendControllerChange(1, 12, int(isNegative));
    lastTemperature = t;
  }
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
