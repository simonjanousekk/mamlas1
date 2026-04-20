#!/bin/bash
set -u

TARGET_USER="ddt"
LOG_FILE="/home/ddt/startup.log"
LOCK_FILE="/tmp/mamlas-autostart.lock"
MAMLAS_DIR="/home/ddt/Documents/mamlas1"
USER_ID="$(id -u "$TARGET_USER")"

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  echo "[$(date)] mamlas autostart already running, exiting." >> "$LOG_FILE"
  exit 0
fi

export DISPLAY=:0
export XAUTHORITY=/home/ddt/.Xauthority
export HOME="/home/$TARGET_USER"
export USER="$TARGET_USER"
export LOGNAME="$TARGET_USER"
export SHELL="/bin/bash"
export XDG_RUNTIME_DIR="/run/user/$USER_ID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

echo "[$(date)] Autostart begin." >> "$LOG_FILE"

# Give desktop + USB MIDI time to appear.
sleep 20

# Wait for graphical/audio user runtime to become available.
for i in 1 2 3 4 5 6 7 8 9 10; do
  if [ -S "$XDG_RUNTIME_DIR/bus" ]; then
    echo "[$(date)] Runtime bus ready on attempt $i." >> "$LOG_FILE"
    break
  fi
  echo "[$(date)] Waiting for $XDG_RUNTIME_DIR/bus (attempt $i)." >> "$LOG_FILE"
  sleep 3
done

source "$MAMLAS_DIR/mamlas.sh"

# Retry a few times in case MIDI appears late.
for i in 1 2 3 4 5; do
  echo "[$(date)] Attempt $i: launching mamlas run" >> "$LOG_FILE"
  mamlas run >> "$LOG_FILE" 2>&1
  sleep 8
done
