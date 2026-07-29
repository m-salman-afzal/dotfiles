#!/usr/bin/env bash
#* Install flatpak + flathub, then every app in flatpak/apps.list
#* (runtimes like org.freedesktop.Platform install automatically as dependencies)
set -euo pipefail

sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
xargs -r flatpak install --system --noninteractive flathub < "$HOME/dotfiles/flatpak/apps.list"

#* Neovim: the flatpak only exports `io.neovim.nvim`, but everything that spawns an
#* editor (git, vscode-neovim, EDITOR) looks for `nvim` on PATH — hence the symlink.
#* It also needs host files to edit anything, and its config dir is sandboxed.
flatpak override --user --filesystem=host io.neovim.nvim
mkdir -p "$HOME/.local/bin" "$HOME/.var/app/io.neovim.nvim/config"
ln -sfn /var/lib/flatpak/exports/bin/io.neovim.nvim "$HOME/.local/bin/nvim"
ln -sfn "$HOME/.config/nvim" "$HOME/.var/app/io.neovim.nvim/config/nvim"

echo "Done. Some apps may need a session restart to show up in the launcher."
