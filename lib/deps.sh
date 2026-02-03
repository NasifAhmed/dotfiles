#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Sync - Dependencies Library
# ==============================================================================
# Handles dependency verification and auto-installation.
# ==============================================================================

# Strict mode
set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Source logger if available
if [[ -f "${DOTFILES_DIR}/lib/logger.sh" ]]; then
    # shellcheck source=/dev/null
    source "${DOTFILES_DIR}/lib/logger.sh"
fi

# ==============================================================================
# Required Dependencies
# ==============================================================================
declare -A DEPS_REQUIRED=(
    [git]="Version control - required for syncing"
    [stow]="Symlink manager - required for config deployment"
)

declare -A DEPS_OPTIONAL=(
    [gum]="Modern TUI library - for beautiful interface"
    [dialog]="TUI dialogs - fallback interface"
    [whiptail]="TUI dialogs - fallback interface"
)

# ==============================================================================
# Detection Functions
# ==============================================================================

# Check if a command exists
# Usage: deps_command_exists "command"
deps_command_exists() {
    command -v "$1" &>/dev/null
}

# Get which TUI tool is available
# Usage: deps_get_tui_tool
deps_get_tui_tool() {
    if deps_command_exists "gum"; then
        echo "gum"
    elif deps_command_exists "dialog"; then
        echo "dialog"
    elif deps_command_exists "whiptail"; then
        echo "whiptail"
    else
        echo "none"
    fi
}

# ==============================================================================
# Verification Functions
# ==============================================================================

# Check all required dependencies
# Usage: deps_check_required
# Returns: 0 if all present, 1 if missing
deps_check_required() {
    local missing=()
    
    for dep in "${!DEPS_REQUIRED[@]}"; do
        if ! deps_command_exists "$dep"; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        return 1
    fi
    return 0
}

# Get list of missing required dependencies
# Usage: deps_get_missing_required
deps_get_missing_required() {
    local missing=()
    
    for dep in "${!DEPS_REQUIRED[@]}"; do
        if ! deps_command_exists "$dep"; then
            missing+=("$dep")
        fi
    done
    
    echo "${missing[@]:-}"
}

# Check optional dependencies
# Usage: deps_check_optional
# Returns: 0 if at least one TUI tool present
deps_check_optional() {
    [[ "$(deps_get_tui_tool)" != "none" ]]
}

# ==============================================================================
# Installation Functions
# ==============================================================================

# Detect package manager
# Usage: deps_detect_package_manager
deps_detect_package_manager() {
    if deps_command_exists "pacman"; then
        echo "pacman"
    elif deps_command_exists "apt"; then
        echo "apt"
    elif deps_command_exists "dnf"; then
        echo "dnf"
    elif deps_command_exists "yum"; then
        echo "yum"
    elif deps_command_exists "zypper"; then
        echo "zypper"
    elif deps_command_exists "apk"; then
        echo "apk"
    else
        echo "unknown"
    fi
}

# Get install command for a package
# Usage: deps_get_install_cmd "package"
deps_get_install_cmd() {
    local package="$1"
    local pm
    pm=$(deps_detect_package_manager)
    
    case "$pm" in
        pacman) echo "sudo pacman -S --noconfirm $package" ;;
        apt)    echo "sudo apt install -y $package" ;;
        dnf)    echo "sudo dnf install -y $package" ;;
        yum)    echo "sudo yum install -y $package" ;;
        zypper) echo "sudo zypper install -y $package" ;;
        apk)    echo "sudo apk add $package" ;;
        *)      echo "" ;;
    esac
}

# Install gum (Charmbracelet)
# Usage: deps_install_gum
deps_install_gum() {
    local pm
    pm=$(deps_detect_package_manager)
    
    case "$pm" in
        pacman)
            # Check if yay or paru is available for AUR
            if deps_command_exists "yay"; then
                echo "yay -S --noconfirm gum"
            elif deps_command_exists "paru"; then
                echo "paru -S --noconfirm gum"
            else
                # Try community repo
                echo "sudo pacman -S --noconfirm gum"
            fi
            ;;
        apt)
            # For Debian/Ubuntu, use brew or direct binary
            echo "# Install gum via: https://github.com/charmbracelet/gum#installation"
            ;;
        dnf)
            echo "# Install gum via: https://github.com/charmbracelet/gum#installation"
            ;;
        *)
            echo "# Install gum via: https://github.com/charmbracelet/gum#installation"
            ;;
    esac
}

