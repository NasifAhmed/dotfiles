# 🔮 Nasif's Omarchy Setup

![Version](https://img.shields.io/badge/Version-10.0-ff69b4?style=for-the-badge&logo=archlinux)
![OS](https://img.shields.io/badge/OS-Omarchy-purple?style=for-the-badge&logo=linux)
![WM](https://img.shields.io/badge/WM-Hyprland-green?style=for-the-badge)

A highly opinionated, fault-tolerant configuration and storage manager specifically designed for **Omarchy OS** (Arch Linux). This system manages profile-specific Hyprland configurations, creates a unified workflow across different machines (Home PC & Office Laptop), and safely syncs sensitive storage.

**Author:** Nasif Ahmed  
**Current Version:** 10.0 (Native Edition)

---

## 🚀 Features

*   **✨ TUI Dashboard:** A beautiful, interactive CLI interface built with `gum`, featuring a "Cyberpunk/Obsidian" aesthetic.
*   **🎭 Profile System:** Distinct profiles for **Home PC** and **Office Laptop** ensuring the right configs (monitors, startup apps) load on the right machine.
*   **⛓️ Omarchy Integration:** 
    *   Automatically handles Hyprland reloads via `hyprctl reload`.
    *   Preserves Omarchy defaults while applying your overrides safely.
    *   Manages custom keybindings for things like Projector Mode and DrJava.
*   **📦 The Vault (Storage Sync):** Seamlessly sync arbitrary folders (Work documents, JARs, notes) across machines using Git as a transport layer.
*   **🔄 Power Sync:** Automated, intelligent Git workflow.
    *   Auto-commits local changes.
    *   Pulls remote updates (Conflict Resolution: Remote Wins).
    *   Re-applies symlinks instantly.
*   **🛡️ Safety First:** 
    *   **Never** blindly overwrites files.
    *   Existing files are backed up to `~/dotfiles_backups/` before linking.
    *   Rolling backup deletion (keeps last 14 days).

---

## 🛠️ Installation

### Prerequisites
*   **OS:** Omarchy OS (or any Arch-based distro using `pacman`).
*   **Git:** Must be installed.

### Setup
1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
    ```

2.  **Run the Installer:**
    ```bash
    cd ~/dotfiles
    ./setup.sh
    ```
    *The script will automatically detect missing dependencies (`stow`, `gum`, `rsync`) and install them via `pacman`.*

3.  **Access Anywhere:**
    The script installs a symlink to `~/.local/bin/dots`. You can now run it from anywhere:
    ```bash
    dots
    ```

---

## 📂 System Structure

This repository uses **GNU Stow** logic. The folder structure maps 1:1 to your home directory.

```plaintext
~/dotfiles/
├── setup.sh                 # The Engine (v10.0)
├── storage.conf             # Vault database (Tracks synced folders)
│
├── common/                  # 🌍 Applied to ALL profiles
│   ├── hypr/                # Core Hyprland configs
│   ├── nvim/                # Neovim Lua setup
│   ├── mpv/                 # Media player configs
│   └── scripts/             # Global scripts (~/.local/bin)
│       ├── files.sh
│       ├── kill-process.sh  # RAM-aware process killer
│       └── window-fuzzy.sh  # Fuzzy window switcher
│
├── home/                    # 🏠 Applied only to HOME PC
│   └── hypr/                # Home-specific autostart/monitors
│
├── office/                  # 🏢 Applied only to OFFICE LAPTOP
│   ├── hypr/                # Office monitors & bindings
│   └── scripts/             # Office-specific tools
│       ├── office-menu.sh        # Projector/DrJava launcher
│       └── send_to_projector.sh  # Dual-screen management
│
└── storage/                 # 🔒 The Vault (Actual synced data)
    ├── work/                # Synced Work documents
    └── obsidian/            # Synced Notes
```

---

## 🎮 Usage Guide

Run `dots` to open the main dashboard.

### 1. 🚀 Sync System
*   **Scope:** All, Configs Only, or Storage Only.
*   **Action:** Commits local changes, pulls remote updates, merges conflicts, and reloads Hyprland.
*   **Use Case:** Run this at the start and end of your day.

### 2. 🎭 Install/Switch Profile
*   **Select Machine:** "Home PC" or "Office Laptop".
*   **Action:** 
    1.  Unlinks current configs.
    2.  Links `common/` + `[profile]/` folders.
    3.  Links Vault items from `storage.conf`.
    4.  Reloads Hyprland (`hyprctl reload`).

### 3. ➕ Add Config (Stow)
*   **Action:** Moves a local config folder (e.g., `~/.config/waybar`) into the repo and symlinks it back.
*   **Prompt:** asks if it should be Common (Global) or Profile-specific.

### 4. 📦 Add to Vault (Storage)
*   **Action:** Moves a standalone folder (e.g., `~/Desktop/Work`) into `~/dotfiles/storage/` and symlinks it back.
*   **Benefit:** These files are now tracked by Git and will appear on your other machines automatically.

---

## ⌨️ Keybindings (Omarchy Overrides)

These are managed via `common/hypr/bindings.conf` or profile-specific configs.

| Binding | Action | Source |
| :--- | :--- | :--- |
| `SUPER + ALT + X` | 🩸 **Kill Process** (RAM Menu) | Common |
| `SUPER + ALT + I` | 🪟 **Fuzzy Window Switcher** | Common |
| `SUPER + ALT + O` | 🏢 **Office Menu** (Projector/DrJava) | Office Only |
| `SUPER + P` | 📽️ **Send to Projector** (WS 10) | Office Only |
| `SUPER + SHIFT + P` | 💻 **Get from Projector** | Office Only |

---

## ⚠️ Fault Tolerance & Safety

*   **Conflict Detection:** If `stow` detects a file collision, `setup.sh` moves the conflicting file to `~/dotfiles_backups/` (timestamped) before linking.
*   **Omarchy Reset Protection:** This setup deliberately uses `hyprctl reload` instead of `omarchy-refresh-hyprland` to prevent the OS from overwriting your custom symlinks with factory defaults.

---

> *"Order out of chaos."* — Nasif's Omarchy Setup