let player;
let mapa;
let minimapa;
let samples = [];

let relevantWalls = [];
let walls = [];
let rays = [];

let kompas;
let kompasSample;
let radar;
let info;

let rayCount = 36;
let selectedSample;
let selectedSampleIndex = 0;

function setup() {
  let canvas = createCanvas(800, 500);
  canvas.parent("canvas");

  // setup
  mapa = new Mapa(1000, 1000, 10);
  minimapa = new MiniMapa(width - 200, height - 200, 200, mapa);
  let playerStart = randomPosOutsideWalls();
  player = new Player(playerStart.x, playerStart.y);

  for (let i = 0; i < 4; i++) {
    let sampleStart = randomPosOutsideWalls();
    samples.push(new Sample(sampleStart.x, sampleStart.y));
  }
  samples[selectedSampleIndex].selected = true;
  selectedSample = samples[selectedSampleIndex];

  kompas = new Kompas(width - 100, 100, 80);
  kompasSample = new Kompas(width - 100, 100, 25);
  radar = new Radar(width - 100, 100, 80);
  info = new Info();

  // generate rays
  for (let i = 0; i < rayCount; i++) {
    rays.push(
      new Ray(player.pos.x, player.pos.y, radians(i * (360 / rayCount)))
    );
  }
}

// let firstClickPos;
function draw() {
  background(50);

  player.handleInput();

  let wallDistance = rays[0]._rayLength * 2;
  relevantWalls = walls.filter((wall) => {
    return (
      (wall.pos1.x - player.pos.x) * (wall.pos1.x - player.pos.x) +
        (wall.pos1.y - player.pos.y) * (wall.pos1.y - player.pos.y) <
        wallDistance * wallDistance ||
      (wall.pos2.x - player.pos.x) * (wall.pos2.x - player.pos.x) +
        (wall.pos2.y - player.pos.y) * (wall.pos2.y - player.pos.y) <
        wallDistance * wallDistance
    );
  });

  let offsetX = width / 2 - player.pos.x;
  let offsetY = height / 2 - player.pos.y;

  push();
  translate(width / 2, height / 2);
  rotate(-player.angle - (PI / 4) * 3);
  translate(-player.pos.x, -player.pos.y);
  // translate(offsetX, offsetY);

  // rect(0, 0, mapa._size.x, mapa._size.y);
  if (info.getHardMode()) {
    // mapa.display();
  }

  for (let ray of rays) {
    ray.update(player.pos, player.angle);
    let intersections = [];
    // for (let rock of rocks) {
    //   intersections.push(...ray.cast(rock.walls));
    // }
    intersections.push(...ray.cast(relevantWalls));
    ray.findShortestIntersection(intersections);
    if (info.getHardMode()) {
      ray.display();
    }
  }

  for (let wall of relevantWalls) {
    if (info.getHardMode()) {
      wall.display();
    }
    player.collide(wall);
  }

  for (let sample of samples) {
    if (info.getHardMode()) {
      sample.display();
    }
    if (sample.sampleCollected()) {
      sample.collect();
    }
  }

  if (info.getHardMode()) {
    player.display();
  }
  player.move();

  pop();

  kompas.update(player.angle);
  kompas.display();
  let angleToSample =
    atan2(
      selectedSample.pos.y - player.pos.y,
      selectedSample.pos.x - player.pos.x
    ) -
    PI / 4;
  kompasSample.update(angleToSample);
  kompasSample.display();
  radar.update(rays);
  radar.display();
  info.update();
  minimapa.display();
}

function keyPressed() {
  if (key === "q") {
    for (let sample of samples) {
      if (sample.selected) {
        sample.selected = false;
      }
    }
    selectedSampleIndex =
      (selectedSampleIndex - 1 + samples.length) % samples.length;
    selectedSample = samples[selectedSampleIndex];
    selectedSample.selected = true;
  } else if (key === "e") {
    for (let sample of samples) {
      if (sample.selected) {
        sample.selected = false;
      }
    }
    selectedSampleIndex = (selectedSampleIndex + 1) % samples.length;
    selectedSample = samples[selectedSampleIndex];
    selectedSample.selected = true;
  }
}

function isCircleLineColliding(circle, lineStart, lineEnd) {
  const cx = circle.pos.x;
  const cy = circle.pos.y;
  const r = circle._radius;
  const x1 = lineStart.x;
  const y1 = lineStart.y;
  const x2 = lineEnd.x;
  const y2 = lineEnd.y;

  const lineLengthSq = (x2 - x1) ** 2 + (y2 - y1) ** 2;
  const t = ((cx - x1) * (x2 - x1) + (cy - y1) * (y2 - y1)) / lineLengthSq;
  const tClamped = Math.max(0, Math.min(1, t));
  const closestX = x1 + tClamped * (x2 - x1);
  const closestY = y1 + tClamped * (y2 - y1);
  const distanceSq = (cx - closestX) ** 2 + (cy - closestY) ** 2;
  return distanceSq <= r ** 2;
}

function lineLineIntersection(line1Start, line1End, line2Start, line2End) {
  const x1 = line1Start.x;
  const y1 = line1Start.y;
  const x2 = line1End.x;
  const y2 = line1End.y;
  const x3 = line2Start.x;
  const y3 = line2Start.y;
  const x4 = line2End.x;
  const y4 = line2End.y;

  const denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
  if (denominator === 0) {
    return null;
  }

  const t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator;
  const u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denominator;

  if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
    return createVector(x1 + t * (x2 - x1), y1 + t * (y2 - y1));
  }

  return null;
}

function randomPosOutsideWalls() {
  let pos = createVector(random(mapa._size.x), random(mapa._size.y));
  while (
    mapa.grid[floor(pos.x / mapa._cellSize)][floor(pos.y / mapa._cellSize)]
      .state
  ) {
    pos = createVector(random(mapa._size.x), random(mapa._size.y));
  }
  return pos;
}
