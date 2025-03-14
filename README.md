# MAMLAS-1

Maneuverable Module for Land Assessement

![mamlas1 render](website/images/mamlas_render_iso.png?raw=true)


## operation of mamlas-1

- mamlas (opens dir of git repo)
- mamlas open (opens processing sketch in processing IDE)
- mamlas dev (compiles game and runs)
- mamlas build (exports game)
- mamlas run (runs exported game (faster!))

## reinstall tutorial

- disable touch
  - https://www.waveshare.com/wiki/5inch_DSI_LCD
  - /boot/config.txt
    - disable_touchscreen=1
- enable i2c (raspi config)
- download and install processing raspberry version
- clone github repo to ~/Documents "https://github.com/simonjanousekk/prototyp_demo.git"
- change paths on config.sh if necessary
- add ignoring of changing config.sh file `git update-index --assume-unchanged config.sh`
- add autostart
  - crontab works but needs for the display to be "ready", otherwise processing screams
    - `crontab -e`
    - `@reboot sleep 10 && DISPLAY=:0 /bin/bash /home/ddt/startup.sh >> /home/ddt/cronlog.txt 2>&1`
    - startup.sh:
      - ```#!/bin/bash
        export DISPLAY=:0  # Set display for GUI applications
        echo "[$(date)] Setting up display for Processing..." >> /home/ddt/startup.log 2>&1
        source /home/ddt/Documents/mamlas1/mamlas.sh
        mamlas run >> /home/ddt/startup.log 2>&1
        ```
  - add sourcing of mamlas.sh to .bashrc to enable mamlas commands

## known bugs and how to fix them

##### Arduino Micro naming issue

- raspberry sometimes changes card number `"Micro [hw:n,0,0]"` and for whatever reason processing doesnt like that and crashes even if the name is changed in processing.pde.
- fix:
  - `sudo nano /etc/modprobe.d/alsa-base.conf`
  - `options snd-usb-audio index=2`

## todo
##### software
- [ ] signal change on position
- [ ] endscreen graphics
- [ ] driving into wall causes power usage to flicker (not a bug a feature ?)
- [ ] sample spawn distance
- [ ] load screen text ?
- [ ] cool + head - led should not blink
- [ ] radio glitch return copying to x / 2
- [ ] sample fail / sample succes -> battery add / sub
- [ ] global game time
- [ ] restart -> fix setup
- [ ] lcd bugging (why?, might be fixed by exporting)
- [x] try export
- [x] hide cursor
- [ ] highscore screen ..?
##### hardware
- [ ] resistors on bargraphs
- [ ] new knob heads..?
- [ ] top screws

