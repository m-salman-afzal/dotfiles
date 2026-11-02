#* refresh snap list — bases/snapd drop out by their Notes column (they arrive as deps);
#  preinstalled canonical bits and content snaps are hand-listed in snap/ignore.list
snap list | awk 'NR>1 && $NF !~ /base|snapd/ {print $1}' | LC_ALL=C sort \
  | LC_ALL=C comm -23 - $HOME/dotfiles/snap/ignore.list > $HOME/dotfiles/snap/apps.list
