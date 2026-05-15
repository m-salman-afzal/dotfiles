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

alias uuac="sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean all -y && sudo snap refresh && sudo flatpak update && sudo flatpak uninstall --unused"

alias Python="/usr/bin/python3"

alias python="/usr/bin/python3"

alias dropCache="sudo sh -c \"echo 1 >'/proc/sys/vm/drop_caches' && echo 1 >'/proc/sys/vm/compact_memory' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'\" && sudo service mysql stop"

alias srs="sudo systemctl start redis-server"

alias disableKernelIpv6="sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1"

alias enableKernelIpv6="sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0 && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0"


#-----git aliases
alias g="git"

alias gb="git branch"

gdrb() {
	git remote prune origin
	git branch -vv | grep ': gone]' | awk '{print $1}' > /tmp/merged-branches
	cat /tmp/merged-branches | xargs git branch -D
}

alias gfo="g fetch origin"

alias gp="g pull"

alias gc="g commit"

alias gco="g checkout"

alias gph="g push"

alias gmtmfs="gco main && g merge staging && gph && gco -"

alias gce="gc --allow-empty -m 'temp' && gph"

alias gmtsfm="gco staging && g merge main && gph && gco -"

alias gs="g stash"

alias gsl="gs list"

# push to stash
gsp() {
        git stash push -u -m $1
}

# apply stash
gsa() {
	gsl

	echo -n "Enter the stash number to apply: "
	read stash_no

 	git stash apply "stash@{$stash_no}"
}

# drop stash
gsd() {
	gsl

        echo -n "Enter the stash number to drop: "
	read stash_no

        git stash drop "stash@{$stash_no}"
}

# git add, commit, and push
gacph() {
        g add .
	gc -m $1
	gph
}

alias gw="g worktree"

alias gwl="gw list"

#-----Create worktree (creates branch if it doesn't exist)
gwa() {
    local branch="$1"
    if [ -z "$branch" ]; then
        echo "Usage: wta <branch-name>" >&2
        return 1
    fi

    local path="./.worktrees/$branch"

    if git show-ref --verify --quiet "refs/heads/$branch"; then
        git worktree add "$path" "$branch"
    else
        git worktree add -b "$branch" "$path"
    fi
}

#-----Remove worktree (pass extra args like --force if needed)
gwr() {
    local branch="$1"
    if [ -z "$branch" ]; then
        echo "Usage: wtr <branch-name> [--force]" >&2
        return 1
    fi
    shift

    git worktree remove "./.worktrees/$branch" "$@"
}


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

# auto load the node version if nvmrc is found
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

#-----openssl for pdf-creator-node
export OPENSSL_CONF=/tmp/openssl.cnf


#-----rust-cargo
#. "$HOME/.cargo/env"
export PATH=$HOME/.cargo/bin:$PATH


#-----bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"


#-----pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


#-----google cloud sdk.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi


#-----Node
export NODE_COMPILE_CACHE="$HOME/.cache/node"


#-----claude
alias claude="$HOME/.local/bin/claude"

#-----Turso
export PATH="$PATH:$HOME/.turso"

#-----imagine
alias mountChatlyCdn="rclone mount r2CloudflareStorageChatly:chatly ~/r2mount --daemon"

#-----LM Studio CLI
export PATH="$PATH:/home/satop/.lmstudio/bin"

