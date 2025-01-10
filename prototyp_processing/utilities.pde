boolean isCircleLineColliding(PVector circle, float radius, PVector lineStart, PVector lineEnd) {
  float cx = circle.x;
  float cy = circle.y;
  float r = radius;
  float x1 = lineStart.x;
  float y1 = lineStart.y;
  float x2 = lineEnd.x;
  float y2 = lineEnd.y;

  float lineLengthSq = sq(x2 - x1) + sq(y2 - y1);
  float t = ((cx - x1) * (x2 - x1) + (cy - y1) * (y2 - y1)) / lineLengthSq;
  float tClamped = constrain(t, 0, 1);
  float closestX = x1 + tClamped * (x2 - x1);
  float closestY = y1 + tClamped * (y2 - y1);
  float distanceSq = sq(cx - closestX) + sq(cy - closestY);
  return distanceSq <= sq(r);
}

PVector lineLineIntersection(PVector line1Start, PVector line1End, PVector line2Start, PVector line2End) {
  float x1 = line1Start.x;
  float y1 = line1Start.y;
  float x2 = line1End.x;
  float y2 = line1End.y;
  float x3 = line2Start.x;
  float y3 = line2Start.y;
  float x4 = line2End.x;
  float y4 = line2End.y;

  float denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
  if (denominator == 0) {
    return null;
  }
  float t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator;
  float u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denominator;

  if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
    float intersectionX = x1 + t * (x2 - x1);
    float intersectionY = y1 + t * (y2 - y1);
    return new PVector(intersectionX, intersectionY);
  }

  return null;
}

boolean isCircleSquareColliding(PVector circle, float radius, PVector squarePos, float squareSize) {
  float cx = circle.x;
  float cy = circle.y;
  float r = radius;
  float sx = squarePos.x;
  float sy = squarePos.y;
  float sSize = squareSize;

  // Find the closest point on the square to the circle center
  float closestX = constrain(cx, sx, sx + sSize);
  float closestY = constrain(cy, sy, sy + sSize);

  // Calculate the distance from the circle's center to this closest point
  float distanceSq = sq(cx - closestX) + sq(cy - closestY);

  // If the distance is less than the circle's radius, they are colliding
  return distanceSq <= sq(r);
}


PVector randomPosOutsideWalls() {
  PVector pos = new PVector(random(mapa.size.x), random(mapa.size.y));
  while (
    mapa.grid[floor(pos.x / mapa.cellSize)][floor(pos.y / mapa.cellSize)].state
    //&& (mapa.grid[floor(pos.x / mapa.cellSize)][floor(pos.y / mapa.cellSize)].diagonal == Diagonal.FALSE)
    ) {
    pos = new PVector(random(mapa.size.x), random(mapa.size.y));
  }
  return pos;
}

void displayFPS() {
  fill(255);
  textSize(16);
  textAlign(RIGHT, BOTTOM);
  text(fakeFrameRate, width-5, height-20);
  text(int(frameRate), width-5, height-5);
}

void displayMask(int border) {
  push();
  fill(0);
  noStroke();
  rect(0, 0, border, height);
  rect(0, 0, width, border);
  rect(width, height, -border, -height);
  rect(width, height, -width, -border);
  image(mask, border, border, width-border*2, height-border*2);
  pop();
}


boolean isDistanceMore(PVector p1, PVector p2, float threshold) {
  return isDistanceMore(p1.x, p1.y, p2.x, p2.y, threshold);
}
boolean isDistanceMore(float x1, float y1, float x2, float y2, float threshold) {
  return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) > threshold * threshold;
}


boolean isDistanceLess(PVector p1, PVector p2, float threshold) {
  return isDistanceLess(p1.x, p1.y, p2.x, p2.y, threshold);
}
boolean isDistanceLess(float x1, float y1, float x2, float y2, float threshold) {
  return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) < threshold * threshold;
}


PVector pointAlongLine(float x1, float y1, float x2, float y2, float t) {
  // Apply easing to t
  t = constrain(t, 0, 1);

  // Calculate the interpolated point
  float x = x1 + t * (x2 - x1);
  float y = y1 + t * (y2 - y1);

  return new PVector(x, y);
}

float applyEasing(float t, String easing) {
  switch (easing) {
    case "easeInQuad":
      return t * t; // Quadratic ease-in
    case "easeOutQuad":
      return t * (2 - t); // Quadratic ease-out
    case "easeInOutQuad":
      return (t < 0.5) ? 2 * t * t : -1 + (4 - 2 * t) * t; // Quadratic ease-in-out
    case "easeInCubic":
      return t * t * t; // Cubic ease-in
    case "easeOutCubic":
      return (--t) * t * t + 1; // Cubic ease-out
    case "easeInOutCubic":
      return (t < 0.5) ? 4 * t * t * t : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1; // Cubic ease-in-out
    default:
      return t; // Linear
  }
}
