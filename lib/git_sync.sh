#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Sync - Git Sync Library
# ==============================================================================
# Handles git synchronization with auto conflict resolution and time-travel.
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

# ==============================================================================
# Git Status Functions
# ==============================================================================

# Check if we're in a git repository
# Usage: git_is_repo
git_is_repo() {
    git -C "$DOTFILES_DIR" rev-parse --git-dir &>/dev/null
}

# Get current branch name
# Usage: git_get_branch
git_get_branch() {
    git -C "$DOTFILES_DIR" branch --show-current 2>/dev/null || echo "main"
}

# Get remote URL
# Usage: git_get_remote_url
git_get_remote_url() {
    local remote
    remote=$(config_get "REMOTE_URL")
    git -C "$DOTFILES_DIR" remote get-url "$remote" 2>/dev/null || echo ""
}

# Check if there are uncommitted changes
# Usage: git_has_changes
# Returns: 0 if clean, 1 if dirty
git_has_changes() {
    [[ -n "$(git -C "$DOTFILES_DIR" status --porcelain 2>/dev/null)" ]]
}

# Get number of uncommitted files
# Usage: git_get_changes_count
git_get_changes_count() {
    git -C "$DOTFILES_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' '
}

# Get list of changed files
# Usage: git_get_changed_files
git_get_changed_files() {
    git -C "$DOTFILES_DIR" status --porcelain 2>/dev/null | awk '{print $2}'
}

# Get detailed git status
# Usage: git_check_status
# Returns: clean|dirty|ahead|behind|diverged
git_check_status() {
    local remote
    remote=$(config_get "REMOTE_URL")
    local branch
    branch=$(git_get_branch)
    
    # Fetch quietly first
    git -C "$DOTFILES_DIR" fetch "$remote" 2>/dev/null || true
    
    local local_commit remote_commit base_commit
    local_commit=$(git -C "$DOTFILES_DIR" rev-parse HEAD 2>/dev/null)
    remote_commit=$(git -C "$DOTFILES_DIR" rev-parse "$remote/$branch" 2>/dev/null) || remote_commit="$local_commit"
    base_commit=$(git -C "$DOTFILES_DIR" merge-base HEAD "$remote/$branch" 2>/dev/null) || base_commit="$local_commit"
    
    if [[ "$local_commit" == "$remote_commit" ]]; then
        if git_has_changes; then
            echo "dirty"
        else
            echo "clean"
        fi
    elif [[ "$local_commit" == "$base_commit" ]]; then
        echo "behind"
    elif [[ "$remote_commit" == "$base_commit" ]]; then
        echo "ahead"
    else
        echo "diverged"
    fi
}

# Get ahead/behind counts
# Usage: git_get_ahead_behind
# Returns: "ahead behind" (e.g., "3 2")
git_get_ahead_behind() {
    local remote
    remote=$(config_get "REMOTE_URL")
    local branch
    branch=$(git_get_branch)
    
    local counts
    counts=$(git -C "$DOTFILES_DIR" rev-list --left-right --count HEAD..."$remote/$branch" 2>/dev/null) || echo "0 0"
    echo "$counts"
}

# ==============================================================================
# Commit Information
# ==============================================================================

# Get last commit info
# Usage: git_get_last_commit [format]
# format: hash|message|author|date|short|full
git_get_last_commit() {
    local format="${1:-full}"
    
    case "$format" in
        hash)
            git -C "$DOTFILES_DIR" log -1 --format="%h" 2>/dev/null
            ;;
        message)
            git -C "$DOTFILES_DIR" log -1 --format="%s" 2>/dev/null
            ;;
        author)
            git -C "$DOTFILES_DIR" log -1 --format="%an" 2>/dev/null
            ;;
        date)
            git -C "$DOTFILES_DIR" log -1 --format="%ar" 2>/dev/null
            ;;
        short)
            git -C "$DOTFILES_DIR" log -1 --format="%h - %s (%ar)" 2>/dev/null
            ;;
        full)
            git -C "$DOTFILES_DIR" log -1 --format="%h - %s%n  Author: %an%n  Date: %ar" 2>/dev/null
            ;;
    esac
}

# Get commit count
# Usage: git_get_commit_count
git_get_commit_count() {
    git -C "$DOTFILES_DIR" rev-list --count HEAD 2>/dev/null || echo "0"
}

