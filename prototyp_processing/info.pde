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
    text("batt: " + int(battery) + "%", pos.x, pos.y);
    text("walls: " + relevantWallsC + "/" + walls.size(), pos.x, pos.y + 15);
    text("wmarks: " + relevantWMarkersC+ "/" + wmarkers.size(), pos.x, pos.y + 30);
    text("samp: " + player.samplesCollected, pos.x, pos.y + 45);
    int s = player.terrainSetting;
    int p = player.onTerrain;
    text("terr: s" + s + "/p" + p + "/d" + (s-p), pos.x, pos.y + 60);
    text("vel: " + round(player.currentSpeed*10)/10.0, pos.x, pos.y+75);
  }
}
