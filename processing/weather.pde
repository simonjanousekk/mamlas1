//LCD Specific
import com.pi4j.catalog.components.base.I2CDevice;
import com.pi4j.catalog.components.LcdDisplay;
import com.pi4j.Pi4J;
import com.pi4j.context.Context;
import com.pi4j.io.i2c.I2C;

// What will be displayed on line1 when there is no alert
enum DailyCycle {
  DAWN("Day phase:      DAWN"),
  MORNING("Day phase:   MORNING"),
  NOON("Day phase:      NOON"),
  AFTERNOON("Day phase: AFTERNOON"),
  EVENING("Day phase:   EVENING"),
  DUSK("Day phase:      DUSK"),
  NIGHT("Day phase:     NIGHT"),
  MIDNIGHT("Day phase:  MIDNIGHT");

  String message;

  DailyCycle(String message) {
    this.message = message;
  }
  String getMessage() {
    return message;
  }
}

// Displayed lines 2, 3 and 4 - should display weather and maybe some info / recommendations.
// These are NOT Critical, which are in enum class "Alerts"
enum Forecast {
  // do not remove the spaces. its on purpose
  CLEAR("Forecast:      CLEAR"),
  WIND("Forecast:STRONG WIND"),
  SANDSTORM("Forecast:  SANDSTORM"),
  MAGSTORM("Forecast:  MAG STORM"),
  COLD("Forecast: COLD FRONT"),
  HOT("Forecast:   HEATWAVE");

  String message;

  Forecast(String message) {
    this.message = message;
  }
  String getMessage() {
    return message;
  }
}

// These are ALERTS / CRITICAL information. When they will be set, the screen will flash and display the alert until its resolved.
// IMPORTANT: So far, no handling of more than 1 alert. Maybe not necessary ?
enum Alerts {
  //OVERUSAGE("WARNING:\nENERGY CONSUMPTION \nHIGH \nMonitor systems"),
  //POWER("WARNING:\n ENERGY RESERVE\n BELOW 20%\n Conserve Power"),
  //POWER_CRITICAL("CRITICAL FAILURE\n ENERGY RESERVE \n EXHAUSTED\n SHUTTING DOWN"),
  OVERHEATING("    EXTREME HEAT\n\n  Cooling systems\n      required"),
  //OVERHEATING_CRITICAL("CRITICAL FAILURE:\n CORE OVERHEATING \n INTERNAL DAMAGE\n DETECTED"),
  FREEZE("    EXTREME COLD\n\n  Heating systems\n      required"),
  //FREEZE_CRITICAL("CRITICAL FAILURE:\n SYSTEM FREEZING \n INTERNAL DAMAGE\n DETECTED"),
  //MAGSTORM_SOON("WARNING:\n MAGNETIC STORM\n IMMINENT\n Comm unstable"),
  MAGSTORM("   MAGNETIC STORM\n     IN PROGRESS\n Communication link\n      unstable"),
  //WIND("WARNING:\n STRONG WIND\n Rover trajectory\n altered"),
  SANDSTORM("     SANDSTORM\n    IN PROGRESS\n    GPS off-line\n Engage radar mode"),
  END_BATTERY("   ENERGY RESERVE\n     EXHAUSTED\n    All systems\n   shutting down"),
  END_DMG("\n SYSTEM DAMAGE FATAL:\n Mission Terminated"),
  END("\n    PRESS RESET\n TO REPEAT MISSION"),
  NONE("");

  String message;

  Alerts(String message) {
    this.message = message;
  }
  String getMessage() {
    return message;
  }
}






class HazardMonitor {

  LcdDisplay lcd;
  int i2cBus = 1;
  int lcdAddress = 0x27;

  String last_displayBuffer = "";
  String displayBuffer = "";
  String new_alert = "";

  DailyCycle dayCycle = DailyCycle.DAWN;
  Forecast forecast = Forecast.CLEAR;
  Alerts alert = Alerts.NONE;

  boolean interference = false;
  boolean threadActive = false;
  boolean last_interference = false;
  boolean flash = false;

  Thread lcdMain;
  int noiseAmount = 0;

  int windSpeed = 0;
  int temp = 0;

  String[] params = new String[4];

