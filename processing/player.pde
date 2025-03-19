class Player {

  float max_speed = u *.2;
  //float acceleration;
  float speedMultiplier;
  float desiredSpeed;

  float max_rotationAcceleration = TWO_PI/360;
  float rotationAcceleration;
  float friction = 0.2;

  boolean reverse = false;

  float speed, rotationSpeed;

  int turn = 0;
  boolean moving = false;

  PVector pos;
  float angle = random(TWO_PI);
  int samplesCollected = 0;
  final int diameter;

  PVector velocity = new PVector(0, 0);
  float rotationVelocity = 0;

  int onTerrain;
  int lastTerrain = -1;
  int terrainSetting = 0;
  int terrainDifference = 0;

  LedDriver ledDriverTerrain = new LedDriver(new int[]{11, 13});

  boolean scanning = false;
  ArrayList<Ray> rays = new ArrayList<Ray>();
  float distanceTraveled = 0;


  Player(float x, float y, int d) {
    pos = new PVector(x, y);
    diameter = d;
    this.update();
    terrainSetting = onTerrain;
  }

  Player(PVector p, int d) {
    this(p.x, p.y, d);
  }

  void collide(Wall wall) {
    wall.collided = isCircleLineColliding(pos, diameter / 2, wall.pos1, wall.pos2);
    if (wall.collided) {
      resolveCollision(player.pos, player.diameter / 2, wall.pos1, wall.pos2);
      //println("debil naboural");
    }
  }

  void scan() {
    if (screen2State == s2s.RADAR && !scanning) {
      scanning = true;
      for (Ray r : rays) {
        r.findWallAnimation();
      }
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

    translate(pos.x, pos.y);
    rotate(angle);
    //fill(255, 50);
    //noStroke();
    //circle(0, 0, diameter);
    //stroke(0);
    //strokeWeight(2);
    //circle(0, 0, diameter);
    //translate(-imgW/2, -imgH/2);
    translate( -diameter / 2, -diameter / 2);
    fill(primary);
    noStroke();
    beginShape();
    vertex(diameter * .5, 0);
    vertex(diameter * .1, diameter * .8);
    vertex(diameter * .5, diameter * .6);
    vertex(diameter * .9, diameter * .8);




    ////vertex(-diameter/4, diameter/4);
    //vertex(diameter/4, diameter/4);
    //vertex(0, -diameter/2);
    endShape(CLOSE);

    pop();
  }

  void update() {
    int xi = int(pos.x / cellSize);
    int yi = int(pos.y / cellSize);

    lastTerrain = onTerrain;
    onTerrain = mapa.grid[xi][yi].terrain;




    terrainDifference = abs(onTerrain - terrainSetting);
    if (terrainDifference == 0) {
      ledDriverTerrain.turnOff();
    } else {
      ledDriverTerrain.turnOn();
    }

    speedMultiplier = map(terrainDifference, 0, 3, 1, .5);
    speed = desiredSpeed*speedMultiplier;
    if (reverse) speed *= -1;


    // terrain sounds
    //if (lastTerrain != onTerrain) {
      if (abs(speed) > 0) {
        float vol = map(abs(speed), 0, max_speed, 0, 1);
        println(onTerrain, vol);
        soundManager.tracks.get("terrain" + onTerrain).vol(vol);
      }
      //soundManager.allTerrainOff();
      //soundManager.tracks.get("terrain" + onTerrain).on();
    //}


    if (scanning) { // check if all wmarkers are resolved == scanning ended
      boolean b = true;
      for (WMarker wm : wmarkers) {
        if (!wm.finished) {
          b = false;
        }
      }
      if (b) {
        scanning = false;
      }
    }
  }

  void setDesiredVelocity(int v) {
    desiredSpeed = map(v, 2, 125, 0, max_speed);
    desiredSpeed = constrain(desiredSpeed, 0, max_speed);
  }

  void setSuspension(int v) {
    terrainSetting = int(map(v, 0, 127, 0, 4));
  }

  void handleInput() {
    //float terrainMult = map(abs(onTerrain - terrainSetting), 0, terrainTypeCount, 1, .05);
    //turn = floor(turn*1.4);

    PVector prevPos = pos.copy();

    // KEYBOARD CONTROLLS
    float tmpa = angle - PI / 2;
    if (turnLeft) angle -= TWO_PI/360;
    if (turnRight) angle += TWO_PI/360;
    if (moveForward) pos.add(cos(tmpa) * max_speed, sin(tmpa) * max_speed);
    if (moveBackward) pos.sub(cos(tmpa) * max_speed, sin(tmpa) * max_speed);

    if (turnLeft ||
      turnRight ||
      moveForward ||
      moveBackward ||
      speed > .01 ||
      speed < -.01 ||
      turn > 0) {
      moving = true;
    } else {
      moving = false;
    }




    pos.add(cos(tmpa) * speed, sin(tmpa) * speed);


    if (turn != 0) {
      rotationAcceleration += turn * TWO_PI/720;
      rotationAcceleration = constrain(rotationAcceleration, -max_rotationAcceleration, max_rotationAcceleration);
    } else {
      rotationAcceleration *= friction;
      rotationSpeed *= friction;
    }

    rotationSpeed += rotationAcceleration;
    angle += rotationSpeed;

    angle = (angle + TWO_PI) % TWO_PI;
    turn = 0;

    distanceTraveled += prevPos.dist(pos)*distUnitScale;
  }
}
