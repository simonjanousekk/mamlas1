import themidibus.*;

MidiBus mb;

void mbInit() {
  MidiBus.list(); 
  mb = new MidiBus(this, 3, 4);
}

void noteOn(Note note) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+note.channel());
  println("Pitch:"+note.pitch());
  println("Velocity:"+note.velocity());
}

void noteOff(Note note) {
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+note.channel());
  println("Pitch:"+note.pitch());
  println("Velocity:"+note.velocity());
}

void controllerChange(ControlChange change) {
  int channel = change.channel();
  int number = change.number();
  int value = change.value();
  if (channel == 0 &&number == 1) {
    if (value == 0) {
      player.turn(-1);
    } else if (value == 1) {
      player.turn(1);
    }
  }
}
