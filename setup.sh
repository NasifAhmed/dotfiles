#!/bin/bash

# ==============================================================================
#  NASIF'S OMARCHY SETUP v11.0 (Self-Sustaining Edition)
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

# --- 2. Environment Bootstrap ---

ensure_environment() {
    rotate_log

    if ! command -v pacman &> /dev/null; then
        die "This script requires Omarchy OS (Arch-based). 'pacman' was not found."
    fi

    local pkgs=("git" "stow" "gum" "rsync" "diffutils")
    local missing_pkgs=()

    for pkg in "${pkgs[@]}"; do
        local cmd_name="$pkg"
        [ "$pkg" == "diffutils" ] && cmd_name="diff"
        if ! command -v "$cmd_name" &> /dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        echo "📦 Installing missing Omarchy tools: ${missing_pkgs[*]}"
        if sudo pacman -S --noconfirm "${missing_pkgs[@]}"; then
            log "INFO" "Installed dependencies: ${missing_pkgs[*]}"
        else
            die "Failed to install dependencies via pacman."
        fi
    fi

    local LOCAL_BIN="$HOME/.local/bin"
    mkdir -p "$LOCAL_BIN" "$STORAGE_DIR" "$BACKUP_ROOT"
    [ ! -f "$STORAGE_MAP" ] && touch "$STORAGE_MAP"

    # Ensure PATH in current session
    if [[ ":$PATH:" != ":$LOCAL_BIN:"* ]]; then
        export PATH="$LOCAL_BIN:$PATH"
        log "INFO" "Added .local/bin to current session PATH"
    fi

    # Ensure PATH persistence in shell configs
    local PATH_CMD='export PATH="$HOME/.local/bin:$PATH"'
    for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$shell_rc" ]; then
            if ! grep -Fq "$LOCAL_BIN" "$shell_rc"; then
                echo "" >> "$shell_rc"
                echo "# Added by Omarchy Setup" >> "$shell_rc"
                echo "$PATH_CMD" >> "$shell_rc"
                log "INFO" "Appended local/bin to PATH in $shell_rc"
            fi
        fi
    done

    SCRIPT_PATH=$(realpath "$0")
    TARGET_LINK="$LOCAL_BIN/$BIN_NAME"
    if [ ! -L "$TARGET_LINK" ] || [ "$(readlink -f "$TARGET_LINK")" != "$SCRIPT_PATH" ]; then
        ln -sf "$SCRIPT_PATH" "$TARGET_LINK"
    fi

    find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +$MAX_BACKUP_DAYS -exec rm -rf {} + 2>/dev/null
}

# --- 3. Helpers ---

get_profiles() {
    # Lists directories that are not 'storage', 'scripts', 'test', etc.
    find "$DOTFILES_DIR" -maxdepth 1 -mindepth 1 -type d \
        ! -name ".*" \
        ! -name "storage" \
        ! -name "scripts" \
        -exec basename {} \; | sort
}

# --- 4. Config Logic (Stow) ---

# --- 4. Config Logic (Stow) ---

SESSION_REPORT=""

add_report() {
    SESSION_REPORT="${SESSION_REPORT}$1\n"
}

