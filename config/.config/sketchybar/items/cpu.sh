#!/bin/bash

sketchybar --add item cpu right \
           --set cpu  update_freq=1 \
                      icon=􀧓  \
                      background.height=18 \
                      script="$PLUGIN_DIR/cpu.sh"