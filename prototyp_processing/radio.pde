
void radio(int noiseAmount) {
  // later on can be adjusted based on sensor value
  float n = map(noiseAmount, 0, width, 9, 1);

  //noise_t = map(mouseX, 0, width, 0.1, 0.7);
  if (frameCount % int(n) == 0) {
    // threshold for how many pixels are affected by the displacement effect - 0 = none, 0.7 = most of them
    float maxRange = 1.1  - (n / 10);
    noise_t = random(0, maxRange);
  }

  int x_corner = int(screen2Center.x - screenSize / 2);
  int y_corner = int(screen2Center.y - screenSize / 2);
  PImage frame = get(x_corner, y_corner, screenSize, screenSize);

  loadPixels();
  frame.loadPixels();
  for (int x = x_corner + 1; x < x_corner + screenSize - 2; x ++) {
    for (int y = y_corner + 1; y < y_corner + screenSize - 2; y++) {

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
        int x_frame = x - x_corner;
        int y_frame = y - y_corner;

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
