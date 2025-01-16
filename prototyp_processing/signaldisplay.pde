

class SignalDisplay {

  SineWave sinePlayer, sineGame;
  
  float noise1, noise2;
  float noiseFac = random(100);
  float noiseInc = 0.005;
  PVector bandConstrain = new PVector(0.01, 0.5); // min max
  PVector ampConstrain = new PVector(50, screenSize / 2 - screen1Border); // min max

  SignalDisplay() {
    
    calcNoise();
    
    sinePlayer = new SineWave(primary);
    sineGame = new SineWave(color(255), noise1, noise2);
  }
  
  void calcNoise() {
    noise1 = map(noise(noiseFac), 0, 1, ampConstrain.x, ampConstrain.y);
    noise2 = map(noise(noiseFac + 999), 0, 1, bandConstrain.x, bandConstrain.y); // offset
    
    noiseFac += noiseInc;    
  }

  void update() {
    calcNoise();
    
    //sineGame.amp = noise1;
    //sineGame.band = noise2;
    
    println(noise1, noise2);

    sinePlayer.update();
    sineGame.update();
  }

  void display() {
    push();
    translate(screen1Center.x, screen1Center.y);
    fill(0);
    rectMode(CENTER);
    rect(0, 0, screenSize, screenSize);





    stroke(150);
    line(0, -screenSize/2, 0, screenSize/2);
    line(-screenSize/2, 0, screenSize/2, 0);




    sinePlayer.display();
    sineGame.display();

    pop();
  }
}



class SineWave {
  PVector origin = new PVector(screen1Center.x, screen1Center.y);
  PVector pos;
  color col;
  float ang = 0;
  float band, amp, baseIncrement;

  SineWave(int c) {
    this(c, random(0.01, 0.5), random(50, screenSize / 2 - screen1Border));
  }

  SineWave(int c, float b, float a) {
    col = c;
    band = b;
    amp = a;
    baseIncrement = 0.07;
  }

  void update() {
    ang += baseIncrement;

    pos = new PVector(0, map(sin(ang), -1, 1, -amp, amp));
  }


  void display() {
    fill(col);
    noStroke();
    circle(pos.x, pos.y, 5);


    noFill();
    strokeWeight(2);
    stroke(col);

    beginShape();
    float a = ang;
    for (int i = 0; i < screenSize/2; i += 10) {
      curveVertex(i, map(sin(a), -1, 1, -amp, amp));
      a += band;
    }
    endShape();

    beginShape();
    float b = ang;
    for (float i = 0; i > -screenSize/2; i -= 10) {
      curveVertex(i, map(sin(b), -1, 1, -amp, amp));
      b -= band;
    }
    endShape();



    //for (float i = 0; i < TWO_PI; i += 0.01) {
    //  circle(i*10, map(sin(i), -1, 1, -screenSize/2-screen1Border, screenSize/2-screen1Border), 2);
    //}
  }
}
