#* refresh flatpak app list (runtimes excluded; they install as deps)
flatpak list --app --columns=application > $HOME/dotfiles/flatpak/apps.list
