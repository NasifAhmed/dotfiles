#!/bin/bash

# --- CONFIGURATION ---
# Optional: Use your wide config if titles get cut off
# CONFIG_FLAG="--config $HOME/.config/walker-wide/config.toml"
CONFIG_FLAG=""

# 1. GATHER & CALCULATE RAM USAGE
# We use 'ps' to get memory (RSS in KB) and Command Name.
# We use 'awk' to sum up the memory for every process with the same name.
# We use 'sort' to put the biggest hogs at the top.
list=$(ps -e -o rss,comm | awk '
NR>1 {
    # Sum memory (column 1) for this command name (column 2)
    mem[$2] += $1
}
END {
    # Print: Total_KB Command_Name
    for (proc in mem) {
        print mem[proc], proc
    }
}' | sort -rn | head -n 20 | awk '
    BEGIN { rank=1 }
    {
        # Convert KB to readable MB or GB
        kb = $1
        if (kb > 1024*1024) {
            size = sprintf("%.1f GB", kb/1024/1024)
        } else {
            size = sprintf("%.0f MB", kb/1024)
        }
        
        # Format: "1. [1.2 GB] firefox"
        printf "%d. [%s] %s\n", rank, size, $2
        rank++
    }
')

# 2. SELECT APPLICATION
selected=$(echo "$list" | walker $CONFIG_FLAG -d --placeholder "⚠️ Select App to Kill (Grouped by RAM Usage)")

# Exit if cancelled
if [ -z "$selected" ]; then
    exit 0
fi

# 3. EXTRACT NAME
# Format was: "1. [200 MB] discord"
# We want just "discord" (the last word)
app_name=$(echo "$selected" | awk '{print $NF}')

# 4. CONFIRMATION
confirm=$(echo -e "❌ YES, Kill All '$app_name' processes\n🔙 NO, Cancel" | walker $CONFIG_FLAG -d --placeholder "Force Quit $app_name?")

if [[ "$confirm" == *"YES"* ]]; then
    # 5. EXECUTE CLEAN KILL
    # 'pkill' finds all processes with this name and kills them.
    # We try SIGTERM (15) first, then SIGKILL (9) is automatic if you run pkill -9.
    # Here we stick to standard kill (15) to let apps save data if possible.
    
    pkill -15 -x "$app_name"
    
    if [ $? -eq 0 ]; then
        notify-send "App Killer" "Successfully closed $app_name"
    else
        notify-send "App Killer" "Could not kill $app_name (Permission denied?)"
    fi
else
    notify-send "App Killer" "Cancelled."
fi
