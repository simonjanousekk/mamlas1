class Ray { //<>//
  PVector pos, dir;

  float originAngle;
  PVector intersection = null;

  Ray(PVector p, float angle) {
    pos = p.copy();
    originAngle = angle;
    dir = PVector.fromAngle(angle);
  }

  void update(PVector p, float a) {
    pos = p.copy();
    dir = PVector.fromAngle(originAngle + a);
  }

  void display() {

    PVector pos1 = dir.copy().mult(player.diameter/2).add(pos.copy());

    if (intersection != null) {
      stroke(255, 0, 255);
      line(pos1.x, pos1.y, intersection.x, intersection.y);
      noStroke();
      fill(100, 100, 255);
      circle(intersection.x, intersection.y, 5);
    } else {
      stroke(100, 100, 255);

      line(
        pos1.x,
        pos1.y,
        pos.x + dir.x * rayLength,
        pos.y + dir.y * rayLength
        );
    }
  }


  void findWallAnimation() {
    //if (!(intersection == null)) {
      wmarkers.add(new WMarker(
        pos,
        new PVector(pos.x + dir.x * rayLength, pos.y + dir.y * rayLength),
        intersection
        ));
    //}
  }




  ArrayList<PVector> cast(ArrayList<Wall> wls) {
    ArrayList<PVector> intersections = new ArrayList<PVector>();
    for (Wall w : wls) {
      intersections.add(
        lineLineIntersection(
        pos,
        pos.copy().add(dir.copy().mult(rayLength)),
        w.pos1,
        w.pos2));
    }
    return intersections;
  }

  void findShortestIntersection(ArrayList<Wall> wls) {
    ArrayList<PVector> intersections = cast(wls);

    intersection = null;
    PVector shortestIntersection = null;

    for (PVector intersection : intersections) {
      if (intersection != null) {
        float dx = intersection.x - this.pos.x;
        float dy = intersection.y - this.pos.y;
        float distanceSquared = dx * dx + dy * dy;

        if (shortestIntersection == null || distanceSquared < (shortestIntersection.x - this.pos.x) * (shortestIntersection.x - this.pos.x) + (shortestIntersection.y - this.pos.y) * (shortestIntersection.y - this.pos.y)) {
          shortestIntersection = intersection;
        }
      }
    }

    intersection = shortestIntersection;
  }
}
