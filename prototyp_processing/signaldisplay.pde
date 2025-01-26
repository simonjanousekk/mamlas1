

class SignalDisplay {

  SineWave sinePlayer, sineGame;
  float baseIncrement = 0.05;
  PVector bandConstrain = new PVector(0.1, 0.6); // min max
  PVector ampConstrain = new PVector(30, screenSize / 2 - screen1Border); // min max

  float interference = 0;
  boolean sineGameSet = false;

  LedDriver ledDriver = new LedDriver(new int[]{2, 4});

  SignalDisplay() {
    //randomizeSineGame();


    sinePlayer = new SineWave(primary, primaryLight, .5);
    sineGame = new SineWave(white, gray, .01);
  }

  void update() {
    if (!sineGameSet && gameInitialized) requestPotValues();
    // this is fucking piss but i cannot solve for delay that arduino midi brings.
    if (!sineGameSet && gameInitialized && sinePlayer.desAmp != 0 && sinePlayer.desBand != 0) {
      sineGame.amp = sinePlayer.desAmp;
      sineGame.band = sinePlayer.desBand;
      sineGameSet = true;
    }


    //float db = map(player.pos.x, 0, mapa.size.x, bandConstrain.x, bandConstrain.y);
    //float da = map(player.pos.y, 0, mapa.size.y, ampConstrain.x, ampConstrain.y);





    sinePlayer.update();
    sineGame.update();

    float ampTolerance = 5;
    float bandTolerance =.03;

    float pAmp = sinePlayer.amp;
    float pBand = sinePlayer.band;
    float gAmp = sineGame.amp;
    float gBand = sineGame.band;

    if (isCloseEnough(pAmp, gAmp, ampTolerance) && isCloseEnough(pBand, gBand, bandTolerance)) {
      //sinePlayer.col = white;
      sinePlayer.isRight = true;
      interference = 0;

      ledDriver.turnOff();
    } else {
      sinePlayer.isRight = false;

      // Calculate normalized difference
      float ampDiff = max(0, abs(pAmp - gAmp) - ampTolerance) / (ampConstrain.y - ampConstrain.x);
      float bandDiff = max(0, abs(pBand - gBand) - bandTolerance) / (bandConstrain.y - bandConstrain.x);

      // Combine differences, capped at 1
      interference = min(ampDiff + bandDiff, 1);

      ledDriver.turnOn();
    }
  }

  void randomizeSineGame() {
    sineGame.desBand = random(bandConstrain.x, bandConstrain.y);
    sineGame.desAmp = random(ampConstrain.x, ampConstrain.y);
  }

  void display() {

    push();
    translate(screen1Center.x, screen1Center.y);
    fill(0);
    rectMode(CENTER);
    rect(0, 0, screenSize, screenSize);


    stroke(gray);
    line(0, -screenSize / 2, 0, screenSize / 2);
    line( -screenSize / 2, 0, screenSize / 2, 0);


    int step = screenSize / 20;
    int stepLineL = 5;
    for (int i = -screenHalf + step; i <= screenHalf - step; i += step) {
      line( -stepLineL, i, stepLineL, i);
      line(i, -stepLineL, i, stepLineL);
      for (int j = -screenHalf + step; j <= screenHalf - step; j += step) {
        point(i, j);
      }
    }




    sineGame.display();

    sinePlayer.display();

    pop();
  }
}



class SineWave {
  PVector origin = new PVector(screen1Center.x, screen1Center.y);
  PVector pos;
  color col, col2;
  float ang = 0;
  float band, amp;
  float desBand, desAmp;
  int strokeWeight = 2;
  boolean isRight = false;
  float adjustSpeed;

  SineWave(int c, int c2, float s) {
    this(c, c2, 0, 0, s);
  }

  SineWave(int c, int c2, float a, float b, float s) {
    col = c;
    col2 = c2;
    band = b;
    amp = a;
    adjustSpeed = s;
  }

  void update() {
    ang += signalDisplay.baseIncrement;
    pos = new PVector(0, map(sin(ang), -1, 1, -amp, amp));

    band += (desBand - band) * adjustSpeed;
    amp += (desAmp - amp) * adjustSpeed;
  }


  void display() {
    stroke(isRight ? col : col2);
    strokeWeight(1);
    line( -screenSize / 2, amp, screenSize / 2, amp);
    line( -screenSize / 2, -amp, screenSize / 2, -amp);

    fill(col);
    noStroke();
    circle(pos.x, pos.y, 5);


    noFill();
    strokeWeight(isRight ? 4 : 2);
    stroke(col);

    beginShape();
    float a = ang;
    for (int i = 0; i < screenSize / 2 + 20; i += 10) {
      curveVertex(i, map(sin(a), -1, 1, -amp, amp));
      a += band;
    }
    endShape();

    beginShape();
    float b = ang;
    for (float i = 0; i > - screenSize / 2 - 20; i -= 10) {
      curveVertex(i, map(sin(b), -1, 1, -amp, amp));
      b -= band;
    }
    endShape();



    //for (float i = 0; i < TWO_PI; i += 0.01) {
    //  circle(i*10, map(sin(i), -1, 1, -screenHalf-screen1Border, screenHalf-screen1Border), 2);
    //}
  }
}





void radio(float amount) {

  int min = u * 10;
  int max = u * 20;

  loadPixels();
  for (int i = 0; i < amount * 70; i++) {
    int w = floor(random(min, max));
    int h = floor(random(min, max));

    int x1 = floor(random(screen2Corner.x, screen2Corner.x + screenSize - w));
    int y1 = floor(random(screen2Corner.y, screen2Corner.y + screenSize - h));

    int x2 = floor(random(screen2Corner.x, screen2Corner.x + screenSize - w));
    int y2 = floor(random(screen2Corner.y, screen2Corner.y + screenSize - h));

    // Copy pixels manually
    for (int dx = 0; dx < w; dx++) {
      for (int dy = 0; dy < h; dy++) {
        int srcIndex = (x1 + dx) + (y1 + dy) * width;
        int destIndex = (x2 + dx) + (y2 + dy) * width;
        pixels[destIndex] = pixels[srcIndex];
      }
    }
  }
  updatePixels();

  int resolution = 4;
  noStroke();
  for (int x = int(screen2Center.x - screenSize / 2); x < screen2Center.x + screenSize / 2; x += resolution) {
    for (int y = int(screen2Center.y - screenSize / 2); y < screen2Center.y + screenSize / 2; y += resolution) {
      if (random(1) < map(amount, 0, 1, 0, .1)) {
        fill(random(1) > 0.5 ? (random(1) > 0.7 ? white : gray) : 0);
        //fill(random(1) > .5 ? white : 0);
        //fill(random(255));
        //fill(white);

        rect(x, y, resolution, resolution);
      }
    }
  }
}