stow_config_package() {
    local profile=$1
    local pkg_name=$2
    local stow_dir="$DOTFILES_DIR/$profile" 

    log "INFO" "Stowing package: $pkg_name"

    # 1. Dry-run to catch conflicts
    local conflict_output
    conflict_output=$(stow -d "$stow_dir" -t "$HOME" -n "$pkg_name" 2>&1)
    
    if [[ "$conflict_output" == *"existing target"* ]]; then
        log "WARN" "Conflicts detected in $pkg_name, attempting resolution..."
        local backup_ts="$BACKUP_ROOT/conflict_configs_$(date +%Y%m%d_%H%M%S)"
        local temp_report=$(mktemp)
        
        # Extract conflicting file paths
        echo "$conflict_output" | grep -iE "existing target" | sed -E '
            s/.*over existing target (.*) since.*/\1/
            s/.*existing target is not owned by stow: (.*)/\1/
            s/.*existing target is neither a link nor a directory: (.*)/\1/
        ' | while read conflict; do
            conflict=$(echo "$conflict" | xargs)
            [ -z "$conflict" ] && continue

            local real="$HOME/$conflict"
            local source_file="$stow_dir/$pkg_name/$conflict"

            if [ -e "$real" ] && [ ! -L "$real" ]; then
                if [ -f "$source_file" ] && cmp -s "$real" "$source_file"; then
                    rm "$real"
                    log "INFO" "Resolved conflict (identical content): $conflict"
                    echo "  [FIX] Replaced identical: $conflict" >> "$temp_report"
                else
                    mkdir -p "$backup_ts/$(dirname "$conflict")"
                    mv "$real" "$backup_ts/$conflict"
                    log "SAFETY" "Conflict backed up to $backup_ts: $conflict"
                    echo "  [BAK] Backed up: $conflict" >> "$temp_report"
                fi
            elif [ -L "$real" ]; then 
                rm "$real"
                log "INFO" "Removed conflicting symlink: $conflict"
                echo "  [FIX] Removed broken link: $conflict" >> "$temp_report"
            fi
        done
        
        if [ -s "$temp_report" ]; then
            SESSION_REPORT="${SESSION_REPORT}$(cat "$temp_report")\n"
        fi
        rm -f "$temp_report"
    fi

    # 2. Actual Stow Command
    stow -d "$stow_dir" -t "$HOME" -R "$pkg_name" >> "$LOG_FILE" 2>&1
    local res=$?
    
    if [ $res -ne 0 ]; then
        log "ERROR" "Stow failed for $profile/$pkg_name (Exit: $res)"
        add_report "  [ERR] Stow failed for package: $pkg_name"
        return $res
    else
        log "OK" "Successfully stowed: $pkg_name"
    fi
    return 0
}

