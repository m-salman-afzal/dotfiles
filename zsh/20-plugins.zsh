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

#* Vi mode. sourcing = init now instead of at first prompt, so the fzf/fzf-tab
#* keybindings below land on top of its keymaps instead of being wiped by them
ZVM_INIT_MODE=sourcing
#* Clipboard: y/d/c/x also copy to the system clipboard; p/P paste the shell's own yanks
#* only, other apps' text comes in with Ctrl+V (Ghostty's paste). No wl-copy/wl-paste:
#* GNOME has no data-control, so each call maps a window and grabs focus = a blink (same
#* bug as nvim/lua/host/vscode.lua). Copy = OSC 52, set by Ghostty itself (clipboard-write
#* = allow); the plugin's own OSC 52 path skips base64 -w0, so long yanks would get wrapped
#* mid-sequence. PASTE_CMD is a no-op but must be non-empty, or the plugin auto-detects
#* wl-copy/wl-paste for both.
#* ponytail: no tmux passthrough wrap, tmux isn't installed
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
function _zvm_osc52_copy() { printf '\e]52;c;%s\a' "$(base64 -w0)" > /dev/tty; }
ZVM_CLIPBOARD_COPY_CMD=_zvm_osc52_copy ZVM_CLIPBOARD_PASTE_CMD=:
#* nvim's Visual grey instead of the plugin's red for v-mode and pasted text. region:none
#* drops zle's reverse-video region: dd/yy/cc pass through visual-line mode and flashed white
ZVM_VI_HIGHLIGHT_BACKGROUND='#4f5258' ZVM_VI_HIGHLIGHT_FOREGROUND=default
zle_highlight=(region:none)
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

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
