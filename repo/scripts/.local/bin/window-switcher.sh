#!/bin/bash

# 1. Get windows list. 
# We use jq to format: "[WS 1] AppName: Title | <address>"
# The address is put at the end so we can easily grab it later.
list=$(hyprctl clients -j | jq -r '.[] | "[WS \(.workspace.id)] \(.class): \(.title) | <\(.address)>"')

# 2. Pipe to walker.
# We disable Pango markup (-p) to prevent weird crashes if window titles have symbols like "&" or "<"
selected=$(echo "$list" | walker --dmenu --placeholder "Switch to Window...")

# 3. Exit if cancelled
if [ -z "$selected" ]; then
    exit 0
fi

# 4. Extract Address
# We look for the pattern <0x...> at the end of the line
addr=$(echo "$selected" | awk -F'[<>]' '{print $(NF-1)}')

# 5. Focus
hyprctl dispatch focuswindow address:$addr
