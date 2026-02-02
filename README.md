# Dotman - Omarchy Dotfiles Manager

A modern, self-healing, and automated TUI for managing dotfiles and syncing configurations across multiple machines.

## Features

- **Profile Management**: Create and switch between profiles (e.g., Home, Office).
- **Auto-Sync**: Smart Git syncing with conflict resolution (prefers cloud).
- **Stow Integration**: Automated `stow` usage with conflict handling (backup & retry).
- **Self-Healing**: Checks and fixes environment issues (PATH, dependencies).
- **TUI**: Beautiful terminal interface powered by Bubble Tea.

## Usage

### Bootstrap (First Time)

Run the bootstrap script to install dependencies and build the tool:

```bash
./bootstrap.sh
```

### Running

Once installed, simply run:

```bash
dotman
```

### Controls

- **s**: Sync with Git (Fetch/Pull/Push)
- **p**: Select and Apply Profile
- **c**: Create New Profile
- **o**: Manage Storage Files
- **r**: Reset Modified Files
- **q**: Quit

## Structure

- `dotman/`: Source code (Go).
- `home/`, `office/`: Profiles containing stowable configs.
- `storage/`: General file storage.

## License

MIT
