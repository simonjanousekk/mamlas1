#!/bin/bash
set -u

LOG_FILE="/home/ddt/startup.log"
LOCK_FILE="/tmp/mamlas-autostart.lock"
MAMLAS_DIR="/home/ddt/Documents/mamlas1"

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  echo "[$(date)] mamlas autostart already running, exiting." >> "$LOG_FILE"
  exit 0
fi

export DISPLAY=:0
export XAUTHORITY=/home/ddt/.Xauthority

echo "[$(date)] Autostart begin." >> "$LOG_FILE"

# Give desktop + USB MIDI time to appear.
sleep 20

source "$MAMLAS_DIR/mamlas.sh"

# Retry a few times in case MIDI appears late.
for i in 1 2 3 4 5; do
  echo "[$(date)] Attempt $i: launching mamlas run" >> "$LOG_FILE"
  mamlas run >> "$LOG_FILE" 2>&1
  sleep 8
done
