

class DCross {
  PVector pos;
  String label;
  int size;
  DCross(float x, float y, int s, String l) {
    pos = new PVector(x,y);
    label = l;
    size = s;
  }
  
  DCross(PVector p, int s, String l) {
    this(p.x, p.y, s, l);
  }
  
  
  void display() {
    push();
    translate(pos.x, pos.y);
    stroke(primary);
    strokeWeight(s_thick);
    line(0, -size / 2, 0, size / 2);
    line( -size / 2, 0, size / 2, 0);
    
    
    rotate(player.angle);
    line(0, 0, size *.75, -size *.75);
    translate(size *.75, -size *.75);
    textAlign(LEFT, BOTTOM);
    fill(primary);
    // textSize(24);
    text(label, 0, 0);
    pop();
    
    
  }
}
