#!/bin/bash

# --- 1. Get Your Current Location ---
# We find exactly which workspace YOU are looking at right now.
CURRENT_WS=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')

# --- 2. Get Windows on Projector (WS 10) ---
# Format: "Window Title (App Class) <invisible_separator> Address"
# We use a distinct delimiter ":::" to separate the name from the ID
WINDOWS=$(hyprctl clients -j | jq -r '.[] | select(.workspace.id == 10) | "\(.title) (\(.class)) ::: \(.address)"')

if [ -z "$WINDOWS" ]; then
    notify-send "Projector" "Workspace 10 is empty."
    exit 0
fi

# --- 3. Select Window ---
# We show the list. Walker usually displays the whole line, but the ID is at the end.
SELECTION=$(echo "$WINDOWS" | walker --dmenu --placeholder "Pull from Projector...")

if [ -n "$SELECTION" ]; then
    # --- 4. Extract the Address ---
    # We take the part AFTER the " ::: " separator
    ADDRESS=$(echo "$SELECTION" | awk -F ' ::: ' '{print $2}')

    # --- 5. Debug Check (Optional) ---
    # If retrieval still fails, uncomment the next line to see what address it found:
    # notify-send "Debug" "Moving $ADDRESS to Workspace $CURRENT_WS"

    # --- 6. Execute Move ---
    # We specify: Move window [ADDRESS] to workspace [CURRENT_WS]
    hyprctl dispatch movetoworkspace "$CURRENT_WS,address:$ADDRESS"

    notify-send "Projector" "Window retrieved."
fi
