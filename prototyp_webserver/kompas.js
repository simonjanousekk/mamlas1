class Kompas {
  constructor(x, y, size) {
    this.pos = createVector(x, y);
    this.angle = 0;
    this.arrowLength = 10;
    this.kompasLength = size;
  }

  update(angle) {
    this.angle = angle;
  }

  display() {
    push();
    stroke(0);
    fill(200);
    translate(this.pos.x, this.pos.y);
    circle(0, 0, this.kompasLength * 2);
    rotate(this.angle);
    line(
      this.kompasLength / 2,
      this.kompasLength / 2,
      -this.kompasLength / 2,
      -this.kompasLength / 2
    );

    translate(this.kompasLength / 2, this.kompasLength / 2);
    rotate(PI / 4 + PI);
    line(0, 0, this.arrowLength, -this.arrowLength);
    line(0, 0, this.arrowLength, this.arrowLength);
    pop();
  }
}
