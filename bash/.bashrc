#===============================================================================
#
#		 ██████       ██      ████████ ██      ██
#		░█░░░░██     ████    ██░░░░░░ ░██     ░██
#		░█   ░██    ██░░██  ░██       ░██     ░██
#		░██████    ██  ░░██ ░█████████░██████████
#		░█░░░░ ██ ██████████░░░░░░░░██░██░░░░░░██
#		░█    ░██░██░░░░░░██       ░██░██     ░██
#		░███████ ░██     ░██ ████████ ░██     ░██
#		░░░░░░░  ░░      ░░ ░░░░░░░░  ░░      ░░ 
#===============================================================================

################################################################################
##  Generated from online bashrc generator                                    ##
################################################################################

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}] "
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

export PS1="\[\e[32m\]\u\[\e[m\]@\[\e[36m\]\h\[\e[m\] \w \[\e[33m\]\`parse_git_branch\`\[\e[m\]\\$ "

export PATH=$PATH:/$HOME/.local/bin/
SUDO_EDITOR=/usr/bin/nvim
export SUDO_EDITOR


################################################################################
##  Tweaks                                                                    ##
################################################################################

HISTSIZE= 
HISTFILESIZE=
# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

################################################################################
##  alias                                                                     ##
################################################################################

alias np='nano -w PKGBUILD'
alias more=less
alias ll='ls -al --color=auto'
alias dot='cd ~/dotfiles && git status'
alias jump='cd $(find ~ -type d | fzf)'
alias edit='nvim $(find ~ -type f | fzf)'
alias define='dict $(cat /usr/share/cracklib/cracklib-small | fzf) | less'
alias cheat='curl -s cheat.sh/$(curl -s cheat.sh/:list | fzf) | less'


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

#pfetch
figlet -f 3d ${HOSTNAME^^} -t | lolcat
echo -e "\n"
date +%c
echo -e "\n"


### EOF ###

