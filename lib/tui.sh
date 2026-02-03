#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Sync - TUI Library
# ==============================================================================
# Modern TUI using gum (Charmbracelet) with fallback to dialog/whiptail.
# Provides beautiful, interactive interface components.
# ==============================================================================

# Strict mode
set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Source required libraries
# shellcheck source=/dev/null
source "${DOTFILES_DIR}/lib/logger.sh"
# shellcheck source=/dev/null
source "${DOTFILES_DIR}/lib/deps.sh"
# shellcheck source=/dev/null
source "${DOTFILES_DIR}/lib/config.sh"

# TUI tool detection
TUI_TOOL=""

# ==============================================================================
# Initialization
# ==============================================================================

# Initialize TUI system
# Usage: tui_init
tui_init() {
    TUI_TOOL=$(deps_get_tui_tool)
    log_debug "TUI initialized with tool: $TUI_TOOL"
}

# ==============================================================================
# ASCII Art & Styling
# ==============================================================================

# Draw ASCII banner
# Usage: draw_ascii_banner
draw_ascii_banner() {
    if [[ "$TUI_TOOL" == "gum" ]]; then
        gum style \
            --foreground 212 \
            --border-foreground 212 \
            --border double \
            --align center \
            --width 50 \
            --margin "1 2" \
            --padding "1 2" \
            ' ____   ___ _____ __  __    _    _   _ ' \
            '|  _ \ / _ \_   _|  \/  |  / \  | \ | |' \
            '| | | | | | || | | |\/| | / _ \ |  \| |' \
            '| |_| | |_| || | | |  | |/ ___ \| |\  |' \
            '|____/ \___/ |_| |_|  |_/_/   \_\_| \_|' \
            '' \
            "Nasif's Dotfiles Manager"
    else
        echo ""
        echo "  +--------------------------------------------------+"
        echo "  |  ____   ___ _____ __  __    _    _   _           |"
        echo "  | |  _ \ / _ \_   _|  \/  |  / \  | \ | |          |"
        echo "  | | | | | | | || | | |\/| | / _ \ |  \| |          |"
        echo "  | | |_| | |_| || | | |  | |/ ___ \| |\  |          |"
        echo "  | |____/ \___/ |_| |_|  |_/_/   \_\_| \_|          |"
        echo "  |                                                  |"
        echo "  |           Nasif's Dotfiles Manager               |"
        echo "  +--------------------------------------------------+"
        echo ""
    fi
}

# Style text with gum or fallback
# Usage: tui_style "text" [foreground] [bold]
tui_style() {
    local text="$1"
    local fg="${2:-}"
    local bold="${3:-}"
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        local args=()
        [[ -n "$fg" ]] && args+=(--foreground "$fg")
        [[ "$bold" == "true" ]] && args+=(--bold)
        gum style "${args[@]}" "$text"
    else
        if [[ "$bold" == "true" ]]; then
            echo -e "\033[1m${text}\033[0m"
        else
            echo "$text"
        fi
    fi
}

# ==============================================================================
# Input Components
# ==============================================================================

# Show a menu and get selection
# Usage: tui_menu "prompt" "option1" "option2" ...
# Returns: selected option
tui_menu() {
    local prompt="$1"
    shift
    local options=("$@")
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        gum choose --header "$prompt" "${options[@]}"
    elif [[ "$TUI_TOOL" == "dialog" ]]; then
        local items=()
        local i=1
        for opt in "${options[@]}"; do
            items+=("$opt" "")
            ((i++))
        done
        dialog --clear --menu "$prompt" 20 60 10 "${items[@]}" 2>&1 >/dev/tty
    elif [[ "$TUI_TOOL" == "whiptail" ]]; then
        local items=()
        for opt in "${options[@]}"; do
            items+=("$opt" "")
        done
        whiptail --menu "$prompt" 20 60 10 "${items[@]}" 3>&1 1>&2 2>&3
    else
        # Basic fallback
        echo "$prompt" >&2
        local i=1
        for opt in "${options[@]}"; do
            echo "  $i) $opt" >&2
            ((i++))
        done
        echo -n "Select [1-${#options[@]}]: " >&2
        local choice
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#options[@]})); then
            echo "${options[$((choice-1))]}"
        else
            echo ""
        fi
    fi
}

# Show confirmation dialog
# Usage: tui_confirm "prompt"
# Returns: 0 for yes, 1 for no
tui_confirm() {
    local prompt="$1"
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        gum confirm "$prompt"
    elif [[ "$TUI_TOOL" == "dialog" ]]; then
        dialog --clear --yesno "$prompt" 8 50
    elif [[ "$TUI_TOOL" == "whiptail" ]]; then
        whiptail --yesno "$prompt" 8 50
    else
        echo -n "$prompt [y/N]: " >&2
        local answer
        read -r answer
        [[ "${answer,,}" == "y" || "${answer,,}" == "yes" ]]
    fi
}

