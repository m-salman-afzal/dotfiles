# (#q...) glob qualifiers need EXTENDED_GLOB, which is off in this shell;
# the anonymous function keeps the option local instead of changing it globally
() {
  emulate -L zsh -o extendedglob

  #* dotfiles — daily sync, but it asks first: shows the diff in this terminal,
  #  pushes only on go-ahead. Silent when nothing changed. Stamp file = last run.
  [[ -t 0 && ( ! -e $HOME/.cache/dotfiles-last-sync || -n $HOME/.cache/dotfiles-last-sync(#qNm+0) ) ]] || return 0

  #* refresh gnome extension list + settings so new installs get committed too
  command ls $HOME/.local/share/gnome-shell/extensions > $HOME/dotfiles/gnome/extensions.list   # command: dodge the ls alias
  #  awk drops only the private bits: window titles, bt MACs, phone pairing state.
  #  everything else in those extensions still syncs
  dconf dump /org/gnome/shell/extensions/ | awk '
    /^\[/ { sec=$0; if (sec ~ /^\[gsconnect\/device/) next }   # pairing state: certs, caps
    sec ~ /^\[gsconnect\/device/ { next }
    sec ~ /^\[(SmartAutoMoveNG|smart-auto-move)\]/ && /^saved-windows=/ { next }
    sec == "[Bluetooth-Battery-Meter]" && /^(device-list|gattbas-list|upower-device-list)=/ { next }
    sec == "[gsconnect]" && /^devices=/ { next }
    { print }
  ' > $HOME/dotfiles/gnome/extensions.dconf

  #* refresh custom keyboard shortcuts (app launchers, wm, shell)
  dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > $HOME/dotfiles/gnome/media-keys.dconf
  dconf dump /org/gnome/desktop/wm/keybindings/ > $HOME/dotfiles/gnome/wm-keybindings.dconf
  dconf dump /org/gnome/shell/keybindings/ > $HOME/dotfiles/gnome/shell-keybindings.dconf

  #* refresh flatpak app list (runtimes excluded; they install as deps)
  flatpak list --app --columns=application > $HOME/dotfiles/flatpak/apps.list

  #* refresh apt manual-package list, minus baseline noise (apt/ignore.list)
  #  LC_ALL=C: ignore.list is C-sorted; comm errors out if collations differ
  apt-mark showmanual | LC_ALL=C sort | LC_ALL=C comm -23 - $HOME/dotfiles/apt/ignore.list > $HOME/dotfiles/apt/packages.list

  #* commit + push, gated on a keypress
  git -C $HOME/dotfiles add -A   # stage everything so untracked files show in the diff
  if [[ -n $(git -C $HOME/dotfiles status --porcelain) ]]; then
    echo "dotfiles changed since last sync:"
    git -C $HOME/dotfiles --no-pager diff --cached --stat
    local reply=""
    while [[ $reply != [pns] ]]; do
      read -k1 "reply?sync dotfiles -> github? [p]ush [d]iff [n]ot-today [s]kip-once: "; echo
      case $reply in
        p) git -C $HOME/dotfiles commit -m "updated config" \
             && git -C $HOME/dotfiles push ;;   # stamp touched by .githooks/pre-push
        d) git -C $HOME/dotfiles diff --cached --color-words ;;   # word-level diff: long dconf lines stay readable
        n) git -C $HOME/dotfiles reset -q && touch $HOME/.cache/dotfiles-last-sync ;;   # ask again tomorrow
        s) git -C $HOME/dotfiles reset -q ;;   # ask again next terminal
      esac
    done
  else
    #* nothing new: quietly retry a previously failed/pending push
    #  (any push that reaches github touches the stamp via .githooks/pre-push)
    git -C $HOME/dotfiles push &>/dev/null &!
  fi
}
