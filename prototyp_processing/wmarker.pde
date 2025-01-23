

class WMarker {

  PVector pos, lstart, lend, fpos;
  boolean destroy = false;
  boolean finished = false;
  boolean isWall;
  int animationL = 40;
  int animationStart, animationEnd;

  color col = color(255, 255);



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
      pos = pointAlongLine(lstart.x, lstart.y, lend.x, lend.y, amt);
      if (!isWall) {
        col = color(255, map(amt, 0, 1, 255, 0));
      }

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
      destroy = true;
    }
  }



  void display() {
    fill(col);
    noStroke();
    circle(pos.x, pos.y, int(u*.7));
  }
}
