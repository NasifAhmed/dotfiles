#!/bin/bash

# ==============================================================================
#  OMARCHY DOTS MANAGER v5.2 (Fix: Conflict Regex)
#  Author: Ahmed
#  Description: Automated Dotfile & Vault Manager for Arch/Omarchy
# ==============================================================================

# --- Configuration & Constants ---
DOTFILES_DIR="$HOME/dotfiles"
STORAGE_DIR="$DOTFILES_DIR/storage"
STORAGE_MAP="$DOTFILES_DIR/storage.conf"
BACKUP_ROOT="$HOME/dotfiles_backups"
LOG_FILE="$DOTFILES_DIR/setup.log"
PROFILE_FILE="$DOTFILES_DIR/.current_profile"
BIN_NAME="dots"

set -o pipefail 

# --- 1. Logging & Error Handling ---

log() {
    local level=$1
    local msg=$2
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
    if [[ "$level" == "ERROR" || "$level" == "FATAL" ]]; then
        gum style --foreground 196 "❌ $level: $msg"
    fi
}

die() {
    log "FATAL" "$1"
    gum style --border double --border-foreground 196 --foreground 196 --align center \
    "CRITICAL FAILURE" "$1" "See $LOG_FILE for details."
    exit 1
}

safe_exec() {
    "$@" 2>> "$LOG_FILE"
    local status=$?
    if [ $status -ne 0 ]; then
        log "ERROR" "Command failed: $* (Exit Code: $status)"
        return $status
    fi
    return 0
}

# --- 2. Environment Bootstrap ---

ensure_environment() {
    if ! command -v git &> /dev/null || ! command -v stow &> /dev/null || ! command -v gum &> /dev/null || ! command -v rsync &> /dev/null; then
        echo "📦 Installing core dependencies..."
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm git stow gum rsync || die "Failed to install dependencies."
        else
            die "Pacman not found. Is this Omarchy?"
        fi
    fi

    mkdir -p "$HOME/.local/bin"
    mkdir -p "$STORAGE_DIR"
    mkdir -p "$BACKUP_ROOT"
    [ ! -f "$STORAGE_MAP" ] && touch "$STORAGE_MAP"

    SCRIPT_PATH=$(realpath "$0")
    TARGET_LINK="$HOME/.local/bin/$BIN_NAME"

    if [ ! -L "$TARGET_LINK" ] || [ "$(readlink -f "$TARGET_LINK")" != "$SCRIPT_PATH" ]; then
        ln -sf "$SCRIPT_PATH" "$TARGET_LINK"
        log "INFO" "Self-installed 'dots' command to $TARGET_LINK"
    fi

    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        EXPORT_CMD='export PATH="$HOME/.local/bin:$PATH"'
        for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
            if [ -f "$rc" ]; then
                grep -qxF "$EXPORT_CMD" "$rc" || echo "$EXPORT_CMD" >> "$rc"
            fi
        done
        log "INFO" "Added local bin to PATH"
    fi
}

# --- 3. Configuration Management (Fixed Conflict Detection) ---

