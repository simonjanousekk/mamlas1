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
  int outTemperaturePhases[][] = {{ - 30, -60}, {20, 70}, {100, 120}, {40, 80}, {0, -40}, { - 70, -100}, { - 140, -160}, { - 80, -110} };
  float temperature = 0;
  float outTemperature = 0;
  int max_temperature = 80;
  int min_temperature = -125;
  LedDriver ledDriverTemperature = new LedDriver(new int[] {0, 3, 7});

  // COOL AND HEAT ʕ⌐■ᴥ■ʔ
  boolean heating;
  boolean cooling;
  float coolingStrength =.05;
  float heatingStrength =.05;

  // POWER STUFF
  int powerUsage = 0;
  float batteryDrain = 100 / 10;
  float battery = 100;

  // HAZARDS
  boolean hazardHappening = false;
  int lastHazard = 0;
  float hazardChanceMultiplier;
  boolean alertCold = false;
  boolean alertHot = false;
  boolean alertSand = false;
  boolean alertMag = false;


  float[] magStormChancePhases = {.25, .1, .02, .1, .25, .1, .02, 1}; // chances in %/100
  float[] sandStormChancePhases = {.1, .05, .01, .05, .1, .05, .01, .05};


  GameState() {
    //handle arduino stuff
    turnAllLedOff();



    sendTemperature(int(temperature));
    sendBattery(battery);
    sendPowerUsage(powerUsage);
  }


  void update() {
    updatePowerUsage();
    updateBattery();
    updateTimePhase();
    updateTemperature();
    updateAlert();

    battery = constrain(battery, 0, 100);
    powerUsage = constrain(powerUsage, 0, 100);
  }


  void updateHazards() {
    if (!(hazardMonitor.forecast == Forecast.CLEAR)) {
      hazardHappening = true;
      lastHazard = millis();
      if (hazardMonitor.forecast == Forecast.SANDSTORM) {
        alertSand = true;
        storm.startStorm(int(phaseLength), .1, .1);
      } else {
        alertSand = false;
      }
      if (hazardMonitor.forecast == Forecast.MAGSTORM) {
        alertMag = true;
        signalDisplay.randomizeSineGame();
      } else {
        alertMag = false;
      }
    }

    hazardChanceMultiplier = map(millis(), lastHazard, lastHazard + dayLength / 2, 0, 10);
    if (random(1) < magStormChancePhases[(dayPhaseIndex + 1) % dayPhases.length] * hazardChanceMultiplier) {
      println("magStorm imminent");
      hazardMonitor.forecast = Forecast.MAGSTORM;
    } else if (random(1) < sandStormChancePhases[(dayPhaseIndex + 1) % dayPhases.length] *hazardChanceMultiplier) {
      println("sandStorm imminent");
      hazardMonitor.forecast = Forecast.SANDSTORM;
    } else if (dayPhases[(dayPhaseIndex+1) % dayPhases.length] == "NOON") {
      hazardMonitor.forecast = Forecast.HOT;
    } else if (dayPhases[(dayPhaseIndex+1) % dayPhases.length] == "MIDNIGHT") {
      hazardMonitor.forecast = Forecast.COLD;
    } else {
      hazardMonitor.forecast = Forecast.CLEAR;
    }
  }

  void updateAlert() {
    if (hazardMonitor != null) {
      if (alertMag) {
        hazardMonitor.alert = Alerts.MAGSTORM;
      } else if (alertSand) {
        hazardMonitor.alert = Alerts.SANDSTORM;
      } else if (alertHot) {
        hazardMonitor.alert = Alerts.OVERHEATING;
      } else if (alertCold) {
        hazardMonitor.alert = Alerts.FREEZE;
      } else {
        hazardMonitor.alert = Alerts.NONE;
      }
      hazardMonitor.updateHazard();
    }
  }


  int prevDayPhaseIndex = -1;
  void updateTimePhase() {
    if (millis() >= dayStart + dayLength) {
      dayStart = millis();
    }
    dayTime = millis() - dayStart;
    dayPhaseIndex = (int) map(millis(), dayStart, dayStart + dayLength, 0, dayPhases.length);
    dayPhase = dayPhases[dayPhaseIndex];

    //generates random temperature for current and next phase
    if (prevDayPhaseIndex != dayPhaseIndex) { // called on new phase
      int cR[] = outTemperaturePhases[dayPhaseIndex];
      int nR[] = outTemperaturePhases[(dayPhaseIndex + 1) % outTemperaturePhases.length];
      currentPhaseTemp = random(cR[0], cR[1]);
      nextPhaseTemp = random(nR[0], nR[1]);

      if (hazardMonitor != null) updateHazards();

      prevDayPhaseIndex = dayPhaseIndex;
    }
  }

  void updateTemperature() {
    float progressInPhase = map(dayTime % phaseLength, 0, phaseLength, 0, 1);
    progressInPhase = applyEasing(progressInPhase, "easeInOutCubic");

    outTemperature = lerp(currentPhaseTemp, nextPhaseTemp, progressInPhase);


    float temperatureChange = (outTemperature - temperature) * 0.005; // Proportional to the difference
    temperature += temperatureChange;

    //this is generated and i dont kow if it works
    if (heating) {
      float heatingEffectiveness = max(0, 1 - (temperature / max_temperature)); // Less effective when already hot
      temperature += heatingStrength * heatingEffectiveness; // Slow, scalable adjustment
    }
    if (cooling) {
      float coolingEffectiveness = max(0, (temperature - min_temperature) / max_temperature); // Less effective when already cold
      temperature -= coolingStrength * coolingEffectiveness; // Slow, scalable adjustment
    }

    sendTemperature(int(temperature));

    ledDriverTemperature.turnBased(temperature > max_temperature || temperature < min_temperature);

    alertHot = temperature > max_temperature;
    alertCold = temperature < min_temperature;
  }


  void updatePowerUsage() {
    int pu = 0;
    if (player.onTerrain != player.terrainSetting && player.moving) pu += batteryDrain;
    if (heating) pu += batteryDrain * 2;
    if (cooling) pu += batteryDrain * 2;
    if (screen2State == s2s.GPS) pu += batteryDrain * 3;
    if (player.speed > 0) { // player moving
      float s = map(player.speed, 0, player.max_speed, 0, 2); // speed drain
      pu+= batteryDrain * s;
      float t = player.terrainDifference;
      pu+= batteryDrain * t;
    }
    if (player.scanning) pu += batteryDrain * 1;

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
