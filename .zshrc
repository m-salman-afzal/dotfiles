# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#Set dir we want to store zinit and plugins
export ZINIT_HOME="$XDG_DATA_HOME:-$HOME/.local/share/zinit/zinit.git"

# Download zinit if not already exists
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source and load zinit
source "$ZINIT_HOME/zinit.zsh"

# run starship
#####eval "$(starship init zsh)"

# Add Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# PLUGINS
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey '^f' autosuggest-accept
#bindkey -e
bindkey '5A' history-search-backward
bindkey '5B' history-search-forward

# History
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

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'

# Aliases
alias ls='ls -la --color'

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
