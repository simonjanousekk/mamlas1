class Mapa {  //<>//
  final PVector size;
  final int cellSize, cols, rows;
  float noiseScale, wallNoiseScale;

  MapaCell[][] grid;

  Mapa(int x, int y, int c, float n, float wn) {
    size = new PVector(x, y);
    cellSize = c;
    noiseScale = n;
    wallNoiseScale = wn;
    cols = int(size.x / cellSize);
    rows = int(size.y / cellSize);

    grid = new MapaCell[cols][rows];

    // First create all cells without checking neighbors
    for (int xl = 0; xl < cols; xl++) {
      for (int yl = 0; yl < rows; yl++) {
        float terrain = map(noise(xl * noiseScale, yl * noiseScale), .1, .9, 0, 1);
        float isWall = map(noise(xl * wallNoiseScale, yl * wallNoiseScale), .1, .9, 0, 1);
        grid[xl][yl] = new MapaCell(xl, yl, cellSize, terrain, isWall);
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

    
    
    removeSmallCaves();


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
        grid[x][y].displayAlt();
      }
    }
  }



  void removeSmallCaves() {
    boolean[][] visited = new boolean[cols][rows];
    ArrayList<ArrayList<PVector>> caves = new ArrayList<>();

    // Step 1: Identify caves (cells that are off)
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        if (!grid[x][y].state && !visited[x][y]) { // Check for off cells
          ArrayList<PVector> cave = new ArrayList<>();
          floodFill(x, y, visited, cave);
          caves.add(cave);
        }
      }
    }

    // Step 2: Find the largest cave
    ArrayList<PVector> largestCave = null;
    for (ArrayList<PVector> cave : caves) {
      if (largestCave == null || cave.size() > largestCave.size()) {
        largestCave = cave;
      }
    }

    // Step 3: Remove smaller caves
    for (ArrayList<PVector> cave : caves) {
      if (cave != largestCave) {
        for (PVector cell : cave) {
          grid[(int)cell.x][(int)cell.y].state = true; // Turn on the cells to remove the cave
        }
      }
    }
  }

  void floodFill(int x, int y, boolean[][] visited, ArrayList<PVector> cave) {
    if (x < 0 || x >= cols || y < 0 || y >= rows || visited[x][y] || grid[x][y].state) { // Check for on cells
      return;
    }

    visited[x][y] = true;
    cave.add(new PVector(x, y));

    // Check all 4 directions
    floodFill(x + 1, y, visited, cave);
    floodFill(x - 1, y, visited, cave);
    floodFill(x, y + 1, visited, cave);
    floodFill(x, y - 1, visited, cave);
  }
}
