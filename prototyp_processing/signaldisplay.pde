

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
    
    
    image(p, screenCenter1.x-screenSize/2, screenCenter2.y-screenSize/2, screenSize, screenSize);
  }
}
