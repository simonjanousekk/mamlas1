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
    ATERNOON("Day phase: AFTERNOON"),
    EVENING("Day phase:   EVENING"),
    DUSK("Day phase:      DUSK"),
    NIGHT("Day phase:     NIGHT");

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
enum Weather {
  // do not remove the spaces. its on purpose
  CLEAR("Forecast:      CLEAR"),
    WIND("Forecast:STRONG WIND"),
    SANDSTORM("Forecast:  SANDSTORM"),
    MAGSTORM("Forecast:  MAG STORM"),
    HOT("Forecast:  HIGH TEMP");

  String message;

  Weather(String message) {
    this.message = message;
  }
  String getMessage() {
    return message;
  }
}

// These are ALERTS / CRITICAL information. When they will be set, the screen will flash and display the alert until its resolved.
// IMPORTANT: So far, no handling of more than 1 alert. Maybe not necessary ?
enum Alerts {
  OVERUSAGE("WARNING:\n ENERGY CONSUMPTION \n HIGH \n Monitor systems"),
    POWER("WARNING:\n ENERGY RESERVE\n BELOW 20%\n Conserve Power"),
    POWER_CRITICAL("CRITICAL FAILURE\n ENERGY RESERVE \n EXHAUSTED\n SHUTTING DOWN"),
    OVERHEATING("WARNING:\n TEMPERATURE NEARING\n SAFE LIMITS\n Cooling required"),
    OVERHEATING_CRITICAL("CRITICAL FAILURE:\n CORE OVERHEATING \n INTERNAL DAMAGE\n DETECTED"),
    FREEZE("WARNING:\n TEMPERATURE NEARING\n SAFE LIMITS\n Heating required"),
    FREEZE_CRITICAL("CRITICAL FAILURE:\n SYSTEM FREEZING \n INTERNAL DAMAGE\n DETECTED"),
    STORM_SOON("WARNING:\n MAGNETIC STORM\n IMMINENT\n Comm unstable"),
    STORM_HERE("WARNING:\n MAGNETIC STORM\n IN PROGRESS\n Comm unstable"),
    WIND("WARNING:\n STRONG WIND\n Rover trajectory\n altered"),
    SANDSTORM("WARNING: \n SANDSTORM IN\n PROGRESS\n Engage radar mode"),
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

  String last_forecast = "";
  String forecast = "";
  String new_alert = "";
  DailyCycle d = DailyCycle.MORNING;
  Weather w = Weather.WIND;
  Alerts alert = Alerts.NONE;

  boolean interference = false;
  boolean threadActive = false;
  boolean last_interference = false;
  boolean flash = false;

  Thread lcdMain;
  int noiseAmount = 0;

  float windSpeed = 15;
  float temp = 90;

  HazardMonitor() {
    // initialize lcd display
    Context pi4j = Pi4J.newAutoContext();
    lcd = new LcdDisplay(pi4j, 4, 20);
    lcd.clearDisplay();
    displayHazard();
  }
  
  void updateHazard() {
    // important : whenever an alert is cleared, HazardMonitor.alert should be set to Alerts.NONE
    if (alert == Alerts.NONE) {
      println("DEBUG: Calling padParam function.");
      String windLine = padParam("Wind speed:", windSpeed);
      String tempLine = padParam("Surface temp:", temp);
      forecast = String.join("\n", d.getMessage(), w.getMessage(), windLine, tempLine);
    } else {
      forecast = alert.getMessage();
    }
  }

  void displayHazard() {
    //if (alert == Alerts.NONE) {
    //  forecast = String.join("\n", d.getMessage(), w.getMessage());
    //} else {
    //  forecast = alert.getMessage();
    if (alert != Alerts.NONE) {
      if (forecast != new_alert) {
        // new alert, we must flash
        flash = true;
        new_alert = forecast;
      }
    }
    //}
    if (!interference) {
      sendLcd(forecast, false, 0);
    } else if (interference) {
      sendLcd(forecast, true, noiseAmount);
    }
  }

  void sendLcd(String forecast, boolean interference, int noiseAmount) {
    if (threadActive) {
      // There is no way to stop an active thread. all attempts were disasters. the best is to let the thread tell itself
      // when it is finished (by setting threadActive = false at the end of the thread) And not do ANYTHING if it is active.
      return;
    }

    lcdMain = new Thread(() -> {
      threadActive = true;
      while (threadActive) {
        println("new thread ", frameCount);
        if (!interference) {
          // Make sure cleaning random symbol after signal problems are resolvd
          lcd.clearDisplay();
          delay(100);
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
        lcd.displayText(forecast);
        if (interference) {
          int n = int(map(noiseAmount, 0, width, 0, 40));
          for (int i = 0; i< n; i++) {
            int randomCharCode = int(random(256));
            lcd.writeCharacter((char) randomCharCode, int(random(4)), int(random(20)));
          }
        }
        threadActive = false;
        last_forecast = forecast;
        last_interference = interference;
      }
    }
    );
    lcdMain.start();
  }

  String padParam(String param, float value) {
    println("DEBUG - inside padParam function");
    // max. length total should be 20
    int total_length = param.length() + String.valueOf(value).length();

    if (total_length > 20) {
      // shouldnt happen. Here for debugging
      println("error for: ", param, " and value: ", value);
      return "";
    } else {
      int spaces = 20 - total_length;
      for (int i = 0; i < spaces; i++) {
        param+=" ";
      }
      String padded_param = param + String.valueOf(value);
      println("DEBUG - returning the following padded parameters.");
      return padded_param;
    }
  }
}


class Storm {
  int rectSize = 4;
  float noiseScale = 0.05;
  float timeSpeed = 0.0001;

  float windSpeed = .000001;
  PVector windDirection = random2DVector();
  PVector windVelocity = windDirection.copy().mult(windSpeed);
  PVector wind = new PVector(0, 0);


  int animationStart = -1;
  int animationEnd = -1;
  boolean storm = false;
  float rise, fall;

  Storm() {
  }


  void startStorm(int length, float r, float f) {
    animationStart = frameCount;
    animationEnd = animationStart + length;
    rise = r;
    fall = f;
    windDirection = random2DVector();
    windVelocity = windDirection.copy().mult(windSpeed);
    println(windDirection.x, windDirection.y, windVelocity.x, windVelocity.y);
  }

  void display() {

    if (frameCount > animationStart && frameCount < animationEnd) {

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

          wind.add(windVelocity);

          // Scale for noise
          float nx = rotatedX / rectSize * noiseScale + wind.x;
          float ny = rotatedY / rectSize * noiseScale + wind.y;
          float nz = frameCount * timeSpeed;

          // Generate noise value
          float noiseVal = map(noise(nx, ny, nz), .05, .95, 0, 1);
          ;

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
}



float riseStandFall(float t, float riseL, float fallL) {
  t = constrain(t, 0, 1);
  if (t < riseL) {
    return map(t, 0, riseL, 0, 1);
  } else if (t < 1-fallL) {
    return 1;
  } else {
    return map(t, 1-fallL, 1, 1, 0);
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
