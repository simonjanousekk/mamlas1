int relevantWallsC;
int relevantWMarkersC;

class Info {
  PVector pos;
  Info(PVector p) {
    pos = p;
  }

  void display() {
    fill(255);
    textAlign(LEFT, TOP);
    text("Battery: " + int(battery) + "%", pos.x, pos.y);
    text("Walls: " + relevantWallsC + "/" + walls.size(), pos.x, pos.y + 15);
    text("WMarks: " + relevantWMarkersC+ "/" + wmarkers.size(), pos.x, pos.y + 30);
    text("Samp: " + player.samplesCollected, pos.x, pos.y + 45);
  }
}
