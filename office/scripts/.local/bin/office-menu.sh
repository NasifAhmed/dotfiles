#!/bin/bash

# --- Configuration ---
JAVA_8_PATH="/usr/lib/jvm/java-8-openjdk/bin/java"
DRJAVA_PATH="/home/nasif/Desktop/drjava.jar"
SEARCH_ROOT_DIR="/home/nasif/Desktop/WORK/Documents/Teach"

# --- Main Menu Options ---
OPT_DISPLAY="🖥️ Monitor"
OPT_JAVA="☕ DrJava"
OPT_SEARCH="🔍 Search PDF"

# --- Main Execution ---
SELECTION=$(echo -e "$OPT_DISPLAY\n$OPT_JAVA\n$OPT_SEARCH" | walker --dmenu --placeholder "Dashboard")

case $SELECTION in

    # 1. Display Manager
    "$OPT_DISPLAY")
        # Auto-detect monitors
        INTERNAL=$(hyprctl monitors all | grep "Monitor" | awk '{print $2}' | grep "eDP" | head -n 1)
        EXTERNAL=$(hyprctl monitors all | grep "Monitor" | awk '{print $2}' | grep -v "$INTERNAL" | head -n 1)
        [ -z "$INTERNAL" ] && INTERNAL="eDP-1"

        if [ -z "$EXTERNAL" ]; then
            notify-send "Display Error" "No external monitor detected."
            exit 1
        fi

        MODE=$(echo -e "Duplicate (Mirror)\nExtend (Strict WS 10)\nDisconnect Projector" | walker --dmenu --placeholder "Select Display Mode")

        case $MODE in
            "Duplicate (Mirror)")
                # Clear workspace bindings so mirroring works normally
                for i in {1..10}; do
                    hyprctl keyword workspace "$i, monitor:desc:bound"
                done

                hyprctl keyword monitor "$EXTERNAL, 1366x768@60, auto, 1, mirror, $INTERNAL"
                notify-send "Display" "Mirroring to $EXTERNAL"
                ;;

            "Extend (Strict WS 10)")
                notify-send "Display" "Extending... Focus will remain on Laptop."

                # 1. PRE-CHECK: If we are currently ON workspace 10, leave it first.
                CURRENT_WS=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
                if [ "$CURRENT_WS" -eq 10 ]; then
                    hyprctl dispatch workspace 1
                fi

                # 2. Enable the Projector
                hyprctl keyword monitor "$EXTERNAL, preferred, auto-right, 1"

                # 3. Wait for the monitor to wake up
                sleep 2

                # 4. STRICT LOCK: Force Workspace 10 to EXTERNAL (Projector)
                hyprctl keyword workspace "10, monitor:$EXTERNAL"

                # 5. STRICT LOCK: Force Workspaces 1-9 to INTERNAL (Laptop)
                for i in {1..9}; do
                    hyprctl keyword workspace "$i, monitor:$INTERNAL"
                done

                # 6. Push Workspace 10 to the Projector
                hyprctl dispatch moveworkspacetomonitor 10 "$EXTERNAL"

                # 7. CRITICAL: Force focus BACK to Laptop immediately
                hyprctl dispatch focusmonitor "$INTERNAL"

                notify-send "Display" "Extended. Workspace 10 is on Projector."
                ;;

            "Disconnect Projector")
                # 1. Pull WS 10 back to internal so windows aren't lost
                hyprctl dispatch moveworkspacetomonitor 10 "$INTERNAL"

                # 2. Reset the locks (Bind everything back to Internal)
                for i in {1..10}; do
                    hyprctl keyword workspace "$i, monitor:$INTERNAL"
                done

                # 3. Turn off projector
                hyprctl keyword monitor "$EXTERNAL, disable"
                notify-send "Display" "Disconnected $EXTERNAL"
                ;;
        esac
        ;;

    # 2. DrJava
    "$OPT_JAVA")
        notify-send "Java" "Launching DrJava..."

        # --- NEW: Force Tiling ---
        # Java apps often default to floating. This rule forces it to tile.
        hyprctl keyword windowrule "tile, title:.*DrJava.*"

        "$JAVA_8_PATH" -jar "$DRJAVA_PATH" &
        ;;

    # 3. Search All PDFs
    "$OPT_SEARCH")
        cd "$SEARCH_ROOT_DIR" || exit
        SELECTED_NAME=$(find . -type f -name "*.pdf" | sed 's!.*/!!' | walker --dmenu --placeholder "Search All Files...")

        if [ -n "$SELECTED_NAME" ]; then
            FULL_PATH=$(find . -type f -name "$SELECTED_NAME" -print -quit)
            if [ -n "$FULL_PATH" ]; then
                xdg-open "$FULL_PATH"
            fi
        fi
        ;;
esac