stow_config_package() {
    local rel_path=$1  # e.g., "common/mpv"

    local parent_dir=$(dirname "$rel_path") # "common"
    local pkg_name=$(basename "$rel_path")  # "mpv"
    local stow_dir="$DOTFILES_DIR/$parent_dir" 

    # 1. Detect Conflicts (Simulation)
    # We grep specifically for the file path causing the issue.
    # Output format varies, but usually: "... over existing target filepath since ..."
    local conflict_output=$(stow -d "$stow_dir" -t "$HOME" -n "$pkg_name" 2>&1)

    # Extract file paths from the error message
    # Looking for: "existing target [FILEPATH] since" OR "existing target is [FILEPATH]"
    local conflicts=$(echo "$conflict_output" | grep -oE "over existing target .* since|existing target is .*" | sed -E 's/over existing target (.*) since/\1/; s/existing target is (.*)/\1/')

    if [ ! -z "$conflicts" ] && [ "$conflicts" != " " ]; then
        local backup_ts="$BACKUP_ROOT/conflict_configs_$(date +%Y%m%d_%H%M%S)"
        log "WARN" "Conflicts detected in $pkg_name. Moving to backup..."

        echo "$conflicts" | while read conflict; do
            # Trim whitespace
            conflict=$(echo "$conflict" | xargs)
            [ -z "$conflict" ] && continue

            local real="$HOME/$conflict"

            if [ -e "$real" ] && [ ! -L "$real" ]; then
                log "BACKUP" "Moving collision $conflict to $backup_ts"
                mkdir -p "$backup_ts/$(dirname "$conflict")"
                mv "$real" "$backup_ts/$conflict"
            elif [ -L "$real" ]; then 
                # If it's a symlink pointing wrong, just remove it
                rm "$real"
            fi
        done
    fi

    # 2. Perform the Stow
    safe_exec stow -d "$stow_dir" -t "$HOME" -R "$pkg_name" 2>/dev/null
}

