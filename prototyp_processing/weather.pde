// this is not over - probably the noise should move based on player rotation and movement but I will do it later {._.}
class Weather {
  boolean storm = false, storm_IsStarted = false;
  float storm_StartTime = 0;
  float storm_threshold, storm_maxThreshold;
  int[] sequenceTiming;
  int ease_in, ease_out;
  float leftShift = 0;
  float s_noiseScale = 0.005;

  int rectSize = 4;

  Weather() {
    storm_maxThreshold = 200;
    storm_threshold = 50;
    ease_in = 15;
    ease_out = 8;
  }

  void display() {

    if (storm) {
      stormSequence(40);
    }
  }

  void stormSequence(int duration) {
    noStroke();
    noiseDetail(5, 0.5);
    if (!storm_IsStarted) {
      storm_StartTime = millis();
      storm_IsStarted = true;
      storm_threshold = 40;
    }

    if (storm_StartTime + (duration * 1000) > millis()) {

      for (int x = screen2_cornerX; x < screen2_cornerX + screenSize; x += rectSize) {
        for (int y = screen2_cornerY; y < screen2_cornerY + screenSize; y += rectSize) {
          // Convert screen coordinates to world coordinates
          float worldX = player.pos.x + (x - screen2Center.x);
          float worldY = player.pos.y + (y - screen2Center.y);

          // Rotate world coordinates around the player
          float dx = worldX - player.pos.x;
          float dy = worldY - player.pos.y;

          float rotatedX = cos(player.angle) * dx - sin(player.angle) * dy + player.pos.x;
          float rotatedY = sin(player.angle) * dx + cos(player.angle) * dy + player.pos.y;

          // Scale for noise
          float nx = rotatedX / rectSize * noiseScale + leftShift;
          float ny = rotatedY / rectSize * noiseScale + leftShift;

          float nt = s_noiseScale *  frameCount / 10 ;
          float noiseCompute = noise(nx, ny, nt);

          float c = 255 * noiseCompute;
          push();

          if (c > storm_threshold) {
            fill(0, 0);
          } else if (c < storm_threshold && c > storm_threshold - 50) {
            fill(0, 128, 128);
          } else if (c < storm_threshold - 50 && c > storm_threshold - 80) {
            fill(0, 255, 255);
          } else if (c < storm_threshold - 80 && c > storm_threshold - 180) {
            fill(255);
          }

          rect(x, y, rectSize, rectSize);
          pop();
        }
      }

      leftShift += 0.002;

      storm_threshold += calculateThreshold(storm_threshold, duration);
    } else if (storm_StartTime + (duration * 1000) < millis()) {
      storm_IsStarted = false;
      storm = false;
    }
  }

  float calculateThreshold(float t, int duration) {
    float t_inc = 0;

    if (millis() - storm_StartTime <(ease_in * 1000) && t <= storm_maxThreshold) {
      // ease in period
      float increase_amout = storm_maxThreshold - t;
      float time_left = ease_in - ((millis() - storm_StartTime) / 1000);
      t_inc = increase_amout / (time_left * frameRate);
    } else if (storm_StartTime + (duration * 1000) - (ease_out * 1000) < millis()) {
      // ease out period
      float decrease_amount = 0 - t;
      float time_left = ((storm_StartTime + duration * 1000) - millis()) / 1000;
      t_inc = decrease_amount / (time_left * frameRate);
      leftShift += 0.002;
    }
    return t_inc;
  }
}



class Weather2 {
  int rectSize = 10;
  float noiseScale = 0.1;

  int animationStart = 99999999;
  int animationEnd = 99999999;
  boolean storm = false;

  Weather2() {
  }


  void startStorm(int length) {
    animationStart = frameCount;
    animationEnd = animationStart + length;
  }

  void display() {

    //translate(screen2Center.x, screen2Center.y);
    //rotate(-player.angle);
    //rectMode(CENTER);
    //rect(0, 0, 100, 100);

    if (frameCount > animationStart && frameCount < animationEnd) {

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

          // Scale for noise
          float nx = rotatedX / rectSize * noiseScale;
          float ny = rotatedY / rectSize * noiseScale;

          // Generate noise value
          float noiseVal = noise(nx, ny);

          // Draw rectangles based on noise value
          if (noiseVal > 0.6) {
            noStroke();
            fill(noiseVal * 255);
            rect(x, y, rectSize, rectSize);
          }
        }
      }
    }
  }
}
