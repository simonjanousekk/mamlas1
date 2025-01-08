

class WMarker {

  PVector pos, lstart, lend, fpos;
  boolean destroy = false;
  boolean finished = false;
  boolean isWall;
  int animationL = 60;
  int animationStart, animationEnd;
  int fadeAnimationL = 30;
  int fadeAnimationStart, fadeAnimationEnd;

  color col = color(255, 0, 255, 255);



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
      pos = pointAlongLine(lstart.x, lstart.y, lend.x, lend.y, amt, "easeOutCubic");

      if (isWall) {
        if (isDistanceLess(pos.x, pos.y, fpos.x, fpos.y, 5)) {
          finished = true;
          pos = fpos;
        }
      } else {
        if (amt >= 1) {
          finished = true;
          fadeAnimationStart = frameCount;
          fadeAnimationEnd = fadeAnimationStart + fadeAnimationL;
        }
      }
    } else if (finished && !isWall && !destroy) {
      float opacity = map(frameCount, fadeAnimationStart, fadeAnimationEnd, 260, 0);
      col = color(255, 0, 255, opacity);
      if (opacity >= 255) {
        destroy = true;
      }
    }
  }

  void display() {
    fill(col);
    noStroke();
    circle(pos.x, pos.y, 5);
  }
}