# Install missing required dependencies
# Usage: deps_install_missing
deps_install_missing() {
    local missing
    missing=$(deps_get_missing_required)
    
    if [[ -z "$missing" ]]; then
        return 0
    fi
    
    log_section "Installing Missing Dependencies"
    
    for dep in $missing; do
        local cmd
        cmd=$(deps_get_install_cmd "$dep")
        if [[ -n "$cmd" ]]; then
            log_info "Installing $dep..."
            if eval "$cmd"; then
                log_success "Installed $dep"
            else
                log_error "Failed to install $dep"
                return 1
            fi
        else
            log_error "Cannot auto-install $dep - unknown package manager"
            log_info "Please install manually: $dep"
            return 1
        fi
    done
    
    return 0
}

# ==============================================================================
# Verification & Report
# ==============================================================================

# Print dependency status report
# Usage: deps_print_status
deps_print_status() {
    echo ""
    echo "╭──────────────────────────────────────╮"
    echo "│       Dependency Status              │"
    echo "├──────────────────────────────────────┤"
    
    # Required deps
    for dep in "${!DEPS_REQUIRED[@]}"; do
        if deps_command_exists "$dep"; then
            printf "│  %-14s %s %-17s │\n" "$dep" "✓" "installed"
        else
            printf "│  %-14s %s %-17s │\n" "$dep" "✗" "MISSING"
        fi
    done
    
    echo "├──────────────────────────────────────┤"
    
    # TUI tool
    local tui
    tui=$(deps_get_tui_tool)
    if [[ "$tui" == "gum" ]]; then
        printf "│  %-14s %s %-17s │\n" "TUI" "✓" "gum (best)"
    elif [[ "$tui" != "none" ]]; then
        printf "│  %-14s %s %-17s │\n" "TUI" "✓" "$tui (fallback)"
    else
        printf "│  %-14s %s %-17s │\n" "TUI" "!" "basic mode"
    fi
    
    echo "╰──────────────────────────────────────╯"
    echo ""
}

# Verify all dependencies and report
# Usage: deps_verify_all
# Returns: 0 if ready, 1 if critical deps missing
deps_verify_all() {
    if ! deps_check_required; then
        local missing
        missing=$(deps_get_missing_required)
        log_error "Missing required dependencies: $missing"
        deps_print_status
        return 1
    fi
    
    if ! deps_check_optional; then
        log_warning "No TUI tool found (gum/dialog/whiptail) - using basic mode"
    fi
    
    return 0
}

# Ensure ~/.local/bin is in PATH
# Usage: deps_ensure_local_bin_path
deps_ensure_local_bin_path() {
    local local_bin="$HOME/.local/bin"
    
    # Create directory if it doesn't exist
    mkdir -p "$local_bin"
    
    # Check if already in PATH
    if [[ ":$PATH:" != *":$local_bin:"* ]]; then
        log_info "Adding $local_bin to PATH..."
        
        # Determine shell config file
        local shell_rc=""
        if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh"* ]]; then
            shell_rc="$HOME/.zshrc"
        elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == *"bash"* ]]; then
            shell_rc="$HOME/.bashrc"
        fi
        
        if [[ -n "$shell_rc" ]] && [[ -f "$shell_rc" ]]; then
            # Check if already added
            if ! grep -q 'export PATH=.*\.local/bin' "$shell_rc" 2>/dev/null; then
                echo '' >> "$shell_rc"
                echo '# Added by dotfiles manager' >> "$shell_rc"
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
                log_success "Added ~/.local/bin to $shell_rc"
                log_info "Run 'source $shell_rc' or restart shell to apply"
            fi
        fi
        
        # Also export for current session
        export PATH="$local_bin:$PATH"
    fi
}
