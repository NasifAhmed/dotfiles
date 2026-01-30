#!/bin/bash

# ==============================================================================
#  OMARCHY DOTS MANAGER v6.1 (Stable UI & Cancel Handling)
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

# Handle Ctrl+C (SIGINT) to restore cursor and exit cleanly
trap "tput cnorm; echo; exit" INT

set -o pipefail 

# --- 1. Logging ---

log() {
    local level=$1
    local msg=$2
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

# --- 2. Environment ---

ensure_environment() {
    if ! command -v git &> /dev/null || ! command -v stow &> /dev/null || ! command -v gum &> /dev/null || ! command -v rsync &> /dev/null; then
        echo "📦 Installing dependencies..."
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm git stow gum rsync || die "Pacman failed."
        else
            die "Dependencies missing (git, stow, gum, rsync)."
        fi
    fi

    mkdir -p "$HOME/.local/bin" "$STORAGE_DIR" "$BACKUP_ROOT"
    [ ! -f "$STORAGE_MAP" ] && touch "$STORAGE_MAP"

    # Self-Install
    SCRIPT_PATH=$(realpath "$0")
    TARGET_LINK="$HOME/.local/bin/$BIN_NAME"
    if [ ! -L "$TARGET_LINK" ] || [ "$(readlink -f "$TARGET_LINK")" != "$SCRIPT_PATH" ]; then
        ln -sf "$SCRIPT_PATH" "$TARGET_LINK"
    fi

    # Path check
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# --- 3. Config Logic ---

stow_config_package() {
    local rel_path=$1
    local parent_dir=$(dirname "$rel_path")
    local pkg_name=$(basename "$rel_path")
    local stow_dir="$DOTFILES_DIR/$parent_dir" 

    # Dry run for conflicts
    local conflict_output=$(stow -d "$stow_dir" -t "$HOME" -n "$pkg_name" 2>&1)

    # Regex to extract filenames from error message
    local conflicts=$(echo "$conflict_output" | grep -oE "over existing target .* since|existing target is .*" | sed -E 's/over existing target (.*) since/\1/; s/existing target is (.*)/\1/')

    if [ ! -z "$conflicts" ] && [ "$conflicts" != " " ]; then
        local backup_ts="$BACKUP_ROOT/conflict_configs_$(date +%Y%m%d_%H%M%S)"
        log "WARN" "Conflict in $pkg_name. Backing up..."

        echo "$conflicts" | while read conflict; do
            conflict=$(echo "$conflict" | xargs)
            [ -z "$conflict" ] && continue
            local real="$HOME/$conflict"

            if [ -e "$real" ] && [ ! -L "$real" ]; then
                mkdir -p "$backup_ts/$(dirname "$conflict")"
                mv "$real" "$backup_ts/$conflict"
            elif [ -L "$real" ]; then 
                rm "$real"
            fi
        done
    fi

    # Real Stow
    stow -d "$stow_dir" -t "$HOME" -R "$pkg_name" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        log "OK" "Linked $pkg_name"
        return 0
    else
        log "ERROR" "Failed to link $pkg_name"
        return 1
    fi
}

apply_configs() {
    local type=$1
    local count=0

    log "INFO" "Applying Configs: $type"

    # Common
    if [ -d "$DOTFILES_DIR/common" ]; then
        for folder in "$DOTFILES_DIR/common"/*; do
            if [ -d "$folder" ]; then
                stow_config_package "common/$(basename "$folder")"
                ((count++))
            fi
        done
    fi

    # Specific
    local target_dir=""
    [[ "$type" == *"Home"* ]] && target_dir="home"
    [[ "$type" == *"Office"* ]] && target_dir="office"

    if [ -d "$DOTFILES_DIR/$target_dir" ]; then
        for folder in "$DOTFILES_DIR/$target_dir"/*; do
            if [ -d "$folder" ]; then
                stow_config_package "$target_dir/$(basename "$folder")"
                ((count++))
            fi
        done
    fi

    if [ $count -eq 0 ]; then
        LAST_MSG="⚠️ No packages found! Check folders."
    else
        LAST_MSG="✅ Applied $count config packages."
    fi
}

unstow_configs() {
    for d in common home office; do
        if [ -d "$DOTFILES_DIR/$d" ]; then
            ls "$DOTFILES_DIR/$d" | xargs -I {} stow -d "$DOTFILES_DIR/$d" -t "$HOME" -D "{}" 2>/dev/null
        fi
    done
}

# --- 4. Storage Logic ---

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
    fi

    # Link
    if [ ! -e "$repo_path" ]; then return; fi
    if [ ! -L "$target_path" ]; then
        mkdir -p "$(dirname "$target_path")"
        ln -sf "$repo_path" "$target_path"
        log "OK" "Linked Vault: $item_name"
    fi
}

apply_storage() {
    if [ ! -f "$STORAGE_MAP" ]; then 
        LAST_MSG="ℹ️ No storage map found."
        return
    fi

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

    # Selection cancelled
    if [ -z "$target_path" ]; then return; fi

    target_path="${target_path/#\~/$HOME}"

    if [ ! -e "$target_path" ]; then LAST_MSG="❌ Path invalid"; return; fi
    local item_name=$(basename "$target_path")

    if grep -q "|$target_path$" "$STORAGE_MAP"; then LAST_MSG="⚠️ Already tracked."; return; fi

    echo "$item_name|$target_path" >> "$STORAGE_MAP"
    handle_single_storage_item "$item_name" "$target_path"
    LAST_MSG="✅ Added $item_name to Vault."
}

# --- 5. Main Loop ---

power_sync() {
    local scope=$1
    if [ -z "$scope" ]; then return; fi # Handle empty scope

    cd "$DOTFILES_DIR" || return

    if [[ -n $(git status -s) ]]; then
        git add .
        safe_exec git commit -m "Auto-sync $(hostname): $(date '+%Y-%m-%d %H:%M')"
    fi

    safe_exec git fetch origin
    local LOCAL=$(git rev-parse @); local REMOTE=$(git rev-parse @{u}); local BASE=$(git merge-base @ @{u})
    local RELOAD=false

    if [ "$LOCAL" = "$REMOTE" ]; then 
        LAST_MSG="✨ Up to date."
    elif [ "$LOCAL" = "$BASE" ]; then 
        gum spin --title "Pulling..." -- git pull
        RELOAD=true
    elif [ "$REMOTE" = "$BASE" ]; then 
        gum spin --title "Pushing..." -- git push
        LAST_MSG="☁️ Pushed changes."
    else 
        gum spin --title "Merging..." -- git pull --strategy-option=theirs
        git push
        RELOAD=true
    fi

    if [ "$RELOAD" = true ] && [ -f "$PROFILE_FILE" ]; then
        local prof=$(cat "$PROFILE_FILE")
        [[ "$scope" == "All" || "$scope" == "Configs" ]] && { unstow_configs; apply_configs "$prof"; }
        [[ "$scope" == "All" || "$scope" == "Storage" ]] && apply_storage
        LAST_MSG="✅ Synced & Reloaded ($scope)"
    fi
}

execute_setup() {
    local profile=$1; local scope=$2
    # Handle cancellations
    if [ -z "$profile" ] || [ -z "$scope" ]; then 
        LAST_MSG="❌ Selection Cancelled"
        return
    fi

    echo "$profile" > "$PROFILE_FILE"

    [[ "$scope" == "All" || "$scope" == "Configs" ]] && { unstow_configs; apply_configs "$profile"; }
    [[ "$scope" == "All" || "$scope" == "Storage" ]] && apply_storage
}

ensure_environment

# --- THE MENU LOOP ---
LAST_MSG="Welcome to Omarchy Manager"

while true; do
    clear

    # Header
    gum style --border double --padding "1 2" --border-foreground 212 --align center "OMARCHY MANAGER v6.1" "Home: $(hostname)"

    # Dashboard (Fix: Added -- separator to prevent flag errors)
    echo ""
    gum style --foreground 240 -- "--- Recent Activity ---"
    tail -n 5 "$LOG_FILE" | sed 's/^/  /' 
    echo ""

    # Status
    gum style --foreground 82 --bold "$LAST_MSG"
    echo ""

    # Menu
    ACTION=$(gum choose "Sync" "Install/Switch Profile" "Add to Vault" "Reset/Uninstall" "Exit (q)")

    # Handle Empty Selection (e.g., ESC pressed)
    if [ -z "$ACTION" ]; then
        LAST_MSG="❌ Selection Cancelled."
        continue
    fi

    case "$ACTION" in
        "Sync")
            SCOPE=$(gum choose "All" "Configs Only" "Storage Only")
            if [ -n "$SCOPE" ]; then
                power_sync "$SCOPE"
            else
                LAST_MSG="❌ Sync Cancelled"
            fi
            ;;
        "Install/Switch Profile")
            PROFILE=$(gum choose --header "Select Machine" "Home PC" "Office Laptop")
            if [ -n "$PROFILE" ]; then
                SCOPE=$(gum choose --header "Scope" "All" "Configs Only" "Storage Only")
                if [ -n "$SCOPE" ]; then
                    execute_setup "$PROFILE" "$SCOPE"
                else
                    LAST_MSG="❌ Setup Cancelled"
                fi
            else
                LAST_MSG="❌ Setup Cancelled"
            fi
            ;;
        "Add to Vault")
            add_to_storage
            ;;
        "Reset/Uninstall")
            SCOPE=$(gum choose "All" "Configs Only" "Storage Only")
            if [ -n "$SCOPE" ]; then
                if gum confirm "Unlink $SCOPE?"; then
                    [[ "$SCOPE" == "All" || "$SCOPE" == "Configs" ]] && unstow_configs
                    [[ "$SCOPE" == "All" || "$SCOPE" == "Storage" ]] && unstow_storage
                    LAST_MSG="🗑️ Unlinked $SCOPE."
                else
                    LAST_MSG="Cancelled."
                fi
            else
                LAST_MSG="Cancelled."
            fi
            ;;
        "Exit (q)")
            clear
            exit 0
            ;;
    esac
done
