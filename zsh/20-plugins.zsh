#* Set dir we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

#* Download zinit if not already exists
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

#* Source and load zinit
source "$ZINIT_HOME/zinit.zsh"

#* load oh my posh theme
eval "$(oh-my-posh init zsh --config $HOME/.poshthemes/themes/di4am0nd.omp.json)"

#* fzf binary from github releases (no sudo needed)
zinit ice from"gh-r" as"program"
zinit light junegunn/fzf

#* fzf keybindings baked into the binary: ctrl+r history, ctrl+t files, alt+c cd
source <(fzf --zsh)

#* Plugins (before compinit: ones that add completions to fpath)
zinit light zsh-users/zsh-completions

#* Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

#* Plugins (after compinit: fzf-tab first, then the widget-wrapping ones)
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
