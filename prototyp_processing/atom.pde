class Atom {
  
  int size = screenSize / 2 - screen2Border - s_thick;
  int coreSize = size / 3;
  
  int electronCount = 3;
  ArrayList<Electron> electrons = new ArrayList<Electron>();
  
  Atom() {
    
    for (int i = 0; i < electronCount; i++) {
      electrons.add(new Electron(size, coreSize));
    }
  }
  
  void display() {
    push();
    stroke(0, 255, 255);
    strokeWeight(s_thin);
    fill(0);
    
    
    for (float a = 0; a < TWO_PI; a += TWO_PI / 6) {
      float x = map(cos(a), -1, 1, -coreSize / 3, coreSize / 3);
      float y = map(sin(a), -1, 1, -coreSize / 3, coreSize / 3);
      circle(x, y, 18);
    }
    for (float a = 0; a < TWO_PI; a += TWO_PI / 3) {
      float x = map(cos(a), -1, 1, -coreSize / 5, coreSize / 5);
      float y = map(sin(a), -1, 1, -coreSize / 5, coreSize / 5);
      circle(x, y, 18);
    }
    circle(0, 0, 18);
    
    //circle(0, 0, coreSize);
    
    
    for (int i = 0; i < electronCount; i++) {
      rotate(TWO_PI / 3);
      
      electrons.get(i).update();
      electrons.get(i).display();
      //if (i % 3 == 0) {
      //noFill();
      //stroke(100);
      //strokeWeight(1);
      //ellipse(0, 0, size*2, coreSize*2);
      //}
    }
    
    pop();
  }
}


class Electron {
  PVector pos;
  //float ang = random(TWO_PI);
  float ang = 0;
  float speed = 0.05;
  
  ArrayList<PVector> trail = new ArrayList<PVector>();
  
  
  float xmax, ymax;
  Electron(float xm, float ym) {
    xmax = xm;
    ymax = ym;
  }
  
  void update() {
    float x = map(cos(ang), -1, 1, -xmax, xmax);
    float y = map(sin(ang), -1, 1, -ymax, ymax);
    pos = new PVector(x, y);
    ang += speed;
    
    trail.add(pos);
    
    if (trail.size() > 100) {
      trail.remove(0);
    }
  }
  
  void display() {
    
    strokeWeight(s_thick);
    for (int i = 0; i < trail.size() - 1; i++) {
      PVector p1 = trail.get(i);
      PVector p2 = trail.get(i + 1);
      stroke(map(i, 0, trail.size() - 1, 0, 255));
      line(p1.x, p1.y, p2.x, p2.y);
    }
    
    
    //fill(primary);
    //stroke(0);
    //strokeWeight(2);
    //circle(pos.x, pos.y, u*2);
  }
}
