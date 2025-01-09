
Player player;
Mapa mapa;
Minimapa minimapa;
MinimapaWindow minimapaWindow;
Info info;

PImage mask;
PImage teren;

ArrayList<Wall> walls = new ArrayList<Wall>();
ArrayList<Ray> rays = new ArrayList<Ray>();
ArrayList<Sample> samples = new ArrayList<Sample>();
ArrayList<WMarker> wmarkers = new ArrayList<WMarker>();

int rayCount = 36;
final int rayLength = 400;

int sampleCount = 1;

int minimapaSize = 500;
int mapaSize = 5000;
float terrainMapScale = 0.03;
float wallNoiseScale = 0.05;
int cellSize = 30;

int fakeFrameRate = 30;

float battery = 100;
boolean kryplmod = false;



void setup() {
  size(1000, 1000);

  noSmooth();

  mask = loadImage("mask.png");

  walls.clear();
  rays.clear();
  samples.clear();
  wmarkers.clear();

  randomSeed(millis());
  noiseSeed(millis());

  mapa = new Mapa(mapaSize, mapaSize, cellSize, terrainMapScale, wallNoiseScale);
  player = new Player(randomPosOutsideWalls(), 20);
  minimapa = new Minimapa(minimapaSize);
  minimapaWindow = new MinimapaWindow(this, minimapa);
  info = new Info(new PVector(10, 10));


  for (int i = 0; i < rayCount; i++) {
    rays.add(new Ray(player.pos, i*(TWO_PI/rayCount)));
  }
  for (int i = 0; i < sampleCount; i++) {
    samples.add(new Sample(randomPosOutsideWalls()));
  }

  surface.setVisible(false);
  surface.setVisible(true);

  teren = loadImage("teren3.jpg");
}

void draw() {

  fakeFrameRate = int(map(mouseX, 0, width, 1, 60));

  // get relevant walls
  float relevantDistance = rayLength*1.2;
  ArrayList<Wall> relevantWalls = new ArrayList<Wall>(walls);
  for (int i = relevantWalls.size()-1; i >= 0; i--) {
    Wall wall = relevantWalls.get(i);
    if (isDistanceMore(wall.pos1, player.pos, relevantDistance) || isDistanceMore(wall.pos2, player.pos, relevantDistance)) {
      relevantWalls.remove(i);
    }
  }
  relevantWallsC = relevantWalls.size();

  //get relewant wmarkers
  ArrayList<WMarker> relevantWMarkers = new ArrayList<WMarker>(wmarkers);
  for (int i = relevantWMarkers.size()-1; i >= 0; i--) {
    WMarker wm = relevantWMarkers.get(i);
    if (isDistanceMore(wm.pos, player.pos, relevantDistance)) {
      relevantWMarkers.remove(i);
    }
  }
  relevantWMarkersC = relevantWMarkers.size();


  for (Wall wall : relevantWalls) {
    player.collide(wall);
  }
  for (Sample sample : samples) {
    sample.update();
  }
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

  if (frameCount % (60/fakeFrameRate) == 0) {
    push();
    translate(width / 2, height / 2);
    rotate(-player.angle - (PI / 4) * 3);
    translate(-player.pos.x, -player.pos.y);
    if (kryplmod) {
      background(0);

      for (Sample sample : samples) {
        sample.display();
      }
      for (WMarker wm : relevantWMarkers) {
        wm.display();
      }
    } else {
      background(0);
      //image(teren, 0, 0, mapa.size.x, mapa.size.y);

      mapa.display();
      for (Wall wall : relevantWalls) {
        wall.display();
      }


      //for (Ray ray : rays) {
      //  ray.display();
      //}
      for (Sample sample : samples) {
        sample.display();
      }
    }
    pop();
    player.display();
  }


  player.handleInput();



  displayMask(10);
  info.display();
  displayFPS();
}


boolean moveForward, moveBackward, turnLeft, turnRight;

void keyPressed() {
  if (key == 'w' || key == 'W') moveForward = true;
  if (key == 's' || key == 'S') moveBackward = true;
  if (key == 'a' || key == 'A') turnLeft = true;
  if (key == 'd' || key == 'D') turnRight = true;

  if (key == 'r') { // restart
    if (minimapaWindow != null) {
      minimapaWindow.close();
    }
    setup();
  }
  if (key == ' ') { // remove caves
    //println("check terrain");
    //for (int i = 0; i < 5; i++) {
    //  tmarkers.add(new TMarker(random(player.pos.x-sonarRange, player.pos.x+sonarRange), random(player.pos.y-sonarRange, player.pos.y+sonarRange)));
    //}
    for (Ray r : rays) {
      r.findWallAnimation();
    }
  }
  if (key == 'l') { //radar
    kryplmod = !kryplmod;
    for (Ray r : rays) {
      r.findWallAnimation();
    }
  }
}

// Handle key releases
void keyReleased() {
  if (key == 'w' || key == 'W') moveForward = false;
  if (key == 's' || key == 'S') moveBackward = false;
  if (key == 'a' || key == 'A') turnLeft = false;
  if (key == 'd' || key == 'D') turnRight = false;
}
