#!/usr/bin/env bash
# ==============================================================================
#  DOTMAN - Bootstrap Script
#  Nasif's Dotfiles Manager
# ==============================================================================
# Run this script to set up dotman on a new system.
# It will check and install dependencies, set up the environment,
# create symlinks, and make dotman accessible from anywhere.
#
# Usage:
#   bash bootstrap.sh          # Full bootstrap
#   bash bootstrap.sh --quick  # Quick setup (skip prompts)
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Colors
# ==============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ==============================================================================
# Helpers
# ==============================================================================
info() { echo -e "${BLUE}[*]${RESET} $1"; }
success() { echo -e "${GREEN}[+]${RESET} $1"; }
warning() { echo -e "${YELLOW}[!]${RESET} $1"; }
error() { echo -e "${RED}[X]${RESET} $1"; }

# ==============================================================================
# ASCII Banner
# ==============================================================================
show_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
  +--------------------------------------------------+
  |  ____   ___ _____ __  __    _    _   _           |
  | |  _ \ / _ \_   _|  \/  |  / \  | \ | |          |
  | | | | | | | || | | |\/| | / _ \ |  \| |          |
  | | |_| | |_| || | | |  | |/ ___ \| |\  |          |
  | |____/ \___/ |_| |_|  |_/_/   \_\_| \_|          |
  |                                                  |
  |           Nasif's Dotfiles Manager               |
  |                BOOTSTRAP                         |
  +--------------------------------------------------+
EOF
    echo -e "${RESET}"
}

# ==============================================================================
# Get Script Directory
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==============================================================================
# Detect Package Manager
# ==============================================================================
detect_pm() {
    if command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    elif command -v apk &>/dev/null; then
        echo "apk"
    elif command -v brew &>/dev/null; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# ==============================================================================
# Install Package
# ==============================================================================
install_pkg() {
    local pkg="$1"
    local pm
    pm=$(detect_pm)
    
    info "Installing $pkg..."
    
    case "$pm" in
        pacman)
            sudo pacman -S --noconfirm "$pkg"
            ;;
        apt)
            sudo apt update && sudo apt install -y "$pkg"
            ;;
        dnf)
            sudo dnf install -y "$pkg"
            ;;
        yum)
            sudo yum install -y "$pkg"
            ;;
        zypper)
            sudo zypper install -y "$pkg"
            ;;
        apk)
            sudo apk add "$pkg"
            ;;
        brew)
            brew install "$pkg"
            ;;
        *)
            error "Unknown package manager. Please install $pkg manually."
            return 1
            ;;
    esac
}

# ==============================================================================
# Install Gum
# ==============================================================================
install_gum() {
    local pm
    pm=$(detect_pm)
    
    info "Installing gum (Charmbracelet TUI library)..."
    
    case "$pm" in
        pacman)
            # Try main repos first, then AUR
            if sudo pacman -S --noconfirm gum 2>/dev/null; then
                return 0
            elif command -v yay &>/dev/null; then
                yay -S --noconfirm gum
            elif command -v paru &>/dev/null; then
                paru -S --noconfirm gum
            else
                warning "gum not found in repos. Trying go install..."
                if command -v go &>/dev/null; then
                    go install github.com/charmbracelet/gum@latest
                else
                    warning "Please install gum from https://github.com/charmbracelet/gum"
                    return 1
                fi
            fi
            ;;
        apt)
            # For Debian/Ubuntu - add charm repository
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null || true
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
            sudo apt update && sudo apt install -y gum
            ;;
        dnf)
            echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
            sudo dnf install -y gum
            ;;
        brew)
            brew install gum
            ;;
        *)
            warning "Please install gum manually from https://github.com/charmbracelet/gum"
            return 1
            ;;
    esac
}

# ==============================================================================
# Check Dependencies
# ==============================================================================
check_deps() {
    echo ""
    info "Checking dependencies..."
    echo ""
    
    local deps_ok=true
    
    # Required: git
    if command -v git &>/dev/null; then
        success "git: $(git --version | head -1)"
    else
        error "git: NOT INSTALLED"
        deps_ok=false
    fi
    
    # Required: stow
    if command -v stow &>/dev/null; then
        success "stow: $(stow --version | head -1)"
    else
        error "stow: NOT INSTALLED"
        deps_ok=false
    fi
    
    # Optional but recommended: gum
    if command -v gum &>/dev/null; then
        success "gum: $(gum --version)"
    else
        warning "gum: not installed (will use basic TUI)"
    fi
    
    # Optional fallback: dialog or whiptail
    if command -v dialog &>/dev/null; then
        success "dialog: available"
    elif command -v whiptail &>/dev/null; then
        success "whiptail: available"
    else
        if ! command -v gum &>/dev/null; then
            warning "No TUI tool available (gum/dialog/whiptail) - using basic mode"
        fi
    fi
    
    echo ""
    
    if [[ "$deps_ok" == "false" ]]; then
        return 1
    fi
    return 0
}

