

class SignalDisplay {
  PGraphics p = createGraphics(screenSize, screenSize);
  SignalDisplay() {
    
  }
  void update() {
  }
  
  void display() {
    
    p.beginDraw();
    p.background(255, 255, 0);
    
    
    p.endDraw();
    
    
    image(p, screen1Center.x - screenSize / 2, screen2Center.y - screenSize / 2, screenSize, screenSize);
  }
}
