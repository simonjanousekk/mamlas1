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
    textAlign(CENTER, BOTTOM);
    textSize(16);
    text("batt: " + int(gameState.battery) + "%" + " pow: " + gameState.powerUsage, pos.x, pos.y);
    text("walls: " + relevantWallsC + "/" + walls.size(), pos.x, pos.y + 15);
    text("wmarks: " + relevantWMarkersC + "/" + wmarkers.size(), pos.x, pos.y + 30);
    text("samp: " + player.samplesCollected, pos.x, pos.y + 45);
    int s = player.terrainSetting;
    int p = player.onTerrain;
    text("terr: s" + s + "/p" + p + "/d" + player.terrainDifference, pos.x, pos.y + 60);
    text("vel: " + nf(player.speed, 0, 2) + " mult: " + nf(player.speedMultiplier, 0, 2), pos.x, pos.y + 75);
    text("phase: " + gameState.dayPhase + " time: " + gameState.dayTime, pos.x, pos.y + 90);
    text("temp: " + int(gameState.temperature) + " outTemp: " + int(gameState.outTemperature), pos.x, pos.y + 105);
    text("cool: " + gameState.cooling + " heat: " + gameState.heating, pos.x, pos.y + 120);
    if (hazardMonitor != null) {
      text("haz: " + gameState.hazardChanceMultiplier, pos.x, pos.y+135);
    }
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
