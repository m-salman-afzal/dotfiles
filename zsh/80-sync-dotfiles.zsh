# (#q...) glob qualifiers need EXTENDED_GLOB, which is off in this shell;
# the anonymous function keeps the option local instead of changing it globally
() {
  emulate -L zsh -o extendedglob

  #* dotfiles — daily sync, but it asks first: shows the diff in this terminal,
  #  pushes only on go-ahead. Silent when nothing changed. Stamp file = last run.
  [[ -t 0 && (! -e $HOME/.cache/dotfiles-last-sync || -n $HOME/.cache/dotfiles-last-sync(#qNm+0)) ]] || return 0

  #* refresh the generated lists/dumps, one file per kind (gnome, flatpak, appimage, snap, apt).
  #  sourced, not run: they share this function's scope (locals, extendedglob). Not matched by .zshrc's zsh/*.zsh
  local f
  for f in $HOME/dotfiles/zsh/sync/*.zsh; do
    source $f
  done

  #* commit + push, gated on a keypress
  git -C $HOME/dotfiles add -A # stage everything so untracked files show in the diff
  if [[ -n $(git -C $HOME/dotfiles status --porcelain) ]]; then
    echo "dotfiles changed since last sync:"
    git -C $HOME/dotfiles --no-pager diff --cached --stat
    local reply=""
    while [[ $reply != [pns] ]]; do
      read -k1 "reply?sync dotfiles -> github? [p]ush [d]iff [n]ot-today [s]kip-once: "
      echo
      case $reply in
        p) git -C $HOME/dotfiles commit -m "updated config" \
          && git -C $HOME/dotfiles push ;;                                            # stamp touched by .githooks/pre-push
        d) git -C $HOME/dotfiles diff --cached --color-words ;;                       # word-level diff: long dconf lines stay readable
        n) git -C $HOME/dotfiles reset -q && touch $HOME/.cache/dotfiles-last-sync ;; # ask again tomorrow
        s) git -C $HOME/dotfiles reset -q ;;                                          # ask again next terminal
      esac
    done
  else
    #* nothing new: quietly retry a previously failed/pending push
    #  (any push that reaches github touches the stamp via .githooks/pre-push)
    git -C $HOME/dotfiles push &> /dev/null &|
  fi
}
