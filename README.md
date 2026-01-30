# Omarchy Dots Manager

A robust, fault-tolerant configuration and storage manager for Arch Linux (Omarchy).  
Built with **Bash**, **GNU Stow**, and **Gum**.

## 🚀 Features

* **Profile Management:** Separate configurations for **Home PC** and **Office Laptop** while sharing common files.
* **The Vault (Storage Sync):** Sync arbitrary folders (Work docs, Jars, Save files) across machines by treating Git as a transport layer.
* **Power Sync:** Automated Git workflow. Handles commits, pushes, pulls, and resolves merge conflicts (Remote > Local) automatically.
* **Granular Control:** Sync/Install "All", "Configs Only", or "Storage Only".
* **Safety First:** automatically backs up existing config files before overwriting/linking.

## 📦 Installation

**One-Liner (Fresh Install):**
```bash
git clone [https://github.com/YOUR_USERNAME/dotfiles.git](https://github.com/YOUR_USERNAME/dotfiles.git) ~/dotfiles && ~/dotfiles/setup.sh
```


On the first run, the script will:

Install dependencies (git, stow, gum).

Install itself to ~/.local/bin/dots.

Add dots to your PATH.

### 📂 Repository Structure
You must maintain this structure for the script to function:

```plaintext
~/dotfiles/
├── setup.sh               # The main engine
├── storage.conf           # (Auto-generated) Maps Vault items to locations
├── common/                # Configs applied to ALL machines
│   ├── hypr/              # (.config/hypr/...)
│   └── nvim/              # (.config/nvim/...)
├── home/                  # Configs for HOME PC only
│   └── monitors/          # (.config/hypr/monitors.conf)
├── office/                # Configs for OFFICE LAPTOP only
│   └── monitors/          # (.config/hypr/monitors.conf)
└── storage/               # (Auto-generated) Stores actual Vault files
```

### 🛠 Usage
Once installed, just type:

`dots`
**Menu Options**
1. Sync:

    - Checks for local changes -> Auto Commits.

    - Checks for remote updates -> Pulls (and merges if needed).

    - Re-applies symlinks based on new data.

    - Scopes: Choose to sync everything, just dotfiles, or just Vault storage.

2. Install/Switch Profile:

    - Selects "Home" or "Office".

    - Links the common folder.

    - Links the specific folder (home or office).

    - Links Vault items defined in storage.conf.

3. Add to Vault:

    - Select a file or folder on your PC (e.g., ~/Desktop/Work).

    - The script moves it to the repo and symlinks it back.

    - It is now tracked and will appear on your other machine after a Sync.

4. Reset:

    - Safely unlinks configurations to restore system defaults.

## 🛡 Fault Tolerance
- Backups: If `dots` attempts to link a file but a real file already exists, it moves the existing file to `~/dotfiles_backups/[timestamp]/`. It never blindly overwrites data.

- Conflict Resolution: If Git branches diverge, dots defaults to theirs strategy (Remote wins) to ensure consistency across machines without manual merge editing.

- Logs: All operations are logged to ~/dotfiles/setup.log.

## 📝 Configuration
**Configs**: Place config files inside common, home, or office. Use stow directory matching (e.g., common/mpv/.config/mpv/mpv.conf).

Storage: Managed automatically via the UI. Mappings are stored in storage.conf.

```plaintext
DrJava.jar|/home/user/Desktop/DrJava.jar
Work|/home/user/Desktop/Work
```
