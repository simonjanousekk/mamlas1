class Mapa {
  constructor(x, y, cellSize) {
    this._size = createVector(x, y);
    this._cellSize = cellSize;
    this._cols = this._size.x / this._cellSize;
    this._rows = this._size.y / this._cellSize;

    this._noiseScale = 0.05;

    this.grid = [];

    // First create all cells without checking neighbors
    for (let x = 0; x < this._cols; x++) {
      this.grid[x] = [];
      for (let y = 0; y < this._rows; y++) {
        let state = noise(x * this._noiseScale, y * this._noiseScale) >= 0.5;
        this.grid[x][y] = new MapaCell(x, y, cellSize, state);
      }
    }

    // Turn off cells around the map borders
    for (let x = 0; x < this._cols; x++) {
      this.grid[x][0].state = true; // Top row
      this.grid[x][this._rows - 1].state = true; // Bottom row
    }
    for (let y = 0; y < this._rows; y++) {
      this.grid[0][y].state = true; // Left column
      this.grid[this._cols - 1][y].state = true; // Right column
    }

    // Then initialize neighbors after all cells are created
    for (let x = 0; x < this._cols; x++) {
      for (let y = 0; y < this._rows; y++) {
        this.grid[x][y].initNeighbors(this);
      }
    }
  }

  display() {
    for (let x = 0; x < this._cols; x++) {
      for (let y = 0; y < this._rows; y++) {
        this.grid[x][y].display();
      }
    }
  }
}

class MapaCell {
  constructor(x, y, cellSize, state) {
    this.pos = createVector(x * cellSize, y * cellSize);
    this.state = state;
    this.gridX = x;
    this.gridY = y;
    this.cellSize = cellSize; // Store cellSize locally
    this.numOfNeighbors = 0;
  }

  initNeighbors(mapa) {
    // Get neighboring cell states (if they exist)
    if (!this.state) {
      this.neighbors = {
        top:
          this.gridY > 0 ? mapa.grid[this.gridX][this.gridY - 1].state : null,
        right:
          this.gridX < mapa._cols - 1
            ? mapa.grid[this.gridX + 1][this.gridY].state
            : null,
        bottom:
          this.gridY < mapa._rows - 1
            ? mapa.grid[this.gridX][this.gridY + 1].state
            : null,
        left:
          this.gridX > 0 ? mapa.grid[this.gridX - 1][this.gridY].state : null,
      };

      this.numOfNeighbors = Object.values(this.neighbors).filter(
        Boolean
      ).length;

      if (this.numOfNeighbors === 1) {
        for (const dir in this.neighbors) {
          if (this.neighbors[dir]) {
            this.addWall(dir);
          }
        }
      } else if (this.numOfNeighbors === 2) {
        if (
          (this.neighbors.top && this.neighbors.right) ||
          (this.neighbors.bottom && this.neighbors.left)
        ) {
          this.addWall("diagonal1");
        } else if (
          (this.neighbors.top && this.neighbors.left) ||
          (this.neighbors.bottom && this.neighbors.right)
        ) {
          this.addWall("diagonal2");
        } else {
          for (const dir in this.neighbors) {
            if (this.neighbors[dir]) {
              this.addWall(dir);
            }
          }
        }
      } else if (this.numOfNeighbors === 3) {
        for (const dir in this.neighbors) {
          if (!this.neighbors[dir]) {
            this.addWall(dir);
          }
        }
      }
    }
  }

  addWall(dir) {
    if (dir === "top") {
      walls.push(
        new Wall(this.pos.x, this.pos.y, this.pos.x + this.cellSize, this.pos.y)
      );
    } else if (dir === "right") {
      walls.push(
        new Wall(
          this.pos.x + this.cellSize,
          this.pos.y,
          this.pos.x + this.cellSize,
          this.pos.y + this.cellSize
        )
      );
    } else if (dir === "bottom") {
      walls.push(
        new Wall(
          this.pos.x,
          this.pos.y + this.cellSize,
          this.pos.x + this.cellSize,
          this.pos.y + this.cellSize
        )
      );
    } else if (dir === "left") {
      walls.push(
        new Wall(this.pos.x, this.pos.y, this.pos.x, this.pos.y + this.cellSize)
      );
    } else if (dir === "diagonal1") {
      walls.push(
        new Wall(
          this.pos.x,
          this.pos.y,
          this.pos.x + this.cellSize,
          this.pos.y + this.cellSize
        )
      );
    } else if (dir === "diagonal2") {
      walls.push(
        new Wall(
          this.pos.x,
          this.pos.y + this.cellSize,
          this.pos.x + this.cellSize,
          this.pos.y
        )
      );
    }
  }

  display() {
    if (
      this.pos.x < player.pos.x + width / 2 &&
      this.pos.x > player.pos.x - width / 2 - this.cellSize &&
      this.pos.y < player.pos.y + height / 2 &&
      this.pos.y > player.pos.y - height / 2 - this.cellSize
    ) {
      push();
      translate(this.pos.x, this.pos.y);
      noStroke();
      fill(this.state ? 20 : 200);
      rect(0, 0, this.cellSize, this.cellSize);
      if (!this.state) {
        translate(this.cellSize / 2, this.cellSize / 2);
        textSize(this.cellSize);
        textAlign(CENTER, CENTER);
        fill(200);
        // text(this.numOfNeighbors, 0, 0);
      }
      pop();
    }
  }
}
