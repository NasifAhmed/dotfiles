# 🔄 Dotfiles Sync

> **Native Bash Dotfiles Manager for Omarchy Linux**

A beautiful TUI-based dotfiles sync and profile management system built entirely with native Linux tools (Bash, gum, stow, git).

## ✨ Features

- **📊 Dashboard** - Real-time status with ASCII art, git status, profile info
- **🔄 Smart Sync** - Auto commit/push/pull with conflict resolution (prefers cloud)
- **👤 Profiles** - Manage multiple configs (home, office, etc.)
- **📦 Storage** - General file storage with stow integration
- **⏰ Time Travel** - Browse and restore to any commit snapshot
- **🎨 Beautiful TUI** - Uses gum for modern, beautiful interface

## 🚀 Quick Start

```bash
# Bootstrap (installs dependencies)
bash bootstrap.sh

# Launch TUI
./sync

# Or after bootstrap, from anywhere:
sync
```

## 📖 Usage

```bash
./sync              # Launch TUI dashboard
./sync --help       # Show help
./sync --sync       # Quick sync to cloud
./sync --profile X  # Switch to profile X
./sync --status     # Show current status
```

## 📁 Structure

```
dotfiles/
├── sync                 # Main entry point script
├── bootstrap.sh         # Setup script
├── lib/                 # Library modules
│   ├── logger.sh        # Logging with timestamps
│   ├── config.sh        # Configuration management
│   ├── deps.sh          # Dependency verification
│   ├── tui.sh           # TUI framework (gum/dialog)
│   ├── git_sync.sh      # Git sync & time travel
│   ├── stow_manager.sh  # Stow operations & backup
│   ├── profile.sh       # Profile CRUD
│   └── storage.sh       # Storage CRUD
├── home/                # Home profile (example)
├── office/              # Office profile (example)
├── storage/             # General storage
└── backups/             # Conflict backups
```

## 🔧 Dependencies

**Required:**
- `git` - Version control
- `stow` - Symlink manager

**Recommended:**
- `gum` - Modern TUI (Charmbracelet)

**Fallback:**
- `dialog` or `whiptail` - Basic TUI

## ⚙️ How It Works

### Profiles
Each profile is a directory containing stow-compatible config subdirectories:
```
home/
├── hypr/          # Hyprland configs
│   └── .config/
│       └── hypr/
├── nvim/          # Neovim configs
│   └── .config/
│       └── nvim/
└── scripts/       # Custom scripts
    └── .local/
        └── bin/
```

### Sync Logic
1. Fetch from origin
2. Compare local vs remote commits
3. If behind → pull (prefer cloud on conflicts)
4. If ahead → push
5. If diverged → save local, pull, push

### Time Travel
- Browse all commits as snapshots
- Preview changes before restoring
- Creates backup branch before time travel
- Easily return from any backup

## 📝 License

MIT