  HazardMonitor() {
    // initialize lcd display
    Context pi4j = Pi4J.newAutoContext();
    lcd = new LcdDisplay(pi4j, 4, 20);
    lcd.clearDisplay();
    displayHazard();
    String windLine = padParam("Wind speed:", windSpeed, "m/s");
    String tempLine = padParam("Surface temp:", temp, "°C");

    String[] params = {dayCycle.getMessage(), forecast.getMessage(), windLine, tempLine};
  }

  void updateHazard() {
    // important : whenever an alert is cleared, HazardMonitor.alert should be set to Alerts.NONE
    if (alert == Alerts.NONE) {
      String windLine = padParam("Wind speed:", windSpeed, "m/s");
      String degreeCode = Character.toString((char) 223)+"C";
      String tempLine = padParam("Surface temp:", temp, degreeCode);
      displayBuffer = String.join("\n", dayCycle.getMessage(), forecast.getMessage(), windLine, tempLine);
    } else {
      displayBuffer = alert.getMessage();
    }
  }

  void displayHazard() {

    if (alert != Alerts.NONE) {
      if (displayBuffer != new_alert) {
        // new alert, we must flash

        flash = true;
        new_alert = displayBuffer;
      }
    }

    if (signalDisplay.sinePlayer.isRight || alert == Alerts.END) {
      interference = false;
      sendLcd(displayBuffer, false, 0);
    } else if (!signalDisplay.sinePlayer.isRight) {
      interference = true;
      noiseAmount = int((signalDisplay.interference) * 8);
      sendLcd(displayBuffer, true, noiseAmount);
    }
  }



  void sendLcd(String displayBuffer, boolean interference, int noiseAmount) {
    if (threadActive) {
      // There is no way to stop an active thread. all attempts were disasters. the best is to let the thread tell itself
      // when it is finished (by setting threadActive = false at the end of the thread) And not do ANYTHING if it is active.
      return;
    }

    lcdMain = new Thread(() -> {
      threadActive = true;
      while (threadActive) {
        //println("new thread ", frameCount);
        if (!interference && last_interference == true ||  flash || alert == Alerts.END) {
          delay(300);

          // Make sure cleaning random symbol after signal problems are resolvd - and also when theres alert
          lcd.clearDisplay();
          // we also have to reset all params, otherwise they wont be displayed...
          for (int l = 0; l < params.length; l++) {
            params[l] = "";
          }
        } 
        // Flashing when there is new Alert
        if (flash) {
          boolean lightstate = true;
          for (int s = 0; s < 5; s++) {
            lcd.setDisplayBacklight(lightstate);
            lightstate = !lightstate;
            delay(50);
          }
          //make sure we finish with the lights on
          lcd.setDisplayBacklight(true);
          flash = false;
        }

        String[] split_displayBuffer = displayBuffer.split("\n");
        for (int k = 0; k < split_displayBuffer.length; k++) {
          // this is made so that only params that change are displayed- otherwise it refresh whole screen
          if (!split_displayBuffer[k].equals(params[k])) {
            lcd.displayLineOfText(split_displayBuffer[k], k);
            params[k] = split_displayBuffer[k];
          }
        }
        if (interference) {
          //
          //int n = int(map(noiseAmount, 0, width, 0, 40));
          for (int i = 0; i < noiseAmount; i++) {
            int randomCharCode = int(random(256));
            lcd.writeCharacter((char) randomCharCode, int(random(4)), int(random(20)));
          }
        }
        threadActive = false;
        last_displayBuffer = displayBuffer;
        last_interference = interference;
      }
    }
    );
    lcdMain.start();
  }

  String padParam(String param, int value, String unit) {
    // max. length total should be 20
    String value_string = String.valueOf(value).concat(unit);
    int total_length = param.length() + value_string.length();

    if (total_length > 20) {
      // shouldnt happen. Here for debugging
      println("there was a parameter too long: ", param);
      return "";
    } else {
      int spaces = 20 - total_length;
      for (int i = 0; i < spaces; i++) {
        param += " ";
      }
      String padded_param = param + value_string;
      return padded_param;
    }
  }
}


