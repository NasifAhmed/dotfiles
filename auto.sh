#!/usr/bin/env bash

#######################################
# Linux System Setup Script
# Author: Nasif Ahmed
# Version: 2.0
# Created: 2024
# Updated: May 2025
#######################################
# This script automates the installation of essential packages and
# configuration of personal Linux systems. It includes package management,
# dotfiles setup, font installation, and more.
#
# IMPORTANT: This script is personalized and not intended for general use without review.
#######################################

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure script is sourced with the correct path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Color Definitions ---
readonly RESET="\033[0m"
readonly RED="\033[0;31m"
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[0;33m"
readonly BLUE="\033[0;34m"
readonly PURPLE="\033[0;35m"
readonly CYAN="\033[0;36m"
readonly BOLD="\033[1m"

# --- Config Variables ---
DOTFILES_REPO="git@github.com:NasifAhmed/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
TEMP_DIR="/tmp/linux-setup-$(date +%s)"
LOG_FILE="$TEMP_DIR/setup.log"
FNM_VERSION="1.35.1" # Latest stable FNM version

# --- Package Lists by Distribution ---
PACMAN_PACKAGES=(
    "git" "wget" "curl" "make" "gcc" "unzip" "openssh" "openssl" "stow"
    "ripgrep" "fd" "fontconfig" "tldr" "fastfetch" "tree" "neovim" "fzf"
    "bat" "jq"
)

DNF_PACKAGES=(
    "git" "wget" "curl" "make" "gcc" "unzip" "openssh-clients" "openssl"
    "stow" "ripgrep" "fd-find" "fontconfig" "tldr" "fastfetch" "tree"
    "neovim" "fzf" "bat" "jq"
)

APT_PACKAGES=(
    "git" "wget" "curl" "make" "gcc" "unzip" "openssh-client" "openssl"
    "stow" "ripgrep" "fd-find" "fontconfig" "tldr" "fastfetch" "tree"
    "nala" "bat" "jq"
)

# --- Bootstrap Dependencies ---
BOOTSTRAP_APT=("curl" "wget" "git" "unzip")
BOOTSTRAP_DNF=("curl" "wget" "git" "unzip")
BOOTSTRAP_PACMAN=("curl" "wget" "git" "unzip")

# --- Font Information ---
declare -A FONTS=(
    ["JetBrainsMono"]="https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono-2.304.zip"
    ["FiraCode"]="https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
    ["Roboto"]="https://github.com/googlefonts/roboto/releases/latest/download/roboto-unhinted.zip"
)

NERD_FONTS=(
    "JetBrainsMono"
    "FiraCode"
)

#######################################
# UTILITY FUNCTIONS
#######################################

# Initialize the environment for script execution
init_environment() {
    mkdir -p "$TEMP_DIR"
    touch "$LOG_FILE"
    log_info "Initializing environment..."
    trap cleanup EXIT INT TERM
}

# Clean up temporary files and exit
cleanup() {
    log_info "Cleaning up..."
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    log_info "Cleanup complete"
}

# Logging functions
log_info() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${BLUE}[INFO]${RESET} $timestamp: $*" | tee -a "$LOG_FILE"
}

log_success() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${GREEN}[SUCCESS]${RESET} $timestamp: $*" | tee -a "$LOG_FILE"
}

log_warning() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${YELLOW}[WARNING]${RESET} $timestamp: $*" | tee -a "$LOG_FILE"
}

log_error() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${RED}[ERROR]${RESET} $timestamp: $*" | tee -a "$LOG_FILE"
}

# Error handling function
handle_error() {
    local message="$1"
    local suggestion="${2:-No suggestion available}"
    local exit_code="${3:-1}"

    log_error "$message"
    log_info "Suggestion: $suggestion"

    echo -e "\n${YELLOW}Press Enter to continue or Ctrl+C to exit...${RESET}"
    read -r

    # If exit code is non-zero, return that value (but don't exit)
    return $exit_code
}

# Backup a file before modifying it
backup_file() {
    local file="$1"
    local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"

    if [[ -f "$file" ]]; then
        log_info "Backing up $file to $backup"
        if sudo cp -f "$file" "$backup"; then
            log_success "Backup of $file created successfully"
            return 0
        else
            handle_error "Failed to create backup of $file" "Check permissions or disk space"
            return 1
        fi
    else
        log_warning "File $file doesn't exist. No backup created."
        return 0
    fi
}

# Prompt user for confirmation
confirm() {
    local prompt="$1"
    local default="${2:-y}"

    local options="[y/n]"
    if [[ "$default" = "y" ]]; then
        options="[Y/n]"
    else
        options="[y/N]"
    fi

    local answer
    read -p "$prompt $options " answer
    answer=${answer:-$default}

    [[ "$answer" =~ ^[Yy]$ ]]
}

# Wait for user confirmation to continue
press_enter_to_continue() {
    local message="${1:-Press Enter to continue...}"
    echo -e "\n${CYAN}$message${RESET}"
    read -r
}

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Print a separator line
print_separator() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# Print section header
print_header() {
    local title="$1"
    print_separator
    echo -e "${BOLD}${PURPLE}  $title  ${RESET}"
    print_separator
    echo
}

