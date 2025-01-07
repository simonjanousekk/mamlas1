class Info {
  constructor() {
    this.info = document.getElementById("info");
    this.samples = document.createElement("p");
    this.pos = document.createElement("p");
    this.fps = document.createElement("p");
    this.distanceToSample = document.createElement("p");
    this.relevantWalls = document.createElement("p");
    this.hardMode = document.getElementById("checkbox");
    this.info.appendChild(this.samples);
    this.info.appendChild(this.pos);
    this.info.appendChild(this.fps);
    this.info.appendChild(this.relevantWalls);
    this.info.appendChild(this.distanceToSample);
  }

  update() {
    this.pos.innerText = `x: ${floor(player.pos.x)}, y: ${floor(player.pos.y)}`;
    this.samples.innerText = `samples: ${player.samplesCollected}`;
    this.fps.innerText = `fps: ${floor(frameRate())}`;
    this.relevantWalls.innerText = `relevant walls: ${relevantWalls.length}`;
    this.distanceToSample.innerText = `distance to sample: ${floor(
      player.pos.dist(selectedSample.pos)
    )}`;
  }

  getHardMode() {
    return !this.hardMode.checked;
  }
}
