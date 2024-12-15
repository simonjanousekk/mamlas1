class Mapa {
  final PVector size;
  final int cellSize, cols, rows;
  final float noiseScale = 0.05;

  MapaCell[][] grid;

  Mapa(int x, int y, int c) {
    size = new PVector(x, y);
    cellSize = c;
    cols = int(size.x / cellSize);
    rows = int(size.y / cellSize);

    grid = new MapaCell[cols][rows];

    // First create all cells without checking neighbors
    for (int xl = 0; xl < cols; xl++) {
      for (int yl = 0; yl < rows; yl++) {
        float terrain = noise(xl * noiseScale, yl * noiseScale);
        grid[xl][yl] = new MapaCell(xl, yl, cellSize, terrain);
      }
    }

    // Turn off cells around the map borders
    for (int xl = 0; xl < cols; xl++) {
      grid[xl][0].state = true; // Top row
      grid[xl][rows - 1].state = true; // Bottom row
    }
    for (int yl = 0; yl < rows; yl++) {
      grid[0][yl].state = true; // Left column
      grid[cols - 1][yl].state = true; // Right column
    }
    
    
    
    
    

    // Then initialize neighbors after all cells are created
    for (int xl = 0; xl < cols; xl++) {
      for (int yl = 0; yl < rows; yl++) {
        grid[xl][yl].initNeighbors(this);
      }
    }
  }

  void display() {
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        grid[x][y].display();
      }
    }
  }
}
