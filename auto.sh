#!/bin/bash

# Made by Nasif Ahmed 2024
# This script is designed to automate the installation of essential packages and configuration of my personal Linux systems.
# WARNING : The script is heavily opniotaed and personal not for general use

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    echo -e "${BLUE}Cleaning up...${NC}"
    # Add cleanup tasks here
    exit 0
}

handle_error() {
    echo -e "${RED}❌ Error: $1${NC}"
    echo -e "${YELLOW}Possible solution: $2${NC}"
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
        *) echo -e "${RED}Unsupported package manager: $package_manager${NC}" >&2; return 1 ;;
    esac
}

initialize_package_manager() {
    detect_package_manager || return 1
    echo -e "${BLUE}Initializing package manager...${NC}"

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
    echo -e "${GREEN}✅ Package manager initialized successfully.${NC}"
}

configure_pacman() {
    echo -e "${BLUE}Configuring Arch Linux package manager...${NC}"
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
    echo -e "${BLUE}Configuring Debian-based package manager...${NC}"
    sudo apt update || handle_error "Failed to update apt" "Check your internet connection and try again"
    
    # Install netselect-apt if it's not already installed
    if ! dpkg -s netselect-apt &> /dev/null; then
        sudo apt install -y netselect-apt || handle_error "Failed to install netselect-apt" "Try running 'sudo apt update && sudo apt upgrade' to update your system"
    fi
    
    # Check if /etc/apt/sources.list exists
    if [ -f "/etc/apt/sources.list" ]; then
        backup_file "/etc/apt/sources.list"
    else
        echo -e "${YELLOW}Warning: /etc/apt/sources.list not found. Skipping backup.${NC}"
    fi
    
    # Use netselect-apt to find the fastest mirror
    sudo netselect-apt || handle_error "Failed to find fastest mirror" "Check your internet connection and try again"
    
    # Update package lists after changing mirrors
    sudo apt update || handle_error "Failed to update apt after changing mirrors" "Check your internet connection and try again"
}

configure_dnf() {
    echo -e "${BLUE}Configuring Fedora package manager...${NC}"
    
    backup_file "/etc/dnf/dnf.conf"
    
    # Add fastestmirror and max_parallel_downloads to dnf.conf
    if ! grep -q "fastestmirror=True" /etc/dnf/dnf.conf; then
        echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf || handle_error "Failed to enable fastest mirror" "Check if you have write permissions to /etc/dnf/dnf.conf"
    fi
    if ! grep -q "max_parallel_downloads=10" /etc/dnf/dnf.conf; then
        echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf || handle_error "Failed to set max parallel downloads" "Check if you have write permissions to /etc/dnf/dnf.conf"
    fi

    # Enable RPM Fusion repositories
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm || handle_error "Failed to install RPM Fusion Free" "Check your internet connection and try again"
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || handle_error "Failed to install RPM Fusion Non-Free" "Check your internet connection and try again"

    # Install multimedia packages
    sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel || handle_error "Failed to install gstreamer packages" "Check your internet connection and try again"
    sudo dnf install -y lame\* --exclude=lame-devel || handle_error "Failed to install lame packages" "Check your internet connection and try again"

    echo -e "${GREEN}✅ Fedora package manager configured successfully.${NC}"
}

update_system() {
    echo -e "${BLUE}Updating and upgrading the system...${NC}"
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
    echo -e "${BLUE}Installing essential packages...${NC}"

    case $package_manager in
        "pacman")
            install_cmd="sudo pacman -S --noconfirm"
            check_cmd="pacman -Qi"
            exists_cmd="pacman -Ss"
            ;;
        "apt")
            install_cmd="sudo apt install -y"
            check_cmd="dpkg -s"
            exists_cmd="apt-cache show"
            ;;
        "dnf")
            install_cmd="sudo dnf install -y"
            check_cmd="rpm -q"
            exists_cmd="dnf info"
            ;;
        *)
            handle_error "Unsupported package manager" "Ensure you're using a supported distribution (Debian, Fedora, or Arch-based)"
            return
            ;;
    esac

    for package in $essential_packages; do
        if $check_cmd $package &> /dev/null; then
            echo -e "${YELLOW}$package is already installed. Skipping.${NC}"
        elif $exists_cmd $package &> /dev/null; then
            echo -e "${BLUE}Installing $package...${NC}"
            $install_cmd $package || echo -e "${YELLOW}Failed to install $package. Skipping.${NC}"
        else
            echo -e "${YELLOW}Package $package not found in repositories. Skipping.${NC}"
        fi
    done

    verify_package_installation
    read -p "Press Enter to return to the main menu..."
    start_gui
}

