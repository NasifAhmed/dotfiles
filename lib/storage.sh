#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Sync - Storage Library
# ==============================================================================
# Manages general storage with full CRUD operations via TUI.
# Storage is a stow-compatible directory for any files.
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
STORAGE_META_FILE="${STORAGE_DIR}/.storage_meta"

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
    
    if [[ ! -f "$STORAGE_META_FILE" ]]; then
        echo "# Storage Metadata" > "$STORAGE_META_FILE"
        echo "# Format: name|original_path|stow_target|added_date" >> "$STORAGE_META_FILE"
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
# Usage: storage_add "source_path" [name] [stow_target]
storage_add() {
    local source_path="$1"
    local name="${2:-$(basename "$source_path")}"
    local stow_target="${3:-$HOME}"
    
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
    
    log_info "Adding to storage: $name"
    
    # Determine relative path from target
    local abs_source
    abs_source=$(realpath "$source_path")
    local rel_path="${abs_source#$stow_target/}"
    
    # Create stow structure
    mkdir -p "$item_dir"
    local parent_in_stow="${item_dir}/$(dirname "$rel_path")"
    mkdir -p "$parent_in_stow"
    
    # Copy to storage
    if [[ -d "$source_path" ]]; then
        cp -a "$source_path" "${parent_in_stow}/"
    else
        cp -a "$source_path" "${parent_in_stow}/"
    fi
    
    # Save metadata
    local meta_file="${item_dir}/.item_meta"
    {
        echo "original_path=$abs_source"
        echo "stow_target=$stow_target"
        echo "added=$(date -Iseconds)"
    } > "$meta_file"
    
    # Remove original
    rm -rf "$source_path"
    
    # Stow to target
    stow_apply "$item_dir" "$stow_target"
    
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
    
    # Get metadata
    local original_path=""
    local stow_target="$HOME"
    local meta_file="${item_dir}/.item_meta"
    if [[ -f "$meta_file" ]]; then
        original_path=$(grep "^original_path=" "$meta_file" | cut -d'=' -f2- || echo "")
        stow_target=$(grep "^stow_target=" "$meta_file" | cut -d'=' -f2- || echo "$HOME")
    fi
    
    # Unstow first (remove symlinks)
    stow_remove "$item_dir" "$stow_target" 2>/dev/null || true
    
    # Restore to original path if we have it
    if [[ -n "$original_path" ]]; then
        log_info "Restoring to original location: $original_path"
        
        # Find the actual content (skip .item_meta)
        for content in "$item_dir"/*; do
            if [[ -e "$content" ]] && [[ "$(basename "$content")" != ".item_meta" ]]; then
                # This is the stow structure, find actual files
                while IFS= read -r -d '' file; do
                    local rel_in_content="${file#$content/}"
                    
                    # Determine if original was a file or directory
                    if [[ -d "$original_path" ]] || [[ "$rel_in_content" == */* ]]; then
                        # Original was a directory, restore structure
                        local target_file="${original_path}/${rel_in_content}"
                        mkdir -p "$(dirname "$target_file")"
                        cp -a "$file" "$target_file"
                        log_debug "Restored: $target_file"
                    else
                        # Original was a single file
                        mkdir -p "$(dirname "$original_path")"
                        cp -a "$file" "$original_path"
                        log_debug "Restored: $original_path"
                    fi
                done < <(find "$content" -type f -print0 2>/dev/null)
            fi
        done
    else
        # Fallback: restore to stow_target using relative path
        log_warning "No original path in metadata, restoring to $stow_target"
        for content in "$item_dir"/*; do
            if [[ -e "$content" ]] && [[ "$(basename "$content")" != ".item_meta" ]]; then
                while IFS= read -r -d '' file; do
                    local rel_path="${file#$item_dir/}"
                    local target="${stow_target}/${rel_path}"
                    mkdir -p "$(dirname "$target")"
                    cp -a "$file" "$target"
                    log_debug "Restored: $target"
                done < <(find "$content" -type f -print0 2>/dev/null)
            fi
        done
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
    
    # Include metadata if available
    local meta_file="${item_dir}/.item_meta"
    if [[ -f "$meta_file" ]]; then
        cat "$meta_file"
    fi
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
            
            local stow_target="$HOME"
            local meta_file="${item_dir}/.item_meta"
            if [[ -f "$meta_file" ]]; then
                stow_target=$(grep "^stow_target=" "$meta_file" | cut -d'=' -f2- || echo "$HOME")
            fi
            
            log_info "Syncing: $name"
            stow_restow "$item_dir" "$stow_target" 2>/dev/null || stow_apply "$item_dir" "$stow_target"
            ((count++))
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
    
    local stow_target="$HOME"
    local meta_file="${item_dir}/.item_meta"
    if [[ -f "$meta_file" ]]; then
        stow_target=$(grep "^stow_target=" "$meta_file" | cut -d'=' -f2- || echo "$HOME")
    fi
    
    stow_apply "$item_dir" "$stow_target"
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
    
    local stow_target="$HOME"
    local meta_file="${item_dir}/.item_meta"
    if [[ -f "$meta_file" ]]; then
        stow_target=$(grep "^stow_target=" "$meta_file" | cut -d'=' -f2- || echo "$HOME")
    fi
    
    stow_remove "$item_dir" "$stow_target"
}

# ==============================================================================
# Storage Edit Operations
# ==============================================================================

# Change stow target for storage item
# Usage: storage_edit_target "name" "new_target"
storage_edit_target() {
    local name="$1"
    local new_target="$2"
    local item_dir="${STORAGE_DIR}/${name}"
    
    if [[ ! -d "$item_dir" ]]; then
        log_error "Storage item not found: $name"
        return 1
    fi
    
    local meta_file="${item_dir}/.item_meta"
    
    # Get current target
    local old_target="$HOME"
    if [[ -f "$meta_file" ]]; then
        old_target=$(grep "^stow_target=" "$meta_file" | cut -d'=' -f2- || echo "$HOME")
    fi
    
    # Unstow from old target
    stow_remove "$item_dir" "$old_target" 2>/dev/null || true
    
    # Update metadata
    if [[ -f "$meta_file" ]]; then
        sed -i "s|^stow_target=.*|stow_target=$new_target|" "$meta_file"
    else
        echo "stow_target=$new_target" > "$meta_file"
    fi
    
    # Stow to new target
    stow_apply "$item_dir" "$new_target"
    
    log_success "Target updated: $name -> $new_target"
}

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
    
    # Get stow target
    local stow_target="$HOME"
    local meta_file="${old_dir}/.item_meta"
    if [[ -f "$meta_file" ]]; then
        stow_target=$(grep "^stow_target=" "$meta_file" | cut -d'=' -f2- || echo "$HOME")
    fi
    
    # Unstow old
    stow_remove "$old_dir" "$stow_target" 2>/dev/null || true
    
    # Rename
    mv "$old_dir" "$new_dir"
    
    # Restow with new name
    stow_apply "$new_dir" "$stow_target"
    
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
    
    find "$item_dir" -type f ! -name ".item_meta" -printf "%P\n" 2>/dev/null | sort
}
