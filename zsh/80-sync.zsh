# (#q...) glob qualifiers need EXTENDED_GLOB, which is off in this shell;
# the anonymous function keeps the option local instead of changing it globally
() {
  emulate -L zsh -o extendedglob

  #* dotfiles — daily sync, but it asks first: shows the diff in this terminal,
  #  pushes only on go-ahead. Silent when nothing changed. Stamp file = last run.
  if [[ -t 0 && ( ! -e $HOME/.cache/dotfiles-last-sync || -n $HOME/.cache/dotfiles-last-sync(#qNm+0) ) ]]; then
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

    #* refresh flatpak app list (runtimes excluded; they install as deps)
    flatpak list --app --columns=application > $HOME/dotfiles/flatpak/apps.list

    git -C $HOME/dotfiles add -A   # stage everything so untracked files show in the diff
    if [[ -n $(git -C $HOME/dotfiles status --porcelain) ]]; then
      echo "dotfiles changed since last sync:"
      git -C $HOME/dotfiles --no-pager diff --cached --stat
      local reply=""
      while [[ $reply != [pns] ]]; do
        read -k1 "reply?sync dotfiles -> github? [p]ush [d]iff [n]ot-today [s]kip-once: "; echo
        case $reply in
          p) git -C $HOME/dotfiles commit -m "updated config" \
               && git -C $HOME/dotfiles push \
               && touch $HOME/.cache/dotfiles-last-sync ;;
          d) git -C $HOME/dotfiles diff --cached ;;
          n) git -C $HOME/dotfiles reset -q && touch $HOME/.cache/dotfiles-last-sync ;;   # ask again tomorrow
          s) git -C $HOME/dotfiles reset -q ;;   # ask again next terminal
        esac
      done
    else
      #* nothing new: quietly retry a previously failed/pending push
      { git -C $HOME/dotfiles push && touch $HOME/.cache/dotfiles-last-sync } &>/dev/null &!
    fi
  fi

  #* dracula dircolors — monthly, in background, only replaced if upstream changed
  #  curl one file instead of git clone/pull/symlink
  if [[ -n $HOME/.dir_colors/dircolors(#qNmM+1) ]]; then
    { curl -fsSL https://raw.githubusercontent.com/dracula/dircolors/main/.dircolors \
        -o $HOME/.dir_colors/dircolors.new && {
        if cmp -s $HOME/.dir_colors/dircolors{.new,}; then
          touch $HOME/.dir_colors/dircolors   # unchanged upstream: just reset the monthly clock
        else
          mv $HOME/.dir_colors/dircolors{.new,}
        fi }
      rm -f $HOME/.dir_colors/dircolors.new } &>/dev/null &!
  fi
}
