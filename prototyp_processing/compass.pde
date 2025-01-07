class Compass{
  int radius;
  float angleToSample;
  
  
  int arrowL = 100;
  int arrowHL = 20;
  Compass(int r) {
    radius = r;
    
  }
  
  void update() {
    angleToSample = atan2(samples.get(0).pos.x-player.pos.x, samples.get(0).pos.y-player.pos.y);
    angleToSample += player.angle - PI/4+PI;
  }
  
  void display() {
    this.update();
    
    push();
    translate(width/2, height/2);  
    rotate(-angleToSample);
    
    
    stroke(0);    
    strokeWeight(2);
    translate(0, radius);
    line(0, 0, 0, -arrowL);
    line(0, 0, -arrowHL, -arrowHL);
    line(0, 0, arrowHL, -arrowHL);
    
    pop();
    
  }
}
