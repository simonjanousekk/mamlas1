
Player player;
Sample sample;
Mapa mapa;
Minimapa minimapa;
MinimapaWindow minimapaWindow;
Compass compass;
Info info;

int rayCount = 36;
final int rayLength = 300;


int minimapaSize = 500;
int mapaSize = 5000;
float terrainMapScale = 0.03;
float wallNoiseScale = 0.05;
int cellSize = 30;
int terrainTypeCount = 4;
int quadrantSize = 25;

final float treshold = .45;


int fakeFrameRate = 59;

float battery = 100;
int sampleCount = 1;
boolean kryplmod = false;
boolean godmod = false;
String[] terrainTypes = {"SOFT", "DENS", "FIRM", "HARD"};

PImage mask;
PFont mono;

ArrayList<Wall> walls = new ArrayList<Wall>();
ArrayList<Ray> rays = new ArrayList<Ray>();
ArrayList<WMarker> wmarkers = new ArrayList<WMarker>();
ArrayList<DCross> dcrosses = new ArrayList<DCross>();



void setup() {
  size(1000, 1000);

  noSmooth();

  mask = loadImage("mask.png");
  mono = createFont("OCR-A.ttf", 64);
  textFont(mono);

  walls.clear();
  rays.clear();
  wmarkers.clear();
  dcrosses.clear();

  randomSeed(millis());
  noiseSeed(millis());

  mapa = new Mapa(mapaSize, mapaSize, cellSize, terrainMapScale, wallNoiseScale);
  player = new Player(randomPosOutsideWalls(), 20);
  sample = new Sample(randomPosOutsideWalls());
  minimapa = new Minimapa(minimapaSize);
  minimapaWindow = new MinimapaWindow(this, minimapa);
  info = new Info(new PVector(10, 10));
  compass = new Compass(width / 2 - 75, 75);



  for (int i = 0; i < rayCount; i++) {
    rays.add(new Ray(player.pos, i * (TWO_PI / rayCount)));
  }

  for (int x = 0; x < mapa.cols; x += quadrantSize) {
    for (int y = 0; y < mapa.rows; y += quadrantSize) {
      if (!mapa.grid[x][y].state && mapa.grid[x][y].caseValue == 0) {
        String s = terrainTypes[mapa.grid[x][y].terrain];
        //println(s, mapa.grid[x][y].state, mapa.grid[x][y].caseValue, x, y);
        dcrosses.add(new DCross(x * cellSize, y * cellSize, cellSize, s));
      }
    }
  }

  surface.setVisible(false);
  surface.setVisible(true);
}

void draw() {

  //fakeFrameRate = int(map(mouseX, 0, width, 1, 60));

  // get relevant walls
  float relevantDistance = rayLength * 1.1;
  ArrayList<Wall> relevantWalls = new ArrayList<Wall>(walls);
  for (int i = relevantWalls.size() - 1; i >= 0; i--) {
    Wall wall = relevantWalls.get(i);
    if (isDistanceMore(wall.pos1, player.pos, relevantDistance) || isDistanceMore(wall.pos2, player.pos, relevantDistance)) {
      relevantWalls.remove(i);
    }
  }
  relevantWallsC = relevantWalls.size();

  //get relewant wmarkers
  ArrayList<WMarker> relevantWMarkers = new ArrayList<WMarker>(wmarkers);
  for (int i = relevantWMarkers.size() - 1; i >= 0; i--) {
    WMarker wm = relevantWMarkers.get(i);
    if (isDistanceMore(wm.pos, player.pos, relevantDistance)) {
      relevantWMarkers.remove(i);
    }
  }
  relevantWMarkersC = relevantWMarkers.size();


  for (Wall wall : relevantWalls) {
    if (!godmod) player.collide(wall);
  }

  sample.update();

  for (Ray ray : rays) {
    ray.update(player.pos, player.angle);
    ray.findShortestIntersection(relevantWalls);
  }
  for (int i = wmarkers.size() - 1; i >= 0; i--) {
    WMarker wm = wmarkers.get(i);
    if (wm.destroy) {
      wmarkers.remove(i);
    }
    wm.update();
  }

  // realest drawing

  if (frameCount % (60 / fakeFrameRate) == 0) {
    push();
    translate(width / 2, height / 2);
    rotate(-player.angle);
    translate( -player.pos.x, -player.pos.y);
    background(0);
    if (kryplmod) {
      for (WMarker wm : relevantWMarkers) {
        wm.display();
      }
    } else {
      mapa.display();

      for (DCross dc : dcrosses) {
        dc.display();
      }
      for (Wall wall : relevantWalls) {
        wall.display();
      }
      //for (Ray ray : rays) {
      //  ray.display();
      //}
    }
    sample.display();
    pop();
    player.display();
  }

  player.update();
  player.handleInput();


  displayMask(75);

  compass.display();

  info.display();
  displayFPS();
}


boolean moveForward, moveBackward, turnLeft, turnRight;

void keyPressed() {
  if (key == 'r') { // restart
    if (minimapaWindow != null) {
      minimapaWindow.close();
    }
    setup();
  }
  if (key == ' ') {
    for (Ray r : rays) {
      r.findWallAnimation();
    }
  }
  if (key == 'm') { //radar
    kryplmod = !kryplmod;
    if (kryplmod) {
      wmarkers.clear();
      for (Ray r : rays) {
        r.findWallAnimation();
      }
    }
  }
  if (key == 'g') {
    godmod = !godmod;
  }

  if (key == 'i') {
    player.terrainSetting = (player.terrainSetting + 1) % terrainTypeCount;
  }
  if (key == 'k') {
    player.terrainSetting = (player.terrainSetting - 1 + terrainTypeCount) % terrainTypeCount;
  }


  if (key == 'w' || key == 'W') moveForward = true;
  if (key == 's' || key == 'S') moveBackward = true;
  if (key == 'a' || key == 'A') turnLeft = true;
  if (key == 'd' || key == 'D') turnRight = true;
}

// Handle key releases
void keyReleased() {
  if (key == 'w' || key == 'W') moveForward = false;
  if (key == 's' || key == 'S') moveBackward = false;
  if (key == 'a' || key == 'A') turnLeft = false;
  if (key == 'd' || key == 'D') turnRight = false;
}
