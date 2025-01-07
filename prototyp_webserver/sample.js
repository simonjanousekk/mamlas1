class Sample {
  constructor(x, y) {
    this.pos = createVector(x, y);
    this.selected = false;
  }

  display() {
    push();
    noStroke();
    fill(255, 0, 0);
    circle(this.pos.x, this.pos.y, 10);
    pop();
  }

  sampleCollected() {
    let xdiff = player.pos.x - this.pos.x;
    let ydiff = player.pos.y - this.pos.y;
    if (xdiff < 10 && xdiff > -10 && ydiff < 10 && ydiff > -10) {
      return true;
    }
    return false;
  }

  collect() {
    player.samplesCollected++;
    this.pos = randomPosOutsideWalls();
  }
}
