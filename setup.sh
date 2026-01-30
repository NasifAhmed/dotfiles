#!/bin/bash

# ==============================================================================
#  NASIF'S OMARCHY SETUP v10.0 (Native Edition)
#  Author: Nasif Ahmed
# ==============================================================================

# --- Configuration ---
DOTFILES_DIR="$HOME/dotfiles"
STORAGE_DIR="$DOTFILES_DIR/storage"
STORAGE_MAP="$DOTFILES_DIR/storage.conf"
BACKUP_ROOT="$HOME/dotfiles_backups"
LOG_FILE="$DOTFILES_DIR/setup.log"
PROFILE_FILE="$DOTFILES_DIR/.current_profile"
BIN_NAME="dots"
MAX_BACKUP_DAYS=14

# --- Colors & Styling Constants ---
C_PRIMARY=212    # Pink
C_SECONDARY=99   # Purple
C_ACCENT=82      # Green
C_WARN=214       # Orange
C_ERR=196        # Red
C_TEXT=255       # White
C_MUTED=240      # Grey

# --- Safety & Traps ---
trap_exit() {
    [ -t 1 ] && tput cnorm
    echo
    exit
}
trap "trap_exit" INT
set -o pipefail 

# --- 1. Logging & Error Handling ---

rotate_log() {
    local max_size=1048576 # 1MB
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt $max_size ]; then
        log "INFO" "Rotating log file"
        tail -n 1000 "$LOG_FILE" > "$LOG_FILE.tmp"
        mv "$LOG_FILE.tmp" "$LOG_FILE"
    fi
}

log() {
    local level=$1; local msg=$2
    local timestamp=$(date "+%H:%M:%S")
    # Strip color codes for log file
    local clean_msg=$(echo "$msg" | sed 's/\x1b\[[0-9;]*m//g')
    echo "[$timestamp] [$level] $clean_msg" >> "$LOG_FILE"
}

die() {
    log "FATAL" "$1"
    if command -v gum &> /dev/null;
 then
        gum style --border double --border-foreground "$C_ERR" --foreground "$C_ERR" --align center --width 50 --margin "1" "CRITICAL FAILURE" "$1"
    else
        echo "CRITICAL FAILURE: $1"
    fi
    exit 1
}

safe_exec() {
    "$@" 2>> "$LOG_FILE"
    local status=$?
    if [ $status -ne 0 ]; then
        log "ERROR" "Cmd '$1' failed (Exit: $status)"
        return $status
    fi
    return 0
}

# --- 2. Environment Bootstrap (Omarchy OS Exclusive) ---