# Bootstrap the script's dependencies
bootstrap_dependencies() {
    local pkg_manager=$(detect_package_manager)

    log_info "Checking for bootstrap dependencies..."
    local missing_deps=()

    case "$pkg_manager" in
    "apt")
        for dep in "${BOOTSTRAP_APT[@]}"; do
            if ! command_exists "$dep"; then
                missing_deps+=("$dep")
            fi
        done
        if [[ ${#missing_deps[@]} -gt 0 ]]; then
            log_info "Installing missing dependencies: ${missing_deps[*]}"
            sudo apt update
            sudo apt install -y "${missing_deps[@]}"
        fi
        ;;
    "dnf")
        for dep in "${BOOTSTRAP_DNF[@]}"; do
            if ! command_exists "$dep"; then
                missing_deps+=("$dep")
            fi
        done
        if [[ ${#missing_deps[@]} -gt 0 ]]; then
            log_info "Installing missing dependencies: ${missing_deps[*]}"
            sudo dnf install -y "${missing_deps[@]}"
        fi
        ;;
    "pacman")
        for dep in "${BOOTSTRAP_PACMAN[@]}"; do
            if ! command_exists "$dep"; then
                missing_deps+=("$dep")
            fi
        done
        if [[ ${#missing_deps[@]} -gt 0 ]]; then
            log_info "Installing missing dependencies: ${missing_deps[*]}"
            sudo pacman -Sy --noconfirm "${missing_deps[@]}"
        fi
        ;;
    *)
        log_warning "Unknown package manager. Cannot bootstrap dependencies."
        return 1
        ;;
    esac

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_success "Bootstrap dependencies installed successfully"
    else
        log_info "All bootstrap dependencies already installed"
    fi
}

#######################################
# SYSTEM DETECTION FUNCTIONS
#######################################

# Detect the distribution package manager
detect_package_manager() {
    if command_exists apt; then
        echo "apt"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists pacman; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Get appropriate package list based on detected package manager
get_package_list() {
    local manager="$1"

    case "$manager" in
    "apt")
        echo "${APT_PACKAGES[*]}"
        ;;
    "dnf")
        echo "${DNF_PACKAGES[*]}"
        ;;
    "pacman")
        echo "${PACMAN_PACKAGES[*]}"
        ;;
    *)
        return 1
        ;;
    esac
}

#######################################
# PACKAGE MANAGEMENT FUNCTIONS
#######################################

# Initialize and optimize package manager based on distribution
init_package_manager() {
    local manager="$1"

    log_info "Initializing package manager: $manager"

    case "$manager" in
    "apt")
        init_apt_manager
        ;;
    "dnf")
        init_dnf_manager
        ;;
    "pacman")
        init_pacman_manager
        ;;
    *)
        handle_error "Unsupported package manager" "This script supports apt, dnf, and pacman."
        return 1
        ;;
    esac

    # Update the system
    update_system "$manager"
}

# Initialize apt package manager (Debian/Ubuntu)
init_apt_manager() {
    log_info "Configuring apt package manager..."

    # Skip apt configuration as apt is good by default
    log_info "Using default apt configuration"

    # Update package lists
    sudo apt update || handle_error "Failed to update apt" "Check network connection and repositories"

    log_success "apt package manager initialized successfully"
}

# Initialize dnf package manager (Fedora)
init_dnf_manager() {
    log_info "Configuring dnf package manager..."

    # Backup dnf.conf
    backup_file "/etc/dnf/dnf.conf"

    # Optimize dnf configuration
    if ! grep -q "fastestmirror=True" /etc/dnf/dnf.conf; then
        log_info "Enabling fastestmirror in dnf.conf..."
        echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
    fi

    if ! grep -q "max_parallel_downloads=10" /etc/dnf/dnf.conf; then
        log_info "Setting max_parallel_downloads to 10 in dnf.conf..."
        echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
    fi

    if ! grep -q "deltarpm=true" /etc/dnf/dnf.conf; then
        log_info "Enabling deltarpm in dnf.conf..."
        echo "deltarpm=true" | sudo tee -a /etc/dnf/dnf.conf
    fi

    # Install RPM Fusion repositories
    log_info "Enabling RPM Fusion repositories..."
    sudo dnf install -y \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    log_success "dnf package manager configured successfully"
}

# Initialize pacman package manager (Arch Linux)
init_pacman_manager() {
    log_info "Configuring pacman package manager..."

    # Backup pacman.conf
    backup_file "/etc/pacman.conf"

    # Sync repositories
    sudo pacman -Sy

    # Install reflector if not already installed
    if ! pacman -Qi reflector &>/dev/null; then
        log_info "Installing reflector for mirror management..."
        sudo pacman -S --noconfirm reflector
    fi

    # Update mirrorlist with reflector
    log_info "Updating mirrorlist with reflector..."
    sudo reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

    # Enable color and parallel downloads in pacman.conf
    if ! grep -q "^Color" /etc/pacman.conf; then
        log_info "Enabling color in pacman.conf..."
        sudo sed -i '/^#Color/s/^#//' /etc/pacman.conf
    fi

    if ! grep -q "^ParallelDownloads = " /etc/pacman.conf; then
        log_info "Setting ParallelDownloads in pacman.conf..."
        sudo sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
    fi

    # Add ILoveCandy for fun pacman progress
    if ! grep -q "ILoveCandy" /etc/pacman.conf; then
        log_info "Adding ILoveCandy to pacman.conf..."
        sudo sed -i '/# Misc options/a ILoveCandy' /etc/pacman.conf
    fi

    log_success "pacman package manager configured successfully"
}