# ==============================================================================
# Sync Operations
# ==============================================================================

# Auto-commit all changes
# Usage: git_auto_commit [message]
git_auto_commit() {
    local message="${1:-Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')}"
    
    if ! git_has_changes; then
        log_debug "No changes to commit"
        return 0
    fi
    
    log_step 1 3 "Staging changes..."
    git -C "$DOTFILES_DIR" add -A
    
    log_step 2 3 "Creating commit..."
    git -C "$DOTFILES_DIR" commit -m "$message"
    
    log_step 3 3 "Commit created"
    log_success "Committed: $(git_get_last_commit short)"
}

# Pull changes from remote (prefer theirs on conflicts)
# Usage: git_pull_prefer_theirs
git_pull_prefer_theirs() {
    local remote
    remote=$(config_get "REMOTE_URL")
    local branch
    branch=$(git_get_branch)
    
    log_info "Pulling from $remote/$branch..."
    
    # Try normal pull first
    if git -C "$DOTFILES_DIR" pull "$remote" "$branch" --no-edit 2>/dev/null; then
        log_success "Pull completed successfully"
        return 0
    fi
    
    # Handle conflicts by preferring theirs (cloud)
    log_warning "Conflicts detected, preferring cloud version..."
    
    # Backup local changes
    local backup_dir
    backup_dir="$(config_get_backup_dir)/$(date '+%Y-%m-%d_%H-%M-%S')"
    mkdir -p "$backup_dir"
    
    # Get conflicted files
    local conflicts
    conflicts=$(git -C "$DOTFILES_DIR" diff --name-only --diff-filter=U 2>/dev/null || true)
    
    if [[ -n "$conflicts" ]]; then
        log_info "Backing up local versions..."
        while IFS= read -r file; do
            if [[ -f "${DOTFILES_DIR}/${file}" ]]; then
                local backup_path="${backup_dir}/${file}"
                mkdir -p "$(dirname "$backup_path")"
                cp "${DOTFILES_DIR}/${file}" "$backup_path"
                log_debug "Backed up: $file"
            fi
        done <<< "$conflicts"
        
        log_info "Resolving conflicts (prefer cloud)..."
        git -C "$DOTFILES_DIR" checkout --theirs . 2>/dev/null || true
        git -C "$DOTFILES_DIR" add -A
        git -C "$DOTFILES_DIR" commit -m "Auto-resolved conflicts (prefer cloud)" --no-edit 2>/dev/null || true
        
        log_success "Conflicts resolved, local changes backed up to: $backup_dir"
    fi
    
    return 0
}

# Push changes to remote
# Usage: git_push
git_push() {
    local remote
    remote=$(config_get "REMOTE_URL")
    local branch
    branch=$(git_get_branch)
    
    log_info "Pushing to $remote/$branch..."
    
    if git -C "$DOTFILES_DIR" push "$remote" "$branch" 2>&1; then
        log_success "Push completed"
        return 0
    else
        log_error "Push failed"
        return 1
    fi
}

# Smart sync: handles all sync logic
# Usage: git_smart_sync
git_smart_sync() {
    log_section "Git Sync"
    
    if ! git_is_repo; then
        log_error "Not a git repository"
        return 1
    fi
    
    local status
    status=$(git_check_status)
    log_info "Current status: $status"
    
    case "$status" in
        clean)
            log_success "Repository is clean and synced"
            return 0
            ;;
        dirty)
            log_info "Local changes detected"
            git_auto_commit
            git_push
            git_pull_prefer_theirs
            ;;
        behind)
            log_info "Repository is behind remote"
            git_pull_prefer_theirs
            ;;
        ahead)
            log_info "Repository is ahead of remote"
            git_push
            ;;
        diverged)
            log_warning "Repository has diverged from remote"
            git_auto_commit "Pre-sync commit"
            git_pull_prefer_theirs
            git_push
            ;;
    esac
    
    log_success "Sync completed"
    return 0
}

# ==============================================================================
# File Reset
# ==============================================================================

# Reset a specific file to HEAD
# Usage: git_reset_file "filepath"
git_reset_file() {
    local filepath="$1"
    
    log_info "Resetting file: $filepath"
    
    if git -C "$DOTFILES_DIR" checkout HEAD -- "$filepath" 2>/dev/null; then
        log_success "File reset: $filepath"
        return 0
    else
        log_error "Failed to reset: $filepath"
        return 1
    fi
}

