#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_ROOT="$(dirname "$(readlink -f "$0")")"
DOTMAN_SRC="$REPO_ROOT/dotman"
BIN_PATH="$HOME/.local/bin/dotman"
HASH_FILE="$REPO_ROOT/.dotman_build_hash"

# Function to calculate hash of source files
calc_hash() {
    find "$DOTMAN_SRC" -name "*.go" -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | awk '{print $1}'
}

# 1. Install Dependencies
# Only check if not already checked recently or force flag? 
# Let's keep it fast. Check command existence is fast.
if ! command -v stow &> /dev/null; then
    echo -e "${BLUE}Installing stow...${NC}"
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm stow
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y stow
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y stow
    else
        echo "Please install 'stow' manually."
        exit 1
    fi
fi

if ! command -v go &> /dev/null; then
    echo "Go not found. Please install Go manually."
    exit 1
fi

# 2. Check for changes and Build
CURRENT_HASH=$(calc_hash)
LAST_HASH=""

if [ -f "$HASH_FILE" ]; then
    LAST_HASH=$(cat "$HASH_FILE")
fi

if [ "$CURRENT_HASH" != "$LAST_HASH" ] || [ ! -f "$BIN_PATH" ]; then
    echo -e "${BLUE}Changes detected or binary missing. Rebuilding Dotman...${NC}"
    
    cd "$DOTMAN_SRC"
    go mod tidy
    go build -o "$REPO_ROOT/dotman-cli" ./cmd/dotman
    cd "$REPO_ROOT"

    if [ -f "dotman-cli" ]; then
        mkdir -p "$HOME/.local/bin"
        cp "dotman-cli" "$BIN_PATH"
        echo "$CURRENT_HASH" > "$HASH_FILE"
        echo -e "${GREEN}✓ Dotman built and updated${NC}"
    else
        echo "Build failed."
        exit 1
    fi
else
    # echo "Dotman is up to date."
    :
fi

# 3. Setup PATH (Only once)
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    # Only warn/add if not in path
    SHELL_RC=""
    if [[ $SHELL == *"zsh"* ]]; then SHELL_RC="$HOME/.zshrc"
    elif [[ $SHELL == *"bash"* ]]; then SHELL_RC="$HOME/.bashrc"
    fi

    if [ -n "$SHELL_RC" ] && ! grep -q "$HOME/.local/bin" "$SHELL_RC"; then
        echo -e "${BLUE}Adding $HOME/.local/bin to PATH...${NC}"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
        echo -e "${GREEN}✓ Added to $SHELL_RC. Please source it.${NC}"
    fi
fi