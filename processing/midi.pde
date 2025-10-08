import themidibus.*; // midi library

// java nonsence for executing bash commands 
// import java.io.BufferedReader;
// import java.io.InputStreamReader;
// import java.io.ProcessBuilder;


MidiBus mb;
boolean changingVolume = false;

void mbInit() {
  //MidiBus.list();
  String[] inputs = MidiBus.availableInputs();
  
  if (inputs == null || inputs.length == 0) {
    println("No MIDI input devices detected!");
    return;
  }
  midiDevice = null;
  for (String name : inputs) {
    if (name.startsWith("Micro")) {  // change to contains("Micro") if needed
      midiDevice = name;
      break;
    }
  }
  
    if (midiDevice != null) {
  
  mb = new MidiBus(this, midiDevice, midiDevice);
    } else {
      println("No Micro MIDI devices is available");
    }
}

void controllerChange(ControlChange change) {
  if (gameInitialized) {
    int channel = change.channel();
    int control = change.number();
    int value = change.value();

    //print("MIDI INPUT:");
    ////print(" channel: " + channel);
    //print(" control: " + control);
    //print(" value: " + value);
    //println(" ");
    if (channel == 0) {

      // --- ENCODERS ---
      if (control == 1) { // rotation encoder - player rotation
        if (value == 0) {
          player.turn--;
        } else if (value == 1) {
          player.turn++;
        }
        if (changingVolume) {
          if (value == 0) {
            println("volume down");
            changeVolume(false);
          } else {
            println("volume up");
            changeVolume(true);
          }
        }
      } else if (control == 2) { // analyzer encoder
        // handle selection of sample
        // left is 1 and right is 0 for some reason :D
        if (atomAnl != null) {
          atomAnl.handleKey(value);
        }

        // --- POTENCIOMETERS ---
      } else if (control == 3) { // ROT POT for AMP
        float alpha = map(value, 0, 127, signalDisplay.ampConstrain.x, signalDisplay.ampConstrain.y);
        signalDisplay.sinePlayer.desAmp = alpha;
      } else if (control == 4) { // ROT POT for BAND
        float beta = map(value, 0, 127, signalDisplay.bandConstrain.x, signalDisplay.bandConstrain.y);
        signalDisplay.sinePlayer.desBand = beta;
      } else if (control == 5) { // SLIDER POT for SPEED
        player.setDesiredVelocity(value);
      } else if (control == 6) { // SLIDER POT for SUSPENSION
        player.setSuspension(value);


        // --- SWITCHES ---
      } else if (control == 20) { // GPS / RADAR switch
        if (value == 0 && screen2State == s2s.RADAR) {
          screen2State = s2s.GPS;
          load.start();
          soundManager.sounds.get("switch").play();
        } else if (value == 1 && screen2State == s2s.GPS) {
          screen2State = s2s.RADAR;
          load.start();
          soundManager.sounds.get("switch").play();
        }
      } else if (control == 21) { // REVERSE
        if (value == 0) player.reverse = false;
        if (value == 1) player.reverse = true;
      } else if (control == 22) { // HEATING
        if (value == 0) {
          gameState.heating = true;
          turnOnLedNoBlink(5);
        } else {
          gameState.heating = false;
          turnOffLed(5);
        }
      } else if (control == 23) { // COOLING
        if (value == 0) {
          gameState.cooling = true;
          turnOnLedNoBlink(6);
        } else {
          gameState.cooling = false;
          turnOffLed(6);
        }

        // --- BUTTONS ---
      } else if (control == 10 && value == 0) { // RADAR button
        player.scan();
      } else if (control == 11) { // SAMPLE IDENTIFICATION button
        if (value == 0) {
          if (atomAnl != null) {
            atomAnl.validateResult();
          }
          changingVolume = true;
        } else if (value == 1) {
          changingVolume = false;
        }
      } else if (control == 12 && value == 0) { // RESTART button
        hazardMonitor = null;
        restartGame();
      }
    }
  }
}






class LedDriver {
  int[] indexes;
  boolean wasOn = false;
  boolean on = false;

  LedDriver(int[] i) {
    indexes = i;
  }

  LedDriver(int j) {
    this(new int[] {j});
  }

  void update() {
    if (!wasOn && on) {
      for (int i : indexes) {
        turnOnLed(i);
      }
      wasOn = true;
    } else if (wasOn && !on) {
      for (int i : indexes) {
        turnOffLed(i);
      }
      wasOn = false;
    }
  }

  void turnOn() {
    on = true;
    update();
  }

  void turnOff() {
    on = false;
    update();
  }

  void turnBased(boolean b) {
    if (b) {
      turnOn();
    } else {
      turnOff();
    }
  }
}

void requestPotValues() { // for requesting all static values
  mb.sendControllerChange(1, 1, 1);
}

void turnOnLed(int index) {
  mb.sendControllerChange(2, index, 1);
}

void turnOnLedNoBlink(int index) {
  mb.sendControllerChange(2, index, 2);
}

void turnOffLed(int index) {
  mb.sendControllerChange(2, index, 0);
}

void turnAllLedOff() {
  for (int i = 0; i < 14; i++) {
    turnOffLed(i);
  }
}

void turnAllLedOn() {
  for (int i = 0; i < 14; i++) {
    turnOnLed(i);
    delay(int(random(1000)));
  }
}

void changeVolume(boolean up) {
  String command = "amixer set Master 2%";
  command += up ? "+" : "-";
  // println(command);
  try {
    ProcessBuilder pb = new ProcessBuilder("bash", "-c", command);
    pb.inheritIO();
    Process process = pb.start();

    process.waitFor();
  } catch (Exception e) {
    e.printStackTrace();
  }
}
