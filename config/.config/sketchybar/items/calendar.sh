#!/bin/bash

sketchybar --add item calendar right \
           --set calendar icon=􀉉  \
                 update_freq=1 \
                 background.height=18 \
                 script="$PLUGIN_DIR/calendar.sh"
