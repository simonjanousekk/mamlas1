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
  int control = change.number();
  int value = change.value();

  print("MIDI INPUT:");
  //print(" channel: " + channel);
  print(" control: " + control);
  print(" value: " + value);
  println(" ");
  if (channel == 0) {
    if (control == 1) { // rotation encoder - player rotation
      if (value == 0) {
        player.turn--;
      } else if (value == 1) {
        player.turn++;
      }
    } else if (control == 3) { // ROT POT for AMP
      float alpha = map(value, 0, 127, signalDisplay.ampConstrain.x, signalDisplay.ampConstrain.y);
      signalDisplay.sinePlayer.desAmp = alpha;
    } else if (control == 4) { // ROT POT for BAND
      float beta = map(value, 0, 127, signalDisplay.bandConstrain.x, signalDisplay.bandConstrain.y);
      signalDisplay.sinePlayer.desBand = beta;
    } else if (control == 5) { // SLIDER POT for SPEED
      player.setDesiredVelocity(value);
    }
  }
}



void sendDummyMIDI() {
  // Send a Note On message
  int channel = 0; // MIDI channel (0-15)
  int note = 60;   // Middle C
  int velocity = 100; // Velocity (0-127)
  mb.sendNoteOn(channel, note, velocity);
  println("Sent Note On: Channel " + channel + ", Note " + note + ", Velocity " + velocity);

  // Wait and send a Note Off message for the same note
  delay(500); // Half a second
  mb.sendNoteOff(channel, note, velocity);
  println("Sent Note Off: Channel " + channel + ", Note " + note + ", Velocity " + velocity);
}


void requestPotValues() {
  mb.sendControllerChange(1, 1, 1);
}
