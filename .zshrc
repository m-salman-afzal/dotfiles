#-----Set dir we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"


#-----Download zinit if not already exists
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi


#-----Source and load zinit
source "$ZINIT_HOME/zinit.zsh"


#-----Paths
export PATH=$PATH:$HOME/.local/bin


#-----load oh my posh theme
eval "$(oh-my-posh init zsh --config $HOME/.poshthemes/themes/di4am0nd.omp.json)"


#-----Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions


#-----asdf
#. "$HOME/.asdf/asdf.sh"
#fpath=(${ASDF_DIR}/completions $fpath)

#-----Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q


#-----Keybindings
#bindkey '^f' autosuggest-accept
bindkey '5A' history-search-backward
bindkey '5B' history-search-forward


#-----History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups


#-----Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'


#----Aliases
alias ls='ls -la --color'

alias uuac="sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean all -y"

alias Python="/usr/bin/python3"

alias python="/use/bin/python3"

alias dropCache="sudo sh -c \"echo 1 >'/proc/sys/vm/drop_caches' && echo 1 >'/proc/sys/vm/compact_memory' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'\" && sudo service mysql stop"

alias srs="sudo systemctl start redis-server"


#-----git aliases
alias g="git"

alias gb="git branch"

alias gdrb="g remote prune origin && gb --merged >/tmp/merged-branches && nano /tmp/merged-branches && xargs gb -d </tmp/merged-branches"

alias gfo="g fetch origin"

alias gp="g pull"

alias gc="g commit"

alias gco="g checkout"

alias gph="g push"

alias gmtm="gco main && g merge staging && gph && gco -"

alias gce="gc --allow-empty -m 'temp' && gph"

alias gmts="gco staging && g merge main && gph && gco -"

#-----node aliases
alias n="npm"
alias p="pnpm"

alias nr="npm run"
alias pr="pnpm run"

alias nrd="npm run dev"
alias prd="pnpm run dev"

alias nrdh="npm run dev:https"
alias prdh="pnpm run dev:https"

alias nrb="npm run build"
alias prb="pnpm run build"

alias nrs="npm run start"
alias prs="pnpm run start"

alias nrt="npm run test"
alias prt="pnpm run test"

alias nrtd="npm run test:dev"
alias prtd="pnpm run test:dev"

alias nrtp="npm run test:prod"
alias prtp="pnpm run test:prod"

#-----function
killPort() { 
	sudo kill -9 $(lsof -t -i :"$1")
}


#-----nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


#-----openssl for pdf-creator-node
export OPENSSL_CONF=/tmp/openssl.cnf


#-----rust
#. "$HOME/.cargo/env"


#-----bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH


#-----pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


#-----java
export JAVA_HOME="$HOME/jdk-23.0.1"
export PATH=$JAVA_HOME/bin:$PATH


#-----bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

#-----android sdk
export ANDROID_HOME="/mnt/c/Users/CarbonTeq/AppData/Local/Android/Sdk"
export PATH=$ANDROID_HOME:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH

#-----THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi

# Android
export ANDROID_HOME=/mnt/c/Users/CarbonTeq/AppData/Local/Android/Sdk
export WSLENV=ANDROID_HOME/p

# Node
export NODE_COMPILE_CACHE="$HOME/.cache/node"
