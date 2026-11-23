#* apt / snap / flatpak
alias aptPrune='sudo apt autoremove --purge && sudo apt clean'

alias aptLeftoversPrune='dpkg -l | grep "^rc" && sudo apt purge $(dpkg -l | awk "/^rc/{print \$2}")'

alias snapPrune='snap list --all | awk "/disabled/{print \$1, \$3}" | while read n r; do sudo snap remove "$n" --revision="$r"; done'

alias flatpakPrune='flatpak uninstall --unused'

#* docker
# one y/N per category; containers first so their images/volumes become unused
alias dockerPrune="docker system df && docker container prune && docker image prune -a && docker builder prune -a && docker network prune && docker volume prune -a && docker system df"

#* js package managers
pnpmPrune() {
  local s=~/.local/share/pnpm/store
  local -a pnpm10=(~/.local/share/mise/installs/pnpm/10.*/pnpm(Nn))
  (cd ~ && pnpm store prune)
  # v10 is pnpm 10's store and only pnpm 10 can prune it; not `mise x`, which may install a newer 10.x
  [[ -d $s/v10 && -n $pnpm10 ]] && (cd ~ && $pnpm10[-1] store prune)
  # v3 is pnpm <=9's store; no project pins pnpm 9 or older
  rm -rf $s/v3 ~/.cache/pnpm
}

alias npmPrune='npm cache clean --force'

alias bunPrune='bun pm cache rm'

#* mise
# installed npm: tools hardlink into the cache's npm store, so they keep working after the clear
alias misePrune='mise prune && mise cache clear'

#* other caches
# `cargo clean gc` is nightly-only; stable cargo only auto-drops downloads unused for 3 months
alias cargoPrune='rm -rf ~/.cargo/registry/{cache,src}'

# none of these has a clear command: node keeps a dir per version under NODE_COMPILE_CACHE (10-env),
# node-gyp/pip aren't installed to run theirs, TS typings are tsserver's
alias devCachePrune='rm -rf ~/.cache/{node,node-gyp,typescript,pip}'

alias trashPrune='gio trash --empty'

#* everything above: one y/N per command, showing what it currently takes up
_bbStep() { # command, space-separated paths to size ('' = no size)
  local size
  [[ -n $2 ]] && size=$(du -shc ${=2} 2> /dev/null | tail -1 | cut -f1)
  print -P "\n%B==> $1%b${size:+ ($size)}"
  (($+aliases[$1])) && print "    $aliases[$1]"
  read -q '?run? [y/N] ' || {
    print
    return 0
  }
  print
  eval "$1"
}

bigBangCleanup() {
  local before=$(df --output=avail -B1 / | tail -1)
  _bbStep aptPrune /var/cache/apt
  _bbStep aptLeftoversPrune ''
  (($+commands[snap])) && _bbStep snapPrune ''
  (($+commands[flatpak])) && _bbStep flatpakPrune ''
  (($+commands[docker])) && _bbStep dockerPrune ''
  (($+commands[pnpm])) && _bbStep pnpmPrune "$HOME/.local/share/pnpm/store $HOME/.cache/pnpm"
  (($+commands[npm])) && _bbStep npmPrune ~/.npm/_cacache
  [[ -d ~/.bun/install/cache ]] && _bbStep bunPrune ~/.bun/install/cache
  (($+commands[mise])) && _bbStep misePrune ~/.cache/mise
  _bbStep cargoPrune "$HOME/.cargo/registry/cache $HOME/.cargo/registry/src"
  _bbStep devCachePrune "$HOME/.cache/node $HOME/.cache/node-gyp $HOME/.cache/typescript $HOME/.cache/pip"
  _bbStep trashPrune ~/.local/share/Trash
  print "\nfreed $(numfmt --to=iec -- $(($(df --output=avail -B1 / | tail -1) - before)))"
}
