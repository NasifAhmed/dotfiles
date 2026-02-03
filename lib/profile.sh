#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Sync - Profile Library
# ==============================================================================
# Manages profiles with full CRUD operations via TUI.
# Each profile contains stow-compatible config directories.
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
source "${DOTFILES_DIR}/lib/config.sh"
# shellcheck source=/dev/null
source "${DOTFILES_DIR}/lib/stow_manager.sh"

# Directories to exclude from profile detection
PROFILE_EXCLUDES=("lib" "tests" "backups" "storage" ".git" ".gemini")

# ==============================================================================
# Profile Detection
# ==============================================================================

# List all available profiles
# Usage: profile_list
profile_list() {
    local profiles=()
    
    for dir in "$DOTFILES_DIR"/*/; do
        local name
        name=$(basename "$dir")
        
        # Skip excluded directories
        local skip=false
        for exclude in "${PROFILE_EXCLUDES[@]}"; do
            if [[ "$name" == "$exclude" ]]; then
                skip=true
                break
            fi
        done
        
        if [[ "$skip" == "false" && -d "$dir" ]]; then
            # Check if it looks like a profile (has subdirectories)
            if find "$dir" -mindepth 1 -maxdepth 1 -type d | read -r; then
                profiles+=("$name")
            fi
        fi
    done
    
    printf '%s\n' "${profiles[@]}"
}

# Get profile count
# Usage: profile_count
profile_count() {
    profile_list | wc -l | tr -d ' '
}

# Check if profile exists
# Usage: profile_exists "name"
profile_exists() {
    local name="$1"
    local profiles
    profiles=$(profile_list)
    
    echo "$profiles" | grep -qx "$name"
}

# ==============================================================================
# Current Profile Management
# ==============================================================================

# Get current active profile
# Usage: profile_get_current
profile_get_current() {
    config_get_current_profile
}

# Set current profile
# Usage: profile_set_current "name"
profile_set_current() {
    local name="$1"
    config_set_current_profile "$name"
    log_debug "Set current profile: $name"
}

# ==============================================================================
# Profile CRUD Operations
# ==============================================================================

# Create a new profile
# Usage: profile_create "name"
profile_create() {
    local name="$1"
    local profile_dir="${DOTFILES_DIR}/${name}"
    
    if [[ -d "$profile_dir" ]]; then
        log_error "Profile already exists: $name"
        return 1
    fi
    
    log_info "Creating profile: $name"
    mkdir -p "$profile_dir"
    
    # Create profile metadata
    echo "# Profile: $name" > "${profile_dir}/.profile_meta"
    echo "created=$(date -Iseconds)" >> "${profile_dir}/.profile_meta"
    
    log_success "Profile created: $name"
    return 0
}

# Delete a profile
# Usage: profile_delete "name"
profile_delete() {
    local name="$1"
    local profile_dir="${DOTFILES_DIR}/${name}"
    
    if [[ ! -d "$profile_dir" ]]; then
        log_error "Profile not found: $name"
        return 1
    fi
    
    # Check if current profile
    local current
    current=$(profile_get_current)
    if [[ "$current" == "$name" ]]; then
        log_warning "Removing current profile, clearing selection"
        profile_set_current ""
    fi
    
    # Unstow all packages first
    profile_unapply "$name"
    
    log_info "Deleting profile: $name"
    rm -rf "$profile_dir"
    
    log_success "Profile deleted: $name"
    return 0
}

# Rename a profile
# Usage: profile_rename "old_name" "new_name"
profile_rename() {
    local old_name="$1"
    local new_name="$2"
    local old_dir="${DOTFILES_DIR}/${old_name}"
    local new_dir="${DOTFILES_DIR}/${new_name}"
    
    if [[ ! -d "$old_dir" ]]; then
        log_error "Profile not found: $old_name"
        return 1
    fi
    
    if [[ -d "$new_dir" ]]; then
        log_error "Profile already exists: $new_name"
        return 1
    fi
    
    # Unstow old profile first
    profile_unapply "$old_name"
    
    log_info "Renaming profile: $old_name -> $new_name"
    mv "$old_dir" "$new_dir"
    
    # Update current profile if renamed
    local current
    current=$(profile_get_current)
    if [[ "$current" == "$old_name" ]]; then
        profile_set_current "$new_name"
    fi
    
    log_success "Profile renamed: $new_name"
    return 0
}

# ==============================================================================
# Profile Config Management
# ==============================================================================

# List configs in a profile
# Usage: profile_list_configs "profile_name"
profile_list_configs() {
    local name="$1"
    local profile_dir="${DOTFILES_DIR}/${name}"
    
    if [[ ! -d "$profile_dir" ]]; then
        return 1
    fi
    
    for dir in "$profile_dir"/*/; do
        if [[ -d "$dir" ]]; then
            basename "$dir"
        fi
    done
}

