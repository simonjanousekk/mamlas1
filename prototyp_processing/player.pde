class Player {

  final float max_speed = 2;
  final float max_rotationSpeed = 0.03;
  final float acceleration = .2;
  final float rotationAcceleration = 0.001;
  final float friction = .5;
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
    translate(-imgW/2, -imgH/2);
    image(img, 0, 0, imgW, imgH);

    //stroke(50);
    //strokeWeight(2);
    //noStroke();
    //fill(0, 255, 255);
    //beginShape();
    //vertex(-diameter, diameter);
    //vertex(diameter, diameter);
    //vertex(0, -diameter * 2);
    //endShape(CLOSE);

    pop();
  }

  void handleInput() {




    if (moveForward) {
      velocity.x += cos(angle + PI / 4) * acceleration;
      velocity.y += sin(angle + PI / 4) * acceleration;
    } else if (moveBackward) {
      velocity.x -= cos(angle + PI / 4) * acceleration;
      velocity.y -= sin(angle + PI / 4) * acceleration;
    } else {
      velocity.mult(friction);
    }

    if (turnLeft) {
      rotationVelocity -= rotationAcceleration;
    } else  if (turnRight) {
      rotationVelocity += rotationAcceleration;
    } else {
      rotationVelocity *= friction;
    }

    rotationVelocity = rotationVelocity > max_rotationSpeed ? max_rotationSpeed : rotationVelocity;
    angle += rotationVelocity;

    pos.add(velocity.limit(max_speed));

    if (angle > TWO_PI) {
      angle = 0;
    } else if ( this.angle < 0) {
      angle = TWO_PI;
    }
  }
}
