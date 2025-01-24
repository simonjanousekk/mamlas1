GameState gameState;
Player player;
Sample sample;
Mapa mapa;
//Minimapa minimapa;
//MinimapaWindow minimapaWindow;
Compass compass;
Info info;
SignalDisplay signalDisplay;
HazardMonitor hazardMonitor;

Atom atom;
AtomAnalyzer atomAnl;
Storm storm;
Element[] elements = new Element[6];

ArrayList<Wall> walls = new ArrayList<Wall>();
ArrayList<WMarker> wmarkers = new ArrayList<WMarker>();
ArrayList<DCross> dcrosses = new ArrayList<DCross>();

PImage mask;
PFont mono;

int rayCount = 36;
int rayLength;

color primary = color(0, 255, 255);
color primaryLight = color(0, 150, 150);
color white = color(255);
color gray = color(150);

int u = 5;
final int s_thick = 2;
final int s_thin = 1;
int minimapaSize = 500;
int mapaSize = 500 * u;
float terrainMapScale = 0.03;
float wallNoiseScale = 0.05;
int cellSize = 5 * u;
int terrainTypeCount = 4;
int quadrantSize = 3 * u;

final float treshold = .45;

int fakeFrameRate = 59;

boolean infoDisplay = true;
String[] terrainTypes = {"SOFT", "DENS", "FIRM", "HARD"};

// could cause race condition if too low but so far fine ?
float LcdRefresh = 300;
float lastLcdRefresh = 0;

int screenSize = 360;
int screenHalf = 180;
int screenGap = 36;
PVector screen1Center, screen2Center;
int screen2Border = u * 5;
int screen1Border = u * 10;


PImage screen1Mask, screen2Mask;

int screen2CornerX, screen2CornerY;
enum s2s {
  GPS, RADAR
}

s2s screen2State = s2s.GPS;
Load load;
boolean sampleIdentification = false;
boolean gameInitialized = false;


String midiDevice = "Arduino Micro"; // needs a change on rPI, for macos its "Arduino Micro", for linux its "Micro [hw:2,0,0]"



void setup() {
  // this should disable warnings from pi4j (some of them at least) =^..^=
  System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "error");
  System.setProperty("pi4j.library.gpiod.logging.level", "ERROR");
  System.setProperty("com.pi4j.logging.level", "ERROR");

  //fullScreen();
  size(800, 480);

  noSmooth();
  randomSeed(millis());
  noiseSeed(millis());

  walls.clear();
  //player.rays.clear();
  wmarkers.clear();
  dcrosses.clear();

  screen1Center = new PVector(screenSize / 2 + (width - screenGap - screenSize * 2) / 2, screenSize / 2 + (height - screenSize) / 2);
  screen2Center = new PVector(screenSize / 2 + (width + screenGap - screenSize * 2) / 2 + screenSize, screenSize / 2 + (height - screenSize) / 2);
  screen2CornerX = int(screen2Center.x - screenSize / 2);
  screen2CornerY = int(screen2Center.y - screenSize / 2);

  if (mb == null) {
    mbInit();
  }

  load = new Load();
  mask = loadImage("mask_debug.png"); // mask_debug.png avalible for debug duh
  screen1Mask = getMask(screenSize, 0, mask);
  screen2Mask = getMask(screenSize, screen2Border, mask);
  mono = createFont("OCR-A.ttf", 18);
  rayLength = int((screenSize / 2 - screen2Border) * .66);
  textFont(mono);

  gameState = new GameState();
  mapa = new Mapa(mapaSize, mapaSize, cellSize, terrainMapScale, wallNoiseScale);
  player = new Player(randomPosOutsideWalls(), 4 * u);
  sample = new Sample(randomPosOutsideWalls());
  //minimapa = new Minimapa(minimapaSize);
  //minimapaWindow = new MinimapaWindow(this, minimapa);
  info = new Info(new PVector(10, 10));
  compass = new Compass(screenSize / 2 - screen2Border);
  signalDisplay = new SignalDisplay();


  atom = new Atom();
  elements[0] = new Element("Au", "High", false);
  elements[1] = new Element("T", "Low", true);
  elements[2] = new Element("U", "High", true);
  elements[3] = new Element("Po", "Mid", true);
  elements[4] = new Element("Fe", "Mid", false);
  elements[5] = new Element("Li", "Low", false);
  storm = new Storm();

  try {
    hazardMonitor = new HazardMonitor();
  }
  catch(Throwable t) {
    println("LCD could not be created");
    hazardMonitor = null;
  }

  for (int i = 0; i < rayCount; i++) {
    player.rays.add(new Ray(player.pos, i * (TWO_PI / rayCount)));
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
  
  gameInitialized = true;
}

