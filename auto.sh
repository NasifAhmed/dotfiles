#!/bin/bash

set -e

# Function to display messages with emojis
show_message() {
    echo -e "\n$1 $2"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect package manager
detect_package_manager() {
    for pm in apt pacman dnf; do
        if command_exists $pm; then
            echo $pm
            return
        fi
    done
    echo "Unknown"
}

# Platform-specific tweaks for Arch-based systems
arch_tweaks() {
    show_message "🏗️" "Performing Arch-specific tweaks..."

    # Install paru
    # if ! command_exists paru; then
    #     show_message "📦" "Installing paru..."
    #     git clone https://aur.archlinux.org/paru.git
    #     cd paru
    #     makepkg -si --noconfirm
    #     cd ..
    #     rm -rf paru
    # fi

    # Update pacman config
    local pacman_conf="/etc/pacman.conf"
    local tweaks=("Color" "ParallelDownloads = 5" "ILoveCandy")
    for tweak in "${tweaks[@]}"; do
        if ! grep -q "^$tweak" "$pacman_conf"; then
            show_message "🔧" "Adding $tweak to pacman config..."
            echo "$tweak" | sudo tee -a "$pacman_conf" > /dev/null
        fi
    done

    # Find fastest mirrors
    show_message "🔍" "Finding fastest mirrors..."
    if ! command_exists reflector; then
        sudo pacman -Syyu --noconfirm reflector
    fi
    sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

    show_message "✅" "Arch-specific tweaks completed."
}

# Platform-specific tweaks for Debian-based systems
debian_tweaks() {
    show_message "🏗️" "Performing Debian-specific tweaks..."

    # Install nala
    if ! command_exists nala; then
        show_message "📦" "Installing nala..."
        sudo apt update
        sudo apt install -y nala
    fi

    # Update and upgrade system using nala
    show_message "🔄" "Updating and upgrading system using nala..."
    sudo nala update
    sudo nala upgrade -y

    show_message "✅" "Debian-specific tweaks completed."
}

# Platform-specific tweaks for Fedora-based systems
fedora_tweaks() {
    show_message "🏗️" "Performing Fedora-specific tweaks..."

    # Update DNF config
    local dnf_conf="/etc/dnf/dnf.conf"
    if ! grep -q "^max_parallel_downloads" "$dnf_conf"; then
        show_message "🔧" "Adding max_parallel_downloads to DNF config..."
        echo "max_parallel_downloads=10" | sudo tee -a "$dnf_conf" > /dev/null
    fi

    # Update and upgrade system
    show_message "🔄" "Updating and upgrading system..."
    sudo dnf update -y

    # Install RPM Fusion and multimedia packages
    show_message "📦" "Installing RPM Fusion and multimedia packages..."
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
    sudo dnf install -y lame\* --exclude=lame-devel
    # sudo dnf group upgrade -y --with-optional Multimedia

    show_message "✅" "Fedora-specific tweaks completed."
}


# Install required packages
install_required_packages() {
    local debian_packages=("git" "neovim" "fzf" "wget" "make" "gcc" "unzip" "openssh-client" "openssl" "stow" "ripgrep" "fd-find" "fontconfig")
    local arch_packages=("git" "neovim" "fzf" "wget" "make" "gcc" "unzip" "openssh" "openssl" "stow" "ripgrep" "fd" "fontconfig")
    local fedora_packages=("git" "neovim" "fzf" "wget" "make" "gcc" "unzip" "openssh-clients" "openssl" "stow" "ripgrep" "fd-find" "fontconfig")
    local package_commands=("git" "nvim" "fzf" "wget" "make" "gcc" "unzip" "ssh-keygen" "openssl" "stow" "rg" "fd" "fc-list")
    local pm=$(detect_package_manager)

    local packages

    case $pm in
        apt)    packages=("${debian_packages[@]}") ;;
        pacman) packages=("${arch_packages[@]}") ;;
        dnf)    packages=("${fedora_packages[@]}") ;;
        *)      show_message "❌" "Unsupported package manager. Please install packages manually."
                return ;;
    esac

    for i in "${!packages[@]}"; do
        if ! command_exists "${package_commands[$i]}"; then
            show_message "📦" "Installing ${packages[$i]}..."
            case $pm in
                apt)    sudo apt update && sudo apt install -y "${packages[$i]}" ;;
                pacman) sudo pacman -Sy --noconfirm "${packages[$i]}" ;;
                dnf)    sudo dnf install -y "${packages[$i]}" ;;
            esac
        else
            show_message "✅" "${packages[$i]} is already installed."
        fi
    done
}

