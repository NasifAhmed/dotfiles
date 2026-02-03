#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Sync - Configuration Library
# ==============================================================================
# Manages configuration loading, saving, and retrieval.
# Configuration is stored in .dotfiles_config
# ==============================================================================

# Strict mode
set -euo pipefail

# ==============================================================================
# Configuration Paths
# ==============================================================================
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CONFIG_FILE="${DOTFILES_DIR}/.dotfiles_config"
CURRENT_PROFILE_FILE="${DOTFILES_DIR}/.current_profile"

# ==============================================================================
# Default Configuration Values
# ==============================================================================
declare -A CONFIG_DEFAULTS=(
    [REMOTE_URL]="origin"
    [DEFAULT_PROFILE]=""
    [AUTO_SYNC]="true"
    [LOG_LEVEL]="info"
    [BACKUP_DIR]="backups"
    [STORAGE_DIR]="storage"
)

# ==============================================================================
# Configuration Functions
# ==============================================================================

# Initialize configuration with defaults
# Usage: config_init
config_init() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        {
            echo "# Dotfiles Manager Configuration"
            echo "# Generated on $(date '+%Y-%m-%d %H:%M:%S')"
            echo ""
            for key in "${!CONFIG_DEFAULTS[@]}"; do
                echo "${key}=\"${CONFIG_DEFAULTS[$key]}\""
            done
        } > "$CONFIG_FILE"
    fi
    
    # Initialize current profile file
    if [[ ! -f "$CURRENT_PROFILE_FILE" ]]; then
        echo "" > "$CURRENT_PROFILE_FILE"
    fi
}

# Load configuration into environment
# Usage: config_load
config_load() {
    config_init
    # shellcheck source=/dev/null
    source "$CONFIG_FILE" 2>/dev/null || true
}

# Get a configuration value
# Usage: config_get "key" [default]
config_get() {
    local key="$1"
    local default="${2:-${CONFIG_DEFAULTS[$key]:-}}"
    
    config_load
    local value
    value=$(grep "^${key}=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2- | tr -d '"' || echo "")
    
    if [[ -z "$value" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# Set a configuration value
# Usage: config_set "key" "value"
config_set() {
    local key="$1"
    local value="$2"
    
    config_init
    
    if grep -q "^${key}=" "$CONFIG_FILE" 2>/dev/null; then
        # Update existing key
        sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$CONFIG_FILE"
    else
        # Add new key
        echo "${key}=\"${value}\"" >> "$CONFIG_FILE"
    fi
}

# Get current profile
# Usage: config_get_current_profile
config_get_current_profile() {
    if [[ -f "$CURRENT_PROFILE_FILE" ]]; then
        cat "$CURRENT_PROFILE_FILE" | tr -d '\n'
    else
        echo ""
    fi
}

# Set current profile
# Usage: config_set_current_profile "profile_name"
config_set_current_profile() {
    local profile="$1"
    echo "$profile" > "$CURRENT_PROFILE_FILE"
}

# Get dotfiles directory
# Usage: config_get_dotfiles_dir
config_get_dotfiles_dir() {
    echo "$DOTFILES_DIR"
}

# Get backup directory path
# Usage: config_get_backup_dir
config_get_backup_dir() {
    local backup_base
    backup_base=$(config_get "BACKUP_DIR")
    echo "${DOTFILES_DIR}/${backup_base}"
}

# Get storage directory path
# Usage: config_get_storage_dir
config_get_storage_dir() {
    local storage_base
    storage_base=$(config_get "STORAGE_DIR")
    echo "${DOTFILES_DIR}/${storage_base}"
}

# List all configuration keys and values
# Usage: config_list
config_list() {
    config_load
    if [[ -f "$CONFIG_FILE" ]]; then
        grep -v "^#" "$CONFIG_FILE" | grep -v "^$" || true
    fi
}

# Reset configuration to defaults
# Usage: config_reset
config_reset() {
    rm -f "$CONFIG_FILE"
    config_init
}
