

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
      frames[i] = loadImage("rover_animation_310/"+nf(i+1, 4)+".png");
    }
  }

  void start() {
    loading = true;
    start = frameCount;
    println("load start");
  }

  void update() {
    if (loading && frameCount >= start+duration) {
      loading = false;
    }
  }

  void display() {
    push();
    fill(0);
    rect(screen2Corner.x+screen2Border, screen2Corner.y+screen2Border, screenSize-screen2Border*2, screenSize-screen2Border*2);
    imageMode(CENTER);
    image(frames[frameIndex], screen2Center.x, screen2Center.y);
    if (frameCount % 2 == 0) {
      frameIndex = (frameIndex + 1) % frames.length;
    }
    fill(255);
    pop();
  }
}