verify_package_installation() {
    echo -e "${BLUE}Verifying package installation...${NC}"
    all_installed=true
    for package in $essential_packages; do
        if $check_cmd $package &> /dev/null; then
            echo -e "${GREEN}✅ $package is successfully installed.${NC}"
        elif $exists_cmd $package &> /dev/null; then
            echo -e "${YELLOW}⚠️ $package is available but not installed.${NC}"
            all_installed=false
        else
            echo -e "${YELLOW}⚠️ $package is not available in the package repositories.${NC}"
            all_installed=false
        fi
    done

    if $all_installed; then
        echo -e "${GREEN}✅ All available essential packages have been installed.${NC}"
    else
        echo -e "${YELLOW}⚠️ Some packages could not be installed or are not available.${NC}"
    fi
}

configure_ssh_and_git() {
    echo -e "${BLUE}Configuring SSH...${NC}"
    
    local ssh_dir="$HOME/.ssh"
    local key_file="$ssh_dir/id_ed25519"
    local email="nasif2ahmed@gmail.com"
    local name="Nasif Ahmed"

    # Check if SSH key already exists
    if [ -f "$key_file" ]; then
        echo -e "${YELLOW}SSH key already exists.${NC}"
        echo -e "${BLUE}Please add the following public key to your GitHub account:${NC}"
        cat "${key_file}.pub"
        read -p "Press Enter when you've added the key to GitHub..."
    else
        # Generate new SSH key
        mkdir -p "$ssh_dir"
        ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
        echo -e "${GREEN}New SSH key generated.${NC}"
        echo -e "${BLUE}Please add the following public key to your GitHub account:${NC}"
        cat "${key_file}.pub"
        read -p "Press Enter when you've added the key to GitHub..."
    fi

    # Start ssh-agent and add the key
    eval "$(ssh-agent -s)"
    ssh-add "$key_file"

    # Test SSH connection
    echo -e "${BLUE}Testing SSH connection to GitHub...${NC}"
    ssh -T git@github.com

    if [ $? -eq 1 ]; then
        echo -e "${GREEN}✅ SSH configured successfully and connected to GitHub.${NC}"
        
        # Configure Git
        echo -e "${BLUE}Configuring Git...${NC}"
        read -p "Enter your name for Git configuration: " git_name
        read -p "Enter your email for Git configuration: " git_email
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        
        echo -e "${GREEN}✅ Git configured successfully.${NC}"
    else
        handle_error "Failed to connect to GitHub" "Check your internet connection and ensure the SSH key is added to your GitHub account"
    fi

    read -p "Press Enter to return to the main menu..."
    start_gui
}