ensure_environment() {
    # 0. Rotate log file
    rotate_log

    # 1. Check for Pacman (Core Sanity Check)
    if ! command -v pacman &> /dev/null; then
        die "This script requires Omarchy OS (Arch-based). 'pacman' was not found."
    fi

    # 2. Check & Install Dependencies
    local pkgs=("git" "stow" "gum" "rsync" "diffutils")
    local missing_pkgs=()

    for pkg in "${pkgs[@]}"; do
        local cmd_name="$pkg"
        [ "$pkg" == "diffutils" ] && cmd_name="diff"
        
        if ! command -v "$cmd_name" &> /dev/null;
 then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        if command -v gum &> /dev/null;
 then
            gum style --foreground "$C_WARN" "📦 Installing missing Omarchy tools: ${missing_pkgs[*]}"
        else
            echo "📦 Installing missing Omarchy tools: ${missing_pkgs[*]}"
        fi

        # Omarchy is Arch-based -> Use Pacman
        if sudo pacman -S --noconfirm "${missing_pkgs[@]}"; then
            log "INFO" "Installed dependencies: ${missing_pkgs[*]}"
        else
            die "Failed to install dependencies via pacman."
        fi
    fi

    # 3. Setup Directories & Path
    mkdir -p "$HOME/.local/bin" "$STORAGE_DIR" "$BACKUP_ROOT"
    [ ! -f "$STORAGE_MAP" ] && touch "$STORAGE_MAP"

    SCRIPT_PATH=$(realpath "$0")
    TARGET_LINK="$HOME/.local/bin/$BIN_NAME"
    if [ ! -L "$TARGET_LINK" ] || [ "$(readlink -f "$TARGET_LINK")" != "$SCRIPT_PATH" ]; then
        ln -sf "$SCRIPT_PATH" "$TARGET_LINK"
    fi

    if [[ ":$PATH:" != ":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # 4. Cleanup old backups
    find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +$MAX_BACKUP_DAYS -exec rm -rf {} + 2>/dev/null
}

# --- 3. Reporting Logic ---

view_system_status() {
    local report_file="/tmp/dots_status_report.txt"
    {
        gum style --foreground "$C_PRIMARY" --bold "🔮 NASIF'S OMARCHY STATUS"
        echo "==================================="

        local current_prof="None"
        [ -f "$PROFILE_FILE" ] && current_prof=$(cat "$PROFILE_FILE")
        echo -e "\n🔹 ACTIVE PROFILE: $current_prof\n"

        echo "🔹 CONFIG PACKAGES:"
        echo "   [Common]"
        if [ -d "$DOTFILES_DIR/common" ]; then
            ls -1 "$DOTFILES_DIR/common" | sed 's/^/   - /'
        else
            echo "   (None)"
        fi

        if [[ "$current_prof" != "None"* ]]; then
            local target_dir=""
            [[ "$current_prof" == *"Home"* ]] && target_dir="home"
            [[ "$current_prof" == *"Office"* ]] && target_dir="office"

            echo -e "\n   [Specific: $target_dir]"
            if [ -d "$DOTFILES_DIR/$target_dir" ]; then
                ls -1 "$DOTFILES_DIR/$target_dir" | sed 's/^/   - /'
            fi
        fi

        echo -e "\n🔹 VAULT (Tracked Folders):"
        if [ -f "$STORAGE_MAP" ] && [ -s "$STORAGE_MAP" ]; then
            while IFS='|' read -r name path || [ -n "$name" ]; do
                [[ "$name" =~ ^#.*$ ]] && continue
                [ -z "$name" ] && continue
                echo "   • $name  ->  $path"
            done < "$STORAGE_MAP"
        else
            echo "   (Vault is empty)"
        fi
    } > "$report_file"

    gum pager < "$report_file"
}

# --- 4. Config Logic (Stow) ---

stow_config_package() {
    local rel_path=$1
    local parent_dir=$(dirname "$rel_path")
    local pkg_name=$(basename "$rel_path")
    local stow_dir="$DOTFILES_DIR/$parent_dir" 

    # Capture output to find conflicts
    local conflict_output
    conflict_output=$(stow -d "$stow_dir" -t "$HOME" -n "$pkg_name" 2>&1)
    
    # Regex to catch standard stow conflict messages
    local conflicts
    conflicts=$(echo "$conflict_output" | grep -oE "(over existing target|existing target is) .*" | sed -E 's/.*over existing target (.*) since.*/\1/; s/.*existing target is (.*)/\1/')

    if [ -n "$conflicts" ] && [ "$conflicts" != " " ]; then
        local backup_ts="$BACKUP_ROOT/conflict_configs_$(date +%Y%m%d_%H%M%S)"

        echo "$conflicts" | while read conflict;
 do
            conflict=$(echo "$conflict" | xargs)
            [ -z "$conflict" ] && continue

            local real="$HOME/$conflict"
            local source_file="$stow_dir/$pkg_name/$conflict"

            if [ -e "$real" ] && [ ! -L "$real" ]; then
                if [ -f "$source_file" ] && cmp -s "$real" "$source_file"; then
                    rm "$real"
                    log "INFO" "Replaced identical file: $conflict"
                else
                    mkdir -p "$backup_ts/$(dirname "$conflict")"
                    mv "$real" "$backup_ts/$conflict"
                    log "SAFETY" "Backed up: $conflict"
                fi
            elif [ -L "$real" ]; then 
                # If it's a dead or wrong link, remove it
                rm "$real"
                log "INFO" "Removed broken/wrong link: $conflict"
            fi
        done
    fi

    stow -d "$stow_dir" -t "$HOME" -R "$pkg_name" >> "$LOG_FILE" 2>&1
    local res=$?
    [ $res -ne 0 ] && log "ERROR" "Stow failed for $pkg_name (Exit: $res)"
    return $res
}

apply_configs() {
    local type=$1; local count=0
    log "INFO" "Applying Configs: $type"

    if [ -d "$DOTFILES_DIR/common" ]; then
        for folder in "$DOTFILES_DIR/common"/*;
 do
            [ -d "$folder" ] && { stow_config_package "common/$(basename "$folder")"; ((count++)); }
        done
    fi

    local target_dir=""
    [[ "$type" == *"Home"* ]] && target_dir="home"
    [[ "$type" == *"Office"* ]] && target_dir="office"

    if [ -d "$DOTFILES_DIR/$target_dir" ]; then
        for folder in "$DOTFILES_DIR/$target_dir"/*;
 do
            [ -d "$folder" ] && { stow_config_package "$target_dir/$(basename "$folder")"; ((count++)); }
        done
    fi
    [ $count -eq 0 ] && LAST_MSG="⚠️  No packages found!" || LAST_MSG="✅ Applied $count config packages."
}

unstow_configs() {
    for d in common home office;
 do
        if [ -d "$DOTFILES_DIR/$d" ]; then
            ls "$DOTFILES_DIR/$d" | xargs -I {} stow -d "$DOTFILES_DIR/$d" -t "$HOME" -D "{}" 2>/dev/null
        fi
    done
}

add_new_config() {
    local target_path=$(gum input --cursor.foreground "$C_PRIMARY" --placeholder "/home/user/.config/app" --header "Add Config (Esc to cancel)")
    if [ -z "$target_path" ]; then return; fi
    target_path="${target_path/#\~/$HOME}"

    if [ ! -e "$target_path" ]; then LAST_MSG="❌ Path invalid."; return; fi
    if [[ "$target_path" != "$HOME"* ]]; then LAST_MSG="❌ Must be in Home dir."; return; fi
    if [ -L "$target_path" ]; then LAST_MSG="❌ Already a symlink."; return; fi

    local category=$(gum choose --cursor.foreground "$C_PRIMARY" --header "Select Scope" "Common (All Machines)" "Home PC Only" "Office Laptop Only")
    if [ -z "$category" ]; then return; fi

    local repo_subdir="common"
    [[ "$category" == "Home PC Only" ]] && repo_subdir="home"
    [[ "$category" == "Office Laptop Only" ]] && repo_subdir="office"

    local rel_path="${target_path#$HOME/}"
    local pkg_name=$(basename "$target_path") 
    local user_pkg_name=$(gum input --value "$pkg_name" --header "Package Name")
    [ -z "$user_pkg_name" ] && user_pkg_name="$pkg_name"

    local repo_pkg_root="$DOTFILES_DIR/$repo_subdir/$user_pkg_name"
    if [ -d "$repo_pkg_root" ]; then LAST_MSG="❌ Package '$user_pkg_name' exists."; return; fi

    local repo_final_dest="$repo_pkg_root/$rel_path" 

    gum confirm "Move '$target_path' to $repo_subdir?" || return
    gum spin --spinner dot --title "Moving..." -- sleep 0.5

    if [ -d "$target_path" ]; then
        mkdir -p "$(dirname "$repo_final_dest")"
        mv "$target_path" "$(dirname "$repo_final_dest")/"
    else
        mkdir -p "$(dirname "$repo_final_dest")"
        mv "$target_path" "$repo_final_dest"
    fi

    stow_config_package "$repo_subdir/$user_pkg_name"
    if [ $? -eq 0 ]; then LAST_MSG="✅ Config '$user_pkg_name' added."; else LAST_MSG="⚠️ Added but stow failed."; fi
}

# --- 5. Storage Logic (Vault) ---

handle_single_storage_item() {
    local item_name=$1; local target_path=$2
    local repo_path="$STORAGE_DIR/$item_name"

    # Migration Mode: If target exists and is NOT a symlink, ingest it into repo
    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
        gum spin --spinner globe --title "Ingesting $item_name..." -- sleep 0.5
        local backup_loc="$BACKUP_ROOT/pre_link_$(date +%Y%m%d_%H%M%S)/$item_name"
        mkdir -p "$(dirname "$backup_loc")"
        cp -r "$target_path" "$backup_loc"
        
        if [ -d "$target_path" ]; then
            safe_exec rsync -avu "$target_path/" "$repo_path/"
        else
            mkdir -p "$(dirname "$repo_path")"
            safe_exec cp -u "$target_path" "$repo_path"
        fi
        rm -rf "$target_path"
    fi

    if [ ! -e "$repo_path" ]; then return; fi
    
    # Linking Mode: Target shouldn't exist or should be a symlink
    if [ ! -e "$target_path" ]; then
        mkdir -p "$(dirname "$target_path")"
        ln -sf "$repo_path" "$target_path"
        log "OK" "Linked Vault: $item_name"
    elif [ -L "$target_path" ]; then
        # If it's a symlink, check where it points
        if [ "$(readlink -f "$target_path")" != "$(readlink -f "$repo_path")" ]; then
             rm "$target_path"
             ln -sf "$repo_path" "$target_path"
             log "FIX" "Relinked Vault: $item_name"
        fi
    else
         log "WARN" "Conflict for $item_name. Target is a file/dir, not a link."
    fi
}

apply_storage() {
    if [ ! -f "$STORAGE_MAP" ]; then LAST_MSG="ℹ️ No storage map found."; return; fi
    local count=0
    while IFS='|' read -r item_name target_path || [ -n "$item_name" ]; do
        [[ "$item_name" =~ ^#.*$ ]] && continue
        [ -z "$item_name" ] && continue
        target_path="${target_path/#\~/$HOME}"
        handle_single_storage_item "$item_name" "$target_path"
        ((count++))
    done < "$STORAGE_MAP"
    [ -z "$LAST_MSG" ] && LAST_MSG="✅ Synced $count Vault items."
}

unstow_storage() {
    [ -f "$STORAGE_MAP" ] && while IFS='|' read -r item_name target_path || [ -n "$item_name" ]; do
        [[ "$item_name" =~ ^#.*$ ]] && continue
        target_path="${target_path/#\~/$HOME}"
        [ -L "$target_path" ] && rm "$target_path"
    done < "$STORAGE_MAP"
}

add_to_storage() {
    local target_path=$(gum input --cursor.foreground "$C_PRIMARY" --placeholder "/abs/path" --header "Add to Vault")
    if [ -z "$target_path" ]; then return; fi
    target_path="${target_path/#\~/$HOME}"

    if [ ! -e "$target_path" ]; then LAST_MSG="❌ Invalid path."; return; fi
    if [ -L "$target_path" ]; then LAST_MSG="❌ Already linked."; return; fi

    local item_name=$(basename "$target_path")
    if grep -q "|$target_path$" "$STORAGE_MAP"; then LAST_MSG="⚠️ Already tracked."; return; fi

    echo "$item_name|$target_path" >> "$STORAGE_MAP"
    handle_single_storage_item "$item_name" "$target_path"
    LAST_MSG="✅ Added $item_name to Vault."
}

# --- 6. Power Sync ---

power_sync() {
    local scope=$1
    if [ -z "$scope" ]; then return; fi
    cd "$DOTFILES_DIR" || return

    local BRANCH=$(git branch --show-current)
    [ -z "$BRANCH" ] && { LAST_MSG="❌ Git Detached HEAD."; return; }

    if [[ -n $(git status -s) ]]; then
        gum spin --spinner points --title "Committing..." -- git add .
        safe_exec git commit -m "Auto-sync $(hostname): $(date '+%Y-%m-%d %H:%M')"
    fi

    gum spin --spinner points --title "Fetching..." -- git fetch origin
    if [ $? -ne 0 ]; then LAST_MSG="❌ Remote unreachable."; return; fi

    local LOCAL=$(git rev-parse HEAD)
    local REMOTE=$(git rev-parse origin/$BRANCH)
    local BASE=$(git merge-base HEAD origin/$BRANCH)
    local RELOAD=false

    if [ "$LOCAL" = "$REMOTE" ]; then
        LAST_MSG="✨ System is up to date."
    elif [ "$LOCAL" = "$BASE" ]; then
        gum spin --spinner points --title "⬇️  Pulling..." -- git pull origin "$BRANCH"
        RELOAD=true
    elif [ "$REMOTE" = "$BASE" ]; then
        gum spin --spinner points --title "⬆️  Pushing..." -- git push origin "$BRANCH"
        LAST_MSG="☁️  Pushed to cloud."
    else
        if gum confirm "⚠️ Conflict! Force merge (remote wins)?"; then
             gum spin --title "Resolving..." -- git pull origin "$BRANCH" --strategy-option=theirs
             gum spin --title "Pushing..." -- git push origin "$BRANCH"
             RELOAD=true
        else
            LAST_MSG="⚠️ Sync paused."
            return
        fi
    fi

    if [ "$RELOAD" = true ] && [ -f "$PROFILE_FILE" ]; then
        local prof=$(cat "$PROFILE_FILE")
        [[ "$scope" == "All" || "$scope" == "Configs" ]] && { unstow_configs; apply_configs "$prof"; }
        [[ "$scope" == "All" || "$scope" == "Storage" ]] && apply_storage
        
        if command -v hyprctl &> /dev/null; then
            log "INFO" "Reloading Hyprland..."
            hyprctl reload
        fi

        LAST_MSG="✅ Synced & Reloaded."
    fi
}

execute_setup() {
    local profile=$1; local scope=$2
    if [ -z "$profile" ] || [ -z "$scope" ]; then LAST_MSG="❌ Cancelled"; return; fi
    echo "$profile" > "$PROFILE_FILE"
    [[ "$scope" == "All" || "$scope" == "Configs" ]] && { unstow_configs; apply_configs "$profile"; }
    [[ "$scope" == "All" || "$scope" == "Storage" ]] && apply_storage

    if command -v hyprctl &> /dev/null; then
        log "INFO" "Reloading Hyprland..."
        hyprctl reload
    fi
}

# --- 7. UI Helpers ---

get_greeting() {
    local h=$(date +%H)
    if [ $h -lt 12 ]; then echo "Good Morning";
    elif [ $h -lt 18 ]; then echo "Good Afternoon";
    else echo "Good Evening"; fi
}

draw_dashboard() {
    clear
    local greeting="$(get_greeting), Nasif"
    local branch=$(git branch --show-current 2>/dev/null || echo "Unknown")
    local status="Clean ✨"
    [[ -n $(git status -s) ]] && status="Dirty ✏️"
    local vault_count=$(wc -l < "$STORAGE_MAP" 2>/dev/null || echo 0)

    # Header Card
    gum style \
        --border double --margin "1" --padding "1 2" --border-foreground "$C_PRIMARY" --align center \
        "$(gum style --foreground "$C_PRIMARY" --bold "🔮 NASIF'S OMARCHY SETUP")" \
        "" \
        "$(gum style --foreground "$C_SECONDARY" "👤 $greeting  |  💻 $(hostname)")" \
        "$(gum style --foreground "$C_SECONDARY" "🔧 Profile: $CURRENT_PROFILE  |  🌿 Branch: $branch")"

    # Status Bar
    gum style --foreground "$C_MUTED" --align center "📦 Vault Items: $vault_count  |  📝 Git State: $status"
    echo "" 
    
    # Recent Logs
    gum style --foreground "$C_MUTED" -- "--- Recent Activity ---"
    tail -n 10 "$LOG_FILE" | sed 's/^/  /' | cut -c 1-60
    echo "" 

    # Message Area
    if [ -n "$LAST_MSG" ]; then
        gum style --foreground "$C_ACCENT" --bold --align center --border normal --border-foreground "$C_ACCENT" --padding "0 2" "$LAST_MSG"
        echo "" 
    fi
}

# --- 8. Main Loop ---

ensure_environment
LAST_MSG="Welcome back, Nasif."

while true;
 do
    CURRENT_PROFILE="None"
    [ -f "$PROFILE_FILE" ] && CURRENT_PROFILE=$(cat "$PROFILE_FILE")

    draw_dashboard

    ACTION=$(gum choose --cursor.foreground "$C_PRIMARY" --header "Select Operation" \
        "🚀  Sync System" \
        "🎭  Switch Profile" \
        "📊  System Status" \
        "➕  Add Config (Stow)" \
        "📦  Add to Vault" \
        "🧹  Uninstall/Reset" \
        "📜  View Logs" \
        "🔎  Filter Logs" \
        "📝  Open Log in Editor" \
        "👋  Exit")

    case "$ACTION" in
        "🚀  Sync System")
            SCOPE=$(gum choose --cursor.foreground "$C_PRIMARY" "All" "Configs Only" "Storage Only")
            [ -n "$SCOPE" ] && power_sync "$SCOPE" || LAST_MSG="❌ Cancelled"
            ;; 
        "🎭  Switch Profile")
            PROFILE=$(gum choose --cursor.foreground "$C_PRIMARY" --header "Select Machine" "Home PC" "Office Laptop")
            if [ -n "$PROFILE" ]; then
                SCOPE=$(gum choose --cursor.foreground "$C_PRIMARY" --header "Scope" "All" "Configs Only" "Storage Only")
                [ -n "$SCOPE" ] && execute_setup "$PROFILE" "$SCOPE" || LAST_MSG="❌ Cancelled"
            else
                LAST_MSG="❌ Cancelled"
            fi
            ;; 
        "📊  System Status") view_system_status ;; 
        "➕  Add Config (Stow)") add_new_config ;; 
        "📦  Add to Vault") add_to_storage ;; 
        "🧹  Uninstall/Reset")
            SCOPE=$(gum choose --cursor.foreground "$C_ERR" "All" "Configs Only" "Storage Only")
            if [ -n "$SCOPE" ] && gum confirm "Unlink $SCOPE? This is destructive."; then
                [[ "$SCOPE" == "All" || "$SCOPE" == "Configs" ]] && unstow_configs
                [[ "$SCOPE" == "All" || "$SCOPE" == "Storage" ]] && unstow_storage
                LAST_MSG="🗑️ Unlinked $SCOPE."
            else
                LAST_MSG="Cancelled."
            fi
            ;; 
        "📜  View Logs") gum pager < "$LOG_FILE" ;; 
        "🔎  Filter Logs")
            LEVEL=$(gum choose "INFO" "WARN" "ERROR" "FATAL" "SAFETY" "OK" "FIX")
            if [ -n "$LEVEL" ]; then
                grep "\[$LEVEL\]" "$LOG_FILE" | gum pager
            fi
            ;;
        "📝  Open Log in Editor")
            if [ -n "$EDITOR" ]; then
                "$EDITOR" "$LOG_FILE"
            else
                # fallback to less
                less "$LOG_FILE"
            fi
            ;;
        "👋  Exit") 
            clear
            gum style --foreground "$C_PRIMARY" "See you later, Nasif! 👋"
            exit 0 
            ;; 
    esac
done
