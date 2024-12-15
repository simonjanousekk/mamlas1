class Sample {
  PVector pos;
  boolean selected = false;
  Sample(float x, float y) {
    pos = new PVector(x, y);
  }
  Sample(PVector p) {
    this(p.x, p.y);
  }

  void update() {
    if (sampleCollected()) {
      collect();
    }
  }

  void display() {
    push();
    noStroke();
    fill(255, 0, 0);
    circle(this.pos.x, this.pos.y, 10);
    pop();
  }

  boolean sampleCollected() {
    float xdiff = player.pos.x - this.pos.x;
    float ydiff = player.pos.y - this.pos.y;
    float m = player.diameter/2;
    if (xdiff < m && xdiff > -m && ydiff < m && ydiff > -m) {
      return true;
    }
    return false;
  }

  void collect() {
    player.samplesCollected++;
    pos = randomPosOutsideWalls();
  }
}
