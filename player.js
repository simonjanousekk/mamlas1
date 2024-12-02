class Player {
  constructor(x, y) {
    this._speed = 1;
    this._rotationSpeed = 0.03;
    this._radius = 5;

    this.pos = createVector(x, y);
    this.angle = 0;
    this.samplesCollected = 0;

    this.belt = createVector(0, 0);
  }

  collide(wall) {
    wall.colided = isCircleLineColliding(this, wall.pos1, wall.pos2);
    if (wall.colided) {
      console.log("game over");
    }
  }

  display() {
    push();

    stroke(50);
    strokeWeight(2);
    fill(0, 255, 0);
    translate(this.pos.x, this.pos.y);
    rotate(this.angle + PI / 4);
    beginShape();
    vertex(-this._radius, -this._radius);
    vertex(-this._radius, this._radius);
    vertex(this._radius * 2, 0);
    endShape(CLOSE);

    pop();
  }

  handleInput() {
    if (keyIsDown(65)) {
      // 'a' key
      this.angle -= this._rotationSpeed;
    }
    if (keyIsDown(68)) {
      // 'd' key
      this.angle += this._rotationSpeed;
    }
    if (keyIsDown(87)) {
      // 'w' key
      const moveSpeed = this._speed;
      this.pos.x += cos(this.angle + PI / 4) * moveSpeed;
      this.pos.y += sin(this.angle + PI / 4) * moveSpeed;
    }
    if (keyIsDown(83)) {
      // 's' key
      const moveSpeed = this._speed;
      this.pos.x -= cos(this.angle + PI / 4) * moveSpeed;
      this.pos.y -= sin(this.angle + PI / 4) * moveSpeed;
    }

    const slider1 = document.getElementById("slider1");
    if (slider1) {
      this.belt.x = map(slider1.value, 0, 100, -this._speed, this._speed);
    }
    const slider2 = document.getElementById("slider2");
    if (slider2) {
      this.belt.y = map(slider2.value, 0, 100, -this._speed, this._speed);
    }

    this.belt.limit(this._speed);
  }

  move() {
    const forwardSpeed = (this.belt.x + this.belt.y) / 2;
    const turnSpeed = (this.belt.y - this.belt.x) / 2;

    if (this.angle > TWO_PI) {
      this.angle = 0;
    } else if (this.angle < 0) {
      this.angle = TWO_PI;
    }

    this.pos.x += cos(this.angle + PI / 4) * forwardSpeed;
    this.pos.y += sin(this.angle + PI / 4) * forwardSpeed;

    // if (this.pos.x < 0) this.pos.x = width;
    // if (this.pos.x > width) this.pos.x = 0;
    // if (this.pos.y < 0) this.pos.y = height;
    // if (this.pos.y > height) this.pos.y = 0;

    this.angle += turnSpeed * this._rotationSpeed;
  }
}
