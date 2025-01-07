class Radar {
  constructor(x, y, size) {
    this.pos = createVector(x, y);
    this.lights = [];
    this.size = size;

    this.angleIncrement = TWO_PI / rayCount;
    for (let i = 0; i < rayCount; i++) {
      const angle = i * this.angleIncrement;
      const x = cos(angle) * this.size;
      const y = sin(angle) * this.size;
      this.lights.push(new Light(this.pos.x + x, this.pos.y + y));
    }
  }

  display() {
    for (let light of this.lights) {
      light.display();
    }
  }

  update(rays) {
    this.lights.forEach((light, index) => {
      if (rays[index].intersection !== null) {
        light.value = map(
          (rays[index].intersection.x - player.pos.x) ** 2 +
            (rays[index].intersection.y - player.pos.y) ** 2,
          rays[index]._rayLength ** 2,
          100,
          0,
          100
        );
      } else {
        light.value = 0;
      }
    });
  }
}

class Light {
  constructor(x, y) {
    this.pos = createVector(x, y);
    this.value = 0;
  }

  display() {
    push();
    noStroke();
    if (this.value == 0) {
      fill(150);
    } else if (this.value > 50) {
      fill(255, 0, 0);
    } else {
      fill(0, 255, 0);
    }
    circle(this.pos.x, this.pos.y, 10);
    pop();
  }
}
