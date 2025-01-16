

class SignalDisplay {

  SineWave sinePlayer = new SineWave(primary);
  SineWave sineGame = new SineWave(color(255));

  SignalDisplay() {
  }
  void update() {
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

    sinePlayer.update();
    sineGame.update();

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
    col = c;
    band = random(0.01, 0.5);
    amp = random(50, screenSize / 2 - screen1Border);
    
    baseIncrement = TWO_PI / (screenSize / band);
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
      push();
      fill(0, 255, 0);
      noStroke();
      circle(i, map(sin(a), -1, 1, -amp, amp), 5);
      pop();
      a += band;
    }
    endShape();

    beginShape();
    float b = ang;
    for (float i = 0; i > -screenSize/2; i -= 10) {
      println(i);
      curveVertex(i, map(sin(b), -1, 1, -amp, amp));
      b -= band;
    }
    endShape();



    //for (float i = 0; i < TWO_PI; i += 0.01) {
    //  circle(i*10, map(sin(i), -1, 1, -screenSize/2-screen1Border, screenSize/2-screen1Border), 2);
    //}
  }
}
