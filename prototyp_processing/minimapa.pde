class Minimapa {
  int size;
  float minimapaCellSize;
  PGraphics pg;

  Minimapa(int s) {
    size = s;
    pg = createGraphics(size, size);
    minimapaCellSize = float(size) / mapa.rows;
    update();
  }

  void update() {
    pg.beginDraw();
    pg.background(127);
    pg.noStroke();
    //pg.stroke(0);
    //pg.strokeWeight(0);

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
}



class MinimapaWindow extends PApplet {
  PApplet parent;
  Minimapa minimap;

  MinimapaWindow(PApplet parent, Minimapa minimap) {
    this.parent = parent;
    this.minimap = minimap;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(minimap.size, minimap.size);
  }

  public void setup() {
    surface.setTitle("Minimap");
  }

  public void draw() {
    background(50);
    this.image(minimap.pg, 0, 0, this.width, this.height);
    // Render player position
    PVector minimapPlayerPos = new PVector(
      map(player.pos.x, 0, mapa.size.x, 0, this.width),
      map(player.pos.y, 0, mapa.size.y, 0, this.height)
      );
    this.fill(0, 255, 0);
    this.noStroke();
    this.circle(minimapPlayerPos.x, minimapPlayerPos.y, 5);

    // Render samples

    PVector minimapSamplePos = new PVector(
      map(sample.pos.x, 0, mapa.size.x, 0, this.width),
      map(sample.pos.y, 0, mapa.size.y, 0, this.height)
      );
    this.fill(255, 0, 0);
    this.noStroke();
    this.circle(minimapSamplePos.x, minimapSamplePos.y, 5);


    for (DCross dc : dcrosses) {
      this.fill(0, 255, 0);
      this.circle(        map(dc.pos.x, 0, mapa.size.x, 0, this.width), map(dc.pos.y, 0, mapa.size.y, 0, this.height), 5);
    }
  }


  public void close() {
    getSurface().setVisible(false); // Hide the window
    dispose();
  }
}
