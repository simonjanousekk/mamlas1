
Player player;
Sample sample;
Mapa mapa;
Minimapa minimapa;
MinimapaWindow minimapaWindow;
Compass compass;
Info info;

int rayCount = 36;
int rayLength;

color primary = color(0, 255, 255);

int u = 5;
final int s_thick = 2;
final int s_thin = 1;
int minimapaSize = 500;
int mapaSize = 500 * u;
float terrainMapScale = 0.03;
float wallNoiseScale = 0.05;
int cellSize = 4 * u;
int terrainTypeCount = 4;
int quadrantSize = 3 * u;
int border = 5 * u;

final float treshold = .45;

boolean radio = false;
float noiseScale = 0.01;
float noiseCompute = 0;
float noise_t = 0;
int noise_s = 10;

int fakeFrameRate = 59;

float battery = 100;
int sampleCount = 1;
boolean kryplmod = false;
boolean godmod = false;
boolean infoDisplay = false;
String[] terrainTypes = {"SOFT", "DENS", "FIRM", "HARD"};

PImage mask;
PFont mono;

ArrayList<Wall> walls = new ArrayList<Wall>();
ArrayList<Ray> rays = new ArrayList<Ray>();
ArrayList<WMarker> wmarkers = new ArrayList<WMarker>();
ArrayList<DCross> dcrosses = new ArrayList<DCross>();



void setup() {

  size(375, 375);

  noSmooth();

  mbInit();
  u = int(height / 100);

  mask = loadImage("mask.png");
  mono = createFont("OCR-A.ttf", 16);
  rayLength = int ((height / 2 - border) * .66);
  textFont(mono);

  walls.clear();
  rays.clear();
  wmarkers.clear();
  dcrosses.clear();

  randomSeed(millis());
  noiseSeed(millis());

  mapa = new Mapa(mapaSize, mapaSize, cellSize, terrainMapScale, wallNoiseScale);
  player = new Player(randomPosOutsideWalls(), 3 * u);
  sample = new Sample(randomPosOutsideWalls());
  minimapa = new Minimapa(minimapaSize);
  minimapaWindow = new MinimapaWindow(this, minimapa);
  info = new Info(new PVector(10, 10));
  compass = new Compass(height / 2 - border, border);



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

  //push();
  //colorMode(HSB, 255);
  //primary = color(map(frameCount%120, 0, 120, 0, 255), 255, 255);
  //pop();

  //fakeFrameRate = int(map(mouseX, 0, width, 1, 60));

  // get relevant walls
  float relevantDistance = rayLength * 1.3;
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
    rotate( -player.angle);
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



  displayMask(border);

  compass.display();

  if (infoDisplay) {
    info.display();
    displayFPS();
  }
  if (radio) { radio();}
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
  if (key == 'x') {
    radio = !radio;
  }
  if (key == 'l') {
    player.terrainSetting = (player.terrainSetting + 1) % terrainTypeCount;
  }
  if (key == 'k') {
    player.terrainSetting = (player.terrainSetting - 1 + terrainTypeCount) % terrainTypeCount;
  }
  if (key == 'i') {
    infoDisplay = !infoDisplay;
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

void radio() {
  noise_t = map(mouseX, 0, width, 0.1, 0.7);
  if (frameCount % 5 == 0) {
    noise_t = random(0, 0.7);
  }

  PImage frame = get();

  loadPixels();
  frame.loadPixels();
  for (int x = 1; x < width-2; x ++) {
    for (int y = 1; y < height-2; y++) {

      int noise = int(random(100));
      if (noise % 4 == 0) {
        pixels[x+y * width] = color(random(0, 255));
        continue;
      }

      float nx = noiseScale * x;
      float ny = noiseScale * y;
      float nt = noiseScale * frameCount * 10;

      float noiseCompute = noise(nx, nt, ny);

      if (noiseCompute < noise_t) {
        int index_shift = int(sin(frameCount));
        int index = (x - index_shift) + ((y - index_shift) * width);
        pixels[x+y * width] = frame.pixels[x-1 + index];
      }
    }
  }

  updatePixels();
  push();
  textSize(30);
  fill(255, 0, 0, map(sin(frameCount * 0.1), -1, 1, 0, 255));
  textAlign(CENTER, CENTER);
  text("LOW SIGNAL", width/2 , height/2);
  pop();
}
