# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Shell integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi



# This setup is done by following this video :
# https://youtu.be/ud7YxC33Z3w

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions when zsh starts
autoload -U compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e # Sets it to emacs mode
# Here , Ctrl+f to accept suggestion or move forward in line
# Ctrl+b to move backward in line
# Ctrl+p and Ctrl+n to go back and forth in terminal commands. Like Up and Down arrow
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups # dups = duplicates
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Alias
alias np='nano -w PKGBUILD'
alias more=less
alias ll='ls -al'
alias ls='ls'

alias grep='grep --colour=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias dot='cd ~/dotfiles && git status'
alias jump='cd $(find ~ -type d -name node_modules -prune -o -type d | fzf)'
alias edit='file=$(find ~ -type d -name node_modules -prune -o -type f | fzf) && [ -n "$file" ] && nvim "$file"'
alias define='dict $(cat /usr/share/dict/words | fzf) | less'
alias cheat='curl -s cheat.sh/$(curl -s cheat.sh/:list | fzf) | less -R'
# For WSL vscode project opening
alias open='directory=$(find ~/code/ -maxdepth 3 -type d -name node_modules -prune -o -type d | fzf) && [ -n "$directory" ] && code "$directory"'
alias win='cd /mnt/c/Users/ahmed/Desktop/'

# Color
export LESS_TERMCAP_mb=$'\e[1;36m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

export PAGER="less"
export MANPAGER="less -R"

#
# Web deb stuff
#
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/ahmed/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Path to DENO installation
export DENO_INSTALL="/home/ahmed/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"


# User PATH setup
# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH


# Completion styling
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# For starship prompt
# eval "$(starship init zsh)"

fastfetch -c ~/dotfiles/fastfetch/test.jsonc
