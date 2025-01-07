

class WMarker {

  PVector pos, lstart, lend, fpos;
  boolean destroy = false;
  boolean finished = false;
  boolean isWall;
  int animationL = 60;
  int animationStart, animationEnd;



  WMarker(PVector s, PVector e, PVector f) {
    pos = s;
    lstart = s;
    lend = e;
    fpos = f;
    animationStart = frameCount;
    animationEnd = animationStart + animationL;
    if (fpos == null) {
      isWall = false;
    } else {
      isWall = true;
    }
  }

  void update() {
    if (!finished) {
      float amt = map(frameCount, animationStart, animationEnd, 0, 1);
      println(amt);
      
      pos.x = lstart.x + amt * (lend.x - lstart.x);
      pos.y = lstart.y + amt * (lend.y - lstart.y);
      
      if (isWall) {
        if (isDistanceLess(pos.x, pos.y, fpos.x, fpos.y, 5)) {
          finished = true;
          pos = fpos;
        }
      } else {
        if (amt >= 1) {
          finished = true;
        }
      }
    } else if (finished && !isWall && !destroy) {
      println("destroy");
      destroy = true;
    }
  }

  void display() {
    fill(255, 0, 255);
    noStroke();
    circle(pos.x, pos.y, 5);
  }
}