# Add config to profile
# Usage: profile_add_config "profile_name" "source_path" [config_name]
profile_add_config() {
    local profile_name="$1"
    local source_path="$2"
    local config_name="${3:-$(basename "$source_path")}"
    local profile_dir="${DOTFILES_DIR}/${profile_name}"
    local config_dir="${profile_dir}/${config_name}"
    
    if [[ ! -d "$profile_dir" ]]; then
        log_error "Profile not found: $profile_name"
        return 1
    fi
    
    if [[ ! -e "$source_path" ]]; then
        log_error "Source not found: $source_path"
        return 1
    fi
    
    if [[ -d "$config_dir" ]]; then
        log_error "Config already exists: $config_name"
        return 1
    fi
    
    log_info "Adding config: $config_name to profile: $profile_name"
    
    # Determine relative path from home
    local rel_path="${source_path#$HOME/}"
    
    # Create stow structure
    mkdir -p "$config_dir"
    
    # Recreate directory structure relative to home
    local parent_in_stow="${config_dir}/$(dirname "$rel_path")"
    mkdir -p "$parent_in_stow"
    
    # Move from source to stow structure
    if [[ -d "$source_path" ]]; then
        cp -a "$source_path" "${parent_in_stow}/"
    else
        cp -a "$source_path" "${parent_in_stow}/"
    fi
    
    # Save original location metadata
    echo "original_path=$source_path" > "${config_dir}/.stow_meta"
    echo "added=$(date -Iseconds)" >> "${config_dir}/.stow_meta"
    
    # Remove original and stow
    rm -rf "$source_path"
    stow_apply "$config_dir"
    
    log_success "Config added: $config_name"
    return 0
}

# Remove config from profile (unstow and restore to original location)
# Usage: profile_remove_config "profile_name" "config_name"
# Remove config from profile (unstow and restore to original location)
# Usage: profile_remove_config "profile_name" "config_name"
profile_remove_config() {
    local profile_name="$1"
    local config_name="$2"
    local profile_dir="${DOTFILES_DIR}/${profile_name}"
    local config_dir="${profile_dir}/${config_name}"
    
    if [[ ! -d "$config_dir" ]]; then
        log_error "Config not found: $config_name in $profile_name"
        return 1
    fi
    
    log_info "Removing config: $config_name from profile: $profile_name"
    
    # Unstow first (remove symlinks)
    stow_remove "$config_dir" 2>/dev/null || true
    
    # Restore files to $HOME based on their relative path in the package
    # We rely on the stow structure being correct relative to HOME
    log_info "Restoring files to original locations..."
    
    if [[ -d "$config_dir" ]]; then
        while IFS= read -r -d '' file; do
            # Skip metadata and git files
            local filename
            filename=$(basename "$file")
            if [[ "$filename" == ".stow_meta" ]] || [[ "$filename" == ".git" ]]; then
                continue
            fi
            
            # Calculate relative path from config_dir root
            local rel_path="${file#$config_dir/}"
            local target="${HOME}/${rel_path}"
            
            # Create parent directory
            mkdir -p "$(dirname "$target")"
            
            if [[ -e "$target" ]]; then
                 log_warning "Target exists, overwriting: $target"
            fi
            
            # Move file back
            mv "$file" "$target"
            log_debug "Restored: $target"
            
        done < <(find "$config_dir" -type f -print0 2>/dev/null)
    fi
    
    # Remove the now empty config directory
    rm -rf "$config_dir"
    
    log_success "Config removed: $config_name (restored)"
    return 0
}

