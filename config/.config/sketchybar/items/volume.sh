#!/bin/bash

sketchybar  --add item volume right \
            --set volume script="$PLUGIN_DIR/volume.sh" \
                  background.height=18 \
            --subscribe volume volume_change \