void hazardMonitorSync() {
  if (hazardMonitor != null) {
    // UPDATING PARAMETERS ON LCD
    // for temperature and windspeed, we have to put a bottleneck , because otherwise it would refresh too often
    if (millis() - bottleneckLast > bottleneckRefresh) {
      bottleneckLast = millis();
      hazardMonitor.temp = int(gameState.outTemperature);
      hazardMonitor.windSpeed = int(gameState.windSpeed);
      hazardMonitor.updateHazard();
    }

    // Day phases should change immediately - here should go
    if (millis() - fastLast > fastRefresh) {
      fastLast = millis();
      hazardMonitor.dayCycle = DailyCycle.valueOf(gameState.dayPhase);
      hazardMonitor.updateHazard();
    }


    if (millis() - lastLcdRefresh > LcdRefresh) {
      lastLcdRefresh = millis();
      if (hazardMonitor.interference) {
        hazardMonitor.displayHazard();
      } else if (!hazardMonitor.displayBuffer.equals(hazardMonitor.last_displayBuffer) || hazardMonitor.last_interference != hazardMonitor.interference) {
        // synchronising thread with real state
        hazardMonitor.displayHazard();
      }
    }
  }
}




class Storm {
  int rectSize = 4;
  float noiseScale = 0.05;
  float timeSpeed = 0.0001;

  PVector wind = new PVector(0, 0);
  LedDriver ledDriver = new LedDriver(new int[] {9, 10});

  int animationStart = -1;
  int animationEnd = -1;
  boolean storm = false;
  float rise, fall;

  Storm() {
  }


  void startStorm(int length, float r, float f) {
    storm = true;
    animationStart = frameCount;
    animationEnd = animationStart + length;
    rise = r;
    fall = f;
  }

  void update() {
    if (storm && screen2State == s2s.GPS) {
      ledDriver.turnOn();
      if (storm && frameCount > animationStart && frameCount < animationEnd) {
        display();
      } else {
        storm = false;
      }
    } else {
      ledDriver.turnOff();
    }
  }


  void display() {
    float t = map(frameCount, animationStart, animationEnd, 0, 1);
    float tcurve = riseStandFall(t, rise, fall);

    // debug animation curve
    //circle(screen2Center.x, screen2Center.y, tcurve*100);

    for (int x = int(screen2Center.x - screenHalf); x < screen2Center.x + screenHalf; x += rectSize) {
      for (int y = int(screen2Center.y - screenHalf); y < screen2Center.y + screenHalf; y += rectSize) {

        // Convert screen coordinates to world coordinates
        float worldX = player.pos.x + (x - screen2Center.x);
        float worldY = player.pos.y + (y - screen2Center.y);

        // Rotate world coordinates around the player
        float dx = worldX - player.pos.x;
        float dy = worldY - player.pos.y;

        float rotatedX = cos(player.angle) * dx - sin(player.angle) * dy + player.pos.x;
        float rotatedY = sin(player.angle) * dx + cos(player.angle) * dy + player.pos.y;

        wind.add(gameState.windVelocity.copy().mult(.00000005));

        // Scale for noise
        float nx = rotatedX / rectSize * noiseScale + wind.x;
        float ny = rotatedY / rectSize * noiseScale + wind.y;
        float nz = frameCount * timeSpeed;

        // Generate noise value
        float noiseVal = map(noise(nx, ny, nz), .05, .95, 0, 1);


        // Draw rectangles based on noise value
        if (noiseVal < tcurve) {
          noStroke();
          //fill(noiseVal * 255);
          float c = map(noiseVal, 0, tcurve, 0, 1);

          if (c < .4) {
            fill(white);
          } else  if (c < .6) {
            fill(primary);
          } else {
            fill(primaryLight);
          }
          rect(x, y, rectSize, rectSize);
        }
      }
    }
  }
}



float riseStandFall(float t, float riseL, float fallL) {
  t = constrain(t, 0, 1);
  if (t < riseL) {
    return map(t, 0, riseL, 0, 1);
  } else if (t < 1 - fallL) {
    return 1;
  } else {
    return map(t, 1 - fallL, 1, 1, 0);
  }
}

float mapEaseInOut(float x, float inMin, float inMax, float outMin, float outMax) {
  // Normalize x to [0, 1] range using map and constrain
  float t = constrain(map(x, inMin, inMax, 0, 1), 0, 1);

  // Apply ease-in-out formula (smoothstep)
  t = t * t * (3 - 2 * t);

  // Map eased t to the output range
  return map(t, 0, 1, outMin, outMax);
}
