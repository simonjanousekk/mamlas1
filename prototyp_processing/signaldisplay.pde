

class SignalDisplay {
  PGraphics p = createGraphics(height, height);
  SignalDisplay() {
  }
  void update() {
  }

  void display() {
    
    p.beginDraw();
    p.background(255, 255, 0);
    
    
    p.endDraw();
    
    
    image(p, height, 0, height, height);
  }
}
