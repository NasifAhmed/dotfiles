#!/usr/bin/env bash

#######################################
# Linux System Setup Script
# Author: Nasif Ahmed
# Version: 2.0
# Created: 2024
# Updated: May 2025
#######################################
# This script automates the installation of essential packages and
# configuration of personal Linux systems distro agnostically. It includes package management setup, installation of necessary packages, setting up fonts, setting up dotfiles and git ssh setup, font installation, and more.
#
# IMPORTANT: This script is personalized and not intended for general use without review.
#######################################

# Enable error handling
set -o pipefail

# Variables
DOTFILES_REPO="git@github.com:NasifAhmed/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
TEMP_DIR="$(mktemp -d)"
FONTS_DIR="$HOME/.local/share/fonts"
LOG_FILE="$HOME/setup_log.txt"
SUMMARY_FILE="$HOME/setup_summary.txt"

# Status tracking arrays
SUCCESSFUL_TASKS=()
SKIPPED_TASKS=()
FAILED_TASKS=()

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log() {
  echo -e "${BLUE}[INFO]${NC} $1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >>"$LOG_FILE"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >>"$LOG_FILE"
  SUCCESSFUL_TASKS+=("$1")
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >>"$LOG_FILE"
  FAILED_TASKS+=("$1")
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $1" >>"$LOG_FILE"
}

log_skip() {
  echo -e "${YELLOW}[SKIPPED]${NC} $1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SKIPPED] $1" >>"$LOG_FILE"
  SKIPPED_TASKS+=("$1")
}

check_cmd() {
  command -v "$1" &>/dev/null
}

