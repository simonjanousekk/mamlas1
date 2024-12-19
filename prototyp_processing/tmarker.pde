enum TerrainType {
  X, O, S, N
}

class TMarker {
  final int radius = 5;
  PVector pos;
  TerrainType type = TerrainType.N;

  TMarker(float x, float y) {
    pos = new PVector(x, y);
    float mc = mapa.grid[int(x/mapa.cellSize)][int(y/mapa.cellSize)].terrainNoise;
    float t = mapa.grid[int(x/mapa.cellSize)][int(y/mapa.cellSize)].treshold;
    float l = t / 3;
    if (mc < l) {
      type = TerrainType.X;
    } else if (mc < l*2) {
      type = TerrainType.O;
    } else {
      type = TerrainType.S;
    }
    println(int(mapa.size.x/x), int(mapa.size.y/y));
  }

  void display() {

    push();
    fill(0);
    noStroke();
    translate(pos.x, pos.y);
    if (type == TerrainType.X) {
      stroke(0);
      strokeWeight(5);
      line(-radius, -radius, radius, radius);
      line(radius, -radius, -radius, radius);
    } else if (type == TerrainType.O) {
      circle(0, 0, radius*2);
    } else if (type == TerrainType.S) {
      rect(-radius, -radius, radius * 2, radius * 2);
    }

    pop();
  }
}
