#!/bin/bash

# ==============================================================================
#  OFFICE MENU - Dynamic Context
#  Integrated with Setup Script v11.0
# ==============================================================================

# --- Configuration (Dynamic Paths) ---
JAVA_8_PATH="/usr/lib/jvm/java-8-openjdk/bin/java"

# Assumes 'work' is stowed/linked to ~/Desktop/work via setup.sh
WORK_DIR="$HOME/Desktop/work"
CODEBASE_DIR="$HOME/Desktop/codebase"

# Paths relative to standard storage locations
DRJAVA_PATH="$HOME/Desktop/drjava.jar" # Default fallback
[ -f "$CODEBASE_DIR/drjava.jar" ] && DRJAVA_PATH="$CODEBASE_DIR/drjava.jar"

SEARCH_ROOT_DIR="$WORK_DIR/Documents/Teach"
STATE_FILE="/tmp/last_display_mode"

# --- HARDCODED MONITOR PORTS ---
# Change EXTERNAL to match your exact port (eDP-1 is standard for internal laptop screens)
INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1" 

# --- Main Menu Options ---
OPT_DISPLAY="🖥️ Monitor"
OPT_JAVA="☕ DrJava"
OPT_SEARCH="🔍 Search PDF"

# --- Main Execution ---
SELECTION=$(echo -e "$OPT_DISPLAY\n$OPT_JAVA\n$OPT_SEARCH" | walker --dmenu --placeholder "Dashboard")

case $SELECTION in

    # 1. Display Manager
    "$OPT_DISPLAY")
    
    MODE=$(echo -e "Mirror\nExtend\nToggle Projector" | walker --dmenu --placeholder "Select Display Mode")

    case $MODE in
        "Mirror")
            hyprctl keyword monitor "$EXTERNAL,preferred,auto,1,mirror"
            echo "Mirror" > "$STATE_FILE"
            notify-send "Display Mode" "Mirrored to $EXTERNAL"
            ;; 

        "Extend")
            hyprctl keyword monitor "$EXTERNAL,preferred,auto,1"
            echo "Extend" > "$STATE_FILE"
            notify-send "Display Mode" "Extended to $EXTERNAL"
            ;;
            
        "Toggle Projector")
            # Check if the external monitor is currently active
            if hyprctl monitors | grep -q "$EXTERNAL"; then
                # It's on, so disable it
                hyprctl keyword monitor "$EXTERNAL,disable"
                notify-send "Display Mode" "Projector Off"
            else
                # It's off, read the last state and turn it back on
                LAST_MODE=$(cat "$STATE_FILE" 2>/dev/null)
                
                if [ "$LAST_MODE" == "Extend" ]; then
                    hyprctl keyword monitor "$EXTERNAL,preferred,auto,1"
                    notify-send "Display Mode" "Projector Reconnected (Extend)"
                else
                    # Default to mirror if the state file is empty or missing
                    hyprctl keyword monitor "$EXTERNAL,preferred,auto,1,mirror,$INTERNAL"
                    echo "Mirror" > "$STATE_FILE" # Save state for next time
                    notify-send "Display Mode" "Projector Reconnected (Mirror)"
                fi
            fi
            ;;
    esac
    ;;

    # 2. DrJava
    "$OPT_JAVA")
    if [ ! -f "$DRJAVA_PATH" ]; then
        notify-send "Error" "DrJava not found at: $DRJAVA_PATH"
        exit 1
    fi

    notify-send "Java" "Launching DrJava..."

        # Force Tiling
        hyprctl keyword windowrule "tile, title:.*DrJava.*"

        "$JAVA_8_PATH" -jar "$DRJAVA_PATH" &
        ;; 

    # 3. Search All PDFs
    "$OPT_SEARCH")
    if [ ! -d "$SEARCH_ROOT_DIR" ]; then
        notify-send "Error" "Search directory not found: $SEARCH_ROOT_DIR"
        exit 1
    fi

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