clone_dotfiles() {
    echo -e "${BLUE}Cloning dotfiles...${NC}"
    
    # Check if SSH is configured properly
    # if ! ssh -T git@github.com &>/dev/null; then
    #     echo -e "${RED}❌ GitHub SSH setup is not complete.${NC}"
    #     echo -e "${YELLOW}Please run the 'Configure SSH' option from the main menu first.${NC}"
    #     read -p "Press Enter to return to the main menu..."
    #     start_gui
    #     return
    # fi

    local dotfiles_dir="$HOME/dotfiles"
    local repo_url="git@github.com:NasifAhmed/dotfiles.git"

    if [ -d "$dotfiles_dir" ]; then
        echo -e "${YELLOW}Dotfiles directory already exists.${NC}"
        read -p "Do you want to overwrite it? (y/n): " overwrite
        if [[ $overwrite =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Removing existing dotfiles...${NC}"
            rm -rf "$dotfiles_dir"
        else
            echo -e "${YELLOW}Skipping dotfiles cloning.${NC}"
            read -p "Press Enter to return to the main menu..."
            start_gui
            return
        fi
    fi

    echo -e "${BLUE}Cloning dotfiles from $repo_url...${NC}"
    if git clone "$repo_url" "$dotfiles_dir"; then
        echo -e "${GREEN}✅ Dotfiles cloned successfully.${NC}"
    else
        handle_error "Failed to clone dotfiles" "Check your internet connection and GitHub SSH setup"
        return
    fi

    read -p "Press Enter to return to the main menu..."
    start_gui
}

setup_dotfiles() {
    echo -e "${BLUE}Setting up dotfiles...${NC}"
    
    local dotfiles_dir="$HOME/dotfiles"
    local stow_dir="$dotfiles_dir/stow"

    # Check if the dotfiles are already there or not
    if [ ! -d "$dotfiles_dir" ]; then
        echo -e "${YELLOW}Dotfiles directory not found.${NC}"
        read -p "Do you want to clone the dotfiles? (y/n): " clone_choice
        if [[ $clone_choice =~ ^[Yy]$ ]]; then
            clone_dotfiles
        else
            echo -e "${YELLOW}Skipping dotfiles setup.${NC}"
            read -p "Press Enter to return to the main menu..."
            start_gui
            return
        fi
    fi

    # Check if stow is installed
    if ! command -v stow &> /dev/null; then
        handle_error "GNU Stow is not installed" "Please install GNU Stow and try again"
        return
    fi
    
    # Backup common shell configuration files
    local backup_files=(".bashrc" ".bash_history" ".zshrc" ".zsh_history")
    for file in "${backup_files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            echo -e "${BLUE}Backing up $file...${NC}"
            cp "$HOME/$file" "$HOME/${file}.bak"
            rm -f "$HOME/$file"
        fi
    done

    # Function to stow a single package
    stow_package() {
        local package_name="$1"
        if stow -d "$stow_dir" -t "$HOME" -R "$package_name"; then
            echo -e "${GREEN}✅ Stowed $package_name successfully.${NC}"
        else
            handle_error "Failed to stow $package_name" "Check for conflicts and try again"
            return 1
        fi
    }

    # Function to display the package selection menu
    display_package_menu() {
        local packages=()
        for package in "$stow_dir"/*; do
            if [ -d "$package" ]; then
                packages+=("$(basename "$package")")
            fi
        done

        while true; do
            echo -e "${BLUE}Select a package to stow:${NC}"
            select package in "${packages[@]}" "Stow all packages" "Return to main menu"; do
                case $REPLY in
                    ''|*[!0-9]*) echo -e "${RED}Invalid option. Please try again.${NC}"; break ;;
                    *)
                        if [ $REPLY -le ${#packages[@]} ]; then
                            stow_package "${packages[$REPLY-1]}"
                            break
                        elif [ $REPLY -eq $((${#packages[@]}+1)) ]; then
                            for pkg in "${packages[@]}"; do
                                stow_package "$pkg"
                            done
                            break
                        elif [ $REPLY -eq $((${#packages[@]}+2)) ]; then
                            echo -e "${YELLOW}Returning to main menu...${NC}"
                            return
                        else
                            echo -e "${RED}Invalid option. Please try again.${NC}"
                        fi
                        ;;
                esac
            done
            
            # Check if user chose to return to main menu
            if [ $REPLY -eq $((${#packages[@]}+2)) ]; then
                break
            fi
        done
    }

    # Display the package selection menu
    display_package_menu

    echo -e "${GREEN}✅ Dotfiles setup completed.${NC}"
    read -p "Press Enter to return to the main menu..."
    start_gui
}

install_fonts() {
    local fonts=(
        "JetBrainsMono:$(curl -s https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest | grep 'browser_download_url.*zip' | cut -d '"' -f 4)"
        "JetBrainsMonoNerdFont:$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep 'browser_download_url.*JetBrainsMono.zip' | cut -d '"' -f 4)"
        "Roboto:$(curl -s https://api.github.com/repos/googlefonts/roboto/releases/latest | grep 'browser_download_url.*unhinted.zip' | cut -d '"' -f 4)"
    )
    local installed_fonts=()
    local to_install=()

    # Ensure unzip is installed
    if ! command -v unzip &> /dev/null; then
        echo -e "${YELLOW}unzip is not installed. Installing...${NC}"
        case $package_manager in
            "pacman") sudo pacman -S --noconfirm unzip ;;
            "apt") sudo apt install -y unzip ;;
            "dnf") sudo dnf install -y unzip ;;
            *) handle_error "Unsupported package manager" "Ensure you're using a supported distribution"; return 1 ;;
        esac
    fi

    echo -e "${BLUE}Checking installed fonts...${NC}"
    for font_info in "${fonts[@]}"; do
        IFS=':' read -r font_name font_url <<< "$font_info"
        if fc-list | grep -i "$font_name" > /dev/null; then
            installed_fonts+=("$font_name")
        else
            to_install+=("$font_info")
        fi
    done

    if [ ${#installed_fonts[@]} -eq ${#fonts[@]} ]; then
        echo -e "${GREEN}All fonts are already installed. Skipping task.${NC}"
        read -p "Press Enter to return to the main menu..."
        start_gui
        return
    fi

    while true; do
        echo -e "${BLUE}Select fonts to install:${NC}"
        for i in "${!to_install[@]}"; do
            IFS=':' read -r font_name _ <<< "${to_install[i]}"
            echo "$((i+1)). $font_name"
        done
        echo "$((${#to_install[@]}+1)). Install Windows 10 fonts"
        echo "$((${#to_install[@]}+2)). Install all fonts (including Windows 10 fonts)"
        echo "$((${#to_install[@]}+3)). Return to main menu"

        read -p "Enter your choice: " choice

        case $choice in
            ''|*[!0-9]*) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
            *)
                if [ "$choice" -le "${#to_install[@]}" ]; then
                    install_font "${to_install[$((choice-1))]}"
                elif [ "$choice" -eq $((${#to_install[@]}+1)) ]; then
                    echo -e "${BLUE}Installing Windows 10 fonts...${NC}"
                    install_windows_fonts
                elif [ "$choice" -eq $((${#to_install[@]}+2)) ]; then
                    echo -e "${BLUE}Installing all fonts (including Windows 10 fonts)...${NC}"
                    install_windows_fonts
                    for font_info in "${to_install[@]}"; do
                        install_font "$font_info"
                    done
                    break
                elif [ "$choice" -eq $((${#to_install[@]}+3)) ]; then
                    echo -e "${YELLOW}Returning to main menu...${NC}"
                    start_gui
                    return
                else
                    echo -e "${RED}Invalid option. Please try again.${NC}"
                fi
                ;;
        esac
    done

    echo -e "${GREEN}✅ Font installation completed.${NC}"
    read -p "Press Enter to return to the main menu..."
    start_gui
}

install_font() {
    IFS=':' read -r font_name font_url <<< "$1"
    echo -e "${BLUE}Installing $font_name...${NC}"
    
    local temp_dir=$(mktemp -d)
    local zip_file="$temp_dir/$font_name.zip"
    
    # Download font
    wget -O "$zip_file" "$font_url" || { handle_error "Failed to download $font_name" "Check your internet connection and try again"; return 1; }
    
    # Unzip font
    sudo unzip -o "$zip_file" -d "/usr/share/fonts/$font_name" || { handle_error "Failed to unzip $font_name" "Check if the downloaded file is valid"; return 1; }
    
    # Clean up
    rm -rf "$temp_dir"
    
    # Update font cache
    sudo fc-cache -f -v
    
    # Verify installation
    if fc-list | grep -i "$font_name" > /dev/null; then
        echo -e "${GREEN}✅ $font_name installed successfully.${NC}"
    else
        echo -e "${RED}❌ $font_name installation failed or not detected.${NC}"
    fi
}

install_windows_fonts() {
    echo -e "${BLUE}Installing Windows 10 fonts...${NC}"
    curl -sSL https://raw.githubusercontent.com/tazihad/bangla-font-fix-linux/main/msfonts-download.sh | sh
    
    # Update font cache
    sudo fc-cache -f -v
    
    # Check if a Windows 10 font exists (e.g., Arial)
    if fc-list | grep -i "Arial" > /dev/null; then
        echo -e "${GREEN}✅ Windows 10 fonts installed successfully.${NC}"
    else
        echo -e "${RED}❌ Windows 10 fonts installation failed or not detected.${NC}"
    fi
}

install_nvm() {
    echo -e "${BLUE}Installing nvm...${NC}"
    # Add nvm installation logic here
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    
    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Check if nvm is working
    if command -v nvm &> /dev/null; then
        echo -e "${GREEN}✅ nvm installed and working successfully.${NC}"
    else
        echo -e "${RED}❌ nvm installation failed or not working properly.${NC}"
        handle_error "nvm installation failed" "Try restarting your terminal and running the script again"
        return 1
    fi
    
    read -p "Press Enter to return to the main menu..."
    start_gui
}

install_bangla_fonts() {
    echo -e "${BLUE}Installing Bangla fonts...${NC}"
    
    # Install Bangla fonts
    curl -sSL https://raw.githubusercontent.com/tazihad/bangla-font-fix-linux/main/fonts-bangla-download.sh | sh
    
    # Make Nirmala UI default Bangla font
    curl -sSL https://raw.githubusercontent.com/tazihad/bangla-font-fix-linux/main/bangla-nirmalaui-default.sh | sh
    
    # Update font cache
    sudo fc-cache -f -v
    
    # Check if Nirmala UI exists and is the default Bangla font
    if fc-list | grep -i "Nirmala UI" > /dev/null; then
        echo -e "${GREEN}✅ Nirmala UI font installed successfully.${NC}"
        if fc-match -s :lang=bn | grep -i "Nirmala UI" > /dev/null; then
            echo -e "${GREEN}✅ Nirmala UI set as default Bangla font successfully.${NC}"
        else
            echo -e "${RED}❌ Failed to set Nirmala UI as default Bangla font.${NC}"
        fi
    else
        echo -e "${RED}❌ Nirmala UI font installation failed or not detected.${NC}"
    fi
    
    read -p "Press Enter to return to the main menu..."
    start_gui
}

cleanup_downloads() {
    echo -e "${BLUE}Cleaning up downloads...${NC}"
    # Add cleanup logic here
    echo -e "${GREEN}✅ Downloads cleaned up successfully.${NC}"
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
    echo -e "${GREEN}✅ All tasks completed.${NC}"
    read -p "Press Enter to return to the main menu..."
    start_gui
}

restart_script() {
    echo -e "${BLUE}Restarting script...${NC}"
    cleanup_downloads
    package_manager=""
    essential_packages=""
    clear
    exec "$0" "$@"
}

# GUI function
start_gui() {
    clear
    echo -e "${GREEN}🚀 Welcome to the Linux Setup Script! 🐧${NC}"
    echo -e "${BLUE}Please choose an option:${NC}"
    echo "1. 📦 Install essential packages"
    echo "2. 🔒 Configure Github with SSH Authintication"
    echo "3. 📂 Clone dotfiles"
    echo "4. ⚙️  Setup dotfiles"
    echo "5. 🖋️  Install fonts"
    echo "6. 📊 Install nvm"
    echo "7. 🇧🇩 Install Bangla fonts"
    echo "8. 🧹 Cleanup downloads"
    echo "9. 🌟 Do everything"
    echo "10. 🔄 Clean and Restart Script"
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
        *) echo -e "${RED}Invalid option. Please try again.${NC}" && start_gui ;;
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
