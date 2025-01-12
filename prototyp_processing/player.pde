class Player {

  final float max_speed = 3;
  float currentSpeed;
  final float max_rotationSpeed = .02;
  final float acceleration = .1;
  final float rotationAcceleration = 0.001;
  final float friction = .9;
  final int diameter;
  PImage img;

  PVector pos;
  float angle = PI/4+PI;
  int samplesCollected = 0;

  PVector velocity = new PVector(0, 0);
  float rotationVelocity = 0;
  float imgAspectRatio;
  float imgW, imgH;
  
  int onTerrain;
  int terrainSetting = 0;

  Player(float x, float y, int d) {
    pos = new PVector(x, y);
    img = loadImage("rover2.png");
    imgAspectRatio = (float) img.width / img.height;
    diameter = d;
    imgW = diameter;
    imgH = diameter / imgAspectRatio;
    this.update();
    terrainSetting = onTerrain;
  }
  Player(PVector p, int d) {
    this(p.x, p.y, d);
  }

  void collide(Wall wall) {
    wall.collided = isCircleLineColliding(pos, diameter/2, wall.pos1, wall.pos2);
    if (wall.collided) {
      resolveCollision(player.pos, player.diameter/2, wall.pos1, wall.pos2);
      //println("debil naboural");
    }
  }

  void resolveCollision(PVector circlePos, float radius, PVector lineStart, PVector lineEnd) {
    PVector lineDir = PVector.sub(lineEnd, lineStart);
    PVector toCircle = PVector.sub(circlePos, lineStart);

    float lineLengthSq = lineDir.magSq();
    float t = PVector.dot(toCircle, lineDir) / lineLengthSq;
    t = constrain(t, 0, 1); // Clamp to segment

    // Closest point on the line segment
    PVector closestPoint = PVector.add(lineStart, PVector.mult(lineDir, t));

    // Distance from circle to the closest point
    float distance = PVector.dist(circlePos, closestPoint);

    if (distance < radius) {
      // Calculate overlap and resolve
      PVector collisionNormal = PVector.sub(circlePos, closestPoint).normalize();
      float overlap = radius - distance;
      circlePos.add(PVector.mult(collisionNormal, overlap));
    }
  }

  void display() {
    push();

    translate(width/2, height/2);
    //fill(255, 50);
    //noStroke();
    //circle(0, 0, diameter);
    //stroke(0);
    //strokeWeight(2);
    //circle(0, 0, diameter);
    //translate(-imgW/2, -imgH/2);
    translate(-diameter/2, -diameter/2);
    fill(0, 255, 0);
    
    beginShape();
    vertex(diameter*.5, 0);
    vertex(diameter*.1, diameter*.8);
    vertex(diameter*.5, diameter*.6);
    vertex(diameter*.9, diameter*.8);
    
    
    
    
    ////vertex(-diameter/4, diameter/4);
    //vertex(diameter/4, diameter/4);
    //vertex(0, -diameter/2);
    endShape(CLOSE);

    pop();
  }
  
  void update() {
    int xi = int(pos.x/cellSize);
    int yi = int(pos.y/cellSize);
    onTerrain = mapa.grid[xi][yi].terrain;
  }
  
  

  void handleInput() {
    
    float terrainMult = map(abs(onTerrain - terrainSetting), 0, terrainTypeCount, 1, .1);
    currentSpeed = max_speed * terrainMult;
    
    
    if (moveForward) {
      pos.add(cos(angle+PI/4)*currentSpeed, sin(angle+PI/4)*currentSpeed);
    }
    if (moveBackward) {
      pos.sub(cos(angle+PI/4)*currentSpeed, sin(angle+PI/4)*currentSpeed);
    }
    if (turnLeft) {
      angle -= max_rotationSpeed;
    }
    if (turnRight) {
      angle += max_rotationSpeed;
    }

    angle = (angle + TWO_PI) % TWO_PI;
  }
}
