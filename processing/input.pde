// KEY HANDLING

boolean moveForward, moveBackward, turnLeft, turnRight;

void keyPressed() {
  if (atomAnl != null && sampleIdentification) {
    atomAnl.handleKey(111111);
  }
  if (key == 'r') { // restart
    restartGame();
  }
  if (key == ' ') {
    player.scan();
  }
  if (key == 'i') {
    infoDisplay = !infoDisplay;
  }
  if (key == 'y') {
    signalDisplay.randomizeSineGame();
  }

  if (key ==  'o') {
    storm.startStorm(int(gameState.phaseLength*2*60/1000), .2, .2);
  }
  if (key == 'q') {
    turnAllLedOff();
    System.exit(0);
  }
  if (key == 'm') {
    atomAnl = new AtomAnalyzer();

    sampleIdentification = !sampleIdentification;
  }
  if (key == 'n') {
    if (screen2State == s2s.GPS) {
      screen2State = s2s.RADAR;
    } else {
      screen2State = s2s.GPS;
    }
    load.start();
  }

  if (key == 'p') {
    gamePaused = !gamePaused;
  }
  if (key == 'e') {
    endGame();
  }
  if (key == ' ') {
    println("off");
    if (soundManager.tracks.get("bass").isOn) {
      soundManager.tracks.get("bass").off();
    } else {
      soundManager.tracks.get("bass").on();
    }
  }


  // --- TMP ---
  if (key == 'h') {
    gameState.heating = !gameState.heating;
  }
  if (key == 'c') {
    gameState.cooling = !gameState.cooling;
  }
  // ---


  if (key == 'b') {
    hazardMonitor.interference = (random(2) < 1) ? true : false;
    Forecast[] randomw = Forecast.values();
    Forecast random_weather = randomw[int(random(randomw.length))];

    Alerts[] randoma = Alerts.values();
    Alerts random_alert = randoma[int(random(randoma.length))];

    DailyCycle[] randomd = DailyCycle.values();
    DailyCycle random_day = randomd[int(random(randomd.length))];

    hazardMonitor.forecast = Forecast.CLEAR;
    hazardMonitor.dayCycle = DailyCycle.MORNING;
    hazardMonitor.windSpeed = int(random(0, 88));
    hazardMonitor.temp = int(random( -90, 88));
    //hazardMonitor.alert = random_alert;

    hazardMonitor.updateHazard();
    println("Current weather :", random_weather);
  }


  // Y centering on screen
  if (key == 't' || key == 'g') {
    if (key == 't') {
      screenYOffset++;
    }
    if (key == 'g') {
      screenYOffset--;
    }
    screen1Center = new PVector(screenSize / 2 + (width - screenGap - screenSize * 2) / 2, screenSize / 2 + (height - screenSize) / 2);
    screen2Center = new PVector(screenSize / 2 + (width + screenGap - screenSize * 2) / 2 + screenSize, screenSize / 2 + (height - screenSize) / 2);
    screen1Center.y += screenYOffset;
    screen2Center.y += screenYOffset;
    screen2Corner.x = int(screen2Center.x - screenSize / 2);
    screen2Corner.y = int(screen2Center.y - screenSize / 2);
  }

  if (key == 'w' || key == 'W') moveForward = true;
  if (key == 's' || key == 'S') moveBackward = true;
  if (key == 'a' || key == 'A') turnLeft = true;
  if (key == 'd' || key == 'D') turnRight = true;
}


// Handle key releases
void keyReleased() {
  if (key == 'w' || key == 'W') moveForward = false;
  if (key == 's' || key == 'S') moveBackward = false;
  if (key == 'a' || key == 'A') turnLeft = false;
  if (key == 'd' || key == 'D') turnRight = false;
}
