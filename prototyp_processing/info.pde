int relevantWallsC;
int relevantWMarkersC;

class Info {
  PVector pos;
  Info(PVector p) {
    pos = p;
  }
  
  void display() {
    push();
    fill(255);
    textAlign(LEFT, TOP);
    textSize(16);
    text("batt: " + int(battery) + "%", pos.x, pos.y);
    text("walls: " + relevantWallsC + "/" + walls.size(), pos.x, pos.y + 15);
    text("wmarks: " + relevantWMarkersC + "/" + wmarkers.size(), pos.x, pos.y + 30);
    text("samp: " + player.samplesCollected, pos.x, pos.y + 45);
    int s = player.terrainSetting;
    int p = player.onTerrain;
    text("terr: s" + s + "/p" + p + "/d" + (s - p), pos.x, pos.y + 60);
    text("vel: " + player.speed, pos.x, pos.y + 75);
    pop();
  }
}


void displayFPS() {
  push();
  fill(255);
  textSize(16);
  textAlign(RIGHT, BOTTOM);
  text(fakeFrameRate, width - 5, height - 20);
  text(int(frameRate), width - 5, height - 5);
  pop();
}