cleanup() {
  log "Cleaning up temporary files..."
  [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
  log_success "Cleanup completed"
}

# Function to generate a summary report
generate_summary() {
  local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

  echo "===== LINUX SETUP SUMMARY =====" >"$SUMMARY_FILE"
  echo "Completed at: $timestamp" >>"$SUMMARY_FILE"
  echo "" >>"$SUMMARY_FILE"

  echo "===== SUCCESSFULLY COMPLETED TASKS =====" >>"$SUMMARY_FILE"
  if [ ${#SUCCESSFUL_TASKS[@]} -eq 0 ]; then
    echo "No tasks completed successfully." >>"$SUMMARY_FILE"
  else
    for task in "${SUCCESSFUL_TASKS[@]}"; do
      echo "✓ $task" >>"$SUMMARY_FILE"
    done
  fi
  echo "" >>"$SUMMARY_FILE"

  echo "===== SKIPPED TASKS =====" >>"$SUMMARY_FILE"
  if [ ${#SKIPPED_TASKS[@]} -eq 0 ]; then
    echo "No tasks were skipped." >>"$SUMMARY_FILE"
  else
    for task in "${SKIPPED_TASKS[@]}"; do
      echo "⏭ $task" >>"$SUMMARY_FILE"
    done
  fi
  echo "" >>"$SUMMARY_FILE"

  echo "===== FAILED TASKS =====" >>"$SUMMARY_FILE"
  if [ ${#FAILED_TASKS[@]} -eq 0 ]; then
    echo "No tasks failed." >>"$SUMMARY_FILE"
  else
    for task in "${FAILED_TASKS[@]}"; do
      echo "⚠ $task" >>"$SUMMARY_FILE"
    done
  fi

  echo "" >>"$SUMMARY_FILE"
  echo "Full log available at: $LOG_FILE" >>"$SUMMARY_FILE"
  echo "===========================" >>"$SUMMARY_FILE"

  # Print to console
  cat "$SUMMARY_FILE"
}

# Function to install build dependencies
install_build_deps() {
  log "Installing build dependencies..."
  case $PKG_MANAGER in
  apt)
    $INSTALL_CMD build-essential cmake pkg-config git
    ;;
  dnf)
    $INSTALL_CMD "@Development Tools" cmake pkgconf-pkg-config git
    ;;
  pacman)
    $INSTALL_CMD base-devel cmake git
    ;;
  esac
  log_success "Build dependencies installed"
}

# Function to setup Paru AUR helper on Arch
setup_paru() {
  if ! check_cmd paru; then
    log "Setting up Paru AUR helper..."
    # Install base-devel if not already installed
    $INSTALL_CMD base-devel git

    # Clone and build paru
    cd "$TEMP_DIR" || exit
    git clone https://aur.archlinux.org/paru.git
    cd paru || exit
    makepkg -si --noconfirm

    if check_cmd paru; then
      log_success "Paru installed successfully"
    else
      log_error "Failed to install Paru"
    fi
  else
    log_success "Paru already installed"
  fi
}

# Trap for graceful exit
trap cleanup EXIT INT TERM

# Banner
clear
cat <<EOF
 ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗    ███████╗███████╗████████╗██╗   ██╗██████╗ 
 ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
 ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝     ███████╗█████╗     ██║   ██║   ██║██████╔╝
 ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗     ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
 ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗    ███████║███████╗   ██║   ╚██████╔╝██║     
 ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝    ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     

by Nasif Ahmed
EOF
echo

# Create necessary directories
mkdir -p "$FONTS_DIR"
mkdir -p "$HOME/.config"

# Start the log file
echo "Linux System Setup Log - Started at $(date '+%Y-%m-%d %H:%M:%S')" >"$LOG_FILE"

#################################################
# 1. Detect Package Manager
#################################################
log "Detecting package manager..."

if check_cmd apt; then
  PKG_MANAGER="apt"
  INSTALL_CMD="sudo apt install -y"
  UPDATE_CMD="sudo apt update && sudo apt upgrade -y"
  PKG_MAP=(
    "git:git"
    "wget:wget"
    "curl:curl"
    "make:make"
    "gcc:gcc"
    "unzip:unzip"
    "openssh:openssh-client"
    "openssl:openssl"
    "stow:stow"
    "zsh:zsh"
    "ripgrep:ripgrep"
    "fd:fd-find"
    "fontconfig:fontconfig"
    "tldr:tldr"
    "tree:tree"
    "bat:bat"
    "jq:jq"
    "zoxide:zoxide"
    "exa:eza" # exa has been renamed to eza in Ubuntu/Debian
  )
  MS_FONTS_PKG="ttf-mscorefonts-installer"
elif check_cmd dnf; then
  PKG_MANAGER="dnf"
  INSTALL_CMD="sudo dnf install -y"
  UPDATE_CMD="sudo dnf update -y"
  PKG_MAP=(
    "git:git"
    "wget:wget"
    "curl:curl"
    "make:make"
    "gcc:gcc"
    "unzip:unzip"
    "openssh:openssh"
    "openssl:openssl"
    "stow:stow"
    "zsh:zsh"
    "ripgrep:ripgrep"
    "fd:fd-find"
    "fontconfig:fontconfig"
    "tldr:tldr"
    "tree:tree"
    "bat:bat"
    "jq:jq"
    "zoxide:zoxide"
    "exa:eza" # Prefer eza (fork of exa) for Fedora
  )
  MS_FONTS_PKG="mscore-fonts-all"
elif check_cmd pacman; then
  PKG_MANAGER="pacman"
  INSTALL_CMD="sudo pacman -S --noconfirm"
  UPDATE_CMD="sudo pacman -Syu --noconfirm"
  PKG_MAP=(
    "git:git"
    "wget:wget"
    "curl:curl"
    "make:make"
    "gcc:gcc"
    "unzip:unzip"
    "openssh:openssh"
    "openssl:openssl"
    "stow:stow"
    "zsh:zsh"
    "ripgrep:ripgrep"
    "fd:fd"
    "fontconfig:fontconfig"
    "tldr:tldr"
    "fastfetch:fastfetch"
    "tree:tree"
    "neovim:neovim"
    "fzf:fzf"
    "bat:bat"
    "jq:jq"
    "zoxide:zoxide"
    "exa:eza"
  )
  MS_FONTS_PKG="ttf-ms-fonts"

  # Setup Paru AUR helper on Arch Linux
  setup_paru

  # If Paru is successfully installed, update the install command
  if check_cmd paru; then
    log "Using Paru for AUR packages"
    AUR_INSTALL_CMD="paru -S --noconfirm"
  fi
else
  log_error "No supported package manager found. Supported: apt, dnf, pacman."
  exit 1
fi

log_success "Detected package manager: $PKG_MANAGER"

#################################################
# 2. Update System & Install Packages
#################################################
log "Updating system..."
eval "$UPDATE_CMD" || log_warning "System update failed, but continuing..."

# Install essential build dependencies first
install_build_deps

log "Installing packages..."
packages_to_install=()
packages_already_installed=()

for pkg_map in "${PKG_MAP[@]}"; do
  pkg_key="${pkg_map%%:*}"
  pkg_name="${pkg_map#*:}"

  if ! check_cmd "$pkg_key"; then
    packages_to_install+=("$pkg_name")
  else
    packages_already_installed+=("$pkg_key")
  fi
done

if [ ${#packages_already_installed[@]} -gt 0 ]; then
  log_skip "Already installed: ${packages_already_installed[*]}"
fi

if [ ${#packages_to_install[@]} -gt 0 ]; then
  log "Installing: ${packages_to_install[*]}"
  if $INSTALL_CMD "${packages_to_install[@]}"; then
    log_success "Installed packages: ${packages_to_install[*]}"
  else
    log_error "Failed to install some packages: ${packages_to_install[*]} - You may need to install them manually"
  fi
else
  log_skip "No new packages to install"
fi

# Install AUR packages if on Arch Linux and Paru is available
if [ "$PKG_MANAGER" = "pacman" ] && [ -n "$AUR_INSTALL_CMD" ]; then
  AUR_PACKAGES=()

  # Check for MS fonts from AUR
  if ! fc-list | grep -i "Times New Roman" &>/dev/null; then
    AUR_PACKAGES+=("$MS_FONTS_PKG")
  else
    log_skip "Microsoft fonts already installed"
  fi

  # Add more AUR packages here if needed

  if [ ${#AUR_PACKAGES[@]} -gt 0 ]; then
    log "Installing AUR packages: ${AUR_PACKAGES[*]}"
    if $AUR_INSTALL_CMD "${AUR_PACKAGES[@]}"; then
      log_success "Installed AUR packages: ${AUR_PACKAGES[*]}"
    else
      log_error "Failed to install AUR packages: ${AUR_PACKAGES[*]} - Try installing manually with 'paru -S ${AUR_PACKAGES[*]}'"
    fi
  else
    log_skip "No AUR packages to install"
  fi
fi

#################################################
# 3. Install packages not available in package managers
#################################################
log "Installing packages from source..."

# Install Neovim from source if needed and not already installed
if ! check_cmd nvim && [ "$PKG_MANAGER" != "pacman" ]; then
  log "Installing Neovim from source..."

  # Check if already installed first
  if [ -f "$HOME/.local/bin/nvim" ] || [ -f "/usr/local/bin/nvim" ]; then
    log_skip "Neovim is already installed"
  else
    # Install dependencies
    case $PKG_MANAGER in
    apt)
      $INSTALL_CMD ninja-build gettext cmake unzip curl libtool-bin libtool autoconf automake pkg-config
      ;;
    dnf)
      $INSTALL_CMD ninja-build gettext cmake unzip curl libtool autoconf automake pkg-config
      ;;
    esac

    cd "$TEMP_DIR" || {
      log_error "Failed to change to temp directory for Neovim installation"
      return 1
    }

    log "Cloning Neovim repository..."
    if ! git clone https://github.com/neovim/neovim; then
      log_error "Failed to clone Neovim repository - Check your internet connection and try again manually"
      return 1
    fi

    cd neovim || {
      log_error "Failed to change to Neovim directory"
      return 1
    }

    git checkout stable

    log "Building Neovim (this may take a while)..."
    if ! make CMAKE_BUILD_TYPE=Release; then
      log_error "Failed to build Neovim - Try manually with: cd $TEMP_DIR/neovim && make CMAKE_BUILD_TYPE=Release"
      return 1
    fi

    log "Installing Neovim..."
    if ! sudo make install; then
      log_error "Failed to install Neovim - Try manually with: cd $TEMP_DIR/neovim && sudo make install"
      return 1
    fi

    if check_cmd nvim; then
      log_success "Neovim installed successfully"
    else
      log_error "Neovim installation verification failed - Check if it's in your PATH"
    fi
  fi
fi

# Install fzf from source if needed and not already installed
if ! check_cmd fzf && [ "$PKG_MANAGER" != "pacman" ]; then
  log "Installing fzf from source..."

  if [ -d "$HOME/.fzf" ] || check_cmd fzf; then
    log_skip "fzf is already installed"
  else
    if ! git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"; then
      log_error "Failed to clone fzf repository - Check your internet connection"
      return 1
    fi

    if ! "$HOME/.fzf/install" --all --no-bash --no-fish; then
      log_error "Failed to install fzf - Try manually with: $HOME/.fzf/install --all"
      return 1
    fi

    if check_cmd fzf || [ -f "$HOME/.fzf/bin/fzf" ]; then
      log_success "fzf installed successfully"
    else
      log_error "fzf installation verification failed"
    fi
  fi
fi

# Install fastfetch from source if needed and not already installed
if ! check_cmd fastfetch && [ "$PKG_MANAGER" != "pacman" ]; then
  log "Installing fastfetch from source..."

  if [ -f "$HOME/.local/bin/fastfetch" ] || [ -f "/usr/local/bin/fastfetch" ] || check_cmd fastfetch; then
    log_skip "fastfetch is already installed"
  else
    # Install dependencies
    case $PKG_MANAGER in
    apt)
      if ! $INSTALL_CMD cmake pkg-config libpci-dev libvulkan-dev libwayland-dev libxrandr-dev libxcb-randr0-dev libdconf-dev; then
        log_error "Failed to install fastfetch dependencies - Some features may not work"
      fi
      # Additional optional dependencies
      $INSTALL_CMD libdrm-dev libxcb-dri3-dev libglib2.0-dev libbsd-dev || log_warning "Some optional fastfetch dependencies couldn't be installed"
      ;;
    dnf)
      if ! $INSTALL_CMD cmake pkgconf-pkg-config pciutils-devel vulkan-headers wayland-devel libXrandr-devel libxcb-devel dconf-devel; then
        log_error "Failed to install fastfetch dependencies - Some features may not work"
      fi
      # Additional optional dependencies
      $INSTALL_CMD libdrm-devel libxcb-dri3-devel glib2-devel libbsd-devel || log_warning "Some optional fastfetch dependencies couldn't be installed"
      ;;
    esac

    cd "$TEMP_DIR" || {
      log_error "Failed to change to temp directory for fastfetch installation"
      return 1
    }

    log "Cloning fastfetch repository..."
    if ! git clone https://github.com/fastfetch-cli/fastfetch.git; then
      log_error "Failed to clone fastfetch repository - Check your internet connection"
      return 1
    fi

    cd fastfetch || {
      log_error "Failed to change to fastfetch directory"
      return 1
    }

    log "Building fastfetch..."
    mkdir -p build
    cd build || {
      log_error "Failed to create or change to build directory for fastfetch"
      return 1
    }

    if ! cmake ..; then
      log_error "Failed to configure fastfetch - Check that cmake is installed"
      return 1
    fi

    log "Installing fastfetch..."
    if ! cmake --build . --target fastfetch --target flashfetch; then
      log_error "Failed to build fastfetch - Try manually with: cd $TEMP_DIR/fastfetch/build && cmake --build . --target fastfetch"
      return 1
    fi

    if ! sudo cmake --install .; then
      log_error "Failed to install fastfetch - Try manually with: cd $TEMP_DIR/fastfetch/build && sudo cmake --install ."
      return 1
    fi

    if check_cmd fastfetch; then
      log_success "fastfetch installed successfully"
    else
      log_error "fastfetch installation verification failed - Check if it's in your PATH"
    fi
  fi
fi

# Install exa/eza from source if not available in package manager
if ! check_cmd exa && ! check_cmd eza && ! command -v exa &>/dev/null && ! command -v eza &>/dev/null; then
  log "Installing exa/eza from source..."

  if [ -f "$HOME/.cargo/bin/exa" ] || [ -f "/usr/local/bin/exa" ] || [ -f "$HOME/.cargo/bin/eza" ] || [ -f "/usr/local/bin/eza" ] || check_cmd exa || check_cmd eza; then
    log_skip "exa/eza is already installed"
  else
    # Install rust if needed
    if ! check_cmd cargo; then
      log "Installing Rust first..."

      # Install required dependencies for Rust
      case $PKG_MANAGER in
      apt)
        $INSTALL_CMD build-essential || log_error "Failed to install build-essential required for Rust"
        ;;
      dnf)
        $INSTALL_CMD gcc || log_error "Failed to install gcc required for Rust"
        ;;
      pacman)
        $INSTALL_CMD gcc || log_error "Failed to install gcc required for Rust"
        ;;
      esac

      if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        log_error "Failed to install Rust - Try manually with: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        return 1
      fi

      source "$HOME/.cargo/env" || {
        log_error "Failed to source Rust environment - Try manually with: source $HOME/.cargo/env"
        return 1
      }

      if check_cmd cargo; then
        log_success "Rust installed successfully"
      else
        log_error "Rust installation failed. Cannot install exa."
        return 1
      fi
    fi

    # Install dependencies
    case $PKG_MANAGER in
    apt)
      if ! $INSTALL_CMD libgit2-dev cmake; then
        log_error "Failed to install exa/eza dependencies"
        return 1
      fi
      ;;
    dnf)
      if ! $INSTALL_CMD libgit2-devel cmake; then
        log_error "Failed to install exa/eza dependencies"
        return 1
      fi
      ;;
    pacman)
      if ! $INSTALL_CMD libgit2 cmake; then
        log_error "Failed to install exa/eza dependencies"
        return 1
      fi
      ;;
    esac

    # Install exa/eza using cargo
    log "Building exa/eza (this may take a while)..."

    # Try eza first (newer fork of exa)
    if cargo install eza; then
      log_success "eza installed successfully"
    else
      log_warning "Failed to install eza, trying exa instead..."

      if ! cargo install exa; then
        log_error "Failed to install exa - Try manually with: cargo install exa or cargo install eza"
        return 1
      else
        log_success "exa installed successfully"
      fi
    fi

    if check_cmd eza || [ -f "$HOME/.cargo/bin/eza" ] || check_cmd exa || [ -f "$HOME/.cargo/bin/exa" ]; then
      log_success "exa/eza installed successfully"

      # Add .cargo/bin to PATH if not already there
      for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$shell_rc" ] && ! grep -q ".cargo/bin" "$shell_rc"; then
          log "Adding cargo bin to PATH in $shell_rc"
          echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>"$shell_rc"
        fi
      done
    else
      log_error "exa/eza installation verification failed - Check if it's in your PATH or $HOME/.cargo/bin"
    fi
  fi
