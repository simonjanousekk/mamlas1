//LCD Specific
import com.pi4j.catalog.components.base.I2CDevice;
import com.pi4j.catalog.components.LcdDisplay;
import com.pi4j.Pi4J;
import com.pi4j.context.Context;
import com.pi4j.io.i2c.I2C;

enum DailyCycle {
    MORNING("Good morning"),
    NOON("Good afternoon"),
    NIGHT("Good night");

  String message;

  DailyCycle(String message) {
    this.message = message;
  }
  String getMessage() {
    return message;
  }
}

enum Weather {
    STABLE("FORECAST:\nConditions stable"),
    WIND("FORECAST:\nHigh wind"),
    HOT("FORECAST:\nTemperatures rising"),
    COLD("WARNING:\nTemperatures falling");

  String message;

  Weather(String message) {
    this.message = message;
  }
  String getMessage() {
    return message;
  }
}

enum Warnings {
    STABLE("INFO:\n All systems stable"),
    SANDSTORM("WARNING:\n Sandstorm"),
    MAGNETIC("WARNING:\n Magnetic storm"),
    WIND("WARNING:\n High wind"),
    NOON("WARNING:\n Temperatures rising rapidly"),
    NIGHT("WARNING:\n Temperatures falling rapidly");

  String message;

  Warnings(String message) {
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
  DailyCycle d = DailyCycle.MORNING;
  Weather w = Weather.STABLE;

  boolean interference = false;
  boolean threadActive = false;
  boolean warnings = false;

  Thread lcdMain;
  int noiseAmount = 0;

  HazardMonitor() {
    // initialize lcd display
    Context pi4j = Pi4J.newAutoContext();
    lcd = new LcdDisplay(pi4j, 4, 20);
    lcd.clearDisplay();
  }

  void displayHazard() {
    if (!warnings) {
      forecast = String.join("\n", d.getMessage(), w.getMessage()); 
    }
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
      println("Thread started for ", forecast);
      threadActive = true;
      while (threadActive) {
        if (!interference) {
          lcd.clearDisplay();
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
      }
    }
    );
    lcdMain.start();
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
