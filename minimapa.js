class MiniMapa {
  constructor(x, y, size, mapa) {
    this._pos = createVector(x, y);
    this._size = size;
    this._mapa = mapa;
    this.pg = createGraphics(size, size);

    this.minimapaCellSize = this._size / this._mapa._cols;
    this.pg.background(0);

    this.pg.noStroke();
    for (let x = 0; x < this._mapa._cols; x++) {
      for (let y = 0; y < this._mapa._rows; y++) {
        if (!this._mapa.grid[x][y].state) {
          this.pg.rect(
            x * this.minimapaCellSize,
            y * this.minimapaCellSize,
            this.minimapaCellSize,
            this.minimapaCellSize
          );
        }
      }
    }
  }

  display() {
    image(this.pg, this._pos.x, this._pos.y, this._size, this._size);
    let minimapPlayerPos = createVector(
      map(player.pos.x, 0, this._mapa._size.x, 0, this._size),
      map(player.pos.y, 0, this._mapa._size.y, 0, this._size)
    );
    fill(0, 255, 0);
    noStroke();
    circle(
      this._pos.x + minimapPlayerPos.x,
      this._pos.y + minimapPlayerPos.y,
      this.minimapaCellSize * 2
    );

    for (let sample of samples) {
      let minimapSamplePos = createVector(
        map(sample.pos.x, 0, this._mapa._size.x, 0, this._size),
        map(sample.pos.y, 0, this._mapa._size.y, 0, this._size)
      );
      sample.selected ? stroke(0, 255, 0) : noStroke();
      fill(255, 0, 0);
      circle(
        this._pos.x + minimapSamplePos.x,
        this._pos.y + minimapSamplePos.y,
        this.minimapaCellSize * 2
      );
    }
  }
}
