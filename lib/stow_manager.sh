#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Sync - Stow Manager Library
# ==============================================================================
# Handles GNU Stow operations with conflict detection and backup.
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

# Default target directory
STOW_TARGET="${STOW_TARGET:-$HOME}"

# ==============================================================================
# Stow Detection 
# ==============================================================================

# Check if stow is available
# Usage: stow_is_available
stow_is_available() {
    command -v stow &>/dev/null
}

# Get stow version
# Usage: stow_get_version
stow_get_version() {
    stow --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+\.\d+' || echo "unknown"
}

# ==============================================================================
# Conflict Detection
# ==============================================================================

# Check for potential conflicts before stowing
# Usage: stow_check_conflicts "package_dir"
# Returns: list of conflicting files
stow_check_conflicts() {
    local package_dir="$1"
    local target="${2:-$STOW_TARGET}"
    local conflicts=()
    
    if [[ ! -d "$package_dir" ]]; then
        return 0
    fi
    
    # Walk through package directory
    while IFS= read -r -d '' file; do
        local rel_path="${file#$package_dir/}"
        local target_path="${target}/${rel_path}"
        
        # Check if target exists and is not a symlink to our file
        if [[ -e "$target_path" && ! -L "$target_path" ]]; then
            conflicts+=("$target_path")
        elif [[ -L "$target_path" ]]; then
            # Check if symlink points elsewhere
            local link_target
            link_target=$(readlink -f "$target_path" 2>/dev/null || true)
            local expected_target
            expected_target=$(readlink -f "$file" 2>/dev/null || echo "$file")
            
            if [[ "$link_target" != "$expected_target" ]]; then
                conflicts+=("$target_path")
            fi
        fi
    done < <(find "$package_dir" -type f -print0 2>/dev/null)
    
    printf '%s\n' "${conflicts[@]}"
}

# ==============================================================================
# Backup Functions
# ==============================================================================

# Backup conflicting files before stowing
# Usage: stow_backup_conflicts "package_dir" [backup_name]
stow_backup_conflicts() {
    local package_dir="$1"
    local backup_name="${2:-$(date '+%Y-%m-%d_%H-%M-%S')}"
    local backup_dir
    backup_dir="$(config_get_backup_dir)/${backup_name}"
    
    local conflicts
    conflicts=$(stow_check_conflicts "$package_dir")
    
    if [[ -z "$conflicts" ]]; then
        log_debug "No conflicts to backup"
        return 0
    fi
    
    log_info "Backing up conflicting files to: $backup_dir"
    mkdir -p "$backup_dir"
    
    while IFS= read -r file; do
        if [[ -n "$file" && -e "$file" ]]; then
            local rel_path="${file#$STOW_TARGET/}"
            local backup_path="${backup_dir}/${rel_path}"
            
            mkdir -p "$(dirname "$backup_path")"
            mv "$file" "$backup_path"
            log_debug "Backed up: $file -> $backup_path"
        fi
    done <<< "$conflicts"
    
    log_success "Backed up ${#conflicts[@]} files"
    return 0
}

# Restore files from backup
# Usage: stow_restore_backup "backup_name"
stow_restore_backup() {
    local backup_name="$1"
    local backup_dir
    backup_dir="$(config_get_backup_dir)/${backup_name}"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup not found: $backup_name"
        return 1
    fi
    
    log_info "Restoring from backup: $backup_name"
    
    while IFS= read -r -d '' file; do
        local rel_path="${file#$backup_dir/}"
        local target_path="${STOW_TARGET}/${rel_path}"
        
        mkdir -p "$(dirname "$target_path")"
        
        # Remove existing symlink/file first
        if [[ -e "$target_path" || -L "$target_path" ]]; then
            rm -f "$target_path"
        fi
        
        cp -a "$file" "$target_path"
        log_debug "Restored: $target_path"
    done < <(find "$backup_dir" -type f -print0 2>/dev/null)
    
    log_success "Restore completed"
    return 0
}

# List available backups
# Usage: stow_list_backups
stow_list_backups() {
    local backup_base
    backup_base=$(config_get_backup_dir)
    
    if [[ -d "$backup_base" ]]; then
        find "$backup_base" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -r
    fi
}

# ==============================================================================
# Stow Operations
# ==============================================================================

# Stow a package (create symlinks)
# Usage: stow_apply "package_dir" [target] [backup]
stow_apply() {
    local package_dir="$1"
    local target="${2:-$STOW_TARGET}"
    local backup="${3:-true}"
    
    local package_name
    package_name=$(basename "$package_dir")
    
    if [[ ! -d "$package_dir" ]]; then
        log_error "Package directory not found: $package_dir"
        return 1
    fi
    
    log_info "Stowing package: $package_name -> $target"
    
    # Check for and backup conflicts
    if [[ "$backup" == "true" ]]; then
        stow_backup_conflicts "$package_dir"
    fi
    
    # Run stow
    local stow_dir
    stow_dir=$(dirname "$package_dir")
    
    if stow -d "$stow_dir" -t "$target" "$package_name" 2>&1; then
        log_success "Stowed: $package_name"
        return 0
    else
        log_error "Failed to stow: $package_name"
        return 1
    fi
}

