class Compass {
  int radius;
  float angleToSample;  
  int arrowL = 70;
  int arrowHL = 20;
  
  Compass(int r) {
    radius = r;
  }
  
  void update() {
    angleToSample = atan2(sample.pos.x - player.pos.x, sample.pos.y - player.pos.y);
    angleToSample += player.angle - PI / 4 + PI;
    
    boolean sampleInView = isDistanceLess(player.pos, sample.pos, width / 2);
  }
  
  void display() {
    this.update();
    
    push();
    translate(width / 2, height / 2);
    rotate( -angleToSample);
    translate(0, radius);
    
    
    stroke(0);
    strokeWeight(15);
    line(0, 0, 0, -arrowL);
    line(0, 0, -arrowHL, -arrowHL);
    line(0, 0, arrowHL, -arrowHL);
    
    
    stroke(0, 255, 0);
    strokeWeight(3);
    line(0, 0, 0, -arrowL);
    line(0, 0, -arrowHL, -arrowHL);
    line(0, 0, arrowHL, -arrowHL);
    
    pop();
  }
}
