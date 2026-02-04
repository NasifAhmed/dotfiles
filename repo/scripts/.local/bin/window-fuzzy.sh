#!/bin/bash

# 1. Fetch all clients in JSON format
# 2. Parse strictly with jq to handle special characters safely
# 3. Format into: [WS] APP (Padded) | TITLE (Full) ...... ADDRESS
hyprctl clients -j | jq -r '.[] | "\(.workspace.id)\t\(.class)\t\(.title)\t\(.address)"' | while IFS=$'\t' read -r ws class title addr; do

    # --- DYNAMIC FORMATTING ---
    # 1. Workspace: Bracketed and padded to 4 chars (e.g., "[1] ")
    f_ws=$(printf "[%s]" "$ws")

    # 2. Class (App Name): Truncated to 14 chars, padded to 15.
    # This creates a solid vertical "sidebar" line.
    f_class=$(printf "%-15.15s" "$class")

    # 3. Title: We leave this FULL length so you can search any word in it.
    # We strip standard " - AppName" suffixes generically if they exist at the end of the string
    # (e.g. "My Document - LibreOffice" becomes "My Document")
    f_title=$(echo "$title" | sed "s/ - $class$//I")

    # 4. Icon: Simple visual separator
    sep="│"

    # --- OUTPUT GENERATION ---
    # The address is hidden after 100 spaces so it doesn't clutter the UI
    printf "%-5s %s %s %-80s %100s\n" "$f_ws" "$f_class" "$sep" "$f_title" "$addr"

done | walker --dmenu \
    | awk '{print $NF}' | xargs -r -I{} hyprctl dispatch focuswindow address:{}
