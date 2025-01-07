class Info{
  PVector pos;
  Info(PVector p) {
    pos = p;
    
  }
  
  void display() {
    fill(255);
    textAlign(LEFT, TOP);
    text("Battery: " + int(battery) + "%", pos.x, pos.y);
    
  }
  
}
