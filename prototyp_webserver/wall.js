class Wall {
  constructor(x1, y1, x2, y2) {
    this.pos1 = createVector(x1, y1);
    this.pos2 = createVector(x2, y2);
    this.colided = false;
  }

  display() {
    this.colided ? stroke(255, 0, 0) : stroke(0, 255, 0);
    push();
    strokeWeight(2);
    line(this.pos1.x, this.pos1.y, this.pos2.x, this.pos2.y);
    pop();
  }
}
