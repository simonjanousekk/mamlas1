class Rock {
  constructor(x, y, radius, wallCount) {
    this._radius = radius;
    this._wallCount = wallCount;
    this.pos = createVector(x, y);
    this.walls = [];

    let previousPos;
    let firstPos;
    for (let i = 0; i < TWO_PI; i += TWO_PI / this._wallCount) {
      let offset = random(-this._radius / 3, this._radius / 3);
      let x = this.pos.x + this._radius * cos(i) + offset;
      let y = this.pos.y + this._radius * sin(i) + offset;
      if (!i == 0) {
        this.walls.push(new Wall(previousPos.x, previousPos.y, x, y));
      } else {
        firstPos = createVector(x, y);
      }
      previousPos = createVector(x, y);
    }
    this.walls.push(
      new Wall(previousPos.x, previousPos.y, firstPos.x, firstPos.y)
    );
  }

  display() {
    push();
    noStroke();
    fill(100);
    beginShape();
    for (let wall of this.walls) {
      vertex(wall.pos1.x, wall.pos1.y);
      vertex(wall.pos2.x, wall.pos2.y);
    }
    endShape(CLOSE);
    pop();
  }
}
