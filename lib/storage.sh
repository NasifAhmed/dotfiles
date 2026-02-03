#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Sync - Storage Library
# ==============================================================================
# Manages general storage with full CRUD operations via TUI.
# Storage is a stow-compatible directory where items mirror paths relative to HOME
# and are always stowed to HOME.
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

# Storage directory
STORAGE_DIR="${DOTFILES_DIR}/storage"

# ==============================================================================
# Storage Initialization
# ==============================================================================

# Initialize storage directory
# Usage: storage_init
storage_init() {
    if [[ ! -d "$STORAGE_DIR" ]]; then
        mkdir -p "$STORAGE_DIR"
        log_debug "Created storage directory"
    fi
}

# ==============================================================================
# Storage List Operations
# ==============================================================================

# List all storage items
# Usage: storage_list
storage_list() {
    storage_init
    
    for dir in "$STORAGE_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            local name
            name=$(basename "$dir")
            [[ "$name" != "*" ]] && echo "$name"
        fi
    done
}

# List storage items with details
# Usage: storage_list_detailed
storage_list_detailed() {
    storage_init
    
    for dir in "$STORAGE_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            local name
            name=$(basename "$dir")
            [[ "$name" == "*" ]] && continue
            
            local size
            size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            local file_count
            file_count=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
            
            printf "%-20s %8s  %5s files\n" "$name" "$size" "$file_count"
        fi
    done
}

# Get storage item count
# Usage: storage_count
storage_count() {
    storage_list | wc -l | tr -d ' '
}

# Get total storage size
# Usage: storage_get_size
storage_get_size() {
    du -sh "$STORAGE_DIR" 2>/dev/null | cut -f1 || echo "0"
}

# ==============================================================================
# Storage CRUD Operations
# ==============================================================================

# Add item to storage
# Usage: storage_add "source_path" [name]
storage_add() {
    local source_path="$1"
    local name="${2:-$(basename "$source_path")}"
    
    storage_init
    
    local item_dir="${STORAGE_DIR}/${name}"
    
    if [[ ! -e "$source_path" ]]; then
        log_error "Source not found: $source_path"
        return 1
    fi
    
    if [[ -d "$item_dir" ]]; then
        log_error "Storage item already exists: $name"
        return 1
    fi
    
    # Determine absolute path of source
    local abs_source
    abs_source=$(realpath "$source_path")
    
    # Check if source is inside HOME
    if [[ "$abs_source" != "$HOME"* ]]; then
        log_error "Source must be inside HOME directory: $source_path"
        log_error "Current implementation only supports HOME-relative storage."
        return 1
    fi
    
    log_info "Adding to storage: $name"
    
    # Determine path relative to HOME
    local rel_path="${abs_source#$HOME/}"
    local parent_dir
    parent_dir=$(dirname "$rel_path")
    
    local storage_path="${item_dir}/${rel_path}"
    
    # Create structure in storage
    mkdir -p "$(dirname "$storage_path")"
    
    # Copy to storage
    cp -a "$source_path" "$storage_path"
    
    # Remove original
    rm -rf "$source_path"
    
    # Stow to HOME
    stow_apply "$item_dir" "$HOME"
    
    log_success "Added to storage: $name"
    return 0
}

# Remove item from storage (unstow and restore to original location)
# Usage: storage_remove "name"
storage_remove() {
    local name="$1"
    local item_dir="${STORAGE_DIR}/${name}"
    
    if [[ ! -d "$item_dir" ]]; then
        log_error "Storage item not found: $name"
        return 1
    fi
    
    log_info "Removing from storage: $name"
    
    # Unstow first (remove symlinks)
    stow_remove "$item_dir" "$HOME" 2>/dev/null || true
    
    # Restore content
    # Walk through the storage item to find the files and move them back to HOME
    log_info "Restoring files..."
    
    if [[ -z "$(ls -A "$item_dir")" ]]; then
        rm -rf "$item_dir"
        return 0
    fi
    
    # Use rsync to merge back to HOME
    if command -v rsync &>/dev/null; then
        rsync -a --remove-source-files "${item_dir}/" "$HOME/"
    else
        # Fallback
        cp -a "${item_dir}/." "$HOME/"
    fi
    
    # Remove from storage
    rm -rf "$item_dir"
    
    log_success "Removed from storage: $name (restored to original location)"
    return 0
}

# Get storage item info
# Usage: storage_get_info "name"
storage_get_info() {
    local name="$1"
    local item_dir="${STORAGE_DIR}/${name}"
    
    if [[ ! -d "$item_dir" ]]; then
        return 1
    fi
    
    local size
    size=$(du -sh "$item_dir" 2>/dev/null | cut -f1)
    local file_count
    file_count=$(find "$item_dir" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    echo "name=$name"
    echo "size=$size"
    echo "files=$file_count"
    echo "target=$HOME"
}

# ==============================================================================
# Storage Stow Operations
# ==============================================================================

# Sync all storage items (restow)
# Usage: storage_sync
storage_sync() {
    storage_init
    
    log_section "Syncing Storage"
    
    local count=0
    for item_dir in "$STORAGE_DIR"/*/; do
        if [[ -d "$item_dir" ]]; then
            local name
            name=$(basename "$item_dir")
            [[ "$name" == "*" ]] && continue
            
            log_info "Syncing: $name"
            if ! (stow_restow "$item_dir" "$HOME" 2>/dev/null || stow_apply "$item_dir" "$HOME"); then
                log_warning "Failed to sync package: $name"
            fi
            ((count+=1))
        fi
    done
    
    log_success "Storage synced: $count items"
}

# Apply single storage item
# Usage: storage_apply "name"
storage_apply() {
    local name="$1"
    local item_dir="${STORAGE_DIR}/${name}"
    
    if [[ ! -d "$item_dir" ]]; then
        log_error "Storage item not found: $name"
        return 1
    fi
    
    stow_apply "$item_dir" "$HOME"
}

# Unapply single storage item
# Usage: storage_unapply "name"
storage_unapply() {
    local name="$1"
    local item_dir="${STORAGE_DIR}/${name}"
    
    if [[ ! -d "$item_dir" ]]; then
        log_error "Storage item not found: $name"
        return 1
    fi
    
    stow_remove "$item_dir" "$HOME"
}

# ==============================================================================
# Storage Edit Operations
# ==============================================================================

# Rename storage item
# Usage: storage_rename "old_name" "new_name"
storage_rename() {
    local old_name="$1"
    local new_name="$2"
    local old_dir="${STORAGE_DIR}/${old_name}"
    local new_dir="${STORAGE_DIR}/${new_name}"
    
    if [[ ! -d "$old_dir" ]]; then
        log_error "Storage item not found: $old_name"
        return 1
    fi
    
    if [[ -d "$new_dir" ]]; then
        log_error "Storage item already exists: $new_name"
        return 1
    fi
    
    # Unstow old
    stow_remove "$old_dir" "$HOME" 2>/dev/null || true
    
    # Rename
    mv "$old_dir" "$new_dir"
    
    # Restow with new name
    stow_apply "$new_dir" "$HOME"
    
    log_success "Renamed: $old_name -> $new_name"
}

# ==============================================================================
# Storage Browse
# ==============================================================================

# Browse storage item contents
# Usage: storage_browse "name"
storage_browse() {
    local name="$1"
    local item_dir="${STORAGE_DIR}/${name}"
    
    if [[ ! -d "$item_dir" ]]; then
        log_error "Storage item not found: $name"
        return 1
    fi
    
    find "$item_dir" -type f -printf "%P\n" 2>/dev/null | sort
}
