#!/usr/bin/env zsh
#    _    _                          _ _          ______    _                
#   / \  | |__  _ __ ___   ___  __| ( )___      |__  / ___| |__  _ __ ___  
#  / _ \ | '_ \| '_ ` _ \ / _ \/ _` |// __|       / /| |_  | '_ \| '__/ __| 
# / ___ \| | | | | | | | |  __/ (_| | \__ \      / /_| |_) | | | | | | (__ 
#/_/   \_\_| |_|_| |_| |_|\___|\__,_| |___/     /____|____/|_| |_|_|  \___|
#
# Ahmed's Zshrc - Last updated: May 6, 2025
# =========================================

# ===== ZINIT SETUP =====
# Based on: https://youtu.be/ud7YxC33Z3w/tmux

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# ===== PLUGINS =====
# Theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Functionality plugins
zinit light zsh-users/zsh-syntax-highlighting  # Syntax highlighting in the shell
zinit light zsh-users/zsh-completions          # Additional completion definitions
zinit light zsh-users/zsh-autosuggestions      # Fish-like autosuggestions
zinit light Aloxaf/fzf-tab                     # Replace zsh's default completion with fzf

# ===== COMPLETION SYSTEM =====
# Load completions when zsh starts
autoload -U compinit && compinit

# Completion styling
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ===== HISTORY CONFIGURATION =====
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory      # Append history instead of overwriting
setopt sharehistory       # Share history across terminals
setopt hist_ignore_space  # Ignore commands that start with space
setopt hist_ignore_all_dups # Ignore duplicates
setopt hist_save_no_dups  # Don't save duplicates
setopt hist_ignore_dups   # Don't record if same as previous command
setopt hist_find_no_dups  # Don't display duplicates when searching

# ===== KEYBINDINGS =====
# bindkey -e # Sets emacs mode keybindings
# bindkey -v # Sets vim mode keybindings
# Ctrl+p and Ctrl+n to search history (like Up/Down arrows)
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
# Note: Ctrl+f to accept suggestion, Ctrl+b to move backward in line are default in emacs mode

# ===== ENVIRONMENT VARIABLES =====
export PAGER="less"
# Setup neovim as manpage pager
export MANPAGER="nvim -c 'Man!' -"

# ===== TMUX CONFIGURATION =====
# Function to attach to the persistent main session or create it if it doesn't exist
tmux-main() {
    if command -v tmux &> /dev/null; then
        if tmux has-session -t main 2>/dev/null; then
            # Session exists, attach to it
            tmux attach-session -t main
        else
            # Session doesn't exist, create it and attach to it
            tmux new-session -s main
            tmux attach-session -t main
        fi
    else
        echo "tmux is not installed"
    fi
}

# Simple alias to quickly access the main session
alias tm='tmux-main'

# ===== PATH CONFIGURATION =====
# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
if ! [[ "$PATH" =~ "/sbin" ]]; then
    PATH="/sbin:$PATH"
fi
if ! [[ "$PATH" =~ "$HOME/go/bin" ]]; then
    PATH="$HOME/go/bin:$PATH"
fi
if ! [[ "$PATH" =~ "$HOME/.cargo/bin" ]]; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

# ===== Fast Node Manager (FNM) =====
FNM_PATH="/home/ahmed/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/ahmed/.local/share/fnm:$PATH"
  eval "$(fnm env)"
fi

export PATH

# ===== ALIASES =====
# File navigation and listing
alias more=less
alias ll='exa -alh'        # Detailed list
alias ls='exa'             # Modern ls replacement
alias cd='z'               # Use zoxide for better directory navigation

# File operations with confirmation
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
 
# Search utilities
alias grep='grep --colour=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Tmux shortcuts
alias t='tmux'
alias ta='tmux attach'
alias tls='tmux list-sessions'
alias tn='tmux new-session'
# tm is already defined above to connect to the persistent main session

# Project shortcuts
alias dot='cd ~/dotfiles && git status'  # Quick access to dotfiles

