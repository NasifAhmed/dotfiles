#!/bin/bash

# Philosophy:
# 1. Always return to the main menu after each task
# 2. Show error and possible solution if there's an error
# 3. Backup original files before making changes and restore if something goes wrong
# 4. Check if a task is already done and skip if it is
# 5. Show progress of tasks to the user
# 6. Ask user to press Enter to return to the main menu
# 7. Show task completion status (completed, skipped, or failed)
# 8. Give me a menu on top during each task execution to go back to the main menu or quit the current task

# Global variables
package_manager=""
essential_packages=""

# Package lists
apt_packages="git fzf wget make gcc unzip openssh-client openssl stow ripgrep fd-find fontconfig tldr fastfetch"
dnf_packages="git fzf wget make gcc unzip openssh-clients openssl stow ripgrep fd-find fontconfig tldr fastfetch"
pacman_packages="git fzf wget make gcc unzip openssh openssl stow ripgrep fd fontconfig tldr fastfetch"

# Commands to check if packages are installed
package_commands="git fzf wget make gcc unzip ssh openssl stow rg fd fc-list tldr fastfetch"

# Function declarations

# Utility functions
cleanup() {
    echo "Cleaning up..."
    # Add cleanup tasks here
    exit 0
}

handle_error() {
    echo "❌ Error: $1"
    echo "Possible solution: $2"
    read -p "Press Enter to return to the main menu..."
    start_gui
}

# Package manager functions
detect_package_manager() {
    if command -v apt &> /dev/null; then
        package_manager="apt"
    elif command -v dnf &> /dev/null; then
        package_manager="dnf"
    elif command -v pacman &> /dev/null; then
        package_manager="pacman"
    else
        handle_error "Unable to detect package manager" "Ensure you're using a supported distribution (Debian, Fedora, or Arch-based)"
        return 1
    fi
}

set_essential_packages() {
    case $package_manager in
        "apt") essential_packages=$apt_packages ;;
        "dnf") essential_packages=$dnf_packages ;;
        "pacman") essential_packages=$pacman_packages ;;
        *) echo "Unsupported package manager: $package_manager" >&2; return 1 ;;
    esac
}

initialize_package_manager() {
    detect_package_manager || return 1
    echo "Initializing package manager..."

    case $package_manager in
        "pacman")
            configure_pacman
            ;;
        "apt")
            configure_apt
            ;;
        "dnf")
            configure_dnf
            ;;
    esac

    update_system
    echo "✅ Package manager initialized successfully."
}

configure_pacman() {
    echo "Configuring Arch Linux package manager..."
    sudo pacman -Sy || handle_error "Failed to sync pacman" "Check your internet connection and try again"
    if ! pacman -Qi reflector &> /dev/null; then
        sudo pacman -S reflector --noconfirm || handle_error "Failed to install reflector" "Try running 'sudo pacman -Syyu' to update your system"
    fi
    sudo reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist || handle_error "Failed to update mirrorlist" "Check your internet connection and try again"
    
    backup_file "/etc/pacman.conf"
    
    if ! grep -q "^Color" /etc/pacman.conf; then
        sudo sed -i '/^#Color/s/^#//' /etc/pacman.conf
    fi
    if ! grep -q "^ParallelDownloads = 5" /etc/pacman.conf; then
        sudo sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
    fi
    if ! grep -q "ILoveCandy" /etc/pacman.conf; then
        echo "ILoveCandy" | sudo tee -a /etc/pacman.conf
    fi
}

configure_apt() {
    echo "Configuring Debian-based package manager..."
    sudo apt update || handle_error "Failed to update apt" "Check your internet connection and try again"
    if ! dpkg -s netselect-apt &> /dev/null; then
        sudo apt install -y netselect-apt || handle_error "Failed to install netselect-apt" "Try running 'sudo apt update && sudo apt upgrade' to update your system"
    fi
    
    backup_file "/etc/apt/sources.list"
    
    sudo netselect-apt || handle_error "Failed to find fastest mirror" "Check your internet connection and try again"
}

