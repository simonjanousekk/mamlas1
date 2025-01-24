void radio(float amount) {
  
  
  int min = screenSize / 10;
  int max = screenSize / 6;
  
  loadPixels();
  for (int i = 0; i < amount * 70; i++) {
    int w = floor(random(min, max));
    int h = floor(random(min, max));
    
    int x1 = floor(random(screen2CornerX, screen2CornerX + screenSize - w));
    int y1 = floor(random(screen2CornerY, screen2CornerY + screenSize - h));
    
    int x2 = floor(random(screen2CornerX, screen2CornerX + screenSize - w));
    int y2 = floor(random(screen2CornerY, screen2CornerY + screenSize - h));
    
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
      if (random(1) < map(amount, 0, 1, 0,.1)) {
        //fill(random(1) > .5 ? white : 0);
        fill(random(255));
        //fill(white);
        
        rect(x, y, resolution, resolution);
      }
    }
  }
}