# Dictionary and cheatsheet functions
alias define='dict $(cat /usr/share/dict/words | fzf)'
alias cheat='curl -s cheat.sh/$(curl -s cheat.sh/:list | fzf) | less -R'

# Package management
alias pacs='fzf-search-packages'

# Better directory listing with tree (if available)
if command -v tree &> /dev/null; then
  alias lt='tree -L 2 --dirsfirst'
  alias ltt='tree -L 3 --dirsfirst'
fi

# ===== PERFORMANCE OPTIMIZATIONS =====
# Compile zcompdump if modified, to increase startup speed
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ===== CUSTOM FUNCTIONS =====
# Enhanced directory navigation with fuzzy finding
fcd() {
    local dir
    dir=$(find ~ -type d \( -name "node_modules" -o -name ".git" -o -name ".next" -o -name "dist" -o -name "build" -o -name ".cache" -o -name ".vscode" -o -name "__pycache__" -o -name "venv" -o -name ".idea" \) -prune -o -type d -print 2>/dev/null | 
          fzf --height=80% --layout=reverse --border --preview 'ls -la --color=always {}' \
              --preview-window=right:60%:wrap --header="Navigate to directory")
    
    if [[ -n "$dir" ]]; then
        cd "$dir" || return 1
        # Show directory content after changing
        ls
    fi
}

# Fuzzy file finding and editing
fe() {
    local file
    file=$(find ~ -type d \( -name "node_modules" -o -name ".git" -o -name ".next" -o -name "dist" -o -name "build" -o -name ".cache" -o -name ".vscode" -o -name "__pycache__" -o -name "venv" -o -name ".idea" \) -prune -o -type f -print 2>/dev/null |
           fzf --height=80% --layout=reverse --border --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}' \
               --preview-window=right:60%:wrap --header="Select file to edit")
    
    if [[ -n "$file" ]]; then
        ${EDITOR:-nvim} "$file"
    fi
}

# Fuzzy finding and opening VS Code workspaces/projects
fcode() {
    local workspace_file="$HOME/.config/Code/User/globalStorage/storage.json"
    local selected_workspace

    if [[ ! -f "$workspace_file" ]]; then
        echo "VS Code storage file not found: $workspace_file"
        return 1
    fi

    # Extract workspace URIs from the storage file
    # This extracts both from backupWorkspaces.folders and profileAssociations.workspaces
    selected_workspace=$(cat "$workspace_file" | grep -o '"file:///[^"]*"' | tr -d '"' | sed 's/file:\/\///' | sort -u |
                         fzf --height=80% --layout=reverse --border --preview 'ls -la --color=always {} 2>/dev/null || echo "Directory not found"' \
                             --preview-window=right:60%:wrap --header="Select VS Code workspace to open")

    if [[ -n "$selected_workspace" ]]; then
        # Check if the directory exists
        if [[ -d "$selected_workspace" ]]; then
            echo "Opening VS Code in: $selected_workspace"
            code "$selected_workspace"
        else
            echo "Directory does not exist: $selected_workspace"
            return 1
        fi
    else
        echo "No workspace selected."
    fi
}

