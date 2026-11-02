#* refresh apt manual-package list, minus baseline noise (apt/ignore.list)
#  LC_ALL=C: ignore.list is C-sorted; comm errors out if collations differ
apt-mark showmanual | LC_ALL=C sort | LC_ALL=C comm -23 - $HOME/dotfiles/apt/ignore.list > $HOME/dotfiles/apt/packages.list
