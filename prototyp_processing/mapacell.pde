
enum Terrain {
  SOFT, HARD, MID
}

class MapaCell {
  final PVector pos;
  boolean state;
  final int gridX, gridY, cellSize;
  int numOfNeighbors;
  
  int caseValue = 0;
  int terrain;
  color col;
  boolean diagonal = false;
  
  MapaCell(int x, int y, int c, float t, float wt) {
    pos = new PVector(x * c, y * c);
    state = wt > treshold;
    gridX = x;
    gridY = y;
    cellSize = c;
    
    numOfNeighbors = 0;
    
    
    terrain = int(t * terrainTypeCount);
    col = color(map(terrain, 0, terrainTypeCount, 0, 255), 0, 0);
  }
  
  
  
  
  void displayAlt() {
    if (
      !state && 
      isDistanceLess(pos, player.pos, screenSize / 2)
     ){
      push();
      
      stroke(gray);
      translate(pos.x, pos.y);
      
      
      line(0, 0, cellSize, cellSize);
      if (terrain == 1) {
        line(0, cellSize, cellSize, 0);
      } else if (terrain == 2) {
        line(cellSize / 2, 0, cellSize, cellSize / 2);
        line(0, cellSize / 2, cellSize / 2, cellSize);
      } else if (terrain == 3) {
        line(0, cellSize, cellSize, 0);
        line(cellSize / 2, 0, cellSize, cellSize / 2);
        line(0, cellSize / 2, cellSize / 2, cellSize);
        line(cellSize / 2, 0, 0, cellSize / 2);
        line(cellSize, cellSize / 2, cellSize / 2, cellSize);
      }
      
      if (diagonal) {
        
        fill(0);
        stroke(0);
        if (caseValue == 3) {
          triangle(0, 0, cellSize, 0, cellSize, cellSize);
        } else if (caseValue == 5) {
        } else if (caseValue == 6) {
          triangle(0, cellSize, cellSize, 0, cellSize, cellSize);
        } else if (caseValue == 9) {
          triangle(0, 0, cellSize, 0, 0, cellSize);
        } else if (caseValue == 12) {
          triangle(0, 0, cellSize, cellSize, 0, cellSize);
        }
      }
      
      pop();
    }
  }
  
  
  
  
  void initNeighbors(Mapa mapa) {
    if (!state) {
      // Determine the Marching Squares case (4-bit number)
      if (gridY > 0 && mapa.grid[gridX][gridY - 1].state) caseValue |= 1; // Top
      if (gridX < mapa.cols - 1 && mapa.grid[gridX + 1][gridY].state) caseValue |= 2; // Right
      if (gridY < mapa.rows - 1 && mapa.grid[gridX][gridY + 1].state) caseValue |= 4; // Bottom
      if (gridX > 0 && mapa.grid[gridX - 1][gridY].state) caseValue |= 8; // Left
      // Lookup and draw walls/diagonals
      drawWalls();
    }
  }
  
  void drawWalls() {
    switch(caseValue) {
      case 1:
        addWall(0);
        break; // Top
      case 2:
        addWall(1);
        break; // Right
      case 3:
        addWall(4);
        diagonal = true;
        break; // Top-right diagonal
      case 4:
        addWall(2);
        break; // Bottom
      case 6:
        addWall(5);
        diagonal = true;
        break; // Bottom-right diagonal
      case 8:
        addWall(3);
        break; // Left
      case 9:
        addWall(5);
        diagonal = true;
        break; // Top-left diagonal
      case 12:
        addWall(4);
        diagonal = true;
        break; // Bottom-left diagonal
      case 15 : /* Fully surrounded, no walls */
        break;
        default:
        if((caseValue & 1) != 0) addWall(0); // Top
        if((caseValue & 2) != 0) addWall(1); // Right
        if((caseValue & 4) != 0) addWall(2); // Bottom
        if((caseValue & 8) != 0) addWall(3); // Left
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
    } else if (d == 4) { // diagonal top-left to bottom-right
        walls.add(new Wall(pos.x, pos.y, pos.x + cellSize, pos.y + cellSize));
    } else if (d == 5) { // diagonal bottom-left to top-right
        walls.add(new Wall(pos.x + cellSize, pos.y, pos.x, pos.y + cellSize));
    }
    }
    }
        
        
        
        
        
        
        /*
        Case Table for Marching Squares:
        
        Case 0 -  Binary: 0000  -  No walls
        Case 1 -  Binary: 0001  -  Bottom-Left corner filled       - Left, Bottom
        Case 2 -  Binary: 0010  -  Bottom-Right corner filled      - Bottom, Right
        Case 3 -  Binary: 0011  -  Bottom row filled               - Diagonal: Top-Right to Bottom-Left
        Case 4 -  Binary: 0100  -  Top-Right corner filled         - Right, Top
        Case 5 -  Binary: 0101  -  Opposite corners (BL, TR)       - Diagonal: Bottom-Left to Top-Right
        Case 6 -  Binary: 0110  -  Right column filled             - Diagonal: Top-Left to Bottom-Right
        Case 7 -  Binary: 0111  -  All but Top-Left filled         - Top, Right, Bottom
        Case 8 -  Binary: 1000  -  Top-Left corner filled          - Top, Left
        Case 9 -  Binary: 1001  -  Left column filled              - Diagonal: Top-Left to Bottom-Right
        Case 10-  Binary: 1010  -  Opposite corners (TL, BR)       - Diagonal: Top-Right to Bottom-Left
        Case 11-  Binary: 1011  -  All but Top-Right filled        - Right, Top, Left
        Case 12-  Binary: 1100  -  Top row filled                  - Diagonal: Bottom-Left to Top-Right
        Case 13-  Binary: 1101  -  All but Bottom-Right filled     - Right, Bottom, Left
        Case 14-  Binary: 1110  -  All but Bottom-Left filled      - Top, Right, Left
        Case 15-  Binary: 1111  -  Fully surrounded                - No walls
        */
        
        
