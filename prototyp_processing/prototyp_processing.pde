
Player player;
Mapa mapa;
Minimapa minimapa;
MinimapaWindow minimapaWindow;

PImage mask;


ArrayList<Wall> walls = new ArrayList<Wall>();
ArrayList<Ray> rays = new ArrayList<Ray>();
ArrayList<Sample> samples = new ArrayList<Sample>();


int rayCount = 36;
int sampleCount = 5;

int minimapaSize = 500;
int mapaSize = 6000;
float mapScale = 0.05;
int cellSize = 50;



void setup() {
  size(600, 600);

  noSmooth();

  mask = loadImage("mask.png");

  walls.clear();
  rays.clear();
  samples.clear();

  randomSeed(millis());
  noiseSeed(millis());

  mapa = new Mapa(mapaSize, mapaSize, cellSize, mapScale);
  player = new Player(randomPosOutsideWalls(), 50);
  minimapa = new Minimapa(minimapaSize);
  minimapaWindow = new MinimapaWindow(this, minimapa);


  for (int i = 0; i < rayCount; i++) {
    rays.add(new Ray(player.pos, radians(i*(360/rayCount))));
  }
  for (int i = 0; i < sampleCount; i++) {
    samples.add(new Sample(randomPosOutsideWalls()));
  }

  surface.setVisible(false);
  surface.setVisible(true);
}

void draw() {
  background(50);


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



  //
  push();
  translate(width / 2, height / 2);
  rotate(-player.angle - (PI / 4) * 3);
  translate(-player.pos.x, -player.pos.y);



  mapa.display();

  for (Wall wall : relevantWalls) {
    player.collide(wall);
    wall.display();
  }

  for (Ray ray : rays) {
    ray.update(player.pos, player.angle);
    ray.findShortestIntersection(relevantWalls);
    ray.display();
  }

  for (Sample sample : samples) {
    sample.display();
    sample.update();
  }

  pop();


  player.handleInput();
  player.display();


  displayMask(10);
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
    mapa.removeSmallCaves();
    minimapa.update();
  }
}

// Handle key releases
void keyReleased() {
  if (key == 'w' || key == 'W') moveForward = false;
  if (key == 's' || key == 'S') moveBackward = false;
  if (key == 'a' || key == 'A') turnLeft = false;
  if (key == 'd' || key == 'D') turnRight = false;
}
