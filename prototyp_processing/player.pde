class Player {

  final float speed = 2;
  final float rotationSpeed = 0.02;
  final int diameter;
  PImage img;

  PVector pos;
  float angle = PI/4+PI;
  int samplesCollected = 0;
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
      println("gameover");
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
      pos.x += cos(angle + PI / 4) * speed;
      pos.y += sin(angle + PI / 4) * speed;
    }
    if (moveBackward) {
      pos.x -= cos(angle + PI / 4) * speed;
      pos.y -= sin(angle + PI / 4) * speed;
    }
    if (turnLeft) {
      angle -= rotationSpeed;
    }
    if (turnRight) {
      angle += rotationSpeed;
    }

    if (angle > TWO_PI) {
      angle = 0;
    } else if ( this.angle < 0) {
      angle = TWO_PI;
    }
  }
}