# Unstow a package (remove symlinks)
# Usage: stow_remove "package_dir" [target]
stow_remove() {
    local package_dir="$1"
    local target="${2:-$STOW_TARGET}"
    
    local package_name
    package_name=$(basename "$package_dir")
    
    if [[ ! -d "$package_dir" ]]; then
        log_warning "Package directory not found: $package_dir"
        return 0
    fi
    
    log_info "Unstowing package: $package_name"
    
    local stow_dir
    stow_dir=$(dirname "$package_dir")
    
    if stow -d "$stow_dir" -t "$target" -D "$package_name" 2>&1; then
        log_success "Unstowed: $package_name"
        return 0
    else
        log_error "Failed to unstow: $package_name"
        return 1
    fi
}

# Restow a package (unstow then stow)
# Usage: stow_restow "package_dir" [target]
stow_restow() {
    local package_dir="$1"
    local target="${2:-$STOW_TARGET}"
    
    local package_name
    package_name=$(basename "$package_dir")
    
    log_info "Restowing package: $package_name"
    
    local stow_dir
    stow_dir=$(dirname "$package_dir")
    
    if stow -d "$stow_dir" -t "$target" -R "$package_name" 2>&1; then
        log_success "Restowed: $package_name"
        return 0
    else
        log_error "Failed to restow: $package_name"
        return 1
    fi
}

# ==============================================================================
# Dry Run / Preview
# ==============================================================================

# Preview stow operation (dry run)
# Usage: stow_preview "package_dir" [target]
stow_preview() {
    local package_dir="$1"
    local target="${2:-$STOW_TARGET}"
    
    local package_name
    package_name=$(basename "$package_dir")
    local stow_dir
    stow_dir=$(dirname "$package_dir")
    
    log_info "Preview stow: $package_name"
    stow -d "$stow_dir" -t "$target" -n -v "$package_name" 2>&1
}

# ==============================================================================
# Symlink Utilities
# ==============================================================================

# Check if a path is a stow-managed symlink
# Usage: stow_is_managed "path"
stow_is_managed() {
    local path="$1"
    
    if [[ ! -L "$path" ]]; then
        return 1
    fi
    
    local link_target
    link_target=$(readlink "$path" 2>/dev/null)
    
    # Check if symlink points to dotfiles directory
    [[ "$link_target" == *"$DOTFILES_DIR"* ]]
}

# Get all stow-managed symlinks for a package
# Usage: stow_list_symlinks "package_dir" [target]
stow_list_symlinks() {
    local package_dir="$1"
    local target="${2:-$STOW_TARGET}"
    
    while IFS= read -r -d '' file; do
        local rel_path="${file#$package_dir/}"
        local target_path="${target}/${rel_path}"
        
        if [[ -L "$target_path" ]]; then
            echo "$target_path -> $(readlink "$target_path")"
        fi
    done < <(find "$package_dir" -type f -print0 2>/dev/null)
}

# ==============================================================================
# Cleanup Functions
# ==============================================================================

# Remove broken symlinks in target
# Usage: stow_cleanup_broken [target]
stow_cleanup_broken() {
    local target="${1:-$STOW_TARGET}"
    local count=0
    
    log_info "Cleaning broken symlinks in: $target"
    
    while IFS= read -r -d '' link; do
        if [[ ! -e "$link" ]]; then
            rm "$link"
            log_debug "Removed broken link: $link"
            ((count++))
        fi
    done < <(find "$target" -type l -print0 2>/dev/null)
    
    if [[ $count -gt 0 ]]; then
        log_success "Removed $count broken symlinks"
    else
        log_info "No broken symlinks found"
    fi
}

# ==============================================================================
# PATH Management
# ==============================================================================

# Ensure ~/.local/bin is in PATH and scripts are linked
# Usage: stow_ensure_scripts_in_path "scripts_dir"
stow_ensure_scripts_in_path() {
    local scripts_dir="$1"
    local bin_dir="$HOME/.local/bin"
    
    # Create bin directory
    mkdir -p "$bin_dir"
    
    # Source deps to ensure PATH is set
    source "${DOTFILES_DIR}/lib/deps.sh"
    deps_ensure_local_bin_path
    
    # Check if scripts_dir exists
    if [[ ! -d "$scripts_dir" ]]; then
        log_debug "No scripts directory: $scripts_dir"
        return 0
    fi
    
    log_info "Linking scripts to $bin_dir"
    
    # Link all scripts
    for script in "$scripts_dir"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            local script_name
            script_name=$(basename "$script")
            local target="$bin_dir/$script_name"
            
            if [[ -L "$target" ]]; then
                rm "$target"
            fi
            
            ln -sf "$script" "$target"
            log_debug "Linked: $script_name"
        fi
    done
    
    log_success "Scripts linked to PATH"
}