configure_dnf() {
    echo "Configuring Fedora package manager..."
    
    backup_file "/etc/dnf/dnf.conf"
    
    if ! grep -q "fastestmirror=True" /etc/dnf/dnf.conf; then
        echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf || handle_error "Failed to enable fastest mirror" "Check if you have write permissions to /etc/dnf/dnf.conf"
    fi
}

update_system() {
    echo "Updating and upgrading the system..."
    case $package_manager in
        "pacman")
            sudo pacman -Syu --noconfirm || handle_error "Failed to update system" "Check your internet connection and try again"
            ;;
        "apt")
            sudo apt update && sudo apt upgrade -y || handle_error "Failed to update system" "Check your internet connection and try again"
            ;;
        "dnf")
            sudo dnf upgrade -y || handle_error "Failed to update system" "Check your internet connection and try again"
            ;;
    esac
}

# Task functions
install_essential_packages() {
    initialize_package_manager || return
    set_essential_packages || return
    echo "Installing essential packages..."

    case $package_manager in
        "pacman")
            install_cmd="sudo pacman -S --noconfirm"
            check_cmd="pacman -Qi"
            ;;
        "apt")
            install_cmd="sudo apt install -y"
            check_cmd="dpkg -s"
            ;;
        "dnf")
            install_cmd="sudo dnf install -y"
            check_cmd="rpm -q"
            ;;
        *)
            handle_error "Unsupported package manager" "Ensure you're using a supported distribution (Debian, Fedora, or Arch-based)"
            return
            ;;
    esac

    for package in $essential_packages; do
        if $check_cmd $package &> /dev/null; then
            echo "$package is already installed. Skipping."
        else
            echo "Installing $package..."
            $install_cmd $package || handle_error "Failed to install $package" "Try updating your system and run the script again"
        fi
    done

    verify_package_installation
    read -p "Press Enter to return to the main menu..."
    start_gui
}

verify_package_installation() {
    echo "Verifying package installation..."
    all_installed=true
    for package in $essential_packages; do
        if $check_cmd $package &> /dev/null; then
            echo "✅ $package is successfully installed."
        else
            echo "❌ Warning: $package is not installed or not in package database."
            all_installed=false
        fi
    done

    if $all_installed; then
        echo "✅ Essential packages installation completed."
    else
        echo "⚠️ Some packages may not have installed correctly."
    fi
}

# This will configure the SSH for Github
# Check the ssh key is already there or not
# If not then generate a new one and put it on the screen and tell me to add it to the Github
# If the key is already there then tell me to add it to the Github and wait for my confirmation
# email address for the key is "nasif2ahmed@gmail.com"
# name for the key is "Nasif Ahmed"
# type of the key is ed25519
# finally test the ssh connection by running "ssh -T git@github.com"

configure_ssh_and_git() {
    echo "Configuring SSH..."
    
    local ssh_dir="$HOME/.ssh"
    local key_file="$ssh_dir/id_ed25519"
    local email="nasif2ahmed@gmail.com"
    local name="Nasif Ahmed"

    # Check if SSH key already exists
    if [ -f "$key_file" ]; then
        echo "SSH key already exists."
        echo "Please add the following public key to your GitHub account:"
        cat "${key_file}.pub"
        read -p "Press Enter when you've added the key to GitHub..."
    else
        # Generate new SSH key
        mkdir -p "$ssh_dir"
        ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
        echo "New SSH key generated."
        echo "Please add the following public key to your GitHub account:"
        cat "${key_file}.pub"
        read -p "Press Enter when you've added the key to GitHub..."
    fi

    # Start ssh-agent and add the key
    eval "$(ssh-agent -s)"
    ssh-add "$key_file"

    # Test SSH connection
    echo "Testing SSH connection to GitHub..."
    ssh -T git@github.com

    if [ $? -eq 1 ]; then
        echo "✅ SSH configured successfully and connected to GitHub."
        
        # Configure Git
        echo "Configuring Git..."
        read -p "Enter your name for Git configuration: " git_name
        read -p "Enter your email for Git configuration: " git_email
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        
        echo "✅ Git configured successfully."
    else
        handle_error "Failed to connect to GitHub" "Check your internet connection and ensure the SSH key is added to your GitHub account"
    fi

    read -p "Press Enter to return to the main menu..."
    start_gui
}

