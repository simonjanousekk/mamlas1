class Compass {
  int radius;
  float angleToSample;
  int distanceToSample;
  float radiusToSample;

  int shortLineL = u;
  int longLineL = u * 2;

  int sampleArrowSpace = u*2;


  //int arrowL = 70;
  //int arrowHL = 20;


  Compass(int r) {
    radius = r;
  }

  void update() {
    angleToSample = atan2(sample.pos.x - player.pos.x, sample.pos.y - player.pos.y);
    angleToSample += player.angle + PI;

    distanceToSample = int(player.pos.dist(sample.pos) * distUnitScale);



    boolean sampleInView = isDistanceLess(player.pos, sample.pos, radius + sampleArrowSpace);

    if (!sampleInView) {
      radiusToSample = radius;
    } else {
      radiusToSample = player.pos.dist(sample.pos) - sampleArrowSpace;
    }
  }

  void displayInside() {
    this.update();
    textAlign(CENTER, BOTTOM);





    push();
    translate(screen2Center.x, screen2Center.y);
    rotate( -angleToSample);
    translate(0, -radiusToSample);

    stroke(primary);
    strokeWeight(s_thick);
    fill(0);

    beginShape();
    vertex(0, 0);
    vertex(longLineL * .5, longLineL);
    vertex(longLineL * 2, longLineL);
    vertex(longLineL * 2, longLineL * 3);
    vertex( -longLineL * 2, longLineL * 3);
    vertex( -longLineL * 2, longLineL);
    vertex( -longLineL * .5, longLineL);
    endShape(CLOSE);

    fill(white);
    noStroke();
    textAlign(CENTER, TOP);
    text(nf(distanceToSample, 3), 0, longLineL*1.5);

    pop();


    // dash line raylength
    push();
    translate(screen2Center.x, screen2Center.y);
    stroke(255);
    strokeWeight(s_thick);
    float tmpa = TWO_PI / rayCount;
    for (int i = 0; i < rayCount; i++) {
      float x1 = cos(tmpa * i) * rayLength;
      float y1 = sin(tmpa * i) * rayLength;
      float x2 = cos(tmpa * (i + 0.5)) * rayLength;
      float y2 = sin(tmpa * (i + 0.5)) * rayLength;
      line(x1, y1, x2, y2);
    }
    pop();


    // top square with degrees heading to
    //push();
    //translate(screen2Center.x, screen2Center.y - radius);
    //fill(0);
    //stroke(primary);
    ////strokeWeight(2);
    //strokeJoin(BEVEL);
    //beginShape();
    //vertex(0, 0);
    //vertex(longLineL * .5, -longLineL);
    //vertex(longLineL * 2, -longLineL);
    //vertex(longLineL * 2, -longLineL * 3);
    //vertex( -longLineL * 2, -longLineL * 3);
    //vertex( -longLineL * 2, -longLineL);
    //vertex( -longLineL * .5, -longLineL);
    //endShape(CLOSE);
    //fill(white);
    //text(nf(floor(degrees(player.angle)), 3), 0, -longLineL * 1.5);
    //pop();



    // sample dir arrow
    //push();
    //translate(screen2Center.x, screen2Center.y);
    //rotate( -angleToSample);
    //translate(0, -radius);
    //fill(primary);
    //stroke(primary);
    ////fill(0);
    //beginShape();
    //strokeJoin(ROUND);
    //vertex(0, 0);
    //vertex(shortLineL, -shortLineL * 2);
    ////vertex(0, -shortLineL*4);
    //vertex( -shortLineL, -shortLineL * 2);
    //endShape(CLOSE);
    //pop();
  }

  void displayOutside() {
    // circle with lines
    push();
    stroke(white);
    noFill();
    translate(screen2Center.x, screen2Center.y);
    rotate( -player.angle);
    strokeWeight(s_thick);
    circle(0, 0, radius * 2);
    int linesCount = 72;
    String[] labels = {"N", "3", "6", "E", "12", "15", "S", "21", "24", "W", "30", "33"};
    float angleInc = TWO_PI / linesCount;
    for (int i = 0; i < linesCount; i++) {
      float l = shortLineL;
      if (i % 2 == 0) l = longLineL;
      push();
      rotate(angleInc * i);
      translate(0, -radius);

      line(0, 0, 0, -l);
      if (i % (linesCount / labels.length) == 0) {
        int index = floor(i / (linesCount / labels.length));
        fill(255);
        noStroke();
        text(labels[index], -2, -l);
      }
      pop();
    }
    pop();
  }
}