# Get text input
# Usage: tui_input "prompt" [default] [placeholder]
# Returns: user input
tui_input() {
    local prompt="$1"
    local default="${2:-}"
    local placeholder="${3:-}"
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        local args=(--header "$prompt")
        [[ -n "$default" ]] && args+=(--value "$default")
        [[ -n "$placeholder" ]] && args+=(--placeholder "$placeholder")
        gum input "${args[@]}"
    elif [[ "$TUI_TOOL" == "dialog" ]]; then
        dialog --clear --inputbox "$prompt" 8 60 "$default" 2>&1 >/dev/tty
    elif [[ "$TUI_TOOL" == "whiptail" ]]; then
        whiptail --inputbox "$prompt" 8 60 "$default" 3>&1 1>&2 2>&3
    else
        echo -n "$prompt " >&2
        [[ -n "$default" ]] && echo -n "[$default] " >&2
        local input
        read -r input
        echo "${input:-$default}"
    fi
}

# Fuzzy filter selection
# Usage: tui_filter "prompt" "option1" "option2" ...
# Returns: selected option
tui_filter() {
    local prompt="$1"
    shift
    local options=("$@")
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        printf '%s\n' "${options[@]}" | gum filter --header "$prompt"
    else
        # Fallback to regular menu
        tui_menu "$prompt" "${options[@]}"
    fi
}

# Show spinner while command runs
# Usage: tui_spin "title" command args...
# Note: For shell functions, we run directly since gum spin can't execute them
tui_spin() {
    local title="$1"
    shift
    
    # Run the command directly (works for both functions and executables)
    # Show a simple spinner animation
    echo -n "  [*] $title... "
    
    # Run command in background and capture result
    local tmpfile="/tmp/tui_spin_$$"
    (
        set +e
        "$@" > "$tmpfile.out" 2>&1
        echo $? > "$tmpfile.rc"
    ) &
    local pid=$!
    
    # Animate spinner
    local chars='|/-\'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        printf "\b%c" "${chars:$i:1}"
        ((i = (i + 1) % 4)) || true
        sleep 0.1
    done
    wait $pid 2>/dev/null || true
    
    # Check result
    local rc=0
    [[ -f "$tmpfile.rc" ]] && rc=$(cat "$tmpfile.rc")
    
    if [[ "$rc" -eq 0 ]]; then
        printf "\b Done!\n"
    else
        printf "\b Failed!\n"
        [[ -f "$tmpfile.out" ]] && cat "$tmpfile.out"
    fi
    
    rm -f "$tmpfile.rc" "$tmpfile.out"
    return "$rc"
}

# ==============================================================================
# Message Components
# ==============================================================================

# Show message box
# Usage: tui_msgbox "title" "message"
tui_msgbox() {
    local title="$1"
    local message="$2"
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        gum style \
            --border rounded \
            --border-foreground 240 \
            --margin "1" \
            --padding "1 2" \
            --width 60 \
            "$title" "" "$message"
    elif [[ "$TUI_TOOL" == "dialog" ]]; then
        dialog --clear --title "$title" --msgbox "$message" 12 60
    elif [[ "$TUI_TOOL" == "whiptail" ]]; then
        whiptail --title "$title" --msgbox "$message" 12 60
    else
        echo ""
        echo "═══ $title ═══"
        echo "$message"
        echo ""
    fi
}

# Show error message
# Usage: tui_error "message"
tui_error() {
    local message="$1"
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        gum style \
            --foreground 196 \
            --border rounded \
            --border-foreground 196 \
            --margin "1" \
            --padding "1 2" \
            "[X] Error" "" "$message"
    else
        echo -e "\033[31m[X] Error: $message\033[0m" >&2
    fi
}

# Show success message
# Usage: tui_success "message"
tui_success() {
    local message="$1"
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        gum style \
            --foreground 46 \
            --border rounded \
            --border-foreground 46 \
            --margin "1" \
            --padding "1 2" \
            "[+] Success" "" "$message"
    else
        echo -e "\033[32m[+] $message\033[0m"
    fi
}

# ==============================================================================
# Dashboard Components
# ==============================================================================

# Format a key-value pair for dashboard
# Usage: tui_kv "key" "value" [color]
tui_kv() {
    local key="$1"
    local value="$2"
    local color="${3:-250}"
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        local styled_key styled_value
        styled_key=$(gum style --foreground 240 "$key:")
        styled_value=$(gum style --foreground "$color" --bold "$value")
        echo "$styled_key $styled_value"
    else
        printf "  %-18s %s\n" "$key:" "$value"
    fi
}