fi

#################################################
# 4. Git SSH setup
#################################################
log "Setting up Git SSH..."

# Check if SSH key already exists
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  log "Creating SSH key..."

  # Ensure directory exists and has correct permissions
  if ! mkdir -p "$HOME/.ssh"; then
    log_error "Failed to create .ssh directory - Check permissions"
    return 1
  fi

  if ! chmod 700 "$HOME/.ssh"; then
    log_error "Failed to set permissions on .ssh directory"
    return 1
  fi

  # Generate SSH key
  if ! ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "Nasif's Linux Setup"; then
    log_error "Failed to generate SSH key - Try manually with: ssh-keygen -t ed25519"
    return 1
  fi

  # Set correct permissions
  chmod 600 "$HOME/.ssh/id_ed25519"
  chmod 644 "$HOME/.ssh/id_ed25519.pub"

  log_warning "A new SSH key was generated. You need to add it to your GitHub account."
  echo -e "\n${GREEN}Your SSH public key:${NC}"
  cat "$HOME/.ssh/id_ed25519.pub"
  echo -e "\n${YELLOW}Instructions to add key to GitHub:${NC}"
  echo "1. Copy the key above (including ssh-ed25519 and the email)"
  echo "2. Go to https://github.com/settings/ssh/new"
  echo "3. Paste the key in the 'Key' field"
  echo "4. Give it a title like 'My Linux Setup'"
  echo "5. Click 'Add SSH key'"
  echo -e "\n${BLUE}Direct link to add SSH key to GitHub:${NC} https://github.com/settings/ssh/new"
  log_success "SSH key generated successfully"
