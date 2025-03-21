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
    addTrack("power", 5);
    addTrack("battery0");
    addTrack("battery1");
    addTrack("ambience", 5);
    addTrack("sampleIde");
    addTrack("temperature");

    addSound("switch");
    addSound("selectTrue");
    addSound("selectFalse");
    addSound("sonar");

    for (String key : tracks.keySet()) {
      init(key);
    }

    tracks.get("ambience").on();
  }

  void addTrack(String name, int mv) {
    tracks.put(name, new Track("sound/"+name+".wav", mv));
  }

  void addTrack(String name) {
    tracks.put(name, new Track("sound/"+name+".wav"));
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

  void allTracksOff() {
    for (Track track : tracks.values()) {
      track.off();
    }
  }

  void end() {
    for (Track track : tracks.values()) {
      track.soundFile.stop();
    }
    tracks.clear();
    sounds.clear();
  }
}

class Track {
  SoundFile soundFile;
  boolean isOn = false;
  float maxVolume;
  Track(String path) {
    this(path, 1);
  }

  Track(String path, int mv) {
    soundFile = new SoundFile(globalProcessing, path);
    maxVolume = mv;
  }

  void start() {
    soundFile.loop();
    soundFile.amp(0);
  }
  void on() {
    if (!isOn) {
      soundFile.amp(maxVolume);
      isOn = true;
    }
  }

  void off() {
    if (isOn) {
      soundFile.amp(0);
      isOn = false;
    }
  }

  void vol(float v) { // recives 0..1 and remaps to 0..maxVolume. passing v>1 will set to maxVolume
    v = min(v, 1);
    if (v <= 0) off();
    else {
      // println(v);
      isOn = true;
      soundFile.amp(map(v, 0, 1, 0, maxVolume));
    }
  }
}

class Sound {
  SoundFile soundFile;
  Sound(String path) {
    soundFile = new SoundFile(globalProcessing, path);
  }

  void play() {
    if (!soundFile.isPlaying()) {
    soundFile.play();}
  }
}