void draw() {

  gameState.update();

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
    player.collide(wall);
  }

  sample.update();

  for (Ray ray : player.rays) {
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
    if (sampleIdentification) { // --- SAMPLE IDENTIFICATION ---
      push();
      background(0);
      translate(screen2Center.x, screen2Center.y);
      atom.display();
      pop();

      push();
      translate(screen1Center.x, screen1Center.y);
      atomAnl.display();
      pop();
    } else {
      push();
      translate(screen2Center.x, screen2Center.y);
      rotate( -player.angle);
      translate( -player.pos.x, -player.pos.y);
      background(0);
      if (screen2State == s2s.RADAR) { // --- RADAR ---
        for (WMarker wm : relevantWMarkers) {
          wm.display();
        }
      } else if (screen2State == s2s.GPS) { // --- GPS ---
        mapa.display();
        for (DCross dc : dcrosses) {
          dc.display();
        }
        for (Wall wall : relevantWalls) {
          wall.display();
        }
      }
      sample.display();
      player.display();
      pop();
    }
  }

  player.update();
  player.handleInput();

  if (screen2State == s2s.GPS) {
    storm.display();
  }

  // maybe to verify if its ok
  if (!sampleIdentification) {
    signalDisplay.update();
    signalDisplay.display();
  }

  if (!sampleIdentification) { // draw only the things inside the mask
    compass.displayInside();
  }

  if (!signalDisplay.sinePlayer.isRight && !sampleIdentification) {
    radio(signalDisplay.interference);
  }

  if (load.loading) {
    load.display();
    load.update();
  }

  // draw circular masks
  image(screen1Mask, screen1Center.x - screenSize / 2, screen1Center.y - screenSize / 2);
  image(screen2Mask, screen2Center.x - screenSize / 2, screen2Center.y - screenSize / 2);

  // hide empty parts of the screen, might be deleted for production
  push();
  fill(0);
  noStroke();
  float xgap = (width - screenGap - screenSize * 2) / 2;
  float ygap = (height - screenSize) / 2;
  rect(0, 0, width, ygap);
  rect(width, height, -width, -ygap);
  rect(0, 0, xgap, height);
  rect(width, height, -xgap, -height);
  rect(screenSize + xgap, 0, screenGap, height);
  pop();

  if (!sampleIdentification) { // draw the ouside compass
    compass.displayOutside();
  }

  if (hazardMonitor != null && millis() - lastLcdRefresh > LcdRefresh) {
    lastLcdRefresh = millis();
    if (hazardMonitor.interference) {
      hazardMonitor.noiseAmount = mouseX;
      hazardMonitor.displayHazard();
    } else if (!hazardMonitor.forecast.equals(hazardMonitor.last_forecast) || hazardMonitor.last_interference != hazardMonitor.interference) {
      // synchronising thread with real state
      println("last forecast :", hazardMonitor.last_forecast);
      println(" Current forecast :", hazardMonitor.forecast);
      hazardMonitor.displayHazard();
    }
  }



  if (infoDisplay) {
    info.display();
  }

  displayFPS();
}
