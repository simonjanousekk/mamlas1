class Led {

private:
  int index;
  bool state = false;
  unsigned long interval = 400;
  unsigned long lastToggleTime = 0;

public:
  Led() {}

  Led(int i)
    : index(i) {}

  void update() {
    if (state) {
      unsigned long currentTime = millis();
      if (currentTime - lastToggleTime >= interval) {
        toggleSingleBit(index);
        lastToggleTime = currentTime;
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
  }
};
