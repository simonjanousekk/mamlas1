class GameState {


  // TIME PHASES STUFF
  int dayPhaseIndex = 0;
  int dayLength = 1000 * 60 * 4;
  String[] dayPhases = {"DAWN", "MORNING", "NOON", "AFTERNOON", "DUSK", "EVENING", "MIDNIGHT", "NIGHT"};
  String dayPhase = dayPhases[dayPhaseIndex];
  int dayStart = 0;
  int dayTime = 0;
  float phaseLength = dayLength / dayPhases.length;
  float currentPhaseTemp, nextPhaseTemp;

  // TEMPERATURE STUFF
  int[][] outTemperaturePhases = {{ 30, -60}, {20, 70}, {100, 120}, {40, 80}, {0, -40}, {-70, -100}, {-140, -160}, {-80, -110} };
  float temperature = 0;
  float outTemperature = 0;
  int max_temperature = 80;
  int min_temperature = -125;
  LedDriver ledDriverTemperature = new LedDriver(new int[] {0, 3, 7});


  // COOL AND HEAT ʕ⌐■ᴥ■ʔ
  boolean heating;
  boolean cooling;
  float coolingStrength =.1;
  float heatingStrength =.1;

  // WIND
  float windDirectionAngle = random(TWO_PI);
  PVector[] windSpeedConstrain = {new PVector(5, 40), new PVector(40, 100)};
  float windSpeed = random(windSpeedConstrain[0].x, windSpeedConstrain[0].y);
  PVector windVelocity;

  // POWER STUFF
  int powerUsage = 0;
  float batteryDrain = 100 / 10;
  float battery = 100;

  // HAZARDS
  boolean hazardHappening = false;
  int lastHazard = millis();
  float hazardChanceMultiplier;
  boolean alertCold = false;
  boolean alertHot = false;
  boolean alertSand = false;
  boolean alertMag = false;
  int temperatureAlertStart = 999999999;
  float temperatureSurvivabilityLength = phaseLength / 2;


  float[] magStormChancePhases = {.25, .1, .02, .1, .25, .1, .02, .1}; // chances in %/100
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
    updateWind();
    updateAlert();
  }


  void updateHazards() {
    if (!(hazardMonitor.forecast == Forecast.CLEAR)) {
      hazardHappening = true;
      lastHazard = millis();
      if (hazardMonitor.forecast == Forecast.SANDSTORM) {
        alertSand = true;
        storm.startStorm(int(gameState.phaseLength*2*60/1000), .2, .2); // convert time to frames cos why would i select one
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

    println("hazard chance multiplier... :", hazardChanceMultiplier);
    if (random(1) < sandStormChancePhases[(dayPhaseIndex + 1) % dayPhases.length] * hazardChanceMultiplier) {
      println("sandStorm imminent");
      hazardMonitor.forecast = Forecast.SANDSTORM;
    } else if (random(1) < magStormChancePhases[(dayPhaseIndex + 1) % dayPhases.length] * hazardChanceMultiplier) {
      println("magStorm imminent");
      hazardMonitor.forecast = Forecast.MAGSTORM;
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

  void updateWind() {
    windDirectionAngle = map(noise(millis()/50000.0), .1, .9, 0, TWO_PI);
    windSpeed = map(noise(millis()/40000.0+9999), .1, .9, windSpeedConstrain[0].x, windSpeedConstrain[0].y);
    //if (windDirectionAngle>TWO_PI) windDirectionAngle = 0;
    //if (windDirectionAngle<0) windDirectionAngle = TWO_PI;
    PVector windDirectionVector = PVector.fromAngle(windDirectionAngle);
    windVelocity = windDirectionVector.copy().mult(windSpeed);
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

    if (temperature > max_temperature || temperature < min_temperature) {
      if (!alertHot && !alertCold) {
        temperatureAlertStart = millis();
        println("rmpAlertStart set");
      }
      if (temperatureAlertStart + temperatureSurvivabilityLength < millis()) {
        println(temperature, temperatureAlertStart);
        println("time exeded");
        alertEnd = Alerts.END_DMG;
        endGame();
      }
    }
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
    powerUsage = constrain(powerUsage, 0, 100);

    int soundThreshold = 50;
    if (powerUsage > soundThreshold) {
      float vol = map(powerUsage, soundThreshold, 100, 0, 1);
      soundManager.tracks.get("power").vol(vol);
    } else {
      soundManager.tracks.get("power").off();
    }

    sendPowerUsage(powerUsage);
  }

  void updateBattery() {
    battery -= powerUsage / 5000.0;
    if (battery <= 0) {
      endGame();
      alertEnd = Alerts.END_BATTERY;
    }
    sendBattery(battery);

    if (battery < 50) {
      soundManager.tracks.get("battery0").on();
    }
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