# Update the system packages
update_system() {
    local manager="$1"

    log_info "Updating system packages..."

    case "$manager" in
    "apt")
        # Use nala if available, otherwise fall back to apt
        if command_exists nala; then
            sudo nala update && sudo nala upgrade -y
        else
            sudo apt update && sudo apt upgrade -y
        fi
        ;;
    "dnf")
        sudo dnf upgrade -y
        ;;
    "pacman")
        sudo pacman -Syu --noconfirm
        ;;
    *)
        handle_error "Unknown package manager, skipping system update" "Supported: apt, dnf, pacman"
        return 1
        ;;
    esac

    log_success "System update completed"
}

# Install packages from list
install_packages() {
    local manager="$1"
    shift                 # Remove first parameter
    local packages=("$@") # Get all remaining parameters as array

    log_info "Installing packages with $manager..."

    case "$manager" in
    "apt")
        install_apt_packages "${packages[@]}"
        ;;
    "dnf")
        install_dnf_packages "${packages[@]}"
        ;;
    "pacman")
        install_pacman_packages "${packages[@]}"
        ;;
    *)
        handle_error "Unknown package manager" "Supported: apt, dnf, pacman"
        return 1
        ;;
    esac

    # Install fzf and neovim from source for apt systems
    if [[ "$manager" == "apt" ]]; then
        install_fzf_from_github
        install_neovim_from_source
    fi

    log_success "Package installation completed"
}

# Install packages using apt
install_apt_packages() {
    local packages=("$@")
    local install_cmd

    # Use nala if available, otherwise fall back to apt
    if command_exists nala; then
        install_cmd="sudo nala install -y"
    else
        install_cmd="sudo apt install -y"
    fi

    for pkg in "${packages[@]}"; do
        # Skip nala if we're already using it (to avoid circular dependency)
        if [[ "$pkg" == "nala" ]] && command_exists nala; then
            log_info "Package $pkg is already installed, skipping"
            continue
        fi

        if dpkg -s "$pkg" &>/dev/null; then
            log_info "Package $pkg is already installed, skipping"
        else
            log_info "Installing package: $pkg"
            $install_cmd "$pkg" || log_warning "Failed to install $pkg, continuing with next package"
        fi
    done
}

# Install packages using dnf
install_dnf_packages() {
    local packages=("$@")

    for pkg in "${packages[@]}"; do
        if rpm -q "$pkg" &>/dev/null; then
            log_info "Package $pkg is already installed, skipping"
        else
            log_info "Installing package: $pkg"
            sudo dnf install -y "$pkg" || log_warning "Failed to install $pkg, continuing with next package"
        fi
    done
}

# Install packages using pacman
install_pacman_packages() {
    local packages=("$@")

    for pkg in "${packages[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            log_info "Package $pkg is already installed, skipping"
        else
            log_info "Installing package: $pkg"
            sudo pacman -S --noconfirm "$pkg" || log_warning "Failed to install $pkg, continuing with next package"
        fi
    done
}

# Install fzf from GitHub (for apt-based systems)
install_fzf_from_github() {
    if command_exists fzf; then
        log_info "fzf is already installed, checking if it was installed from GitHub"

        # Check if fzf was installed via git (look for .fzf directory)
        if [[ -d "$HOME/.fzf" ]]; then
            log_info "fzf is already installed from GitHub, updating"
            cd "$HOME/.fzf" && git pull && ./install --all
            # Source bashrc to make fzf available immediately
            source "$HOME/.bashrc" 2>/dev/null || source "$HOME/.zshrc" 2>/dev/null
            log_success "fzf updated successfully"
            return 0
        else
            log_info "fzf is installed but not from GitHub, proceeding with GitHub installation"
        fi
    fi

    log_info "Installing fzf from GitHub..."

    # Clone fzf repository
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"

    # Run the install script
    "$HOME/.fzf/install" --all

    # Source bashrc to make fzf available immediately
    source "$HOME/.bashrc" 2>/dev/null || source "$HOME/.zshrc" 2>/dev/null

    # Verify installation
    if command_exists fzf; then
        log_success "fzf installed successfully from GitHub"
    else
        handle_error "Failed to install fzf from GitHub" "Try manual installation or restart terminal"
        return 1
    fi
}

# Install Neovim from source (for apt-based systems)
install_neovim_from_source() {
    if command_exists nvim; then
        local current_version=$(nvim --version | head -n1)
        log_info "Neovim is already installed: $current_version, checking for updates"

        # Implement version checking here if needed
    fi

    log_info "Installing Neovim dependencies..."
    local neovim_deps="ninja-build gettext cmake unzip curl build-essential"

    # Use nala if available
    if command_exists nala; then
        sudo nala install -y $neovim_deps
    else
        sudo apt install -y $neovim_deps
    fi

    log_info "Downloading and building Neovim from source..."
    cd "$TEMP_DIR"

    # Clone the repository
    git clone --depth=1 https://github.com/neovim/neovim

    # Build and install
    cd neovim
    make CMAKE_BUILD_TYPE=Release -j$(nproc)
    sudo make install

    # Verify installation
    if command_exists nvim; then
        local installed_version=$(nvim --version | head -n1)
        log_success "Neovim installed successfully: $installed_version"
    else
        handle_error "Failed to install Neovim from source" "Try installing from package manager"
        return 1
    fi
}