# Get list of files that can be reset
# Usage: git_get_resettable_files
git_get_resettable_files() {
    git_get_changed_files
}

# ==============================================================================
# Time Travel / Snapshots
# ==============================================================================

# List all commits as snapshots
# Usage: git_list_snapshots [count]
# Returns: formatted list of commits
git_list_snapshots() {
    local count="${1:-20}"
    
    git -C "$DOTFILES_DIR" log \
        --format="%h|%s|%ar|%an" \
        -n "$count" 2>/dev/null
}

# List snapshots with formatted output
# Usage: git_list_snapshots_formatted [count]
git_list_snapshots_formatted() {
    local count="${1:-20}"
    
    git -C "$DOTFILES_DIR" log \
        --format="%C(yellow)%h%C(reset) %C(white)%s%C(reset) %C(dim)(%ar by %an)%C(reset)" \
        --color=always \
        -n "$count" 2>/dev/null
}

# Get snapshot details
# Usage: git_get_snapshot_details "commit_hash"
git_get_snapshot_details() {
    local hash="$1"
    
    git -C "$DOTFILES_DIR" show \
        --stat \
        --format="%h - %s%n%nAuthor: %an <%ae>%nDate: %ci%n" \
        "$hash" 2>/dev/null
}

# Preview changes in a snapshot
# Usage: git_preview_snapshot "commit_hash"
git_preview_snapshot() {
    local hash="$1"
    
    git -C "$DOTFILES_DIR" show --stat "$hash" 2>/dev/null
}

# Restore to a specific snapshot
# Usage: git_restore_snapshot "commit_hash"
git_restore_snapshot() {
    local hash="$1"
    local branch
    branch=$(git_get_branch)
    
    log_section "Time Travel"
    log_warning "Restoring to snapshot: $hash"
    
    # Create backup branch first
    local backup_branch="backup-$(date '+%Y%m%d-%H%M%S')"
    log_step 1 4 "Creating backup branch: $backup_branch"
    git -C "$DOTFILES_DIR" branch "$backup_branch"
    
    # Commit any uncommitted changes
    if git_has_changes; then
        log_step 2 4 "Saving uncommitted changes..."
        git_auto_commit "Pre-time-travel save"
    fi
    
    log_step 3 4 "Resetting to snapshot..."
    git -C "$DOTFILES_DIR" reset --hard "$hash"
    
    log_step 4 4 "Done!"
    log_success "Restored to snapshot: $hash"
    log_info "Backup branch created: $backup_branch"
    log_info "To return: git checkout $backup_branch"
    
    return 0
}

# Get diff between current and a snapshot
# Usage: git_diff_snapshot "commit_hash"
git_diff_snapshot() {
    local hash="$1"
    
    git -C "$DOTFILES_DIR" diff "$hash"..HEAD --stat 2>/dev/null
}

# List available backup branches (from time travel)
# Usage: git_list_backup_branches
git_list_backup_branches() {
    git -C "$DOTFILES_DIR" branch --list "backup-*" 2>/dev/null | sed 's/^[* ]*//'
}

# Return from time travel (restore backup branch)
# Usage: git_restore_from_backup "backup_branch"
git_restore_from_backup() {
    local backup_branch="$1"
    
    if git -C "$DOTFILES_DIR" rev-parse --verify "$backup_branch" &>/dev/null; then
        local current_branch
        current_branch=$(git_get_branch)
        
        log_info "Restoring from backup: $backup_branch"
        git -C "$DOTFILES_DIR" reset --hard "$backup_branch"
        
        log_success "Restored from backup branch"
        return 0
    else
        log_error "Backup branch not found: $backup_branch"
        return 1
    fi
}

# ==============================================================================
# Repository Info
# ==============================================================================

# Get repository size
# Usage: git_get_repo_size
git_get_repo_size() {
    du -sh "$DOTFILES_DIR" 2>/dev/null | cut -f1
}

# Get git directory size
# Usage: git_get_git_size
git_get_git_size() {
    du -sh "${DOTFILES_DIR}/.git" 2>/dev/null | cut -f1
}
