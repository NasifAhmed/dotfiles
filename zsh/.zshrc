
#         _     
#     _______| |__  
#    |_  / __| '_ \ 
#     / /\__ \ | | |
#    /___|___/_| |_|
#               
#



################################################################################
##  ZSH Auto Configs                                                          ##
################################################################################


# Enable vi mode
bindkey -v


## Options section
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.



zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache



# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=999999999
SAVEHIST=999999999
setopt INC_APPEND_HISTORY 
setopt HIST_EXPIRE_DUPS_FIRST
setopt autocd beep
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/nasif/.zshrc'

# Basic auto tab complete and slection
autoload -Uz compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files in tab complete
# End of lines added by compinstall


################################################################################
##  Coloring                                                                ####
################################################################################


alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias ls='ls --color=auto'


export LESS=-R
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline
export EDITOR=nvim 

man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}




################################################################################
##  alias                                                                     ##
################################################################################

alias l='lsd'
alias la='lsd -a'
alias ll='lsd -l'
alias lla='lsd -la'
alias lt='lsd --tree'
alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less
alias i3config='vim ~/.config/i3/config'
alias windows='cd /run/media/nasif'
alias corona='curl https://corona-stats.online?source=2'
alias coronabd='curl https://corona-stats.online/bangladesh?source=2' 
alias dot='cd ~/dotfiles && git status'
alias vpnusa='sudo protonvpn c US-FREE#1'
alias vpn='sudo protonvpn c -f'
alias suck='rm -rf config.h & sudo make clean install'
alias gitu='git add . && git commit && git push'
alias vim='nvim'
alias study='cd ~/study'

edit() {
    nvim "$(find -type f | fzf)"
}

fcd() {
    cd "$(find -type d | fzf)"
}

################################################################################
##  Plugins                                                                   ##
################################################################################

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh   
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
#source /usr/share/autojump/autojump.zsh 


################################################################################
##  Keybinds                                                                  ##
################################################################################

# bind UP and DOWN arrow keys to history substring search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up			
bindkey '^[[B' history-substring-search-down



################################################################################
##  Startup Commands                                                          ##
################################################################################

pfetch  
# echo -n "\v"

# sh ~/.scripts/unix

# neofetch --backend chafa --size 21% --source ~/dotfiles/Pictures/linux_PNG12.png

# echo "$(date '+Date:%D Time:%H:%M %p' | toilet -f term -F border --gay)"



################################################################################
##  Starship Initialization                                                   ##
################################################################################

eval "$(starship init zsh)"



### EOF ###



# Offer to install missing package if command is not found
#if [[ -r /usr/share/zsh/functions/command-not-found.zsh ]]; then
#    source /usr/share/zsh/functions/command-not-found.zsh
#    export PKGFILE_PROMPT_INSTALL_MISSING=1
#fi