apply_configs() {
    local type=$1
    log "INFO" "Applying Configs for profile: $type"

    # Apply Common
    for folder in "$DOTFILES_DIR/common"/*; do
        if [ -d "$folder" ]; then
            stow_config_package "common/$(basename "$folder")"
        fi
    done

    # Apply Specific
    local target_dir=""
    [[ "$type" == *"Home"* ]] && target_dir="home"
    [[ "$type" == *"Office"* ]] && target_dir="office"

    if [ -d "$DOTFILES_DIR/$target_dir" ]; then
        for folder in "$DOTFILES_DIR/$target_dir"/*; do
            if [ -d "$folder" ]; then
                stow_config_package "$target_dir/$(basename "$folder")"
            fi
        done
    fi
    gum style --foreground 82 "✅ Configs Applied."
}

unstow_configs() {
    for d in common home office; do
        if [ -d "$DOTFILES_DIR/$d" ]; then
            ls "$DOTFILES_DIR/$d" | xargs -I {} stow -d "$DOTFILES_DIR/$d" -t "$HOME" -D "{}" 2>/dev/null
        fi
    done
}

# --- 4. Storage Vault Logic ---

handle_single_storage_item() {
    local item_name=$1
    local target_path=$2
    local repo_path="$STORAGE_DIR/$item_name"

    # Ingest
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
        log "BACKUP" "Moved original $item_name to $backup_loc"
    fi

    # Link
    if [ ! -e "$repo_path" ]; then return; fi

    if [ ! -L "$target_path" ]; then
        mkdir -p "$(dirname "$target_path")"
        ln -sf "$repo_path" "$target_path"
        log "SUCCESS" "Linked Storage: $item_name"
    fi
}

apply_storage() {
    if [ ! -f "$STORAGE_MAP" ]; then return; fi
    log "INFO" "Syncing Vault Storage..."

    while IFS='|' read -r item_name target_path || [ -n "$item_name" ]; do
        [[ "$item_name" =~ ^#.*$ ]] && continue
        [ -z "$item_name" ] && continue
        target_path="${target_path/#\~/$HOME}"
        handle_single_storage_item "$item_name" "$target_path"
    done < "$STORAGE_MAP"
    gum style --foreground 82 "✅ Storage Synced."
}

unstow_storage() {
    if [ -f "$STORAGE_MAP" ]; then
        while IFS='|' read -r item_name target_path || [ -n "$item_name" ]; do
            target_path="${target_path/#\~/$HOME}"
            if [ -L "$target_path" ]; then rm "$target_path"; fi
        done < "$STORAGE_MAP"
    fi
}

add_to_storage() {
    local target_path=$(gum input --placeholder "/path/to/folder" --header "Enter absolute path to add to Vault")
    [ -z "$target_path" ] && return
    target_path="${target_path/#\~/$HOME}"

    if [ ! -e "$target_path" ]; then gum style --foreground 196 "Path invalid"; return; fi
    local item_name=$(basename "$target_path")

    if grep -q "|$target_path$" "$STORAGE_MAP"; then gum style --foreground 196 "Already tracked."; return; fi

    gum confirm "Sync '$item_name' across devices?" || return
    echo "$item_name|$target_path" >> "$STORAGE_MAP"
    handle_single_storage_item "$item_name" "$target_path"
    gum style --foreground 82 "Added to Vault."
}

# --- 5. Orchestration ---

execute_setup() {
    local profile=$1
    local scope=$2
    echo "$profile" > "$PROFILE_FILE"

    if [[ "$scope" == "All" || "$scope" == "Configs" ]]; then
        gum spin --spinner dot --title "Refreshing Configs..." -- sleep 0.5
        unstow_configs
        apply_configs "$profile"
    fi

    if [[ "$scope" == "All" || "$scope" == "Storage" ]]; then
        gum spin --spinner dot --title "Syncing Storage..." -- sleep 0.5
        apply_storage
    fi
}

power_sync() {
    local scope=$1
    cd "$DOTFILES_DIR" || die "Repo missing"

    gum style --foreground 212 "🔄 Power Sync ($scope)..."

    if [[ -n $(git status -s) ]]; then
        gum style --italic "Committing changes..."
        git add .
        safe_exec git commit -m "Auto-sync $(hostname): $(date '+%Y-%m-%d %H:%M')"
    fi

    safe_exec git fetch origin
    local LOCAL=$(git rev-parse @); local REMOTE=$(git rev-parse @{u}); local BASE=$(git merge-base @ @{u})
    local RELOAD=false

    if [ "$LOCAL" = "$REMOTE" ]; then gum style "✨ Up to date.";
    elif [ "$LOCAL" = "$BASE" ]; then gum style "⬇️ Pulling..."; safe_exec git pull; RELOAD=true;
    elif [ "$REMOTE" = "$BASE" ]; then gum style "⬆️ Pushing..."; safe_exec git push;
    else gum style "⚠️ Merging..."; safe_exec git pull --strategy-option=theirs; safe_exec git push; RELOAD=true; fi

    if [ "$RELOAD" = true ] && [ -f "$PROFILE_FILE" ]; then
        execute_setup "$(cat "$PROFILE_FILE")" "$scope"
    fi
}

# --- 6. Main UI ---

ensure_environment
clear
gum style --border double --padding "1 2" --align center "OMARCHY MANAGER" "v5.2 - Regex Fix"

ACTION=$(gum choose "Sync" "Install/Switch Profile" "Add to Vault" "Reset/Uninstall" "View Logs")

case "$ACTION" in
    "Sync")
        SCOPE=$(gum choose "All" "Configs Only" "Storage Only")
        power_sync "$SCOPE"
        ;;
    "Install/Switch Profile")
        PROFILE=$(gum choose --header "Select Machine" "Home PC" "Office Laptop")
        SCOPE=$(gum choose --header "Scope" "All" "Configs Only" "Storage Only")
        execute_setup "$PROFILE" "$SCOPE"
        ;;
    "Add to Vault") add_to_storage ;;
    "Reset/Uninstall")
        SCOPE=$(gum choose --header "Reset Scope" "All" "Configs Only" "Storage Only")
        if gum confirm "Unlink $SCOPE?"; then
            [[ "$SCOPE" == "All" || "$SCOPE" == "Configs" ]] && unstow_configs
            [[ "$SCOPE" == "All" || "$SCOPE" == "Storage" ]] && unstow_storage
            gum style "Done."
        fi
        ;;
    "View Logs") 
        if [ -f "$LOG_FILE" ]; then gum pager < "$LOG_FILE"; else echo "No logs."; fi 
        ;;
esac
