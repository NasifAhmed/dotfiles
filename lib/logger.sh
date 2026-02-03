#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Sync - Logger Library
# ==============================================================================
# Provides logging functionality with timestamps, colors, and file output.
# All logs are written to dotfiles.log with ISO 8601 timestamps.
# ==============================================================================

# Strict mode
set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LOG_FILE="${DOTFILES_DIR}/dotfiles.log"
LOG_LEVEL="${LOG_LEVEL:-info}"

# ==============================================================================
# Colors & Symbols
# ==============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

SYMBOL_SUCCESS="✓"
SYMBOL_ERROR="✗"
SYMBOL_WARNING="⚠"
SYMBOL_INFO="ℹ"
SYMBOL_ARROW="→"
SYMBOL_BULLET="•"

# ==============================================================================
# Internal Functions
# ==============================================================================

# Get current timestamp in ISO 8601 format
_timestamp() {
    date '+%Y-%m-%dT%H:%M:%S%z'
}

# Get short timestamp for display
_short_timestamp() {
    date '+%H:%M:%S'
}

# Write to log file (always, regardless of verbosity)
_write_log() {
    local level="$1"
    local message="$2"
    echo "[$(_timestamp)] [$level] $message" >> "$LOG_FILE"
}

# Check if should display based on log level
_should_display() {
    local level="$1"
    case "$LOG_LEVEL" in
        debug) return 0 ;;
        info)
            [[ "$level" != "DEBUG" ]] && return 0 || return 1
            ;;
        warn)
            [[ "$level" == "WARN" || "$level" == "ERROR" ]] && return 0 || return 1
            ;;
        error)
            [[ "$level" == "ERROR" ]] && return 0 || return 1
            ;;
        *) return 0 ;;
    esac
}

# ==============================================================================
# Public Logging Functions
# ==============================================================================

# Log info message
# Usage: log_info "message"
log_info() {
    local message="$1"
    _write_log "INFO" "$message"
    if _should_display "INFO"; then
        echo -e "${BLUE}${SYMBOL_INFO}${RESET} ${message}"
    fi
}

# Log success message
# Usage: log_success "message"
log_success() {
    local message="$1"
    _write_log "SUCCESS" "$message"
    if _should_display "INFO"; then
        echo -e "${GREEN}${SYMBOL_SUCCESS}${RESET} ${message}"
    fi
}

# Log warning message
# Usage: log_warning "message"
log_warning() {
    local message="$1"
    _write_log "WARN" "$message"
    if _should_display "WARN"; then
        echo -e "${YELLOW}${SYMBOL_WARNING}${RESET} ${YELLOW}${message}${RESET}"
    fi
}

# Log error message
# Usage: log_error "message"
log_error() {
    local message="$1"
    _write_log "ERROR" "$message"
    if _should_display "ERROR"; then
        echo -e "${RED}${SYMBOL_ERROR}${RESET} ${RED}${message}${RESET}" >&2
    fi
}

# Log debug message
# Usage: log_debug "message"
log_debug() {
    local message="$1"
    _write_log "DEBUG" "$message"
    if _should_display "DEBUG"; then
        echo -e "${DIM}[DEBUG] ${message}${RESET}"
    fi
}

# Log a step in a process
# Usage: log_step "step number" "total steps" "message"
log_step() {
    local step="$1"
    local total="$2"
    local message="$3"
    _write_log "STEP" "[$step/$total] $message"
    echo -e "${CYAN}${SYMBOL_ARROW}${RESET} ${BOLD}[$step/$total]${RESET} ${message}"
}

# Log a section header
# Usage: log_section "section title"
log_section() {
    local title="$1"
    local line
    line=$(printf '─%.0s' {1..50})
    _write_log "SECTION" "$title"
    echo -e "\n${BOLD}${PURPLE}$line${RESET}"
    echo -e "${BOLD}${PURPLE}  $title${RESET}"
    echo -e "${BOLD}${PURPLE}$line${RESET}\n"
}

# Log a subsection
# Usage: log_subsection "title"
log_subsection() {
    local title="$1"
    _write_log "SUBSECTION" "$title"
    echo -e "\n${BOLD}${CYAN}${SYMBOL_BULLET} $title${RESET}"
}

# Log a key-value pair
# Usage: log_kv "key" "value"
log_kv() {
    local key="$1"
    local value="$2"
    echo -e "  ${DIM}$key:${RESET} ${WHITE}$value${RESET}"
}

# ==============================================================================
# Log File Management
# ==============================================================================

# Initialize log file
log_init() {
    # Create log file if it doesn't exist
    touch "$LOG_FILE"
    _write_log "INIT" "=== New session started ==="
}

# Get last N log entries
# Usage: log_get_recent [count]
log_get_recent() {
    local count="${1:-5}"
    if [[ -f "$LOG_FILE" ]]; then
        tail -n "$count" "$LOG_FILE"
    fi
}

# Get log file path
log_get_path() {
    echo "$LOG_FILE"
}

# Clear log file
log_clear() {
    : > "$LOG_FILE"
    _write_log "CLEAR" "Log file cleared"
}

# Get log file size
log_get_size() {
    if [[ -f "$LOG_FILE" ]]; then
        du -h "$LOG_FILE" | cut -f1
    else
        echo "0"
    fi
}
