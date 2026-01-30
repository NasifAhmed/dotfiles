#!/bin/bash

# ==============================================================================
#  OMARCHY DOTS MANAGER v8.0 (Final Gold Master)
#  Author: Ahmed
# ==============================================================================

# --- Configuration ---
DOTFILES_DIR="$HOME/dotfiles"
STORAGE_DIR="$DOTFILES_DIR/storage"
STORAGE_MAP="$DOTFILES_DIR/storage.conf"
BACKUP_ROOT="$HOME/dotfiles_backups"
LOG_FILE="$DOTFILES_DIR/setup.log"
PROFILE_FILE="$DOTFILES_DIR/.current_profile"
BIN_NAME="dots"

# Trap Interrupts (Ctrl+C) to exit cleanly
trap "tput cnorm; echo; exit" INT
set -o pipefail 

# --- 1. Logging & Error Handling ---

log() {
    local level=$1; local msg=$2
    local timestamp=$(date "+%H:%M:%S")
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
}

die() {
    log "FATAL" "$1"
    gum style --border double --foreground 196 "CRITICAL FAILURE: $1"
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
    # Check Dependencies
    if ! command -v git &> /dev/null || ! command -v stow &> /dev/null || ! command -v gum &> /dev/null || ! command -v rsync &> /dev/null; then
        echo "📦 Installing dependencies..."
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm git stow gum rsync diffutils || die "Pacman failed."
        else
            die "Dependencies missing (git, stow, gum, rsync)."
        fi
    fi

    # Structure Setup
    mkdir -p "$HOME/.local/bin" "$STORAGE_DIR" "$BACKUP_ROOT"
    [ ! -f "$STORAGE_MAP" ] && touch "$STORAGE_MAP"

    # Self-Install (Symlink)
    SCRIPT_PATH=$(realpath "$0")
    TARGET_LINK="$HOME/.local/bin/$BIN_NAME"
    if [ ! -L "$TARGET_LINK" ] || [ "$(readlink -f "$TARGET_LINK")" != "$SCRIPT_PATH" ]; then
        ln -sf "$SCRIPT_PATH" "$TARGET_LINK"
    fi

    # Path Setup
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# --- 3. Reporting Logic ---

view_system_status() {
    local report_file="/tmp/dots_status_report.txt"
    echo "OMARCHY SYSTEM STATUS" > "$report_file"
    echo "=====================" >> "$report_file"

    local current_prof="None"
    [ -f "$PROFILE_FILE" ] && current_prof=$(cat "$PROFILE_FILE")
    echo -e "\n🔹 ACTIVE PROFILE: $current_prof\n" >> "$report_file"

    echo "🔹 CONFIG PACKAGES:" >> "$report_file"
    echo "   [Common]" >> "$report_file"
    if [ -d "$DOTFILES_DIR/common" ]; then
        ls -1 "$DOTFILES_DIR/common" | sed 's/^/   - /' >> "$report_file"
    else
        echo "   (None)" >> "$report_file"
    fi

    if [[ "$current_prof" != "None"* ]]; then
        local target_dir=""
        [[ "$current_prof" == *"Home"* ]] && target_dir="home"
        [[ "$current_prof" == *"Office"* ]] && target_dir="office"

        echo -e "\n   [Specific: $target_dir]" >> "$report_file"
        if [ -d "$DOTFILES_DIR/$target_dir" ]; then
            ls -1 "$DOTFILES_DIR/$target_dir" | sed 's/^/   - /' >> "$report_file"
        fi
    fi

    echo -e "\n🔹 VAULT (Tracked Folders):" >> "$report_file"
    if [ -f "$STORAGE_MAP" ] && [ -s "$STORAGE_MAP" ]; then
        while IFS='|' read -r name path || [ -n "$name" ]; do
            [[ "$name" =~ ^#.*$ ]] && continue
            [ -z "$name" ] && continue
            echo "   • $name  ->  $path" >> "$report_file"
        done < "$STORAGE_MAP"
    else
        echo "   (Vault is empty)" >> "$report_file"
    fi

    gum pager < "$report_file"
}

# --- 4. Config Logic (Stow) ---

stow_config_package() {
    local rel_path=$1
    local parent_dir=$(dirname "$rel_path")
    local pkg_name=$(basename "$rel_path")
    local stow_dir="$DOTFILES_DIR/$parent_dir" 

    # 1. Detect Conflicts
    local conflict_output=$(stow -d "$stow_dir" -t "$HOME" -n "$pkg_name" 2>&1)
    local conflicts=$(echo "$conflict_output" | grep -oE "over existing target .* since|existing target is .*" | sed -E 's/over existing target (.*) since/\1/; s/existing target is (.*)/\1/')

    if [ ! -z "$conflicts" ] && [ "$conflicts" != " " ]; then
        local backup_ts="$BACKUP_ROOT/conflict_configs_$(date +%Y%m%d_%H%M%S)"

        echo "$conflicts" | while read conflict; do
            conflict=$(echo "$conflict" | xargs)
            [ -z "$conflict" ] && continue

            local real="$HOME/$conflict"
            local source_file="$stow_dir/$pkg_name/$conflict"

            if [ -e "$real" ] && [ ! -L "$real" ]; then
                # Check for identity to avoid redundant backups
                if [ -f "$source_file" ] && cmp -s "$real" "$source_file"; then
                    rm "$real"
                    log "INFO" "Replaced identical file with link: $conflict"
                else
                    mkdir -p "$backup_ts/$(dirname "$conflict")"
                    mv "$real" "$backup_ts/$conflict"
                    log "SAFETY" "Backed up modified file: $conflict"
                fi
            elif [ -L "$real" ]; then 
                rm "$real" # Remove dead/incorrect links
            fi
        done
    fi

    # 2. Apply Link
    stow -d "$stow_dir" -t "$HOME" -R "$pkg_name" >> "$LOG_FILE" 2>&1
    return $?
}

apply_configs() {
    local type=$1; local count=0
    log "INFO" "Applying Configs: $type"

    # Common
    if [ -d "$DOTFILES_DIR/common" ]; then
        for folder in "$DOTFILES_DIR/common"/*; do
            [ -d "$folder" ] && { stow_config_package "common/$(basename "$folder")"; ((count++)); }
        done
    fi

    # Specific
    local target_dir=""
    [[ "$type" == *"Home"* ]] && target_dir="home"
    [[ "$type" == *"Office"* ]] && target_dir="office"

    if [ -d "$DOTFILES_DIR/$target_dir" ]; then
        for folder in "$DOTFILES_DIR/$target_dir"/*; do
            [ -d "$folder" ] && { stow_config_package "$target_dir/$(basename "$folder")"; ((count++)); }
        done
    fi
    [ $count -eq 0 ] && LAST_MSG="⚠️ No packages found!" || LAST_MSG="✅ Applied $count config packages."
}

unstow_configs() {
    for d in common home office; do
        if [ -d "$DOTFILES_DIR/$d" ]; then
            ls "$DOTFILES_DIR/$d" | xargs -I {} stow -d "$DOTFILES_DIR/$d" -t "$HOME" -D "{}" 2>/dev/null
        fi
    done
}

add_new_config() {
    local target_path=$(gum input --placeholder "/home/user/.config/my_app" --header "Add Existing Config (Esc to cancel)")
    if [ -z "$target_path" ]; then return; fi
    target_path="${target_path/#\~/$HOME}"

    if [ ! -e "$target_path" ]; then LAST_MSG="❌ Path invalid."; return; fi
    if [[ "$target_path" != "$HOME"* ]]; then LAST_MSG="❌ Config must be in Home dir."; return; fi
    if [ -L "$target_path" ]; then LAST_MSG="❌ Is already a symlink."; return; fi

    local category=$(gum choose --header "Select Scope" "Common (All Machines)" "Home PC Only" "Office Laptop Only")
    if [ -z "$category" ]; then return; fi

    local repo_subdir="common"
    [[ "$category" == "Home PC Only" ]] && repo_subdir="home"
    [[ "$category" == "Office Laptop Only" ]] && repo_subdir="office"

    local rel_path="${target_path#$HOME/}"
    local pkg_name=$(basename "$target_path") 

    local user_pkg_name=$(gum input --value "$pkg_name" --header "Package Name")
    if [ -z "$user_pkg_name" ]; then user_pkg_name="$pkg_name"; fi

    local repo_pkg_root="$DOTFILES_DIR/$repo_subdir/$user_pkg_name"

    # SAFETY: Prevent overwriting existing packages
    if [ -d "$repo_pkg_root" ]; then
        LAST_MSG="❌ Package '$user_pkg_name' already exists in $repo_subdir."
        return
    fi

    local repo_final_dest="$repo_pkg_root/$rel_path" 

    gum confirm "Move '$target_path' to $repo_subdir and symlink?" || return
    gum spin --spinner dot --title "Moving files..." -- sleep 0.5

    if [ -d "$target_path" ]; then
        mkdir -p "$(dirname "$repo_final_dest")"
        mv "$target_path" "$(dirname "$repo_final_dest")/"
    else
        mkdir -p "$(dirname "$repo_final_dest")"
        mv "$target_path" "$repo_final_dest"
    fi

    log "INFO" "Moved $target_path to $repo_final_dest"

    stow_config_package "$repo_subdir/$user_pkg_name"
    if [ $? -eq 0 ]; then LAST_MSG="✅ Config '$user_pkg_name' added."; else LAST_MSG="⚠️ Added but stow failed."; fi
}

# --- 5. Storage Logic (Vault) ---

handle_single_storage_item() {
    local item_name=$1; local target_path=$2
    local repo_path="$STORAGE_DIR/$item_name"

    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
        gum spin --spinner globe --title "Ingesting $item_name..." -- sleep 0.5
        if [ -d "$target_path" ]; then
            safe_exec rsync -avu "$target_path/" "$repo_path/"
        else
            mkdir -p "$(dirname "$repo_path")"
            safe_exec cp -u "$target_path" "$repo_path"
        fi

        local backup_loc="$BACKUP_ROOT/pre_link_$(date +%Y%m%d_%H%M%S)/$item_name"
        mkdir -p "$(dirname "$backup_loc")"
        mv "$target_path" "$backup_loc"
        log "SAFETY" "Archived original storage: $item_name"
    fi

    if [ ! -e "$repo_path" ]; then return; fi
    if [ ! -L "$target_path" ]; then
        mkdir -p "$(dirname "$target_path")"
        ln -sf "$repo_path" "$target_path"
        log "OK" "Linked Vault: $item_name"
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
        target_path="${target_path/#\~/$HOME}"
        [ -L "$target_path" ] && rm "$target_path"
    done < "$STORAGE_MAP"
}

add_to_storage() {
    local target_path=$(gum input --placeholder "/abs/path/to/folder" --header "Add to Vault (Esc to cancel)")
    if [ -z "$target_path" ]; then return; fi
    target_path="${target_path/#\~/$HOME}"

    if [ ! -e "$target_path" ]; then LAST_MSG="❌ Path invalid"; return; fi
    if [ -L "$target_path" ]; then LAST_MSG="❌ Already a symlink."; return; fi

    local item_name=$(basename "$target_path")
    if grep -q "|$target_path$" "$STORAGE_MAP"; then LAST_MSG="⚠️ Already tracked."; return; fi

    echo "$item_name|$target_path" >> "$STORAGE_MAP"
    handle_single_storage_item "$item_name" "$target_path"
    LAST_MSG="✅ Added $item_name to Vault."
}

# --- 6. Power Sync (Robust) ---

power_sync() {
    local scope=$1
    if [ -z "$scope" ]; then return; fi
    cd "$DOTFILES_DIR" || return

    # SAFETY: Check branch
    local BRANCH=$(git branch --show-current)
    if [ -z "$BRANCH" ]; then
        LAST_MSG="❌ Git detached HEAD. Cannot sync."
        return
    fi

    # 1. AUTO-COMMIT
    if [[ -n $(git status -s) ]]; then
        gum spin --title "Committing local changes..." -- git add .
        safe_exec git commit -m "Auto-sync $(hostname): $(date '+%Y-%m-%d %H:%M')"
        log "INFO" "Auto-committed local changes."
    fi

    # 2. FETCH
    gum spin --title "Checking remote..." -- git fetch origin
    if [ $? -ne 0 ]; then LAST_MSG="❌ Remote unreachable."; return; fi

    local LOCAL=$(git rev-parse HEAD)
    local REMOTE=$(git rev-parse origin/$BRANCH)
    local BASE=$(git merge-base HEAD origin/$BRANCH)
    local RELOAD=false

    # 3. COMPARE & ACT
    if [ "$LOCAL" = "$REMOTE" ]; then
        LAST_MSG="✨ Everything is up to date."

    elif [ "$LOCAL" = "$BASE" ]; then
        gum spin --title "⬇️  Pulling updates..." -- git pull origin "$BRANCH"
        RELOAD=true

    elif [ "$REMOTE" = "$BASE" ]; then
        gum spin --title "⬆️  Pushing changes..." -- git push origin "$BRANCH"
        LAST_MSG="☁️ Changes pushed to cloud."

    else
        # CONFLICT -> Remote Wins (Merging with -X theirs)
        gum style --foreground 196 "⚠️ Conflict detected. Merging (Remote Preferred)..."
        gum spin --title "Resolving..." -- git pull origin "$BRANCH" --strategy-option=theirs

        # Push the merge
        gum spin --title "⬆️  Pushing merge..." -- git push origin "$BRANCH"
        RELOAD=true
    fi

    # 4. RELOAD
    if [ "$RELOAD" = true ] && [ -f "$PROFILE_FILE" ]; then
        local prof=$(cat "$PROFILE_FILE")
        [[ "$scope" == "All" || "$scope" == "Configs" ]] && { unstow_configs; apply_configs "$prof"; }
        [[ "$scope" == "All" || "$scope" == "Storage" ]] && apply_storage
        LAST_MSG="✅ Synced & Reloaded ($scope)"
    fi
}

execute_setup() {
    local profile=$1; local scope=$2
    if [ -z "$profile" ] || [ -z "$scope" ]; then LAST_MSG="❌ Cancelled"; return; fi
    echo "$profile" > "$PROFILE_FILE"
    [[ "$scope" == "All" || "$scope" == "Configs" ]] && { unstow_configs; apply_configs "$profile"; }
    [[ "$scope" == "All" || "$scope" == "Storage" ]] && apply_storage
}

# --- 7. Main Menu Loop ---

ensure_environment
LAST_MSG="Welcome to Omarchy Manager"

while true; do
    clear
    CURRENT_PROFILE="None"
    [ -f "$PROFILE_FILE" ] && CURRENT_PROFILE=$(cat "$PROFILE_FILE")

    gum style --border double --padding "1 2" --border-foreground 212 --align center \
    "OMARCHY MANAGER v8.0" \
    "Host: $(hostname)" \
    "Active Profile: $CURRENT_PROFILE"

    echo ""
    gum style --foreground 240 -- "--- Recent Activity ---"
    tail -n 5 "$LOG_FILE" | sed 's/^/  /' 
    echo ""

    gum style --foreground 82 --bold "$LAST_MSG"
    echo ""

    ACTION=$(gum choose "Sync" "Install/Switch Profile" "System Status" "Add Config (Stow)" "Add to Vault (Storage)" "Reset/Uninstall" "View Full Logs" "Exit (q)")
    if [ -z "$ACTION" ]; then LAST_MSG="❌ Selection Cancelled."; continue; fi

    case "$ACTION" in
        "Sync")
            SCOPE=$(gum choose "All" "Configs Only" "Storage Only")
            [ -n "$SCOPE" ] && power_sync "$SCOPE" || LAST_MSG="❌ Cancelled"
            ;;
        "Install/Switch Profile")
            PROFILE=$(gum choose --header "Select Machine" "Home PC" "Office Laptop")
            if [ -n "$PROFILE" ]; then
                SCOPE=$(gum choose --header "Scope" "All" "Configs Only" "Storage Only")
                [ -n "$SCOPE" ] && execute_setup "$PROFILE" "$SCOPE" || LAST_MSG="❌ Cancelled"
            else
                LAST_MSG="❌ Cancelled"
            fi
            ;;
        "System Status") view_system_status ;;
        "Add Config (Stow)") add_new_config ;;
        "Add to Vault (Storage)") add_to_storage ;;
        "Reset/Uninstall")
            SCOPE=$(gum choose "All" "Configs Only" "Storage Only")
            if [ -n "$SCOPE" ] && gum confirm "Unlink $SCOPE?"; then
                [[ "$SCOPE" == "All" || "$SCOPE" == "Configs" ]] && unstow_configs
                [[ "$SCOPE" == "All" || "$SCOPE" == "Storage" ]] && unstow_storage
                LAST_MSG="🗑️ Unlinked $SCOPE."
            else
                LAST_MSG="Cancelled."
            fi
            ;;
        "View Full Logs") gum pager < "$LOG_FILE" ;;
        "Exit (q)") clear; exit 0 ;;
    esac
done
