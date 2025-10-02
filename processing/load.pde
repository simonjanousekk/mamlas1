

class Load {

  int framesCount = 120;
  int frameIndex = 1;
  PImage[] frames;

  boolean loading = false;
  int duration = 120;
  int start = -1;

  Load() {
    frames = new PImage[framesCount];
    for (int i = 0; i < framesCount; i++) {
      frames[i] = loadImage("rover_animation/"+nf(i+1, 4)+".png");
    }
  }

  void start() {
    loading = true;
    start = frameCount;
  }

  void update() {
    if (loading && frameCount >= start+duration) {
      loading = false;
      if (screen2State == s2s.RADAR) {
        player.scan();
      }
    }
  }

  void display() {
    push();
    fill(0);
    rect(screen2Corner.x+screen2Border, screen2Corner.y+screen2Border, screenSize-screen2Border*2, screenSize-screen2Border*2);
    imageMode(CENTER);
    
    int testPos = 105;


    image(frames[frameIndex], screen2Center.x, screen2Center.y-15);

    
    rectMode(CENTER);
    textAlign(CENTER, CENTER);
    fill(white);
    rect(screen2Center.x, screen2Center.y+testPos, 100, 30);
    fill(0);
    text("LOADING", screen2Center.x, screen2Center.y+testPos);

    //String loadText;
    //if (screen2State == s2s.RADAR) {
    //  loadText = "Radar systems loading...";
    //} else {
    //  loadText = "Satelite imagery loading...";
    //}
    if (frameCount % 2 == 0) {
      frameIndex = (frameIndex + 1) % frames.length;
    }
    //fill(white);
    //text(loadText, screen2Center.x, screen2Center.y+u*20);

    pop();
  }
}
