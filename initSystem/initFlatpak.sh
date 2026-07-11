#!/usr/bin/env bash
#* Install flatpak + flathub, then every app in flatpak/apps.list
#* (runtimes like org.freedesktop.Platform install automatically as dependencies)
set -euo pipefail

sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
xargs -r flatpak install --system --noninteractive flathub < "$HOME/dotfiles/flatpak/apps.list"

echo "Done. Some apps may need a session restart to show up in the launcher."