# Dynamic package manager detection and fuzzy package search
fzf-search-packages() {
    local pm search_cmd install_cmd info_cmd package_query selected_pkgs

    # Detect package manager
    if command -v apt &> /dev/null; then
        pm="apt"
        # Use nala for all operations if available, fall back to apt/apt-cache
        search_cmd="apt-cache search"
        info_cmd="apt-cache show"
        if command -v nala &> /dev/null; then
            install_cmd="sudo nala install"
        else
            install_cmd="sudo apt install"
        fi
    elif command -v pacman &> /dev/null; then
        pm="pacman"
        search_cmd="pacman -Ss"
        install_cmd="sudo pacman -S"
        info_cmd="pacman -Si"
    elif command -v dnf &> /dev/null; then
        pm="dnf"
        search_cmd="dnf search"
        install_cmd="sudo dnf install"
        info_cmd="dnf info"
    elif command -v zypper &> /dev/null; then
        pm="zypper"
        search_cmd="zypper search"
        install_cmd="sudo zypper install"
        info_cmd="zypper info"
    else
        echo "No supported package manager found (apt, pacman, dnf, zypper)."
        return 1
    fi

    # Prompt for package name
    echo -n "Search for package: "
    read -r package_query

    if [[ -z "$package_query" ]]; then
        echo "No search query provided."
        return 1
    fi

    local pkgs
    local preview_cmd

    # Create appropriate search and display command based on package manager
    case "$pm" in
        apt)
            # For apt: Extract package names from search results
            preview_cmd="$info_cmd {1}"
            pkgs=$(eval "$search_cmd '$package_query'" | grep -v "^Sorting\|^Full Text\|^$" | 
                  sed -E 's/^([^ ]+) - .*/\1/' | sort -u | 
                  fzf --multi --height=80% --layout=reverse --preview="$preview_cmd" \
                      --preview-window=right:60%:wrap --header="Select packages to install (TAB to select multiple)")
            ;;
        pacman)
            # For pacman: Extract package names (before /)
            preview_cmd="$info_cmd {1}"
            pkgs=$(eval "$search_cmd '$package_query'" | sed -n 's/^\([^ /]*\)\/\([^ ]*\) .*/\1\/\2/p' | 
                  fzf --multi --height=80% --layout=reverse --preview="$preview_cmd {1}" \
                      --preview-window=right:60%:wrap --header="Select packages to install (TAB to select multiple)" |
                  awk -F/ '{print $2}')
            ;;
        dnf)
            # For dnf: Extract package names
            preview_cmd="$info_cmd {1}"
            pkgs=$(eval "$search_cmd '$package_query'" | grep -v "Last metadata\|^$" | 
                  awk '{print $1}' | sort -u |
                  fzf --multi --height=80% --layout=reverse --preview="$preview_cmd {1}" \
                      --preview-window=right:60%:wrap --header="Select packages to install (TAB to select multiple)")
            ;;
        zypper)
            # For zypper: Extract package names
            preview_cmd="$info_cmd {1}"
            pkgs=$(eval "$search_cmd '$package_query'" | grep -v "^Loading\|^$" | 
                  awk -F'|' 'NR>2 {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' | sort -u |
                  fzf --multi --height=80% --layout=reverse --preview="$preview_cmd {1}" \
                      --preview-window=right:60%:wrap --header="Select packages to install (TAB to select multiple)")
            ;;
    esac

    if [[ -n "$pkgs" ]]; then
        # Convert to array for zsh
        selected_pkgs=("${(f)pkgs}")
        
        echo "Installing packages: ${selected_pkgs[*]}"
        eval "$install_cmd ${selected_pkgs[*]}"
    else
        echo "No packages selected."
    fi
}

# Extract any archive
extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Weather forecast
weather() {
  curl -s "wttr.in/${1:-}" | head -n 27
}

# Dictionary lookup with moreutils
if command -v xargs &> /dev/null && command -v curl &> /dev/null; then
  dict() {
    if [ $# -eq 0 ]; then
      echo "Usage: dict <word>"
    else
      curl -s "https://api.dictionaryapi.dev/api/v2/entries/en/$1" | 
      jq -r '.[0].meanings[] | "- " + .partOfSpeech + ": " + .definitions[0].definition'
    fi
  }
fi

# yazi integration
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# ===== SHELL INTEGRATION =====
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

# Display system info on terminal start if available
if command -v pfetch &> /dev/null; then
  pfetch
fi

# ===== TMUX AUTOSTART =====
# Automatically start tmux main session on terminal launch
# Only run in interactive shells that aren't already in tmux
if [[ -z "$TMUX" && "$-" == *i* ]]; then
  # Don't autostart when in SSH sessions
  if [[ -z "$SSH_CONNECTION" ]]; then
    tmux-main
  fi
fi

# ===== THEME CONFIGURATION =====
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===== POWERLEVEL10K INSTANT PROMPT =====
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
