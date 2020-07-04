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

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=999999999
SAVEHIST=999999999
setopt INC_APPEND_HISTORY 
setopt HIST_EXPIRE_DUPS_FIRST
setopt autocd beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/nasif/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh



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


################################################################################
##  PowerLevel10k                                                             ##
################################################################################

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi



################################################################################
##  Plugins                                                                   ##
################################################################################

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh   
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/autojump/autojump.zsh 



################################################################################
##  Keybinds                                                                  ##
################################################################################

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down



################################################################################
##  Startup Commands                                                          ##
################################################################################

neofetch
# echo "$(date '+%D %T' | toilet -f term -F border --gay)"


### EOF ###
