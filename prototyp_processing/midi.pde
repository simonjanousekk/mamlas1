import themidibus.*;

MidiBus mb;

void mbInit() {
  MidiBus.list(); 
  mb = new MidiBus(this, "Arduino Micro", "Arduino Micro");
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
  
  println("MIDI INPUT:");
  print("channel: " + channel);
  print(" number: " + number);
  print(" value: " + value);
  println(" ");
  
  if (channel == 0 && number == 1) { // rotation encoder - player rotation
    if (value == 0) {
      player.turn--;
    } else if (value == 1) {
      player.turn++;
    }
  } else if (channel == 0 && number == 2) {
    player.setDesiredVelocity(value);
  }
}
