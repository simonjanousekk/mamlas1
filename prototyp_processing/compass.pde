class Compass {
  int radius;
  float arrowRadius;
  float angleToSample;  
  int arrowL = 70;
  int arrowHL = 20;
  
  int arrowSampleSpace;
  
  Compass(int r, int as) {
    radius = r;
    arrowSampleSpace = as;
  }
  
  void update() {
    angleToSample = atan2(sample.pos.x - player.pos.x, sample.pos.y - player.pos.y);
    angleToSample += player.angle;
    
    boolean sampleInView = isDistanceLess(player.pos, sample.pos, radius + arrowSampleSpace);
    
    if (!sampleInView) {
      arrowRadius = radius;
    } else {
      arrowRadius = player.pos.dist(sample.pos) - arrowSampleSpace;
    }
  }
  
  void display() {
    this.update();
    
    push();
    translate(width / 2, height / 2);
    rotate( -angleToSample);
    translate(0, arrowRadius);
    
    
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