# ==============================================================================
# Install Missing Dependencies
# ==============================================================================
install_missing() {
    local quick="${1:-false}"
    
    echo ""
    info "Installing missing dependencies..."
    echo ""
    
    # Git
    if ! command -v git &>/dev/null; then
        install_pkg git || return 1
        success "git installed"
    fi
    
    # Stow
    if ! command -v stow &>/dev/null; then
        install_pkg stow || return 1
        success "stow installed"
    fi
    
    # Gum (optional but recommended)
    if ! command -v gum &>/dev/null; then
        if [[ "$quick" == "true" ]]; then
            install_gum && success "gum installed" || warning "gum installation failed, will use fallback"
        else
            echo ""
            read -rp "Install gum for better TUI? (recommended) [Y/n]: " install_gum_answer
            if [[ "${install_gum_answer,,}" != "n" ]]; then
                install_gum && success "gum installed" || warning "gum installation failed, will use fallback"
            fi
        fi
    fi
    
    return 0
}

# ==============================================================================
# Setup PATH
# ==============================================================================
setup_path() {
    local bin_dir="$HOME/.local/bin"
    
    # Create ~/.local/bin if it doesn't exist
    mkdir -p "$bin_dir"
    
    # Check all shell rc files
    local rc_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile")
    local path_added=false
    
    for rc_file in "${rc_files[@]}"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q 'export PATH=.*\.local/bin' "$rc_file" 2>/dev/null; then
                echo '' >> "$rc_file"
                echo '# Added by dotman' >> "$rc_file"
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc_file"
                success "Added ~/.local/bin to PATH in $(basename "$rc_file")"
                path_added=true
            fi
        fi
    done
    
    if [[ "$path_added" == "false" ]]; then
        # Create .profile if no rc file exists
        if [[ ! -f "$HOME/.bashrc" ]] && [[ ! -f "$HOME/.zshrc" ]]; then
            echo '# Added by dotman' > "$HOME/.profile"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
            success "Created ~/.profile with PATH"
        else
            success "~/.local/bin already in PATH"
        fi
    fi
    
    # Export PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
}

# ==============================================================================
# Setup Environment
# ==============================================================================
setup_env() {
    local bin_dir="$HOME/.local/bin"
    
    echo ""
    info "Setting up environment..."
    echo ""
    
    # Setup PATH first
    setup_path
    
    # Make dotman script executable
    chmod +x "${SCRIPT_DIR}/dotman"
    success "Made dotman script executable"
    
    # Make lib scripts executable
    chmod +x "${SCRIPT_DIR}/lib/"*.sh 2>/dev/null || true
    
    # Create directories
    mkdir -p "${SCRIPT_DIR}/backups"
    mkdir -p "${SCRIPT_DIR}/storage"
    success "Created backups and storage directories"
    
    # Initialize config if needed
    if [[ ! -f "${SCRIPT_DIR}/.dotfiles_config" ]]; then
        cat > "${SCRIPT_DIR}/.dotfiles_config" << 'EOF'
# Dotman Configuration
REMOTE_URL="origin"
DEFAULT_PROFILE=""
AUTO_SYNC="true"
LOG_LEVEL="info"
BACKUP_DIR="backups"
STORAGE_DIR="storage"
EOF
        success "Created default configuration"
    fi
    
    # Create/update symlink in ~/.local/bin
    local target="${SCRIPT_DIR}/dotman"
    local link="${bin_dir}/dotman"
    
    # Remove old symlink if it points elsewhere
    if [[ -L "$link" ]]; then
        local current_target
        current_target=$(readlink -f "$link")
        if [[ "$current_target" != "$target" ]]; then
            rm -f "$link"
        fi
    fi
    
    # Create symlink
    if [[ ! -L "$link" ]]; then
        ln -sf "$target" "$link"
        success "Created symlink: $link -> $target"
    else
        success "Symlink already exists: $link"
    fi
}

# ==============================================================================
# Verify Git Repository
# ==============================================================================
verify_git() {
    echo ""
    info "Verifying git repository..."
    echo ""
    
    if [[ ! -d "${SCRIPT_DIR}/.git" ]]; then
        warning "Not a git repository. Initializing..."
        git init "${SCRIPT_DIR}"
        success "Git repository initialized"
    else
        success "Git repository found"
    fi
    
    # Check for remote
    if git -C "${SCRIPT_DIR}" remote get-url origin &>/dev/null; then
        local remote_url
        remote_url=$(git -C "${SCRIPT_DIR}" remote get-url origin)
        success "Remote: $remote_url"
    else
        warning "No remote configured. Add one with: git remote add origin <url>"
    fi
}

# ==============================================================================
# Detect if First Run on New Machine
# ==============================================================================
detect_new_machine() {
    # Check if profile is set
    if [[ ! -f "${SCRIPT_DIR}/.current_profile" ]]; then
        return 0  # First run
    fi
    
    # Check if symlink exists
    if [[ ! -L "$HOME/.local/bin/dotman" ]]; then
        return 0  # Needs setup
    fi
    
    return 1  # Already set up
}

