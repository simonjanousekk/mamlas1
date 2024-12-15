class Minimapa {
  PVector pos;
  int size;
  float minimapaCellSize;
  PGraphics pg;
  Minimapa(int xl, int yl, int s) {
    pos = new PVector(xl, yl);
    size = s;
    pg = createGraphics(size, size);

    minimapaCellSize = float(size) / mapa.rows;
    pg.beginDraw();
    pg.background(0);

    pg.noStroke();
    for (int x = 0; x < mapa.cols; x++) {
      for (int y = 0; y < mapa.rows; y++) {
        if (!mapa.grid[x][y].state) {
          pg.fill(mapa.grid[x][y].col);
          pg.rect(
            x * minimapaCellSize,
            y * minimapaCellSize,
            minimapaCellSize,
            minimapaCellSize
            );
        }
      }
    }
    pg.endDraw();
  }

  void display() {
    image(pg, pos.x, pos.y, size, size);
    PVector minimapPlayerPos = new PVector(
      map(player.pos.x, 0, mapa.size.x, 0, size),
      map(player.pos.y, 0, mapa.size.y, 0, size)
      );
    fill(0);
    noStroke();
    circle(
      pos.x + minimapPlayerPos.x,
      pos.y + minimapPlayerPos.y,
      5
      );

    for (Sample sample : samples) {
      PVector minimapSamplePos = new PVector(
        map(sample.pos.x, 0, mapa.size.x, 0, size),
        map(sample.pos.y, 0, mapa.size.y, 0, size)
        );
      if (sample.selected) {
        stroke(0, 255, 0);
      } else {
        noStroke();
      }
      fill(255, 0, 0);
      circle(
        pos.x + minimapSamplePos.x,
        pos.y + minimapSamplePos.y,
        5
        );
    }
  }
}
