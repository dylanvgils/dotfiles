#!/bin/sh
# @raycast.schemaVersion 1
# @raycast.title Toggle Caps Lock
# @raycast.mode silent
# @raycast.icon 🔠

# Runs the binary that `make all` builds from raycast/src
exec "$(dirname "$0")/../bin/toggle-caps-lock"