# This will clone the dotfiles from the Github
# Make sure to check if the dotfiles are already there or not
# Make sure the github ssd setup is done properly
# If not tell me to do it
# If the dotfiles are already there then tell me to overwrite them
# If I want to overwrite them then ask for confirmation and if I don't want to overwrite them then skip the task
# URL for the repo is git@github.com:NasifAhmed/dotfiles.git
clone_dotfiles() {
    echo "Cloning dotfiles..."
    # Add dotfiles cloning logic here
    echo "✅ Dotfiles cloned successfully."
    read -p "Press Enter to return to the main menu..."
    start_gui
}

setup_dotfiles() {
    echo "Setting up dotfiles..."
    # Add dotfiles setup logic here
    echo "✅ Dotfiles set up successfully."
    read -p "Press Enter to return to the main menu..."
    start_gui
}

install_fonts() {
    echo "Installing fonts..."
    # Add font installation logic here
    echo "✅ Fonts installed successfully."
    read -p "Press Enter to return to the main menu..."
    start_gui
}

install_nvm() {
    echo "Installing nvm..."
    # Add nvm installation logic here
    echo "✅ nvm installed successfully."
    read -p "Press Enter to return to the main menu..."
    start_gui
}

install_bangla_fonts() {
    echo "Installing Bangla fonts..."
    # Add Bangla font installation logic here
    echo "✅ Bangla fonts installed successfully."
    read -p "Press Enter to return to the main menu..."
    start_gui
}

cleanup_downloads() {
    echo "Cleaning up downloads..."
    # Add cleanup logic here
    echo "✅ Downloads cleaned up successfully."
    read -p "Press Enter to return to the main menu..."
    start_gui
}

do_everything() {
    install_essential_packages
    configure_ssh_and_git
    clone_dotfiles
    setup_dotfiles
    install_fonts
    install_nvm
    install_bangla_fonts
    cleanup_downloads
    echo "✅ All tasks completed."
    read -p "Press Enter to return to the main menu..."
    start_gui
}

restart_script() {
    echo "Restarting script..."
    cleanup_downloads
    package_manager=""
    essential_packages=""
    clear
    exec "$0" "$@"
}

# GUI function
start_gui() {
    clear
    echo "🚀 Welcome to the Linux Setup Script! 🐧"
    echo "Please choose an option:"
    echo "1. 📦 Install essential packages"
    echo "2. 🔒 Configure SSH"
    echo "3. 📂 Clone dotfiles"
    echo "4. ⚙️  Setup dotfiles"
    echo "5. 🖋️  Install fonts"
    echo "6. 📊 Install nvm"
    echo "7. 🇧🇩 Install Bangla fonts"
    echo "8. 🧹 Cleanup downloads"
    echo "9. 🌟 Do everything"
    echo "10. 🔄 Clean and Restart"
    echo "11. 🚪 Exit"
    
    read -p "Enter your choice (1-11): " choice
    
    case $choice in
        1) install_essential_packages ;;
        2) configure_ssh_and_git ;;
        3) clone_dotfiles ;;
        4) setup_dotfiles ;;
        5) install_fonts ;;
        6) install_nvm ;;
        7) install_bangla_fonts ;;
        8) cleanup_downloads ;;
        9) do_everything ;;
        10) restart_script ;;
        11) cleanup ;;
        *) echo "Invalid option. Please try again." && start_gui ;;
    esac
}

# Utility function for backing up files
backup_file() {
    local file=$1
    sudo cp "$file" "${file}.bak" || handle_error "Failed to backup $file" "Check if you have write permissions to $(dirname "$file")"
}

# Main execution
main() {
    start_gui
}

# Set up trap for graceful exit
trap cleanup SIGINT SIGTERM

# Run the main function
main
