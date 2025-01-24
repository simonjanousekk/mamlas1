

class LedDriver {
  
  int[] indexes;
  boolean wasOn = false;
  boolean on = false;

  LedDriver(int[] i) {
    indexes = i;
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
}
