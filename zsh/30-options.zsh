#* Keybindings
#bindkey '^f' autosuggest-accept
bindkey '5A' history-search-backward
bindkey '5B' history-search-forward

#* History
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

#* Completion styling
zstyle ':completion:*' menu no   # fzf-tab replaces the native menu
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'   # fzf-tab colors entries with this

#* Categories: name each completion group so fzf-tab shows [headers] per category
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' completer _complete _history   # history words as fallback category

#* fzf-tab: compact popup instead of full-page list
zstyle ':fzf-tab:*' fzf-flags --height=~40% --layout=reverse
[[ -n $TMUX ]] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup   # floating popup, tmux only
zstyle ':fzf-tab:*' switch-group '<' '>'   # cycle one category at a time
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

#* dircolors (synced monthly by 80-sync.zsh)
eval `dircolors $HOME/.dir_colors/dircolors`
