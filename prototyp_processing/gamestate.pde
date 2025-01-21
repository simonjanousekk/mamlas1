class GameState {

  int temperature = -150;

  GameState() {
  }


  void update() {


    if (frameCount % 120 == 0) {
      temperature = (int) random(-999, 999);

      temperature = temperature > 999 ? -999 : temperature;
      temperature = temperature < -999 ? 999 : temperature;

      sendTemperature(temperature);

      
    }
  }
}



void sendTemperature(int t) {
  int tens = abs(t / 100);
  int units = abs(t % 100);
  boolean isNegative = t < 0;
  mb.sendControllerChange(1, 10, tens);
  mb.sendControllerChange(1, 11, units);
  mb.sendControllerChange(1, 12, int(isNegative));
}
