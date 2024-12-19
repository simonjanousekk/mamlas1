class Wall {
  PVector pos1, pos2;
  boolean collided = false;
  Wall(float x1, float y1, float x2, float y2) {
    pos1 = new PVector(x1, y1);
    pos2 = new PVector(x2, y2);
  }
  Wall(PVector p1, PVector p2) {
    this(p1.x, p1.y, p2.x, p2.y);
  }

  void display() {
    stroke(collided ? color(255, 255, 0) : color(255, 0, 255));
    push();
    strokeWeight(4);
    line(this.pos1.x, this.pos1.y, this.pos2.x, this.pos2.y);
    pop();
  }
}
