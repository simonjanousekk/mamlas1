

class SignalDisplay {
  
  SineWave sinePlayer, sineGame;
  float baseIncrement = 0.05;
  PVector bandConstrain = new PVector(0.1, 0.6); // min max
  PVector ampConstrain = new PVector(30, screenSize / 2 - screen1Border); // min max
  
  
  SignalDisplay() {
    requestPotValues();
    sinePlayer = new SineWave(primary, primaryLight);
    sineGame = new SineWave(color(255), color(100));
    randomizeSineGame();
  }
  
  void update() {
    
    //println(noise1, noise2);
    
    sinePlayer.update();
    sineGame.update();
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
    
    
    
    
    
    stroke(100);
    line(0, -screenSize / 2, 0, screenSize / 2);
    line( -screenSize / 2, 0, screenSize / 2, 0);
    
    for (int i = -screenSize/2; i < screenSize/2; i += 10) {
      line(-5, i, 5, i);
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
  
  SineWave(int c, int c2) {
    this(c, c2, 0, 0);
  }
  
  SineWave(int c, int c2, float b, float a) {
    col = c;
    col2 = c2;
    band = b;
    amp = a;
  }
  
  void update() {
    ang += signalDisplay.baseIncrement;
    pos = new PVector(0, map(sin(ang), -1, 1, -amp, amp)); 
    
    band += (desBand - band) *.1;
    amp += (desAmp - amp) *.1;
  }
  
  
  void display() {
    stroke(col2);
    strokeWeight(1);
    line( - screenSize / 2, amp, screenSize / 2, amp);
    line( - screenSize / 2, -amp, screenSize / 2, -amp);
    
    fill(col);
    noStroke();
    circle(pos.x, pos.y, 5);
    
    
    noFill();
    strokeWeight(2);
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
    //  circle(i*10, map(sin(i), -1, 1, -screenSize/2-screen1Border, screenSize/2-screen1Border), 2);
    //}
  }
}
