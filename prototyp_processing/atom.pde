import java.util.Arrays;
import java.util.List;
import java.util.Collections;

class Atom {

  int size = screenSize / 2 - screen2Border - s_thick;
  int coreSize = size / 3;

  int electronCount = 3;
  ArrayList<Electron> electrons = new ArrayList<Electron>();

  Atom() {

    for (int i = 0; i < electronCount; i++) {
      electrons.add(new Electron(size, coreSize*1.5));
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
    float y = map(sin(ang), -1, 1, -ymax/2, ymax/2);
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


class Element {
  String kratky;
  String name;
  String density;
  boolean radioactive;

  Element(String k, String n, String d, boolean r) {
    kratky = k;
    name = n;
    density = d;
    radioactive = r;
  }
}


PImage biohazard;

class AtomAnalyzer {
  //loading bar params
  float r_width = screenSize / 1.5;
  float r_height = u * 2;
  float acc = 0;
  float progress = 0;
  float loading_w = 250;
  float loading_h = u * 2;

  //table, title division, padding
  float table_w = 310;
  float table_h = 160;
  float corps_y = 20;
  float padding = 10;
  float padding_s = 5;

  Element e;

  // picker
  int cursorPlayer = 2;
  float highlight_y = 0;
  float highlight_h = 0;

  String matchResult = "";
  String failMessage = "Matching failed!";
  String successMessage = "Matching succeeded!";
  int transitionOut = 3000;
  int countDown = 0;

  LedDriver ledDriver = new LedDriver(12);

  AtomAnalyzer() {
    Collections.shuffle(elements);
    biohazard = loadImage("radioactive_8bit.png");
    e = elements.get(int(random(elements.size())));
    println("element mem:");
    printArray(elements_mem);

    while (Arrays.asList(elements_mem).contains(e.name)) {
      printArray(elements_mem);
      e = elements.get(int(random(elements.size())));
    }
      println("element pick: ", e.name);

    // Adding e to memory
    mem_index = ((mem_index < 3) ? mem_index : 0);
    elements_mem[mem_index] = e.name;
    mem_index++;

    println("The current element is.. ", e.name);
    countDown = 0;
    ledDriver.turnOn();

    gamePaused = true;
  }

  void display() {

    //loading bar
    if (progress < r_width) {
      if (frameCount % 10 == 0) {
        acc = random(0.2, 1.5);
      }

      textAlign(CENTER);
      fill(white);
      text("Analysis in progress", 0, -loading_h * 1.5);
      rectMode(CORNER);
      strokeWeight(2);
      stroke(white);
      noFill();
      rect(-loading_w/2, -r_height/2, loading_w, loading_h);

      noStroke();
      fill(primary);
      rect(-loading_w/2, -r_height/2, progress, loading_h);
      progress+=acc;
    } else if (countDown == 0 || countDown > millis() - transitionOut) {
      // analysis results
      strokeWeight(1);
      rectMode(CENTER);
      noFill();
      stroke(white);

      // Outer rectangle
      rect(0, 0, table_w, table_h);
      line(0, -table_h/2, 0, table_h/2);
      //table underneath title
      rect(0, corps_y - padding_s, table_w, table_h - corps_y*2 + (2*padding_s));

      textSize(16);
      textAlign(CENTER, TOP);
      fill(white);
      text("Analysis result", -table_w/4, -table_h/2 + padding);
      text("Select sample", table_w/4, -table_h/2 + padding);
      textAlign(LEFT, TOP);
      fill(white);
      text("Density:", -table_w/2 + padding_s, -table_h/2 + corps_y * 2);

      textAlign(CENTER, CENTER);
      fill(primary);
      text(e.density, -table_w/4, -table_h/2 + corps_y * 4);

      textAlign(LEFT, TOP);
      fill(white);
      text("Radioactivity:", -table_w/2 + padding_s, -table_h/2 + corps_y * 5);
      if (!e.radioactive) {
        textAlign(CENTER, CENTER);
        fill(primary);
        text("-", -table_w/4, -table_h/2 + corps_y * 7);
      } else if (e.radioactive) {
        imageMode(CENTER);
        tint(primary);
        image(biohazard, -table_w/4, -table_h/2 + corps_y * 6.9, 24, 24);
      }

      for (int i=2; i < 8; i++ ) {
        stroke(white);
        // debug - lines where we draw the things
        //line(-table_w/2, -table_h/2 + (i * corps_y), table_w/2, -table_h/2 + (i * corps_y) );
        fill(white);
        String zebi = elements.get(i-2).name;
        String zebi_kratky = elements.get(i-2).kratky;
        textAlign(RIGHT, TOP);
        text(zebi_kratky, table_w/2 - padding_s, -table_h/2 + (i * corps_y));
        textAlign(LEFT, TOP);
        text(zebi, 0 + padding_s, -table_h/2 + (i * corps_y));
      }
      rectMode(CORNER);
      fill(white, 125);

      // highlight based on controller
      // we have to adjust if its 2 or 7 because these lines have extra padding otherwise it looks like trash
      if (cursorPlayer == 2) {
        highlight_y = -table_h/2 - padding + corps_y * cursorPlayer;
        highlight_h = corps_y + padding/2;
      } else if (cursorPlayer == 7) {
        highlight_y = -table_h/2 - padding/2 + corps_y * cursorPlayer;
        highlight_h = corps_y + padding/2;
      } else {
        highlight_y = -table_h/2 - padding/2 + corps_y * cursorPlayer;
        highlight_h = corps_y;
      }
      rect(0, highlight_y, table_w/2, highlight_h);


      // displaying match result
      if (matchResult.equals(successMessage) && countDown == 0) {
        countDown = millis();
      }
      textAlign(CENTER, TOP);
      fill(white);

      text(matchResult, 0, table_h/2 + padding);
      if (matchResult.equals(failMessage) && frameCount % 10 == 0) {
        fill(0);
        rectMode(CENTER);
        noStroke();
        rect(0, 0, screenSize, screenSize);
        if (countDown == 0) {
          countDown = millis() - 1500;
        }
      }
    } else {
      if (matchResult.equals(failMessage)) {
        matchResult = "";
        countDown = 0;
      } else {
        sampleIdentification = false;
        ledDriver.turnOff();
        gamePaused = false;
      }
    }
  }


  void handleKey(int value) {
    //this will be replaced by button and potaky
    if (keyCode == UP || value == 1) {
      cursorPlayer--;
    } else if (keyCode == DOWN || value == 0) {
      cursorPlayer++;
    } else if (keyCode == ENTER || keyCode == RETURN) {
      validateResult();
    }
    if (cursorPlayer > 7) {
      cursorPlayer = 2;
    } else if (cursorPlayer < 2) {
      cursorPlayer = 7;
    }
  }

  void validateResult() {
    String elementSelected = elements.get(cursorPlayer-2).name;
    if (elementSelected.equals(e.name)) {
      matchResult = successMessage;
    } else {
      matchResult = failMessage;
    }
  }
}