# Verify package installation
verify_packages() {
    local packages=($1)
    local all_installed=true

    log_info "Verifying package installation..."

    for pkg in "${packages[@]}"; do
        # Custom check for fzf and neovim which might be installed from source
        if [[ "$pkg" == "fzf" ]] && command_exists fzf; then
            log_success "✅ $pkg is installed"
            continue
        elif [[ "$pkg" == "neovim" ]] && (command_exists nvim || command_exists neovim); then
            log_success "✅ $pkg is installed"
            continue
        fi

        # Distribution-specific checks
        case "$(detect_package_manager)" in
        "apt")
            if dpkg -s "$pkg" &>/dev/null; then
                log_success "✅ $pkg is installed"
            else
                log_warning "⚠️ $pkg is not installed or detected"
                all_installed=false
            fi
            ;;
        "dnf")
            if rpm -q "$pkg" &>/dev/null; then
                log_success "✅ $pkg is installed"
            else
                log_warning "⚠️ $pkg is not installed or detected"
                all_installed=false
            fi
            ;;
        "pacman")
            if pacman -Qi "$pkg" &>/dev/null; then
                log_success "✅ $pkg is installed"
            else
                log_warning "⚠️ $pkg is not installed or detected"
                all_installed=false
            fi
            ;;
        esac
    done

    if $all_installed; then
        log_success "All packages verified successfully"
    else
        log_warning "Some packages could not be verified"
    fi
}

#######################################
# SSH & GIT CONFIGURATION FUNCTIONS
#######################################

