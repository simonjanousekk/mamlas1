# MAMLAS 1

### reinstall tutorial

- disable touch
  - (https://www.waveshare.com/wiki/5inch_DSI_LCD)
  - /boot/config.txt
    - disable_touchscreen=1
- enable i2c (raspi config)
- download and install processing raspberry version
- clone github repo to ~/Documents "https://github.com/simonjanousekk/prototyp_demo.git"
- .bashrc
  ```
  alias proto="cd ~/Documents/prototyp_demo"
  alias protorun="~/Downloads/processing-4.3.2/processing ~/Documents/prototyp_demo/prototyp_processing/prototyp_processing.pde"
  bash ~startup.sh &
  ```
- startup.sh
  ```
  #!/bin/bash
  unclutter -idle 1 -root &
  ```

### todo

- [ ] signal change on position
- [ ] endscreen graphics
- [ ] driving into wall causes power usage to flicker (not a bug a feature ?)
- [ ] sample spawn distance
- [ ] load screen text ?
