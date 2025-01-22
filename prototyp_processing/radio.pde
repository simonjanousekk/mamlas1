
 
void radio2(int noiseAmount) {
  noiseDetail(3,0.5);
  // later on can be adjusted based on sensor value
  float n = map(noiseAmount, 0, width, 9, 1);

  //noise_t = map(mouseX, 0, width, 0.1, 0.7);
  if (frameCount % int(n) == 0) {
    // threshold for how many pixels are affected by the displacement effect - 0 = none, 0.7 = most of them
    float maxRange = 1.1  - (n / 10);
    noise_t = random(0, maxRange);
  }

  PImage frame = get(screen2_cornerX, screen2_cornerY, screenSize, screenSize);

  loadPixels();
  frame.loadPixels();
  for (int x = screen2_cornerX + 1; x < screen2_cornerX + screenSize - 2; x ++) {
    for (int y = screen2_cornerY + 1; y < screen2_cornerY + screenSize - 2; y++) {

      int noise = int(random(100));
      if (noise % int(n + 1) == 0) {
        pixels[x + y * width] = color(random(0, 255));
        continue;
      }

      float nx = noiseScale * x;
      float ny = noiseScale * y;
      float nt = noiseScale * frameCount * 10;

      float noiseCompute = noise(nx, nt, ny);

      if (noiseCompute < noise_t) {
        int x_frame = x - screen2_cornerX;
        int y_frame = y - screen2_cornerY;

        int index = x_frame + y_frame * screenSize;
        pixels[x + y * width] = frame.pixels[x_frame - 1 + index];
      }
    }
  }

  updatePixels();
  push();
  textSize(30);
  fill(255, 0, 0, map(sin(frameCount * 0.1), -1, 1, 0, 255));
  textAlign(CENTER, CENTER);
  text("LOW SIGNAL", screen2Center.x, screen2Center.y);
  pop();
}

void radio(int ammount) {
  
  int min = 5;
  int max = 20;
  
  loadPixels();
  for (int i = 0; i < ammount / 10; i++) {
    int w = floor(random(min, max));
    int h = floor(random(min, max));
    int x1 = floor(random(screen2_cornerX, screen2_cornerX+screenSize-w));
    int y1 = floor(random(screen2_cornerY, screen2_cornerX+screenSize-h));
    
    int x2 = floor(random(screen2_cornerX, screen2_cornerX+screenSize-w));
    int y2 = floor(random(screen2_cornerY, screen2_cornerX+screenSize-h));
    println(w, h, x1, y1, x2, y2);
    set(x2, y2, get(x1, y1, w, h));
  }
  
  
  updatePixels();
  
  
}