# ==============================================================================
# Profile Application
# ==============================================================================

# Apply a profile (stow all configs)
# Usage: profile_apply "name"
profile_apply() {
    local name="$1"
    local profile_dir="${DOTFILES_DIR}/${name}"
    
    if [[ ! -d "$profile_dir" ]]; then
        log_error "Profile not found: $name"
        return 1
    fi
    
    log_section "Applying Profile: $name"
    
    # Unapply current profile first
    local current
    current=$(profile_get_current)
    if [[ -n "$current" && "$current" != "$name" ]]; then
        log_info "Unapplying current profile: $current"
        profile_unapply "$current"
    fi
    
    # Stow each config directory
    local count=0
    for config_dir in "$profile_dir"/*/; do
        if [[ -d "$config_dir" ]]; then
            local config_name
            config_name=$(basename "$config_dir")
            log_step $((count + 1)) "?" "Stowing: $config_name"
            stow_apply "$config_dir"
            ((count++))
        fi
    done
    
    # Handle scripts directory specially
    local scripts_dir="${profile_dir}/scripts"
    if [[ -d "$scripts_dir" ]]; then
        local scripts_bin="${scripts_dir}/.local/bin"
        if [[ -d "$scripts_bin" ]]; then
            stow_ensure_scripts_in_path "$scripts_bin"
        fi
    fi
    
    # Set as current profile
    profile_set_current "$name"
    
    log_success "Profile applied: $name ($count configs)"
    
    # Sync storage
    if command -v storage_sync &>/dev/null; then
        storage_sync
    fi

    # Restart services
    profile_restart_services
    
    return 0
}

# Unapply a profile (unstow all configs)
# Usage: profile_unapply "name"
profile_unapply() {
    local name="$1"
    local profile_dir="${DOTFILES_DIR}/${name}"
    
    if [[ ! -d "$profile_dir" ]]; then
        log_warning "Profile not found: $name"
        return 0
    fi
    
    log_info "Unapplying profile: $name"
    
    for config_dir in "$profile_dir"/*/; do
        if [[ -d "$config_dir" ]]; then
            stow_remove "$config_dir" 2>/dev/null || true
        fi
    done
    
    log_success "Profile unapplied: $name"
}

# ==============================================================================
# Service Restart
# ==============================================================================

# Restart services after profile switch
# Usage: profile_restart_services
profile_restart_services() {
    log_info "Restarting services to apply changes..."
    
    # Check for Hyprland
    if pgrep -x "Hyprland" &>/dev/null; then
        log_info "Reloading Hyprland..."
        if command -v hyprctl &>/dev/null; then
            hyprctl reload 2>/dev/null || true
            log_success "Hyprland reloaded"
        fi
    fi
    
    # Check for sway
    if pgrep -x "sway" &>/dev/null; then
        log_info "Reloading Sway..."
        swaymsg reload 2>/dev/null || true
    fi
    
    # Check for i3
    if pgrep -x "i3" &>/dev/null; then
        log_info "Reloading i3..."
        i3-msg reload 2>/dev/null || true
    fi
    
    # Reload user systemd services
    if command -v systemctl &>/dev/null; then
        systemctl --user daemon-reload 2>/dev/null || true
    fi
    
    log_success "Services reloaded"
}

# ==============================================================================
# Profile Info
# ==============================================================================

# Get profile info
# Usage: profile_get_info "name"
profile_get_info() {
    local name="$1"
    local profile_dir="${DOTFILES_DIR}/${name}"
    
    if [[ ! -d "$profile_dir" ]]; then
        return 1
    fi
    
    local config_count
    config_count=$(profile_list_configs "$name" | wc -l | tr -d ' ')
    local size
    size=$(du -sh "$profile_dir" 2>/dev/null | cut -f1)
    local current
    current=$(profile_get_current)
    local is_current="no"
    [[ "$current" == "$name" ]] && is_current="yes"
    
    echo "name=$name"
    echo "configs=$config_count"
    echo "size=$size"
    echo "is_current=$is_current"
}
