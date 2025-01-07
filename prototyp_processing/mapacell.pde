enum Diagonal {
  FALSE, TOP_LEFT, TOP_RIGHT, BOTT_LEFT, BOTT_RIGHT
}
enum Terrain {
  SOFT, HARD, MID
}

class MapaCell {
  final PVector pos;
  boolean state;
  final int gridX, gridY, cellSize;
  int numOfNeighbors;
  float terrainNoise, wallNoise;
  final float treshold = .45;
  color col;
  Diagonal diagonal = Diagonal.FALSE;
  Terrain terrain;

  MapaCell(int x, int y, int c, float t, float wt) {
    pos = new PVector(x * c, y * c);
    state = wt > treshold;
    gridX = x;
    gridY = y;
    cellSize = c;
    terrainNoise = t;
    wallNoise = wt;

    numOfNeighbors = 0;
  }

  void turnOn() {
    terrainNoise = random(1, treshold);
    state = true;
    push();
    colorMode(HSB, 255);
    //col = color(map(terrainNoise, .2, treshold, 0, 150), 255, 255);
    pop();
  }

  void initNeighbors(Mapa mapa) {
    if (!state) {
      if (terrainNoise > .66) {
        terrain = Terrain.HARD;
        col = color(255, 0, 0);
      } else if (terrainNoise > .33) {
        terrain = Terrain.MID;
        col = color(255, 255, 0);
      } else {
        terrain = Terrain.SOFT;
        col = color(0, 255, 0);
      }
    }

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
        if (neighbors[0] && neighbors[1]) {
          diagonal = Diagonal.BOTT_LEFT;
        } else {
          diagonal = Diagonal.TOP_RIGHT;
        }
      } else if (
        numOfNeighbors == 2 &&
        ((neighbors[0] && neighbors[3]) ||
        (neighbors[2] && neighbors[1]))
        ) {
        addWall(5);
        if (neighbors[0] && neighbors[3]) {
          diagonal = Diagonal.TOP_LEFT;
        } else {
          diagonal = Diagonal.BOTT_RIGHT;
        }
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
    if ((
      pos.x < player.pos.x + width / 2 &&
      pos.x > player.pos.x - width / 2 - cellSize &&
      pos.y < player.pos.y + height / 2 &&
      pos.y > player.pos.y - height / 2 - cellSize) && !state
      ) {
      push();
      translate(pos.x, pos.y);
      //strokeWeight(2);
      stroke(col);
      fill(col);
      if (diagonal == Diagonal.FALSE) {

        rect(0, 0, cellSize, cellSize);
      } else if (diagonal == Diagonal.BOTT_LEFT) {
        beginShape();
        vertex(0, 0);
        vertex(0, cellSize);
        vertex(cellSize, cellSize);
        endShape(CLOSE);
      } else if (diagonal == Diagonal.TOP_RIGHT) {
        beginShape();
        vertex(0, 0);
        vertex(cellSize, 0);
        vertex(cellSize, cellSize);
        endShape(CLOSE);
      } else if (diagonal == Diagonal.TOP_LEFT) {
        beginShape();
        vertex(0, cellSize);
        vertex(cellSize, 0);
        vertex(cellSize, cellSize);
        endShape(CLOSE);
      } else if (diagonal == Diagonal.BOTT_RIGHT) {
        beginShape();
        vertex(0, cellSize);
        vertex(cellSize, 0);
        vertex(0, 0);
        endShape(CLOSE);
      }

      pop();
    }
  }
}