# Create a status indicator
# Usage: tui_status_indicator "status" (clean|dirty|ahead|behind|conflict)
tui_status_indicator() {
    local status="$1"
    
    case "$status" in
        clean)
            [[ "$TUI_TOOL" == "gum" ]] && gum style --foreground 46 "[*] Clean" || echo -e "\033[32m[*] Clean\033[0m"
            ;;
        dirty)
            [[ "$TUI_TOOL" == "gum" ]] && gum style --foreground 214 "[*] Modified" || echo -e "\033[33m[*] Modified\033[0m"
            ;;
        ahead)
            [[ "$TUI_TOOL" == "gum" ]] && gum style --foreground 39 "[^] Ahead" || echo -e "\033[34m[^] Ahead\033[0m"
            ;;
        behind)
            [[ "$TUI_TOOL" == "gum" ]] && gum style --foreground 208 "[v] Behind" || echo -e "\033[33m[v] Behind\033[0m"
            ;;
        conflict)
            [[ "$TUI_TOOL" == "gum" ]] && gum style --foreground 196 "[!] Conflict" || echo -e "\033[31m[!] Conflict\033[0m"
            ;;
        synced)
            [[ "$TUI_TOOL" == "gum" ]] && gum style --foreground 46 "[+] Synced" || echo -e "\033[32m[+] Synced\033[0m"
            ;;
        *)
            echo "$status"
            ;;
    esac
}

# Draw a horizontal divider
# Usage: tui_divider [width] [char]
tui_divider() {
    local width="${1:-50}"
    local char="${2:--}"
    local line
    line=$(printf '%*s' "$width" '' | tr ' ' "$char")
    # Don't use gum style for dividers - it interprets dashes as flags
    echo "$line"
}

# Create a section header
# Usage: tui_section "title"
tui_section() {
    local title="$1"
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        echo ""
        gum style --foreground 212 --bold "> $title"
        tui_divider 40
    else
        echo ""
        echo "> $title"
        echo "----------------------------------------"
    fi
}

# ==============================================================================
# Checklist Component
# ==============================================================================

# Show checklist for multi-select
# Usage: tui_checklist "prompt" "option1" "option2" ...
# Returns: selected options (newline separated)
tui_checklist() {
    local prompt="$1"
    shift
    local options=("$@")
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        printf '%s\n' "${options[@]}" | gum choose --no-limit --header "$prompt"
    elif [[ "$TUI_TOOL" == "dialog" ]]; then
        local items=()
        for opt in "${options[@]}"; do
            items+=("$opt" "" "off")
        done
        dialog --clear --checklist "$prompt" 20 60 10 "${items[@]}" 2>&1 >/dev/tty
    else
        echo "$prompt (enter numbers separated by spaces):" >&2
        local i=1
        for opt in "${options[@]}"; do
            echo "  $i) $opt" >&2
            ((i++))
        done
        echo -n "Select: " >&2
        local choices
        read -r choices
        for c in $choices; do
            if [[ "$c" =~ ^[0-9]+$ ]] && ((c >= 1 && c <= ${#options[@]})); then
                echo "${options[$((c-1))]}"
            fi
        done
    fi
}

# ==============================================================================
# File Browser Component
# ==============================================================================

# Browse and select file/directory
# Usage: tui_file_browser [start_path] [type: file|dir|all]
# Returns: selected path
tui_file_browser() {
    local start_path="${1:-$HOME}"
    local type="${2:-all}"
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        local args=(--path "$start_path")
        [[ "$type" == "file" ]] && args+=(--file)
        [[ "$type" == "dir" ]] && args+=(--directory)
        gum file "${args[@]}"
    else
        echo -n "Enter path [$start_path]: " >&2
        local path
        read -r path
        echo "${path:-$start_path}"
    fi
}

# ==============================================================================
# Progress & Loading Animations
# ==============================================================================

# Background loading PID
_LOADING_PID=""

# Start a loading animation (runs in background)
# Usage: tui_loading_start "message"
tui_loading_start() {
    local message="${1:-Loading...}"
    
    # Kill any existing loading animation
    tui_loading_stop 2>/dev/null || true
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        # Use gum spin in background (won't work directly, so use ASCII spinner)
        _tui_ascii_spinner "$message" &
        _LOADING_PID=$!
    else
        _tui_ascii_spinner "$message" &
        _LOADING_PID=$!
    fi
}

# Stop the loading animation
# Usage: tui_loading_stop
tui_loading_stop() {
    if [[ -n "${_LOADING_PID:-}" ]]; then
        kill "$_LOADING_PID" 2>/dev/null || true
        wait "$_LOADING_PID" 2>/dev/null || true
        _LOADING_PID=""
        # Clear the spinner line
        printf "\r%-60s\r" " "
    fi
}

# Internal ASCII spinner (for background loading)
_tui_ascii_spinner() {
    local message="$1"
    local chars='|/-\'
    local i=0
    
    while true; do
        printf "\r  [%c] %s" "${chars:$i:1}" "$message"
        ((i = (i + 1) % 4))
        sleep 0.1
    done
}

# Show progress message (inline, no animation)
# Usage: tui_progress "message"
tui_progress() {
    local message="$1"
    
    if [[ "$TUI_TOOL" == "gum" ]]; then
        gum style --foreground 214 "[...] $message"
    else
        echo "[...] $message"
    fi
}

# Show a quick action with spinner
# Usage: tui_action "title" command args...
tui_action() {
    local title="$1"
    shift
    
    printf "  [*] %s..." "$title"
    if "$@" >/dev/null 2>&1; then
        printf "\r  [+] %s... Done!     \n" "$title"
        return 0
    else
        printf "\r  [-] %s... Failed!   \n" "$title"
        return 1
    fi
}