else
  log_skip "SSH key already exists, skipping generation"
fi

# Set basic git config if not already set
if [ -z "$(git config --global user.name)" ]; then
  log "Setting up Git config..."

  if ! git config --global user.name "Nasif Ahmed"; then
    log_error "Failed to set Git username"
  fi

  if ! git config --global user.email "nasif2ahmed@gmail.com"; then
    log_error "Failed to set Git email"
  fi

  if ! git config --global init.defaultBranch main; then
    log_error "Failed to set Git default branch"
  fi

  log_success "Git config set up"
else
  log_skip "Git config already set up"
fi

#################################################
# 5. Clone dotfiles
#################################################
log "Setting up dotfiles..."

if [ -d "$DOTFILES_DIR" ]; then
  log_skip "Dotfiles already cloned to $DOTFILES_DIR"
else
  log "Cloning dotfiles repository..."

  # Test SSH connection to GitHub first
  log "Testing SSH connection to GitHub..."
  if ! ssh -T git@github.com -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 2>&1 | grep -q "successfully authenticated"; then
    log_warning "GitHub SSH authentication failed. Make sure your SSH key is added to your GitHub account."

    echo -e "\n${YELLOW}Have you added the SSH key to your GitHub account yet? (y/n)${NC}"
    read -r answer
    if [[ "$answer" =~ ^[Nn] ]]; then
      echo -e "\n${GREEN}Please add your key to GitHub first:${NC}"
      cat "$HOME/.ssh/id_ed25519.pub"
      echo -e "\n${BLUE}Direct link:${NC} https://github.com/settings/ssh/new"
      echo -e "\n${YELLOW}Press Enter after adding the key to GitHub...${NC}"
      read -r
    fi

    log_warning "Attempting to clone anyway..."
  fi

  if ! git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
    log_error "Failed to clone dotfiles. Please check your SSH key setup and connectivity."
    log_error "Try cloning manually with: git clone $DOTFILES_REPO $DOTFILES_DIR"
    log_error "Then run this script again."
  else
    log_success "Dotfiles cloned successfully"
  fi