apply_configs() {
    local profile=$1
    local count=0
    local err_count=0
    SESSION_REPORT=""
    
    log "INFO" "Applying Configs for Profile: $profile"
    echo "⚙️  Applying configuration profile: $profile"
    echo "---------------------------------------------------"

    if [ -d "$DOTFILES_DIR/$profile" ]; then
        for folder in "$DOTFILES_DIR/$profile"/*; do
            if [ -d "$folder" ]; then
                local pkg=$(basename "$folder")
                echo -n "   • $pkg... "
                if stow_config_package "$profile" "$pkg"; then
                    echo "OK"
                    ((count++))
                else
                    echo "FAIL"
                    ((err_count++))
                fi
            fi
        done
    fi
    
    echo ""
    if [ -n "$SESSION_REPORT" ]; then
        echo "📝 Action Report:"
        echo -e "$SESSION_REPORT"
        echo "---------------------------------------------------"
        gum input --placeholder "Press Enter to acknowledge..."
    else
        sleep 0.5
    fi

    if [ $err_count -gt 0 ]; then
        LAST_MSG="⚠️  Applied $count, Failed $err_count."
    elif [ $count -eq 0 ]; then
        LAST_MSG="⚠️  No packages found in $profile!"
    else
        LAST_MSG="✅ Applied $count config packages."
    fi
}

unstow_configs() {
    local profile=$1
    if [ -d "$DOTFILES_DIR/$profile" ]; then
        ls "$DOTFILES_DIR/$profile" | xargs -I {} stow -d "$DOTFILES_DIR/$profile" -t "$HOME" -D "{}" 2>/dev/null
    fi
}

# --- 5. Storage Logic (Vault) ---

handle_single_storage_item() {
    local item_name=$1; local target_path=$2
    local repo_path="$STORAGE_DIR/$item_name"

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

    if [ ! -e "$repo_path" ]; then
        log "WARN" "Storage item not found in vault: $repo_path"
        add_report "  [WARN] Missing source: $item_name"
        return 1
    fi
    
    if [ ! -e "$target_path" ]; then
        local parent_dir=$(dirname "$target_path")
        if ! mkdir -p "$parent_dir"; then
             log "ERROR" "Failed to create directory: $parent_dir"
             add_report "  [ERR] Mkdir failed: $parent_dir"
             return 1
        fi

        log "INFO" "Linking: ln -sf \"$repo_path\" \"$target_path\""
        if ln -sf "$repo_path" "$target_path"; then
            log "OK" "Linked Vault: $item_name"
            return 0
        else
            log "ERROR" "Failed to link $item_name"
            add_report "  [ERR] Link failed: $item_name"
            return 1
        fi
    elif [ -L "$target_path" ]; then
        if [ "$(readlink -f "$target_path")" != "$(readlink -f "$repo_path")" ]; then
             rm "$target_path"
             if ln -sf "$repo_path" "$target_path"; then
                 log "FIX" "Relinked Vault: $item_name"
                 add_report "  [FIX] Relinked: $item_name"
                 return 0
             else
                 log "ERROR" "Failed to relink $item_name"
                 add_report "  [ERR] Relink failed: $item_name"
                 return 1
             fi
        fi
        return 0
    else
         log "WARN" "Conflict for $item_name. Target is a file/dir, not a link."
         add_report "  [WARN] Conflict: $item_name (Target exists)"
         return 1
    fi
}

apply_storage() {
    if [ ! -f "$STORAGE_MAP" ]; then LAST_MSG="ℹ️ No storage map found."; return; fi
    local count=0
    local err_count=0
    SESSION_REPORT=""
    
    log "INFO" "Applying Storage Vault..."
    echo "📦 Linking Storage Vault items..."
    echo "---------------------------------------------------"

    while IFS='|' read -r item_name target_path || [ -n "$item_name" ]; do
        [[ "$item_name" =~ ^#.*$ ]] && continue
        [ -z "$item_name" ] && continue
        
        target_path="${target_path/#\~/$HOME}"
        target_path=$(echo "$target_path" | xargs)
        
        echo -n "   • $item_name -> $target_path... "
        if handle_single_storage_item "$item_name" "$target_path"; then
            echo "OK"
            ((count++))
        else
            echo "FAIL"
            ((err_count++))
        fi
    done < "$STORAGE_MAP"

    echo ""
    if [ -n "$SESSION_REPORT" ]; then
        echo "📝 Storage Report:"
        echo -e "$SESSION_REPORT"
        echo "---------------------------------------------------"
        gum input --placeholder "Press Enter to acknowledge..."
    else
        sleep 0.5
    fi

    if [ $err_count -gt 0 ]; then
        LAST_MSG="⚠️ Synced $count, Failed $err_count Vault items."
    else
        LAST_MSG="✅ Synced $count Vault items."
    fi
}

unstow_storage() {
    [ -f "$STORAGE_MAP" ] && while IFS='|' read -r item_name target_path || [ -n "$item_name" ]; do
        [[ "$item_name" =~ ^#.*$ ]] && continue
        target_path="${target_path/#\~/$HOME}"
        target_path=$(echo "$target_path" | xargs)
        if [ -L "$target_path" ]; then
            rm "$target_path"
            log "INFO" "Unlinked: $target_path"
        fi
    done < "$STORAGE_MAP"
}

# --- 6. CRUD Operations (Self-Sustaining) ---

manage_profiles() {
    local action=$(gum choose --header "Manage Profiles" "Create New Profile" "Delete Profile" "List Content" "Back")
    case "$action" in
        "Create New Profile")
            local name=$(gum input --placeholder "new-profile" --header "Profile Name")
            if [ -n "$name" ]; then
                if [ -d "$DOTFILES_DIR/$name" ]; then
                    LAST_MSG="❌ Profile '$name' already exists."
                else
                    mkdir -p "$DOTFILES_DIR/$name"
                    LAST_MSG="✅ Profile '$name' created."
                fi
            fi
            ;; 
        "Delete Profile")
            local prof=$(gum choose --header "Select Profile to DELETE" $(get_profiles))
            if [ -n "$prof" ]; then
                if gum confirm "Permanently delete '$prof'? This deletes files!"; then
                    rm -rf "$DOTFILES_DIR/$prof"
                    LAST_MSG="🗑️ Profile '$prof' deleted."
                fi
            fi
            ;; 
        "List Content")
            local prof=$(gum choose --header "Select Profile" $(get_profiles))
            if [ -n "$prof" ]; then
                ls -1 "$DOTFILES_DIR/$prof" | gum pager
            fi
            ;; 
    esac
}

manage_configs() {
    local action=$(gum choose --header "Manage Configurations" "Add New Config" "Delete Config" "Back")
    case "$action" in
        "Add New Config")
            local target_path=$(gum input --placeholder "/home/user/.config/app" --header "Config Path (Esc to cancel)")
            if [ -z "$target_path" ]; then return; fi
            target_path="${target_path/#\~/$HOME}"
            
            if [ ! -e "$target_path" ]; then LAST_MSG="❌ Path invalid."; return; fi
            if [[ "$target_path" != "$HOME"* ]]; then LAST_MSG="❌ Must be in Home dir."; return; fi
            if [ -L "$target_path" ]; then LAST_MSG="❌ Already a symlink."; return; fi

            local prof=$(gum choose --header "Select Profile" $(get_profiles))
            if [ -z "$prof" ]; then return; fi

            local pkg_name=$(basename "$target_path")
            local user_pkg_name=$(gum input --value "$pkg_name" --header "Package Name")
            [ -z "$user_pkg_name" ] && user_pkg_name="$pkg_name"

            local rel_path="${target_path#$HOME/}"
            local dest_dir="$DOTFILES_DIR/$prof/$user_pkg_name"

            if [ -d "$dest_dir" ]; then LAST_MSG="❌ Package exists in $prof."; return; fi

            if gum confirm "Move '$target_path' to '$prof/$user_pkg_name'?"; then
                 mkdir -p "$(dirname "$dest_dir/$rel_path")"
                 mv "$target_path" "$dest_dir/$rel_path"
                 stow_config_package "$prof" "$user_pkg_name"
                 LAST_MSG="✅ Config added to $prof."
            fi
            ;; 
        "Delete Config")
            local prof=$(gum choose --header "Select Profile" $(get_profiles))
            [ -z "$prof" ] && return
            local pkg=$(gum choose --header "Select Package" $(ls "$DOTFILES_DIR/$prof"))
            [ -z "$pkg" ] && return

            if gum confirm "Delete '$pkg' from '$prof'? (Unstows & Deletes)"; then
                stow -d "$DOTFILES_DIR/$prof" -t "$HOME" -D "$pkg"
                rm -rf "$DOTFILES_DIR/$prof/$pkg"
                LAST_MSG="🗑️ Package '$pkg' deleted."
            fi
            ;; 
    esac
}

manage_storage() {
    local action=$(gum choose --header "Manage Storage" "Add Item" "Remove Item" "List Items" "Back")
    case "$action" in
        "Add Item")
            local target_path=$(gum input --placeholder "/abs/path" --header "Add to Vault")
            if [ -z "$target_path" ]; then return; fi
            target_path="${target_path/#\~/$HOME}"

            if [ ! -e "$target_path" ]; then LAST_MSG="❌ Invalid path."; return; fi
            if [ -L "$target_path" ]; then LAST_MSG="❌ Already linked."; return; fi

            local item_name=$(basename "$target_path")
            if grep -q "|$target_path$" "$STORAGE_MAP"; then LAST_MSG="⚠️ Already tracked."; return; fi

            # Ensure file ends with newline before appending
            if [ -s "$STORAGE_MAP" ] && [ -n "$(tail -c 1 "$STORAGE_MAP")" ]; then
                echo "" >> "$STORAGE_MAP"
            fi
            echo "$item_name|$target_path" >> "$STORAGE_MAP"
            handle_single_storage_item "$item_name" "$target_path"
            LAST_MSG="✅ Added $item_name to Vault."
            ;; 
        "Remove Item")
            local selection=$(gum choose --header "Select Item to Remove" $(cut -d'|' -f1 "$STORAGE_MAP"))
            if [ -n "$selection" ]; then
                if gum confirm "Stop tracking '$selection'? (Keeps file in Vault, removes link)"; then
                    # Remove line from map
                    grep -v "^$selection|" "$STORAGE_MAP" > "$STORAGE_MAP.tmp" && mv "$STORAGE_MAP.tmp" "$STORAGE_MAP"
                    # We do NOT delete the data from storage/ to be safe, just stop syncing/linking
                    # Optionally we could remove the symlink in HOME
                    # Let's find where it was linked
                    LAST_MSG="✅ Removed '$selection' from map."
                fi
            fi
            ;; 
        "List Items")
            gum pager < "$STORAGE_MAP"
            ;; 
    esac
}

# --- 7. Core Actions ---

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
        [[ "$scope" == "All" || "$scope" == "Configs" ]] && { unstow_configs "$prof"; apply_configs "$prof"; }
        [[ "$scope" == "All" || "$scope" == "Storage" ]] && apply_storage
        
        if command -v hyprctl &> /dev/null;
 then
            hyprctl reload
        fi

        LAST_MSG="✅ Synced & Reloaded."
    fi
}

execute_switch_profile() {
    local new_profile=$(gum choose --header "Select Profile" $(get_profiles))
    if [ -z "$new_profile" ]; then return; fi

    local old_profile="None"
    [ -f "$PROFILE_FILE" ] && old_profile=$(cat "$PROFILE_FILE")

    if [ "$old_profile" == "$new_profile" ]; then
        if ! gum confirm "Profile '$new_profile' is already active. Re-apply everything?"; then
            return
        fi
    fi

    # Unstow old
    if [ "$old_profile" != "None" ]; then
        unstow_configs "$old_profile"
    fi

    # Apply new
    echo "$new_profile" > "$PROFILE_FILE"
    apply_configs "$new_profile"
    apply_storage
    
    # Reload WM if needed
    if command -v hyprctl &> /dev/null;
 then
        hyprctl reload
    fi
}

view_system_status() {
    local report_file="/tmp/dots_status_report.txt"
    {
        gum style --foreground "$C_PRIMARY" --bold "🔮 NASIF'S OMARCHY STATUS"
        echo "==================================="

        local current_prof="None"
        [ -f "$PROFILE_FILE" ] && current_prof=$(cat "$PROFILE_FILE")
        echo -e "\n🔹 ACTIVE PROFILE: $current_prof\n"

        for prof in $(get_profiles);
 do
            echo "🔹 PROFILE: $prof"
            ls -1 "$DOTFILES_DIR/$prof" | sed 's/^/   - /'
            echo ""
        done

        echo -e "\n🔹 VAULT (Tracked Folders):"
        if [ -f "$STORAGE_MAP" ] && [ -s "$STORAGE_MAP" ]; then
            cat "$STORAGE_MAP" | sed 's/^/   • /'
        else
            echo "   (Vault is empty)"
        fi
    } > "$report_file"

    gum pager < "$report_file"
}

draw_dashboard() {
    clear
    local greeting="Hello, Nasif"
    local branch=$(cd "$DOTFILES_DIR" && git branch --show-current 2>/dev/null || echo "Unknown")
    local status="Clean ✨"
    [[ -n $(cd "$DOTFILES_DIR" && git status -s) ]] && status="Dirty ✏️"
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
    
    # Message Area
    if [ -n "$LAST_MSG" ]; then
        gum style --foreground "$C_ACCENT" --bold --align center --border normal --border-foreground "$C_ACCENT" --padding "0 2" "$LAST_MSG"
        echo "" 
    fi
}

# --- 8. Main Loop ---

ensure_environment
LAST_MSG="Welcome back."

while true;
 do
    CURRENT_PROFILE="None"
    [ -f "$PROFILE_FILE" ] && CURRENT_PROFILE=$(cat "$PROFILE_FILE")

    draw_dashboard

    ACTION=$(gum choose --cursor.foreground "$C_PRIMARY" --header "Select Operation" \
        "🚀  Sync System (Git)" \
        "🎭  Switch / Apply Profile" \
        "📁  Manage Profiles" \
        "⚙️  Manage Configs" \
        "📦  Manage Storage" \
        "📊  System Status" \
        "📜  View Logs" \
        "👋  Exit")

    case "$ACTION" in
        "🚀  Sync System (Git)")
            SCOPE=$(gum choose --cursor.foreground "$C_PRIMARY" "All" "Configs Only" "Storage Only")
            [ -n "$SCOPE" ] && power_sync "$SCOPE" || LAST_MSG="❌ Cancelled"
            ;; 
        "🎭  Switch / Apply Profile")
            execute_switch_profile
            ;; 
        "📁  Manage Profiles") manage_profiles ;; 
        "⚙️  Manage Configs") manage_configs ;; 
        "📦  Manage Storage") manage_storage ;; 
        "📊  System Status") view_system_status ;; 
        "📜  View Logs") gum pager < "$LOG_FILE" ;; 
        "👋  Exit") 
            clear
            gum style --foreground "$C_PRIMARY" "See you later! 👋"
            exit 0 
            ;; 
    esac
done