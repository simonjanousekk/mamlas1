class Player {

  final float max_speed = 3;
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

  Player(float x, float y, int d) {
    pos = new PVector(x, y);
    img = loadImage("rover2.png");
    imgAspectRatio = (float) img.width / img.height;
    diameter = d;
    imgW = diameter;
    imgH = diameter / imgAspectRatio;
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
    fill(255, 100);
    //circle(0, 0, diameter);
    //translate(-imgW/2, -imgH/2);
    //image(img, 0, 0, imgW, imgH);

    fill(0, 255, 255);
    beginShape();
    vertex(-diameter/4, diameter/4);
    vertex(diameter/4, diameter/4);
    vertex(0, -diameter/2);
    endShape(CLOSE);

    pop();
  }
  
  void handleInput() {
    if (moveForward) {
      pos.add(cos(angle+PI/4)*max_speed, sin(angle+PI/4)*max_speed);
    }
    if (moveBackward) {
      pos.sub(cos(angle+PI/4)*max_speed, sin(angle+PI/4)*max_speed);
    }
    if (turnLeft) {
      angle -= rotationAcceleration;
    }
    if (turnRight) {
      angle += rotationAcceleration;
    }
      
  }

  void acchandleInput() {
    PVector accelerationVector = new PVector(0, 0);
    if (moveForward) {
      accelerationVector.x += cos(angle + PI / 4) * acceleration;
      accelerationVector.y += sin(angle + PI / 4) * acceleration;
    }
    if (moveBackward) {
      accelerationVector.x -= cos(angle + PI / 4) * acceleration;
      accelerationVector.y -= sin(angle + PI / 4) * acceleration;
    }
    velocity.add(accelerationVector);
    if (!moveForward && !moveBackward) {
      velocity.mult(friction);
    }
    if (velocity.mag() > max_speed) {
      velocity.setMag(max_speed);
    if (turnLeft) {
      rotationVelocity -= rotationAcceleration;
    }
    if (turnRight) {
      rotationVelocity += rotationAcceleration;
    }
    if (!turnLeft && !turnRight) {
      rotationVelocity *= friction;
    }
    rotationVelocity = constrain(rotationVelocity, -max_rotationSpeed, max_rotationSpeed);
    angle += rotationVelocity;
    angle = (angle + TWO_PI) % TWO_PI;
    pos.add(velocity);
  }
}
