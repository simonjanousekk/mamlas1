
Player player;
Mapa mapa;
Minimapa minimapa;

ArrayList<Wall> walls = new ArrayList<Wall>();
ArrayList<Ray> rays = new ArrayList<Ray>();
ArrayList<Sample> samples = new ArrayList<Sample>();


int rayCount = 36;
int sampleCount = 5;
int minimapaSize = 200;



void setup() {
  size(600, 600);
  noSmooth();

  mapa = new Mapa(6000, 6000, 25);
  player = new Player(randomPosOutsideWalls(), 50);
  minimapa = new Minimapa(width-minimapaSize, 0, minimapaSize);

  for (int i = 0; i < rayCount; i++) {
    rays.add(new Ray(player.pos, radians(i*(360/rayCount))));
  }
  for (int i = 0; i < sampleCount; i++) {
    samples.add(new Sample(randomPosOutsideWalls()));
  }
  
}

void draw() {
  background(50);

  

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


  minimapa.display();
  player.handleInput();
  player.display();

  fill(255);
  textSize(16);
  textAlign(RIGHT, BOTTOM);
  text(int(frameRate), width-5, height-5);
}







boolean moveForward, moveBackward, turnLeft, turnRight;

void keyPressed() {
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

boolean isCircleLineColliding(PVector circle, float radius, PVector lineStart, PVector lineEnd) {
  float cx = circle.x;
  float cy = circle.y;
  float r = radius;
  float x1 = lineStart.x;
  float y1 = lineStart.y;
  float x2 = lineEnd.x;
  float y2 = lineEnd.y;

  float lineLengthSq = sq(x2 - x1) + sq(y2 - y1);
  float t = ((cx - x1) * (x2 - x1) + (cy - y1) * (y2 - y1)) / lineLengthSq;
  float tClamped = constrain(t, 0, 1);
  float closestX = x1 + tClamped * (x2 - x1);
  float closestY = y1 + tClamped * (y2 - y1);
  float distanceSq = sq(cx - closestX) + sq(cy - closestY);
  return distanceSq <= sq(r);
}

PVector lineLineIntersection(PVector line1Start, PVector line1End, PVector line2Start, PVector line2End) {
  float x1 = line1Start.x;
  float y1 = line1Start.y;
  float x2 = line1End.x;
  float y2 = line1End.y;
  float x3 = line2Start.x;
  float y3 = line2Start.y;
  float x4 = line2End.x;
  float y4 = line2End.y;

  float denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
  if (denominator == 0) {
    return null;
  }
  float t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator;
  float u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denominator;

  if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
    float intersectionX = x1 + t * (x2 - x1);
    float intersectionY = y1 + t * (y2 - y1);
    return new PVector(intersectionX, intersectionY);
  }

  return null;
}

PVector randomPosOutsideWalls() {
  PVector pos = new PVector(random(mapa.size.x), random(mapa.size.y));
  while (
    mapa.grid[floor(pos.x / mapa.cellSize)][floor(pos.y / mapa.cellSize)].state
    ) {
    pos = new PVector(random(mapa.size.x), random(mapa.size.y));
  }
  return pos;
}
