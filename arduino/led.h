class Led {

private:
  int index;
  bool state = false;
  bool blink = false;
  unsigned long interval = 400;
  unsigned long lastToggleTime = 0;

public:
  Led() {}

  Led(int i)
  : index(i) {}

  void update() {
    if (state) {
      if (blink) {
        unsigned long currentTime = millis();
        if (currentTime - lastToggleTime >= interval) {
          toggleSingleBit(index);
          lastToggleTime = currentTime;
        }
      } else {
        toggleSingleBit(index);
      }
    } else {
      setSingleBit(index, 0);
    }
  }

  void toggleState() {
    state = !state;
  }
  void off() {
    state = false;
  }
  void on() {
    state = true;
    blink = false;
  }
  void on_blink() {
    state = true;
    blink = true;
  }
};
