
Player player;
Mapa mapa;
Minimapa minimapa;
MinimapaWindow minimapaWindow;
Radar radar;
Compass compass;

Info info;

PImage mask;

ArrayList<Wall> walls = new ArrayList<Wall>();
ArrayList<Ray> rays = new ArrayList<Ray>();
ArrayList<Sample> samples = new ArrayList<Sample>();
ArrayList<TMarker> tmarkers = new ArrayList<TMarker>();


int rayCount = 50;
int sampleCount = 1;

int minimapaSize = 500;
int mapaSize = 5000;
float terrainMapScale = 0.02;
float wallNoiseScale = 0.05;
int cellSize = 50;

int fakeFrameRate = 12;

int sonarRange = 100;

float battery = 100;
boolean radarDisplay = false;



void setup() {
  size(600, 600);

  //frameRate(12);
  //noSmooth();

  mask = loadImage("mask.png");

  walls.clear();
  rays.clear();
  samples.clear();
  tmarkers.clear();

  randomSeed(millis());
  noiseSeed(millis());

  mapa = new Mapa(mapaSize, mapaSize, cellSize, terrainMapScale, wallNoiseScale);
  player = new Player(randomPosOutsideWalls(), 40);
  minimapa = new Minimapa(minimapaSize);
  minimapaWindow = new MinimapaWindow(this, minimapa);
  info = new Info(new PVector(10, 10));


  for (int i = 0; i < rayCount; i++) {
    rays.add(new Ray(player.pos, i*(TWO_PI/rayCount)));
  }
  for (int i = 0; i < sampleCount; i++) {
    samples.add(new Sample(randomPosOutsideWalls()));
  }

  radar = new Radar(width/2-50);
  compass = new Compass(width/2-80);


  surface.setVisible(false);
  surface.setVisible(true);
}

void draw() {

  fakeFrameRate = int(map(mouseX, 0, width, 1, 60));


  // get relevant walls
  int wallDistance = rays.get(0).rayLength * 2;
  ArrayList<Wall> relevantWalls = new ArrayList<Wall>(walls);
  for (int i = relevantWalls.size()-1; i >= 0; i--) {
    Wall wall = relevantWalls.get(i);
    if (!((wall.pos1.x - player.pos.x) * (wall.pos1.x - player.pos.x) +
      (wall.pos1.y - player.pos.y) * (wall.pos1.y - player.pos.y) <
      wallDistance * wallDistance ||
      (wall.pos2.x - player.pos.x) * (wall.pos2.x - player.pos.x) +
      (wall.pos2.y - player.pos.y) * (wall.pos2.y - player.pos.y) <
      wallDistance * wallDistance)) {
      relevantWalls.remove(i);
    }
  }

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

  //
  if (frameCount % (60/fakeFrameRate) == 0) {
    if (radarDisplay) {
      background(50);

      radar.display();
      compass.display();
      player.display();
    } else {
      background(50);

      push();
      translate(width / 2, height / 2);
      rotate(-player.angle - (PI / 4) * 3);
      translate(-player.pos.x, -player.pos.y);



      mapa.display();

      for (Wall wall : relevantWalls) {
        wall.display();
      }
      for (TMarker tm : tmarkers) {
        tm.display();
      }

      for (Ray ray : rays) {
        ray.display();
      }

      for (Sample sample : samples) {
        sample.display();
      }

      pop();
       
      radar.display();
      compass.display();
      player.display();
    }
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
    println("check terrain");
    for (int i = 0; i < 5; i++) {
      tmarkers.add(new TMarker(random(player.pos.x-sonarRange, player.pos.x+sonarRange), random(player.pos.y-sonarRange, player.pos.y+sonarRange)));
    }
  }
  if (key == 'l') { //radar
    radarDisplay = !radarDisplay;
  }
}

// Handle key releases
void keyReleased() {
  if (key == 'w' || key == 'W') moveForward = false;
  if (key == 's' || key == 'S') moveBackward = false;
  if (key == 'a' || key == 'A') turnLeft = false;
  if (key == 'd' || key == 'D') turnRight = false;
}