# Function to open URL in default browser
open_url() {
    local url="$1"
    if command_exists xdg-open; then
        xdg-open "$url"
    elif command_exists open; then
        open "$url"
    else
        show_message "❌" "Unable to open URL. Please open $url manually."
    fi
}

# Set up DNS server
setup_dns() {
    local dns_config="/etc/systemd/resolved.conf"
    local dns_content="[Resolve]
DNS=45.90.28.0#a46c82.dns.nextdns.io
DNS=2a07:a8c0::#a46c82.dns.nextdns.io
DNS=45.90.30.0#a46c82.dns.nextdns.io
DNS=2a07:a8c1::#a46c82.dns.nextdns.io
DNSOverTLS=yes"

if [ -f /proc/1/comm ] && [ "$(cat /proc/1/comm)" != "systemd" ]; then
        show_message "⚠️" "Not running under systemd (likely in a container). Skipping DNS setup."
        return
    fi

    if ! grep -q "a46c82.dns.nextdns.io" "$dns_config"; then
        show_message "🌐" "Setting up DNS server..."
        echo "$dns_content" | sudo tee "$dns_config" > /dev/null
        sudo systemctl restart systemd-resolved
        show_message "✅" "DNS server configured successfully."
    else
        show_message "✅" "DNS already configured. Skipping..."
    fi
}

# Configure SSH for GitHub
configure_ssh() {
    local ssh_key="$HOME/.ssh/id_ed25519"
    if [ -f $ssh_key ]; then
        show_message "🔑" "Existing SSH key found."
        read -p "Have you added the SSH key to your GitHub account? (Y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            show_message "📋" "Please add the following SSH key to your GitHub account:"
            cat "${ssh_key}.pub"
            open_url "https://github.com/settings/keys"
            read -p "Have you added the SSH key to your GitHub account now? (Y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                show_message "❌" "SSH key not added. Please add it manually and run the script again."
                exit 1
            fi
        fi
    else
        show_message "🔑" "Generating new SSH key..."
        ssh-keygen -t ed25519 -C "nasif2ahmed@gmail.com"
        show_message "📋" "Please add the following SSH key to your GitHub account:"
        cat "${ssh_key}.pub"
        open_url "https://github.com/settings/keys"
        read -p "Have you added the SSH key to your GitHub account? (Y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            show_message "❌" "SSH key not added. Please add it manually and run the script again."
            exit 1
        fi
    fi

    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        show_message "✅" "SSH connection to GitHub successful."
    else
        show_message "❌" "SSH connection to GitHub failed. Please configure it manually."
        exit 1
    fi
}

# Clone dotfiles repository
clone_dotfiles() {
    if [ ! -d ~/dotfiles ]; then
        show_message "📦" "Cloning dotfiles repository..."
        git clone git@github.com:NasifAhmed/dotfiles.git ~/dotfiles
    else
        show_message "✅" "Dotfiles repository already exists."
    fi
}

