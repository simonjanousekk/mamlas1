

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
    println("load start");
  }
  
  void update() {
    if (loading && frameCount >= start+duration) {
      loading = false;
    }
  }

  void display() {
    fill(0);
    rect(screen2CornerX+screen2Border, screen2CornerY+screen2Border-10, screenSize-screen2Border*2, screenSize-screen2Border*2);
    image(frames[frameIndex], screen2CornerX+screen2Border, screen2CornerY+screen2Border, screenSize-screen2Border*2, screenSize-screen2Border*2);
    if (frameCount % 2 == 0) {
      frameIndex = (frameIndex + 1) % frames.length;
    }
    fill(255);
  }
}
