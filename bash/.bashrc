exec zsh

export PATH=$PATH:/home/nasif/.local/bin



################################################################################
##  alias                                                                     ##
################################################################################

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less
alias i3config='vim ~/.config/i3/config'
alias ll='ls -al --color=auto'
alias windows='cd /run/media/nasif'
alias corona='curl https://corona-stats.online?source=2'
alias coronabd='curl https://corona-stats.online/bangladesh?source=2' 
alias dot='cd ~/dotfiles && git status'


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
##  Startup Commands                                                          ##
################################################################################

pfetch

eval "$(starship init bash)"

### EOF ###
