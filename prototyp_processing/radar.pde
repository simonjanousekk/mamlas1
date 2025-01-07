class Radar {
  int radarRadius;
  RadarDot[] radarDots = new RadarDot[rayCount];
  Radar(int r) {
    radarRadius = r;

    float tmpA = TWO_PI / rayCount;
    for (int i = 0; i < rayCount; i++) {
      float x = map(cos(tmpA * i + PI/4+PI), -1, 1, -radarRadius, radarRadius) + width/2;
      float y = map(sin(tmpA * i + PI/4+PI), -1, 1, -radarRadius, radarRadius)+ width/2;
      radarDots[i] = new RadarDot(new PVector(x, y), rays.get(i));
    }
  }

  void display() {
    for (RadarDot r : radarDots) {
      r.update();
      r.display();
    }
  }
}

class RadarDot {

  PVector pos;
  boolean state;
  Ray ray;
  RadarDot(PVector p, Ray r) {
    pos = p;
    state = false;
    ray = r;
  }

  void update() {
    if (ray.intersection == null) {
      state = false;
    } else {
      state = true;
    }
  }

  void display() {
    noStroke();
    if (state) {
      fill(255, 0, 0);
    } else {
      fill(0, 255, 0);
    }
    circle(pos.x, pos.y, 10);
  }
}
