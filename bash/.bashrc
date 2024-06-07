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
##  Start every session with tmux                                             ##
################################################################################

#if command -v tmux &> /dev/null; then
#    if [ -z "$TMUX" ]; then
#    tmux new -As default
#        # if tmux list-sessions >/dev/null 2>&1; then
#        #     tmux attach
#        # else
#        #     tmux new-session -s default
#        # fi
#    fi
#else
#    echo "Tmux is not installed. Please install Tmux to use this script."
#fi

################################################################################
##  Generated from online bashrc generator                                    ##
################################################################################

# get current branch in git repo
function parse_git_branch() {
	BRANCH=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
	if [ ! "${BRANCH}" == "" ]; then
		STAT=$(parse_git_dirty)
		echo "[${BRANCH}${STAT}] "
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=$(git status 2>&1 | tee)
	dirty=$(
		echo -n "${status}" 2>/dev/null | grep "modified:" &>/dev/null
		echo "$?"
	)
	untracked=$(
		echo -n "${status}" 2>/dev/null | grep "Untracked files" &>/dev/null
		echo "$?"
	)
	ahead=$(
		echo -n "${status}" 2>/dev/null | grep "Your branch is ahead of" &>/dev/null
		echo "$?"
	)
	newfile=$(
		echo -n "${status}" 2>/dev/null | grep "new file:" &>/dev/null
		echo "$?"
	)
	renamed=$(
		echo -n "${status}" 2>/dev/null | grep "renamed:" &>/dev/null
		echo "$?"
	)
	deleted=$(
		echo -n "${status}" 2>/dev/null | grep "deleted:" &>/dev/null
		echo "$?"
	)
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

force_color_prompt=yes
color_prompt=yes

export PS1="[\[\e[32m\]\u\[\e[m\]@\[\e[36m\]\h\[\e[m\]] \w \[\e[33m\]\`parse_git_branch\`\[\e[m\]\n\[\e[32m\]❱❱❱\[\e[m\] "

export PATH="$HOME/.local/bin:$PATH"

# Set the default editor
export EDITOR=nvim
export VISUAL=nvim

################################################################################
##  Tweaks                                                                    ##
################################################################################

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Unlimited history
HISTSIZE=
HISTFILESIZE=
# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

################################################################################
##  alias                                                                     ##
################################################################################

alias np='nano -w PKGBUILD'
alias more=less
alias ll='ls -al --color=auto'
alias dot='cd ~/dotfiles && git status'
alias jump='cd $(find ~ -type d -name node_modules -prune -o -type d | fzf)'
alias edit='file=$(find ~ -type d -name node_modules -prune -o -type f | fzf) && [ -n "$file" ] && nvim "$file"'
alias define='dict $(cat /usr/share/cracklib/cracklib-small | fzf) | less'
alias cheat='curl -s cheat.sh/$(curl -s cheat.sh/:list | fzf) | less'
# For WSL vscode project opening
alias open='directory=$(find ~/code/ -maxdepth 3 -type d -name node_modules -prune -o -type d | fzf) && [ -n "$directory" ] && code "$directory"'
alias win='cd /mnt/c/Users/ahmed/Desktop/'

################################################################################
##  Coloring                                                                ####
################################################################################

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1

# Extracts any archive(s) (if unp isn't installed)
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

################################################################################
##  Webdev Stuff	                                                      ##
################################################################################

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

################################################################################
##  Various Setup                                                             ##
################################################################################

# zoxide
eval "$(zoxide init bash)"

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
eval "$(fzf --bash)"

# zellij
eval "$(zellij setup --generate-auto-start bash)"

################################################################################
##  Startup Commands                                                          ##
################################################################################

#pfetch

#figlet -f 3d ${HOSTNAME^^} -t | lolcat
#echo -e "\n"
#date +%c
#echo -e "\n"

### EOF ###