fi

#################################################
# 6. Font installation
#################################################
log "Installing fonts..."

# Create fonts directory if it doesn't exist
mkdir -p "$FONTS_DIR"

# JetBrains Mono Nerd Font
if [ ! -f "$FONTS_DIR/JetBrainsMono Regular Nerd Font Complete.ttf" ]; then
  log "Installing JetBrains Mono Nerd Font..."
  cd "$TEMP_DIR" || {
    log_error "Failed to change to temp directory for font installation"
    return 1
  }

  if ! wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip; then
    log_error "Failed to download JetBrains Mono font - Check your internet connection"
    return 1
  fi

  if ! unzip -q JetBrainsMono.zip -d jetbrainsmono; then
    log_error "Failed to extract JetBrains Mono font - Make sure unzip is installed"
    return 1
  fi

  if cp jetbrainsmono/*.ttf "$FONTS_DIR/"; then
    log_success "JetBrains Mono Nerd Font installed"
  else
    log_error "Failed to copy JetBrains Mono font files to $FONTS_DIR"
  fi
else
  log_skip "JetBrains Mono Nerd Font already installed"
fi

# Install Microsoft Fonts
log "Installing Microsoft fonts..."
case $PKG_MANAGER in
apt)
  # Debian/Ubuntu
  if $INSTALL_CMD "$MS_FONTS_PKG"; then
    log_success "Microsoft fonts installed"
  else
    log_error "Microsoft fonts installation failed - Try manually with: sudo apt install $MS_FONTS_PKG"
  fi
  ;;
dnf)
  # Fedora
  if $INSTALL_CMD "$MS_FONTS_PKG"; then
    log_success "Microsoft fonts installed"
  else
    log_error "Microsoft fonts installation failed - Try manually with: sudo dnf install $MS_FONTS_PKG"
  fi
  ;;
pacman)
  # Arch Linux - try from AUR
  if [ -n "$AUR_INSTALL_CMD" ]; then
    if $AUR_INSTALL_CMD "$MS_FONTS_PKG"; then
      log_success "Microsoft fonts installed"
    else
      log_error "Microsoft fonts installation failed - Try manually with: paru -S $MS_FONTS_PKG"
    fi
  else
    log_error "AUR helper not found. Microsoft fonts installation skipped."
    log_error "Install manually with: paru -S $MS_FONTS_PKG"
  fi
  ;;
esac

# Install and setup Bangla fonts
log "Installing Bangla fonts..."
if curl -sSL https://raw.githubusercontent.com/tazihad/bangla-font-fix-linux/main/fonts-bangla-download.sh | sh; then
  log_success "Bangla fonts installed"
else
  log_error "Bangla fonts installation failed - Try manually with the command from https://github.com/tazihad/bangla-font-fix-linux"
fi

log "Setting Nirmala UI as default Bangla font..."
if curl -sSL https://raw.githubusercontent.com/tazihad/bangla-font-fix-linux/main/bangla-nirmalaui-default.sh | sh; then
  log_success "Nirmala UI set as default Bangla font"
else
  log_error "Failed to set Nirmala UI as default Bangla font - Try manually with the command from https://github.com/tazihad/bangla-font-fix-linux"
fi

# Refresh font cache
log "Refreshing font cache..."
if fc-cache -f; then
  log_success "Font cache refreshed"
else
  log_error "Failed to refresh font cache - Try manually with: fc-cache -f"
fi

#################################################
# 7. Stow dotfiles
#################################################
log "Stowing dotfiles..."

if [ -d "$DOTFILES_DIR/stow" ]; then
  cd "$DOTFILES_DIR" || {
    log_error "Failed to change to dotfiles directory for stowing"
    return 1
  }

  # Backup existing config files that might conflict
  backup_dir="$HOME/.config_backup_$(date +%Y%m%d%H%M%S)"
  if ! mkdir -p "$backup_dir"; then
    log_error "Failed to create backup directory $backup_dir"
    return 1
  fi

  # Backup important config files
  backup_files=(.bashrc .bash_history .zshrc .zsh_history)
  for file in "${backup_files[@]}"; do
    if [ -f "$HOME/$file" ]; then
      log "Backing up $HOME/$file to $backup_dir"
      if ! cp "$HOME/$file" "$backup_dir/"; then
        log_error "Failed to backup $HOME/$file"
      fi
    fi
  done

  # Track stowing results
  stowed_pkgs=()
  failed_pkgs=()

  # Stow each directory in the stow folder
  for dir in stow/*; do
    if [ -d "$dir" ]; then
      pkg_name=$(basename "$dir")
      log "Stowing $pkg_name..."

      if stow -d stow -t "$HOME" "$pkg_name" 2>/dev/null; then
        stowed_pkgs+=("$pkg_name")
        log_success "Successfully stowed $pkg_name"
      else
        log_warning "Stowing $pkg_name encountered conflicts. Trying to adopt existing files..."

        if stow -d stow -t "$HOME" --adopt "$pkg_name" 2>/dev/null; then
          stowed_pkgs+=("$pkg_name (adopted)")
          log_success "Successfully adopted existing files for $pkg_name"
        else
          failed_pkgs+=("$pkg_name")
          log_error "Failed to stow $pkg_name. You might need to resolve conflicts manually."
          log_error "Try: cd $DOTFILES_DIR && stow -d stow -t \"$HOME\" --adopt $pkg_name"
        fi
      fi
    fi
  done

  # Report stowing results
  if [ ${#stowed_pkgs[@]} -gt 0 ]; then
    log_success "Successfully stowed packages: ${stowed_pkgs[*]}"
  fi

  if [ ${#failed_pkgs[@]} -gt 0 ]; then
    log_error "Failed to stow packages: ${failed_pkgs[*]}"
  fi
else
  log_error "Stow directory not found in dotfiles repo"
  log_error "Expected stow directory at: $DOTFILES_DIR/stow"
fi

#################################################
# 8. Setup shell
#################################################
log "Setting up shell environment..."

# Add ~/.local/bin to PATH if not already there
for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -f "$shell_rc" ] && ! grep -q ".local/bin" "$shell_rc"; then
    log "Adding ~/.local/bin to PATH in $shell_rc"
    if echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$shell_rc"; then
      log_success "Added ~/.local/bin to PATH in $shell_rc"
    else
      log_error "Failed to add ~/.local/bin to PATH in $shell_rc"
    fi
  elif [ -f "$shell_rc" ]; then
    log_skip "~/.local/bin already in PATH in $shell_rc"
  fi
done

# Source the bashrc
if [ -f "$HOME/.bashrc" ]; then
  log "Sourcing .bashrc..."
  # shellcheck disable=SC1090
  if source "$HOME/.bashrc"; then
    log_success "Successfully sourced .bashrc"
  else
    log_warning "Failed to source .bashrc - Shell environment might not be fully configured"
  fi
else
  log_error ".bashrc file not found - Shell environment might not be properly configured"
fi

# Change default shell to zsh if it isn't already
if command -v zsh &>/dev/null; then
  if [ "$SHELL" != "$(which zsh)" ]; then
    log "Changing default shell to zsh..."
    if chsh -s "$(which zsh)"; then
      log_success "Default shell changed to zsh"
    else
      log_error "Failed to change shell to zsh - Try manually with: chsh -s $(which zsh)"
    fi
  else
    log_skip "Default shell is already zsh"
  fi
else
  log_error "zsh is not installed - Cannot change default shell"
fi

#################################################
# 9. Setup FNM (Fast Node Manager)
#################################################
log "Setting up Fast Node Manager (fnm)..."

if ! check_cmd fnm; then
  log "Installing fnm..."

  if ! curl -fsSL https://fnm.vercel.app/install | bash; then
    log_error "Failed to install fnm - Try manually with: curl -fsSL https://fnm.vercel.app/install | bash"
    return 1
  fi

  # Add fnm to shell config if not already there
  fnm_config='
# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"'

  for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$shell_rc" ] && ! grep -q "fnm" "$shell_rc"; then
      log "Adding fnm config to $shell_rc"
      if echo "$fnm_config" >>"$shell_rc"; then
        log_success "Added fnm configuration to $shell_rc"
      else
        log_error "Failed to add fnm configuration to $shell_rc"
      fi
    elif [ -f "$shell_rc" ]; then
      log_skip "fnm configuration already exists in $shell_rc"
    fi
  done

  log_success "fnm installed"
else
  log_skip "fnm already installed"
fi

# Install latest LTS Node.js
if check_cmd fnm || [ -f "$HOME/.local/share/fnm/fnm" ]; then
  # Add fnm to the current PATH
  PATH="$HOME/.local/share/fnm:$PATH"

  # Try to initialize fnm
  if ! eval "$("$HOME/.local/share/fnm/fnm" env --use-on-cd)" 2>/dev/null; then
    log_warning "Failed to initialize fnm environment"
  fi

  log "Installing Node.js LTS..."

  # Install LTS version
  if "$HOME/.local/share/fnm/fnm" install --lts; then
    log_success "Node.js LTS installed"
  else
    log_error "Failed to install Node.js LTS - Try manually with: $HOME/.local/share/fnm/fnm install --lts"
    return 1
  fi

  # Set default Node.js version
  if "$HOME/.local/share/fnm/fnm" default lts-latest; then
    log_success "Node.js LTS set as default"
  else
    log_error "Failed to set Node.js LTS as default - Try manually with: $HOME/.local/share/fnm/fnm default lts-latest"
  fi
else
  log_error "fnm not found - Cannot install Node.js"
fi

#################################################
# 10. Finalize installation
#################################################
log "Finalizing installation..."

# Generate summary report
generate_summary

# Display success message
cat <<EOF

 ██████╗  ██████╗ ███╗   ██╗███████╗██╗
██╔═══██╗██╔═══██╗████╗  ██║██╔════╝██║
██║   ██║██║   ██║██╔██╗ ██║█████╗  ██║
██║   ██║██║   ██║██║╚██╗██║██╔══╝  ╚═╝
╚██████╔╝╚██████╔╝██║ ╚████║███████╗██╗
 ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝
                                       
Setup completed successfully!
EOF

log "Setup completed at $(date '+%Y-%m-%d %H:%M:%S')"
log "Log file saved to: $LOG_FILE"
log_success "Please restart your terminal to apply all changes"

exit 0
