// this is not over - probably the noise should move based on player rotation and movement but I will do it later {._.} 
class Weather {
  boolean storm, storm_IsStarted;
  float storm_StartTime;
  float storm_threshold, storm_maxThreshold;
  int[] sequenceTiming;
  int ease_in, ease_out;
  float leftShift=0;
  float s_noiseScale = 0.005;

  Weather () {
    this.storm = false;
    this.storm_IsStarted=false;
    this.storm_StartTime = 0;
    this.storm_maxThreshold = 200;
    this.storm_threshold = 50;
    this.ease_in = 15;
    this.ease_out = 8;
  }

  void display() {

    if (storm) {
      stormSequence(40);
    }
  }

  void stormSequence(int duration) {
    noStroke();
    noiseDetail(3, 0.5);
    if (!storm_IsStarted) {
      storm_StartTime = millis();
      storm_IsStarted = true;
      storm_threshold = 40;
    }

    if (storm_StartTime + (duration*1000) > millis()) {

      for (int x = screen2_cornerX; x < screen2_cornerX + screenSize; x +=4) {
        for (int y = screen2_cornerY; y < screen2_cornerY + screenSize; y+=4) {
          float nx = s_noiseScale * x + leftShift;
          float ny = s_noiseScale * y + leftShift;
          float nt = s_noiseScale *  frameCount / 10  ;
          float noiseCompute = noise(nx, ny, nt);

          float c = 255 * noiseCompute;
          push();
          
          if (c > storm_threshold) {
            fill(0, 10);
          } else if (c < storm_threshold && c > storm_threshold - 50) {
            fill(0, 128, 128);
          } else if (c < storm_threshold - 50 && c > storm_threshold - 80) {
            fill(0, 255, 255);
          } else if (c < storm_threshold - 80 && c > storm_threshold - 180 ) {
            fill(255);
          }
          
          rect(x, y, 4, 4);
          pop();
        }
      }
      leftShift+=0.0005; 
      
      storm_threshold+=calculateThreshold(storm_threshold, duration);
    } else if (storm_StartTime + (duration*1000) < millis()) {
      storm_IsStarted=false;
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
    } else if (storm_StartTime + (duration*1000) - (ease_out * 1000) < millis()) {
      // ease out period
      float decrease_amount = 0 - t;
      float time_left = ((storm_StartTime + duration*1000) - millis()) /1000;
      t_inc = decrease_amount / (time_left * frameRate);
      leftShift+=0.007;
    }
    return t_inc;
  }
}
