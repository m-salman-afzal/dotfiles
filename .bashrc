# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto -all -h'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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



#----Aliases
alias uuac="sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean all -y"

alias Python="/usr/bin/python3"

alias python="/use/bin/python3"

alias vsStaging="ssh salman.afzal@studentapp-viralsolutions.carbonteq.com"

alias dropCache="sudo sh -c \"echo 1 >'/proc/sys/vm/drop_caches' && echo 1 >'/proc/sys/vm/compact_memory' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'\" && sudo service mysql stop"

alias srs="sudo systemctl start redis-server"

#-----git aliases
alias gdrb="git remote prune origin && git branch --merged >/tmp/merged-branches && nano /tmp/merged-branches && xargs git branch -d </tmp/merged-branches"

alias g="git"

alias gb="git branch"

alias gfo="git fetch origin"

alias gp="git pull"

alias gc="git commit"

alias gch="git checkout"

alias gph="git push"

#-----node aliases
alias n="npm"
alias p="pnpm"

alias nrd="npm run dev"
alias prd="pnpm run dev"

alias nrdh="npm run dev:https"
alias prdh="pnpm run dev:https"

alias nrdht="npx next dev --turbo --experimental-https -p 3001 -H 127.0.0.1"
alias prdht="pnpx next dev --turbo --experimental-https -p 3001 -H 127.0.0.1"

alias nrb="npm run build"
alias prb="pnpm run build"

alias nrs="npm run start"
alias prs="pnpm run start"

alias nrt="npm run test"
alias prt="pnpm run test"

alias nrdt="npm run dev:test"
alias prdt="pnpm run dev:test"

#-----function
killPort() { 
	sudo kill -9 $(lsof -t -i :"$1")
}

#-----nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#-----oh-my-posh
eval "$(oh-my-posh init bash --config /home/salman/.poshthemes/themes/di4am0nd.omp.json)"


#-----openssl for pdf-creator-node
export OPENSSL_CONF=/tmp/openssl.cnf

#-----rust
. "$HOME/.cargo/env"

#-----bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH


#-----node
corepack enable pnpm
corepack enable yarn

#-----pnpm
export PNPM_HOME="/home/salman/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


#-----java
export JAVA_HOME="/home/salman/jdk-21.0.2"
export PATH=$JAVA_HOME/bin:$PATH

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