# ==============================================================================
# Setup Profile on New Machine
# ==============================================================================
setup_new_profile() {
    echo ""
    info "New machine detected! Let's set up your profile..."
    echo ""
    
    # List available profiles
    local profiles=()
    for dir in "${SCRIPT_DIR}"/*/; do
        local name
        name=$(basename "$dir")
        # Skip system directories
        if [[ "$name" != "lib" ]] && \
           [[ "$name" != "backups" ]] && \
           [[ "$name" != "storage" ]] && \
           [[ "$name" != "tests" ]] && \
           [[ "$name" != ".git" ]] && \
           [[ -d "$dir" ]]; then
            # Check if it has subdirectories (actual config)
            if find "$dir" -mindepth 1 -type d 2>/dev/null | head -1 | grep -q .; then
                profiles+=("$name")
            fi
        fi
    done
    
    if [[ ${#profiles[@]} -eq 0 ]]; then
        warning "No profiles found. Create one with 'dotman' after setup."
        return 0
    fi
    
    echo "Available profiles:"
    for i in "${!profiles[@]}"; do
        echo "  $((i+1)). ${profiles[$i]}"
    done
    echo ""
    
    read -rp "Select profile to apply (1-${#profiles[@]}) or Enter to skip: " choice
    
    if [[ -n "$choice" ]] && [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#profiles[@]} ]]; then
        local selected="${profiles[$((choice-1))]}"
        echo "$selected" > "${SCRIPT_DIR}/.current_profile"
        success "Profile set to: $selected"
        
        # Ask to apply profile
        read -rp "Apply profile now (stow configs)? [Y/n]: " apply_answer
        if [[ "${apply_answer,,}" != "n" ]]; then
            info "Applying profile: $selected"
            # Apply each config in the profile
            for config_dir in "${SCRIPT_DIR}/${selected}"/*/; do
                if [[ -d "$config_dir" ]]; then
                    local config_name
                    config_name=$(basename "$config_dir")
                    cd "${SCRIPT_DIR}/${selected}" && stow -v -t "$HOME" "$config_name" 2>/dev/null && \
                        success "Applied: $config_name" || \
                        warning "Conflict applying: $config_name"
                fi
            done
                fi
            done

            # Sync storage after profile application
            if [[ -f "${SCRIPT_DIR}/lib/storage.sh" ]]; then
                echo ""
                info "Syncing storage items..."
                # Source storage lib and run sync
                (source "${SCRIPT_DIR}/lib/logger.sh" && \
                 source "${SCRIPT_DIR}/lib/config.sh" && \
                 source "${SCRIPT_DIR}/lib/stow_manager.sh" && \
                 source "${SCRIPT_DIR}/lib/storage.sh" && \
                 storage_sync) || warning "Storage sync failed"
            fi
        fi
    else
        info "Skipped profile selection"
    fi
}

# ==============================================================================
# Main
# ==============================================================================
main() {
    local quick=false
    
    # Parse arguments
    case "${1:-}" in
        --quick|-q)
            quick=true
            ;;
        --help|-h)
            echo "Usage: bootstrap.sh [--quick]"
            echo ""
            echo "Options:"
            echo "  --quick, -q  Skip interactive prompts"
            echo "  --help, -h   Show this help"
            exit 0
            ;;
    esac
    
    show_banner
    
    info "Starting bootstrap process..."
    info "Script directory: ${SCRIPT_DIR}"
    
    # Check dependencies
    if ! check_deps; then
        if [[ "$quick" == "true" ]]; then
            install_missing "true"
        else
            echo ""
            read -rp "Install missing dependencies? [Y/n]: " install_answer
            if [[ "${install_answer,,}" != "n" ]]; then
                install_missing
            else
                error "Cannot continue without required dependencies."
                exit 1
            fi
        fi
    fi
    
    # Verify dependencies again
    if ! check_deps; then
        error "Dependencies still missing. Please install manually."
        exit 1
    fi
    
    # Setup environment (symlinks, PATH, etc.)
    setup_env
    
    # Verify git
    verify_git
    
    # Check for new machine and offer profile setup
    if detect_new_machine; then
        if [[ "$quick" != "true" ]]; then
            setup_new_profile
        fi
    fi
    
    echo ""
    echo -e "${GREEN}+====================================================+${RESET}"
    echo -e "${GREEN}|            Bootstrap Complete!                     |${RESET}"
    echo -e "${GREEN}+====================================================+${RESET}"
    echo ""
    echo "You can now run dotman from anywhere:"
    echo ""
    echo -e "  ${CYAN}dotman${RESET}            # Launch TUI"
    echo -e "  ${CYAN}dotman --help${RESET}     # Show help"
    echo -e "  ${CYAN}dotman --sync${RESET}     # Quick sync"
    echo -e "  ${CYAN}dotman --status${RESET}   # Show status"
    echo ""
    echo -e "${YELLOW}Note:${RESET} Restart your shell or run: source ~/.bashrc"
    echo ""
    
    # Offer to run dotman
    if [[ "$quick" != "true" ]]; then
        read -rp "Run dotman now? [Y/n]: " run_answer
        if [[ "${run_answer,,}" != "n" ]]; then
            exec "${SCRIPT_DIR}/dotman"
        fi
    fi
}

main "$@"