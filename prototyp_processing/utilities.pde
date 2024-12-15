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
    ) {
    pos = new PVector(random(mapa.size.x), random(mapa.size.y));
  }
  return pos;
}
