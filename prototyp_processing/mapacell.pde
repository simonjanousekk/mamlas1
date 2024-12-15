class MapaCell {
  final PVector pos;
  boolean state;
  final int gridX, gridY, cellSize;
  int numOfNeighbors;
  float terrain;
  final float treshold = .5;
  int col;

  MapaCell(int x, int y, int c, float t) {
    pos = new PVector(x * c, y * c);
    state = t > .5;
    gridX = x;
    gridY = y;
    cellSize = c;
    terrain = t;
    numOfNeighbors = 0;
  }

  void initNeighbors(Mapa mapa) {

    push();
    colorMode(HSB, 255);
    if (!state) {
      col = color(map(terrain, .2, treshold, 0, 150), 255, 255);
    } else {
      col = 20;
    }
    pop();

    if (!state) {
      //get neighbors
      boolean[] neighbors = {
        gridY > 0 ? mapa.grid[gridX][gridY - 1].state : false,
        gridX < mapa.cols - 1 ? mapa.grid[gridX + 1][gridY].state : false,
        gridY < mapa.rows - 1 ? mapa.grid[gridX][gridY + 1].state : false,
        gridX > 0 ? mapa.grid[gridX - 1][gridY].state : false,
      };

      // get num of neighbors
      for (Boolean b : neighbors) {
        if (b) {
          numOfNeighbors++;
        }
      }


      if (
        numOfNeighbors == 2 &&
        ((neighbors[0] && neighbors[1]) ||
        (neighbors[2] && neighbors[3]))
        ) {
        addWall(4);
      } else if (
        numOfNeighbors == 2 &&
        ((neighbors[0] && neighbors[3]) ||
        (neighbors[2] && neighbors[1]))
        ) {
        addWall(5);
      } else {
        for (int i = 0; i < neighbors.length; i++) {
          if (neighbors[i]) addWall(i);
        }
      }
    }
  }




  void addWall(int d) {
    if (d == 0) { // top
      walls.add(new Wall(pos.x, pos.y, pos.x + cellSize, pos.y));
    } else if (d == 1) { // right
      walls.add(new Wall(pos.x + cellSize, pos.y, pos.x + cellSize, pos.y + cellSize));
    } else if (d == 2) { // bottom
      walls.add(new Wall(pos.x, pos.y + cellSize, pos.x + cellSize, pos.y + cellSize));
    } else if (d == 3) { // left
      walls.add(new Wall(pos.x, pos.y, pos.x, pos.y + cellSize));
    } else if (d == 4) { // diagonal 1
      walls.add(new Wall(pos.x, pos.y, pos.x + cellSize, pos.y + cellSize));
    } else if (d == 5) { // diagonal 2
      walls.add(new Wall(pos.x, pos.y + cellSize, pos.x + cellSize, pos.y));
    }
  }



  void display() {
    if (
      pos.x < player.pos.x + width / 2 &&
      pos.x > player.pos.x - width / 2 - cellSize &&
      pos.y < player.pos.y + height / 2 &&
      pos.y > player.pos.y - height / 2 - cellSize
      ) {
      push();
      translate(pos.x, pos.y);
      strokeWeight(2);
      stroke(col);
      fill(col);

      rect(0, 0, cellSize, cellSize);
      pop();
    }
  }
}
