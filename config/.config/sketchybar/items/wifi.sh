#!/bin/bash

# WLAN Status
sketchybar --add item wifi right \
           --set wifi update_freq=10 \
                 script="$PLUGIN_DIR/wifi.sh" \
                 background.height=18 \
           --subscribe wifi wifi_change system_woke