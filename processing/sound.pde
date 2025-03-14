import processing.sound.*;
import java.util.HashMap;

class SoundManager {
  HashMap<String, Track> tracks;

  SoundManager() {
    tracks = new HashMap<String, Track>();

    addSound("terrain0", "sound/terrain1.wav");
    addSound("terrain1", "sound/terrain2.wav");
    addSound("terrain2", "sound/terrain3.wav");
    addSound("terrain3", "sound/terrain4.wav");
    addSound("glitchDrum", "sound/glitch drum.wav");
    addSound("bass", "sound/bass.wav");

    for (String key : tracks.keySet()) {
      init(key);
    }
  }

  void addSound(String name, String filePath) {
    tracks.put(name, new Track(filePath));
  }

  void init(String name) {
    if (tracks.containsKey(name) && !tracks.get(name).soundFile.isPlaying()) {
      tracks.get(name).start();
    }
  }
  
  void allTerrainOff() {
    for (int i = 0; i < 4; i++) {
      tracks.get("terrain"+i).off();
    }
  }
  
  void end() {
    for (Track track : tracks.values()) {
      track.soundFile.stop();
    }
    tracks.clear();
  }
}

class Track {
  SoundFile soundFile;
  boolean isOn = false;
  Track(String path) {
    soundFile = new SoundFile(globalProcessing, path);
  }

  void start() {
    soundFile.loop();
    soundFile.amp(0);
  }
  void on() {
    soundFile.amp(1);
    isOn = true;
  }

  void off() {
    soundFile.amp(0);
    isOn = false;
  }
}
