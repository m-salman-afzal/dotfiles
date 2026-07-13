# (#q...) glob qualifiers need EXTENDED_GLOB, which is off in this shell;
# the anonymous function keeps the option local instead of changing it globally
() {
  emulate -L zsh -o extendedglob

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
