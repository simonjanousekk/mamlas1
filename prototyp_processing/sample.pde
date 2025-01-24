class Sample {
  PVector pos;
  int diameter;
  boolean selected = false;
  Sample(float x, float y) {
    pos = new PVector(x, y);
    diameter = 10;
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
    translate(pos.x, pos.y);
    //rotate(PI / 4);
    //noStroke();
    //strokeWeight(s_thick);
    //fill(primary);

    noStroke();
    fill(primary);
    circle(0, 0, diameter);

    //rectMode(CENTER);
    //rect(0, 0, diameter, diameter);
    pop();
  }

  boolean sampleCollected() {
    return isDistanceLess(player.pos, pos, player.diameter / 2 + diameter / 2);
  }

  void collect() {
    player.samplesCollected++;
    pos = randomPosOutsideWalls();
    sampleIdentification = true;

    atomAnl = new AtomAnalyzer();
  }
}
