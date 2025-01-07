

class TMarker {
  final int radius = 5;
  PVector pos;
  Terrain type;

  TMarker(float x, float y) {
    pos = new PVector(x, y);
    type = mapa.grid[int(x/mapa.cellSize)][int(y/mapa.cellSize)].terrain;
    println(type);
  }

  void display() {
    push();
    fill(0);
    noStroke();
    translate(pos.x, pos.y);
    if (type == Terrain.HARD) {
      stroke(0);
      strokeWeight(5);
      line(-radius, -radius, radius, radius);
      line(radius, -radius, -radius, radius);
    } else if (type == Terrain.MID) {
      circle(0, 0, radius*2);
    } else if (type == Terrain.SOFT) {
      rect(-radius, -radius, radius * 2, radius * 2);
    }

    pop();
  }
}
