import processing.sound.*;
import java.util.HashMap;

class SoundManager {
  HashMap<String, Track> tracks;
  HashMap<String, Sound> sounds;

  SoundManager() {
    tracks = new HashMap<String, Track>();
    sounds = new HashMap<String, Sound>();

    addTrack("terrain0");
    addTrack("terrain1");
    addTrack("terrain2");
    addTrack("terrain3");
    addTrack("sampleIde");
    addTrack("interference");
    addTrack("power");
    addTrack("battery0");
    addTrack("battery1");

    addSound("switch");
    addSound("sonar");

    for (String key : tracks.keySet()) {
      init(key);
    }

    // tracks.get("sampleIde").on();
  }

  void addTrack(String name, String filePath) {
    tracks.put(name, new Track(filePath));
  }

  void addTrack(String name) {
    tracks.put(name, new Track("sound/"+name+".wav"));
  }

  void addSound(String name, String filePath) {
    sounds.put(name, new Sound(filePath));
  }

  void addSound(String name) {
    sounds.put(name, new Sound("sound/"+name+".wav"));
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

  void vol(float v) {
    v = min(v, 1);
    if (v <= 0) off();
    else {
      // println(v);
      soundFile.amp(v);
    }
  }
}

class Sound {
  SoundFile soundFile;
  Sound(String path) {
    soundFile = new SoundFile(globalProcessing, path);
  }

  void play() {
    soundFile.play();
  }
}