# Use Stow to symlink dotfiles
setup_dotfiles() {
    local dotfiles_dir="$HOME/dotfiles"
    local stow_dir="$dotfiles_dir/stow"
    local configs=("bash" "nvim")  # Add more config names as needed

    if [ ! -d "$dotfiles_dir" ]; then
        show_message "❌" "Dotfiles directory not found. Please clone your dotfiles repository first."
        return 1
    fi

    cd "$stow_dir"

    rm -rf "$HOME/.bashrc"
    rm -rf "$HOME/.bash_history"
    for config in "${configs[@]}"; do
        if [ -d "$config" ]; then
            show_message "🔗" "Setting up $config configuration..."
            
            # Check and handle existing files/directories
            for file in "$config"/*; do
                local target="$HOME/$(basename "$file")"
                if [ -e "$target" ]; then
                    if [ -L "$target" ]; then
                        show_message "🗑️" "Removing existing symlink: $target"
                        rm "$target"
                    elif [ -f "$target" ] || [ -d "$target" ]; then
                        show_message "📦" "Backing up existing file/directory: $target to ${target}.bak"
                        mv "$target" "${target}.bak"
                    fi
                fi
            done

            show_message "🔗" "Stowing $config configuration..."
            stow -v -t "$HOME" "$config"
            show_message "✅" "$config configuration stowed successfully."
        else
            show_message "⚠️" "$config directory not found in dotfiles/stow. Skipping..."
        fi
    done

    cd - > /dev/null
}

# Install fonts
install_fonts() {
    local fonts=("JetBrains Mono" "JetBrainsMono Nerd Font")
    local urls=(
        "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
    )

    for i in "${!fonts[@]}"; do
        if ! fc-list | grep -q "${fonts[$i]}"; then
            show_message "🔤" "Installing ${fonts[$i]} font..."
            wget "${urls[$i]}" -O "${fonts[$i]}.zip"
            unzip "${fonts[$i]}.zip" -d "${fonts[$i]}"
            sudo cp -r "${fonts[$i]}" /usr/share/fonts/
            rm -rf "${fonts[$i]}" "${fonts[$i]}.zip"
        else
            show_message "✅" "${fonts[$i]} font is already installed."
        fi
    done

    sudo fc-cache -f -v
}

# Install NVM
install_nvm() {
    if [ ! -d ~/.nvm ]; then
        show_message "📦" "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi
    
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    
    if command -v nvm >/dev/null 2>&1; then
        show_message "✅" "NVM is installed and functioning."
    else
        show_message "❌" "NVM installation failed. Please install it manually."
    fi
}


# Install Bangla font fixes
install_bangla_fonts() {
    if ! fc-list | grep -q "Nirmala UI"; then
        show_message "🇧🇩" "Installing Bangla font fixes..."
        for script in fonts-bangla-download bangla-nirmalaui-default msfonts-download; do
            curl -sSL "https://raw.githubusercontent.com/tazihad/bangla-font-fix-linux/main/${script}.sh" | sh
        done
        show_message "✅" "Bangla font fixes installed successfully."
    else
        show_message "✅" "Bangla font fixes are already installed."
    fi
}

# Clean up downloaded files
cleanup_downloads() {
    show_message "🧹" "Cleaning up downloaded files..."
    rm -rf font_dir
    rm -f font.zip
    show_message "✅" "Cleanup completed."
}

# Function to source the new .bashrc
source_new_bashrc() {
    show_message "🔄" "Sourcing the new .bashrc..."
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
        show_message "✅" "New .bashrc has been sourced successfully."
    else
        show_message "❌" "Failed to source .bashrc: File not found."
    fi
}

# Main execution
main() {
    show_message "🚀" "Starting new PC setup..."

    setup_dns

    # Perform platform-specific tweaks
    case $(detect_package_manager) in
        pacman) arch_tweaks ;;
        apt)    debian_tweaks ;;
        dnf)    fedora_tweaks ;;
        *)      show_message "⚠️" "Unsupported package manager. Skipping platform-specific tweaks." ;;
    esac

    install_required_packages
    configure_ssh
    clone_dotfiles
    setup_dotfiles
    install_fonts
    install_nvm
    install_bangla_fonts
    cleanup_downloads
    source_new_bashrc
    show_message "🎉" "New PC setup completed successfully!"
}

# Error handling
trap 'show_message "❌" "An error occurred. Exiting..."; exit 1' ERR

# Run the main function
main
source ~/.bashrc