# Configure SSH and Git
configure_ssh_git() {
    print_header "SSH and Git Configuration"

    local ssh_dir="$HOME/.ssh"
    local key_file="$ssh_dir/id_ed25519"

    # Get user information
    echo -e "${CYAN}Let's configure your Git identity:${RESET}"
    local git_name=""
    local git_email=""

    while [[ -z "$git_name" ]]; do
        read -p "Enter your name for Git configuration: " git_name
    done

    while [[ -z "$git_email" || ! "$git_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; do
        read -p "Enter your email for Git configuration: " git_email
        if [[ -n "$git_email" && ! "$git_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            log_warning "Invalid email format. Please try again."
        fi
    done

    # Check for existing SSH key
    if [[ -f "$key_file" ]]; then
        log_info "SSH key already exists at $key_file"
        echo -e "\n${CYAN}Your existing SSH public key:${RESET}"
        cat "${key_file}.pub"
    else
        # Create .ssh directory if it doesn't exist
        mkdir -p "$ssh_dir"
        chmod 700 "$ssh_dir"

        # Generate new SSH key
        log_info "Generating new SSH key..."
        ssh-keygen -t ed25519 -C "$git_email" -f "$key_file" -N "" || {
            handle_error "Failed to generate SSH key" "Check if ssh-keygen is installed"
            return 1
        }

        log_success "SSH key generated successfully"
        echo -e "\n${CYAN}Your new SSH public key:${RESET}"
        cat "${key_file}.pub"
    fi

    # Set up SSH config if it doesn't exist
    local ssh_config="$ssh_dir/config"
    if [[ ! -f "$ssh_config" ]]; then
        log_info "Creating SSH config file..."
        cat >"$ssh_config" <<EOL
Host github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    
Host gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOL
        chmod 600 "$ssh_config"
        log_success "SSH config created successfully"
    fi

    # Start ssh-agent if not running
    if ! ps -p $SSH_AGENT_PID &>/dev/null; then
        log_info "Starting ssh-agent..."
        eval "$(ssh-agent -s)"
    fi

    # Add key to ssh-agent
    ssh-add "$key_file" 2>/dev/null || log_warning "Failed to add key to ssh-agent"

    echo -e "\n${YELLOW}Please add this SSH key to your GitHub account.${RESET}"
    echo -e "${BLUE}Instructions:${RESET}"
    echo "1. Go to GitHub → Settings → SSH and GPG keys → New SSH key"
    echo "2. Paste your public key and save"
    press_enter_to_continue "Press Enter after adding the key to GitHub..."

    # Test SSH connection
    log_info "Testing SSH connection to GitHub..."
    ssh -T git@github.com -o StrictHostKeyChecking=no || true

    # Configure Git
    log_info "Configuring Git..."
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"

    # Configure additional Git settings
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor "$(which nvim 2>/dev/null || which vim 2>/dev/null || which vi)"
    git config --global core.autocrlf input

    log_success "Git configured successfully"
}

#######################################
# DOTFILES MANAGEMENT FUNCTIONS
#######################################

# Clone dotfiles repository
clone_dotfiles() {
    print_header "Dotfiles Repository"

    if [[ -d "$DOTFILES_DIR" ]]; then
        log_warning "Dotfiles directory already exists at $DOTFILES_DIR"

        if confirm "Would you like to update existing dotfiles?"; then
            log_info "Updating existing dotfiles..."
            cd "$DOTFILES_DIR"
            git pull || handle_error "Failed to update dotfiles" "Check your internet connection and GitHub SSH setup"
            log_success "Dotfiles updated successfully"
        elif confirm "Would you like to backup and re-clone the dotfiles?"; then
            local backup_dir="${DOTFILES_DIR}.bak.$(date +%Y%m%d%H%M%S)"
            log_info "Backing up dotfiles to $backup_dir..."
            mv "$DOTFILES_DIR" "$backup_dir"

            log_info "Cloning dotfiles repository..."
            git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || {
                handle_error "Failed to clone dotfiles" "Check your internet connection and GitHub SSH setup"
                # Restore backup if clone fails
                mv "$backup_dir" "$DOTFILES_DIR"
                return 1
            }
            log_success "Dotfiles cloned successfully"
        else
            log_info "Skipping dotfiles management"
            return 0
        fi
    else
        log_info "Cloning dotfiles repository..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || {
            handle_error "Failed to clone dotfiles" "Check your internet connection and GitHub SSH setup"
            return 1
        }
        log_success "Dotfiles cloned successfully"
    fi
}

# Configure dotfiles using stow
setup_dotfiles() {
    print_header "Dotfiles Setup"

    # Check if stow is installed
    if ! command_exists stow; then
        log_error "GNU Stow is not installed but required for dotfiles setup"

        if confirm "Would you like to install GNU Stow now?"; then
            local pkg_manager=$(detect_package_manager)
            case "$pkg_manager" in
            "apt")
                if command_exists nala; then
                    sudo nala install -y stow
                else
                    sudo apt install -y stow
                fi
                ;;
            "dnf")
                sudo dnf install -y stow
                ;;
            "pacman")
                sudo pacman -S --noconfirm stow
                ;;
            *)
                handle_error "Cannot install stow: unknown package manager" "Install GNU Stow manually"
                return 1
                ;;
            esac
        else
            log_warning "Skipping dotfiles setup due to missing GNU Stow"
            return 1
        fi
    fi

    # Check if dotfiles directory exists
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_warning "Dotfiles directory not found at $DOTFILES_DIR"

        if confirm "Would you like to clone the dotfiles repository?"; then
            clone_dotfiles || return 1
        else
            log_warning "Skipping dotfiles setup due to missing dotfiles directory"
            return 1
        fi
    fi

    # Find stow directory
    local stow_dir="$DOTFILES_DIR/stow"
    if [[ ! -d "$stow_dir" ]]; then
        stow_dir="$DOTFILES_DIR"
    fi

    # Backup important config files before stowing
    backup_configs

    # Get list of packages to stow
    local packages=()
    for dir in "$stow_dir"/*; do
        if [[ -d "$dir" ]]; then
            packages+=("$(basename "$dir")")
        fi
    done

    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warning "No stow packages found in $stow_dir"
        return 1
    fi

    # Show package selection menu
    echo -e "${CYAN}Available dotfiles packages:${RESET}"
    for i in "${!packages[@]}"; do
        echo "  $((i + 1)). ${packages[i]}"
    done
    echo "  $((${#packages[@]} + 1)). All packages"
    echo "  $((${#packages[@]} + 2)). Skip"

    local selection
    read -p "Enter your choice [1-$((${#packages[@]} + 2))]: " selection

    # Process selection
    if [[ "$selection" -eq "$((${#packages[@]} + 1))" ]]; then
        # Stow all packages
        for pkg in "${packages[@]}"; do
            stow_package "$stow_dir" "$pkg"
        done
    elif [[ "$selection" -eq "$((${#packages[@]} + 2))" ]]; then
        log_info "Skipping dotfiles setup"
        return 0
    elif [[ "$selection" -ge 1 && "$selection" -le "${#packages[@]}" ]]; then
        # Stow selected package
        stow_package "$stow_dir" "${packages[$((selection - 1))]}"
    else
        log_warning "Invalid selection, skipping dotfiles setup"
        return 1
    fi

    log_success "Dotfiles setup completed"
}

# Function to stow a single package
stow_package() {
    local stow_dir="$1"
    local package="$2"

    log_info "Stowing package: $package"

    # Check if the package directory exists
    if [[ ! -d "$stow_dir/$package" ]]; then
        log_error "Package directory $stow_dir/$package does not exist"
        return 1
    fi

    # Run stow command
    if stow -d "$stow_dir" -t "$HOME" -R "$package"; then
        log_success "Successfully stowed $package"
        return 0
    else
        log_error "Failed to stow $package"

        # Try to unstow first in case of conflicts, then stow again
        if confirm "Would you like to try force-restowing $package?"; then
            stow -d "$stow_dir" -t "$HOME" -D "$package" 2>/dev/null
            if stow -d "$stow_dir" -t "$HOME" -R "$package"; then
                log_success "Successfully re-stowed $package"
                return 0
            else
                handle_error "Failed to re-stow $package" "Check for conflicts manually"
                return 1
            fi
        fi

        return 1
    fi
}

# Backup configuration files that might be overwritten by stow
backup_configs() {
    log_info "Backing up existing configuration files..."

    local backup_files=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.tmux.conf"
        "$HOME/.vimrc"
        "$HOME/.gitconfig"
        "$HOME/.config/nvim/init.vim"
        "$HOME/.config/nvim/init.lua"
    )

    for file in "${backup_files[@]}"; do
        if [[ -f "$file" && ! -L "$file" ]]; then # Only backup regular files, not symlinks
            local backup="$file.bak.$(date +%Y%m%d%H%M%S)"
            log_info "Backing up $file to $backup"
            cp "$file" "$backup"
        fi
    done
}

#######################################
# FONT INSTALLATION FUNCTIONS
#######################################

# Install fonts
install_fonts() {
    print_header "Font Installation"

    # Ensure required tools are installed
    local tools_missing=false
    for tool in curl unzip fc-cache; do
        if ! command_exists "$tool"; then
            log_warning "Required tool '$tool' is not installed"
            tools_missing=true
        fi
    done

    if $tools_missing; then
        log_info "Installing required tools..."
        local pkg_manager=$(detect_package_manager)

        case "$pkg_manager" in
        "apt")
            if command_exists nala; then
                sudo nala install -y curl unzip fontconfig
            else
                sudo apt install -y curl unzip fontconfig
            fi
            ;;
        "dnf")
            sudo dnf install -y curl unzip fontconfig
            ;;
        "pacman")
            sudo pacman -S --noconfirm curl unzip fontconfig
            ;;
        *)
            handle_error "Cannot install required tools: unknown package manager" "Install curl, unzip, fontconfig manually"
            return 1
            ;;
        esac
    fi

    # Create fonts directory
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"

    # Check which fonts are already installed
    log_info "Checking installed fonts..."
    local fonts_to_install=()
    local installed_fonts=()

    for font_name in "${!FONTS[@]}"; do
        if fc-list | grep -i "$font_name" &>/dev/null; then
            installed_fonts+=("$font_name")
            log_info "Font already installed: $font_name"
        else
            fonts_to_install+=("$font_name")
        fi
    done

    # Check for Nerd Fonts
    local nerd_fonts_to_install=()
    for font_name in "${NERD_FONTS[@]}"; do
        if fc-list | grep -i "${font_name}Nerd" &>/dev/null; then
            installed_fonts+=("${font_name} Nerd Font")
            log_info "Nerd Font already installed: ${font_name} Nerd Font"
        else
            nerd_fonts_to_install+=("$font_name")
        fi
    done

    # Display menu of installable fonts
    if [[ ${#fonts_to_install[@]} -eq 0 && ${#nerd_fonts_to_install[@]} -eq 0 ]]; then
        log_success "All fonts are already installed"
        return 0
    fi

    echo -e "${CYAN}Fonts to install:${RESET}"
    local counter=1

    for font in "${fonts_to_install[@]}"; do
        echo "  $counter. $font"
        ((counter++))
    done

    for font in "${nerd_fonts_to_install[@]}"; do
        echo "  $counter. $font Nerd Font"
        ((counter++))
    done

    echo "  $counter. Install Windows Fonts"
    local windows_fonts_option=$counter
    ((counter++))

    echo "  $counter. Install all fonts"
    local all_fonts_option=$counter
    ((counter++))

    echo "  $counter. Skip font installation"
    local skip_option=$counter

    # Process selection
    local selection
    read -p "Enter your choice [1-$counter]: " selection

    if [[ "$selection" -eq "$windows_fonts_option" ]]; then
        install_windows_fonts
    elif [[ "$selection" -eq "$all_fonts_option" ]]; then
        # Install all regular fonts
        for font in "${fonts_to_install[@]}"; do
            install_font "$font" "${FONTS[$font]}"
        done

        # Install all nerd fonts
        for font in "${nerd_fonts_to_install[@]}"; do
            install_nerd_font "$font"
        done

        # Install Windows fonts
        install_windows_fonts
    elif [[ "$selection" -eq "$skip_option" ]]; then
        log_info "Skipping font installation"
        return 0
    elif [[ "$selection" -ge 1 ]]; then
        local selected_index=$((selection - 1))
        local total_regular_fonts=${#fonts_to_install[@]}

        if [[ "$selected_index" -lt "$total_regular_fonts" ]]; then
            # Install regular font
            local font="${fonts_to_install[$selected_index]}"
            install_font "$font" "${FONTS[$font]}"
        else
            # Install nerd font
            local adjusted_index=$((selected_index - total_regular_fonts))
            if [[ "$adjusted_index" -lt "${#nerd_fonts_to_install[@]}" ]]; then
                local font="${nerd_fonts_to_install[$adjusted_index]}"
                install_nerd_font "$font"
            else
                log_warning "Invalid selection"
            fi
        fi
    else
        log_warning "Invalid selection, skipping font installation"
    fi

    # Update font cache
    log_info "Updating font cache..."
    fc-cache -f -v &>/dev/null

    log_success "Font installation completed"
}

# Install a regular font
install_font() {
    local font_name="$1"
    local font_url="$2"
    local dest_dir="$HOME/.local/share/fonts/$font_name"

    log_info "Installing font: $font_name"

    mkdir -p "$dest_dir"

    # Download and extract font
    local temp_zip="$TEMP_DIR/$font_name.zip"
    log_info "Downloading font from $font_url..."

    if curl -sSL -o "$temp_zip" "$font_url"; then
        log_info "Extracting font..."
        unzip -o "$temp_zip" -d "$dest_dir" &>/dev/null
        rm -f "$temp_zip"

        # Fix permissions
        find "$dest_dir" -name "*.ttf" -o -name "*.otf" -exec chmod 644 {} \;

        # Update font cache
        fc-cache -f -v &>/dev/null

        # Verify installation
        if fc-list | grep -i "$font_name" &>/dev/null; then
            log_success "Font $font_name installed successfully"
        else
            log_warning "Font $font_name installation verification failed"
        fi
    else
        handle_error "Failed to download font $font_name" "Check your internet connection and the URL: $font_url"
    fi
}

# Install a Nerd Font
install_nerd_font() {
    local font_name="$1"
    local dest_dir="$HOME/.local/share/fonts/${font_name}Nerd"

    log_info "Installing Nerd Font: $font_name"

    mkdir -p "$dest_dir"

    # Get latest release URL
    local nerd_fonts_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
    local temp_zip="$TEMP_DIR/${font_name}Nerd.zip"

    log_info "Downloading Nerd Font from $nerd_fonts_url..."

    if curl -sSL -o "$temp_zip" "$nerd_fonts_url"; then
        log_info "Extracting Nerd Font..."
        unzip -o "$temp_zip" -d "$dest_dir" &>/dev/null
        rm -f "$temp_zip"

        # Fix permissions
        find "$dest_dir" -name "*.ttf" -o -name "*.otf" -exec chmod 644 {} \;

        # Update font cache
        fc-cache -f -v &>/dev/null

        # Verify installation
        if fc-list | grep -i "${font_name}Nerd" &>/dev/null; then
            log_success "Nerd Font $font_name installed successfully"
        else
            log_warning "Nerd Font $font_name installation verification failed"
        fi
    else
        handle_error "Failed to download Nerd Font $font_name" "Check your internet connection and the URL: $nerd_fonts_url"
    fi
}

# Install Microsoft Windows fonts
install_windows_fonts() {
    log_info "Installing Microsoft Windows fonts..."

    # Different approaches depending on the distribution
    local pkg_manager=$(detect_package_manager)

    case "$pkg_manager" in
    "apt")
        # For Debian/Ubuntu
        log_info "Adding contrib repository for ttf-mscorefonts-installer..."
        sudo apt-add-repository contrib
        sudo apt update
        if command_exists nala; then
            sudo nala install -y ttf-mscorefonts-installer
        else
            sudo apt install -y ttf-mscorefonts-installer
        fi
        ;;
    "dnf")
        # For Fedora
        log_info "Installing Microsoft core fonts via RPM Fusion..."
        sudo dnf install -y curl cabextract xorg-x11-font-utils
        sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
        ;;
    "pacman")
        # For Arch Linux
        log_info "Installing Microsoft fonts via AUR..."
        if ! command_exists yay; then
            log_warning "Package manager 'yay' not found. Installing..."
            cd "$TEMP_DIR"
            git clone https://aur.archlinux.org/yay.git
            cd yay
            makepkg -si --noconfirm
        fi
        yay -S --noconfirm ttf-ms-fonts
        ;;
    *)
        # Fallback to script method
        log_info "Using script method to install Windows fonts..."
        curl -sSL https://raw.githubusercontent.com/tazihad/bangla-font-fix-linux/main/msfonts-download.sh | bash
        ;;
    esac

    # Update font cache
    log_info "Updating font cache..."
    fc-cache -f -v &>/dev/null

    # Verify installation
    if fc-list | grep -i "Arial" &>/dev/null; then
        log_success "Windows fonts installed successfully"
    else
        log_warning "Windows fonts installation verification failed"
    fi
}

#######################################
# FNM INSTALLATION FUNCTION
#######################################

# Install Fast Node Manager (fnm)
install_fnm() {
    print_header "Fast Node Manager Installation"

    # Check if fnm is already installed
    if command_exists fnm; then
        log_info "fnm is already installed, checking version"
        local current_version=$(fnm --version 2>/dev/null)
        log_info "Current fnm version: $current_version"

        if confirm "Would you like to update fnm?"; then
            log_info "Reinstalling fnm..."
        else
            log_info "Skipping fnm update"
            return 0
        fi
    fi

    log_info "Installing fnm (Fast Node Manager)..."

    # Install using the recommended script
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

    # Source fnm
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"

    # Verify installation
    if command_exists fnm; then
        local installed_version=$(fnm --version 2>/dev/null)
        log_success "fnm installed successfully: $installed_version"

        # Install LTS version of Node.js
        log_info "Installing latest LTS version of Node.js..."
        fnm install --lts

        # Set as default
        fnm default lts-latest

        log_success "Node.js LTS installed and set as default"
    else
        handle_error "fnm installation failed" "Try manual installation or restart terminal"
        return 1
    fi

    # Add shell integration if not already added
    local shell_rc="$HOME/.bashrc"
    if [[ -f "$HOME/.zshrc" ]]; then
        shell_rc="$HOME/.zshrc"
    fi

    if ! grep -q "fnm env" "$shell_rc"; then
        log_info "Adding fnm to $shell_rc..."
        cat >>"$shell_rc" <<EOL

# fnm configuration
export PATH="\$HOME/.local/share/fnm:\$PATH"
eval "\`fnm env\`"
EOL
        log_success "fnm configuration added to $shell_rc"
    fi

    log_success "fnm setup completed"
}

#######################################
# BANGLA FONTS AND LOCALE SETUP
#######################################

# Install Bangla fonts and configure locale
install_bangla_support() {
    print_header "Bangla Language Support"

    # Check if Nirmala UI font (good Bangla font from Windows) is already installed
    if fc-list | grep -i "Nirmala UI" &>/dev/null; then
        log_info "Nirmala UI font is already installed"
    else
        log_info "Installing Bangla fonts..."

        # Install Bangla fonts
        curl -sSL https://raw.githubusercontent.com/tazihad/bangla-font-fix-linux/main/fonts-bangla-download.sh | bash

        # Make Nirmala UI default Bangla font
        if fc-list | grep -i "Nirmala UI" &>/dev/null; then
            log_info "Setting Nirmala UI as default Bangla font..."
            curl -sSL https://raw.githubusercontent.com/tazihad/bangla-font-fix-linux/main/bangla-nirmalaui-default.sh | bash
        else
            log_warning "Nirmala UI font not found, cannot set as default"
        fi
    fi

    # Set up Bangla locale if not already set
    if ! locale -a | grep -i bn_BD &>/dev/null; then
        log_info "Setting up Bangla locale..."
        sudo locale-gen bn_BD.UTF-8 || log_warning "Failed to generate Bangla locale"
    else
        log_info "Bangla locale is already set up"
    fi

    # Update font cache
    fc-cache -f -v &>/dev/null

    # Verify Bangla font setup
    if fc-match -s :lang=bn | grep -i "Nirmala UI" &>/dev/null; then
        log_success "Nirmala UI set as default Bangla font successfully"
    else
        log_warning "Nirmala UI is not set as default Bangla font"
    fi

    log_success "Bangla language support setup completed"
}

#######################################
# MAIN MENU AND EXECUTION FLOW
#######################################

# Display the main menu
show_menu() {
    clear

    echo -e "${BOLD}${GREEN}🚀 Linux System Setup Script 🐧${RESET}"
    echo -e "${BLUE}Created by Nasif Ahmed${RESET}"
    echo -e "${YELLOW}Date: $(date "+%Y-%m-%d")${RESET}"
    echo

    echo -e "${CYAN}Please select an option:${RESET}"
    echo "1. 📦 Install essential packages"
    echo "2. 🔒 Configure SSH and Git"
    echo "3. 📂 Clone dotfiles repository"
    echo "4. ⚙️  Setup dotfiles with GNU Stow"
    echo "5. 🖋️  Install fonts"
    echo "6. 📊 Install Fast Node Manager (fnm)"
    echo "7. 🇧🇩 Install Bangla language support"
    echo "8. 🌟 Run everything (automated setup)"
    echo "9. 📜 View log file"
    echo "0. 🚪 Exit"
    echo
}

# Run all setup tasks automatically
run_all() {
    local pkg_manager=$(detect_package_manager)

    if [[ "$pkg_manager" == "unknown" ]]; then
        handle_error "Unsupported Linux distribution" "This script supports Debian/Ubuntu, Fedora, and Arch Linux"
        return 1
    fi

    # Inform the user about what will happen
    print_header "Complete System Setup"
    echo -e "${YELLOW}This will perform the following actions:${RESET}"
    echo -e "  • Install essential packages for your system"
    echo -e "  • Configure SSH keys and Git"
    echo -e "  • Clone and set up dotfiles"
    echo -e "  • Install fonts (including programming fonts and Nerd Fonts)"
    echo -e "  • Install Fast Node Manager (fnm)"
    echo -e "  • Set up Bangla language support"
    echo

    if ! confirm "Do you want to proceed with the complete setup?"; then
        log_info "Complete setup cancelled by user"
        return 0
    fi

    # Run all tasks sequentially
    init_package_manager "$pkg_manager"

    local pkg_list
    pkg_list=$(get_package_list "$pkg_manager")
    install_packages "$pkg_manager" "$pkg_list"

    configure_ssh_git
    clone_dotfiles
    setup_dotfiles
    install_fonts
    install_fnm
    install_bangla_support

    print_header "Setup Complete"
    log_success "All setup tasks completed successfully!"
    echo -e "${GREEN}Your system has been configured according to your preferences.${RESET}"
    echo -e "${YELLOW}Note: Some changes may require a system restart to take full effect.${RESET}"

    if confirm "Would you like to restart your system now?"; then
        log_info "Restarting system..."
        sudo shutdown -r now
    else
        echo -e "${CYAN}You can restart your system later to apply all changes.${RESET}"
    fi
}

# View the log file
view_log() {
    if [[ -f "$LOG_FILE" ]]; then
        if command_exists bat; then
            bat "$LOG_FILE"
        elif command_exists less; then
            less "$LOG_FILE"
        else
            cat "$LOG_FILE" | more
        fi
    else
        log_warning "Log file not found: $LOG_FILE"
    fi
}

# Main function
main() {
    # Initialize script environment
    init_environment

    # Bootstrap dependencies
    bootstrap_dependencies

    # Banner
    clear
    cat <<EOF
${BOLD}${GREEN}
 ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗    ███████╗███████╗████████╗██╗   ██╗██████╗ 
 ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
 ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝     ███████╗█████╗     ██║   ██║   ██║██████╔╝
 ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗     ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
 ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗    ███████║███████╗   ██║   ╚██████╔╝██║     
 ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝    ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
${RESET}${BLUE}                                                              Created by Nasif Ahmed${RESET}
EOF
    echo

    # Detect package manager and print info
    local pkg_manager=$(detect_package_manager)
    echo -e "${CYAN}System Information:${RESET}"
    echo -e "  • Linux Distribution: ${YELLOW}$(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')${RESET}"
    echo -e "  • Package Manager: ${YELLOW}${pkg_manager}${RESET}"
    echo -e "  • Kernel Version: ${YELLOW}$(uname -r)${RESET}"
    echo
    echo -e "${CYAN}Press any key to continue...${RESET}"
    read -n 1 -s

    # Main menu loop
    while true; do
        show_menu

        read -p "Enter your choice [0-9]: " choice
        echo

        case $choice in
        1)
            # Install essential packages
            local pkg_list
            pkg_list=$(get_package_list "$pkg_manager")
            init_package_manager "$pkg_manager" && install_packages "$pkg_manager" "$pkg_list"
            press_enter_to_continue
            ;;
        2)
            # Configure SSH and Git
            configure_ssh_git
            press_enter_to_continue
            ;;
        3)
            # Clone dotfiles repository
            clone_dotfiles
            press_enter_to_continue
            ;;
        4)
            # Setup dotfiles with GNU Stow
            setup_dotfiles
            press_enter_to_continue
            ;;
        5)
            # Install fonts
            install_fonts
            press_enter_to_continue
            ;;
        6)
            # Install fnm
            install_fnm
            press_enter_to_continue
            ;;
        7)
            # Install Bangla language support
            install_bangla_support
            press_enter_to_continue
            ;;
        8)
            # Run all setup tasks
            run_all
            press_enter_to_continue
            ;;
        9)
            # View log file
            view_log
            press_enter_to_continue
            ;;
        0)
            # Exit
            log_info "Exiting script"
            cleanup
            echo -e "${GREEN}Thank you for using the Linux Setup Script!${RESET}"
            exit 0
            ;;
        *)
            log_warning "Invalid option: $choice"
            press_enter_to_continue
            ;;
        esac
    done
}

# Run the main function
main "$@"
