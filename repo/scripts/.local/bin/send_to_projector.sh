#!/bin/bash

# Move the currently focused window to Workspace 10 silently
# "movetoworkspacesilent" moves the window but keeps focus on your current workspace
hyprctl dispatch movetoworkspacesilent 10

notify-send "Projector" "Window sent to Workspace 10"
