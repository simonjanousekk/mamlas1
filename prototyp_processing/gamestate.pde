class GameState {

  int temperature = 0;

  GameState() {
  }


  void update() {


    if (frameCount % 60 == 0) {
      temperature += random(100);

      temperature = temperature > 999 ? -999 : temperature;
      temperature = temperature < -999 ? 999 : temperature;

      sendTemperature(temperature);

      println(temperature);
    }
  }
}



void sendTemperature(int t) {
  int tens = t / 100;
  int units = t % 100; 
  mb.sendControllerChange(1, 10, tens);
  mb.sendControllerChange(1, 11, units);
}
