class Ray {
  constructor(x, y, angle) {
    this.pos = createVector(x, y);
    this.dir = p5.Vector.fromAngle(angle);
    this._rayLength = 100;

    this.intersection = null;
  }

  update(pos, dir) {
    this.pos.x = pos.x;
    this.pos.y = pos.y;
  }

  display() {
    if (this.intersection) {
      stroke(100, 100, 255);
      line(this.pos.x, this.pos.y, this.intersection.x, this.intersection.y);
      noStroke();
      fill(100, 100, 255);
      circle(this.intersection.x, this.intersection.y, 10);
    } else {
      stroke(100, 100, 255);
      line(
        this.pos.x,
        this.pos.y,
        this.pos.x + this.dir.x * this._rayLength,
        this.pos.y + this.dir.y * this._rayLength
      );
    }
  }

  cast(walls) {
    let intersections = [];
    for (let wall of walls) {
      intersections.push(
        lineLineIntersection(
          this.pos,
          this.pos.copy().add(this.dir.copy().mult(this._rayLength)),
          wall.pos1,
          wall.pos2
        )
      );
    }
    return intersections;
  }

  findShortestIntersection(intersections) {
    this.intersection = null;
    let shortestIntersection = null;
    for (let intersection of intersections) {
      if (intersection) {
        if (
          !shortestIntersection ||
          (intersection.x - this.pos.x) ** 2 +
            (intersection.y - this.pos.y) ** 2 <
            (shortestIntersection.x - this.pos.x) ** 2 +
              (shortestIntersection.y - this.pos.y) ** 2
        ) {
          shortestIntersection = intersection;
        }
      }
    }
    this.intersection = shortestIntersection;
  }
}
