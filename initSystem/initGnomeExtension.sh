#!/usr/bin/env bash
#* Install every extension in gnome/extensions.list from extensions.gnome.org,
#* restore their settings from gnome/extensions.dconf, enable them all.
set -euo pipefail

DOT=$HOME/dotfiles
EXTDIR=$HOME/.local/share/gnome-shell/extensions
VER=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)

command -v jq >/dev/null || sudo apt install -y jq   # fresh ubuntu has no jq

while read -r uuid; do
  [[ -d $EXTDIR/$uuid ]] && continue   # already installed
  url=$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$VER" | jq -r '.download_url // empty') || url=""
  [[ -z $url ]] && { echo "SKIP $uuid (not on extensions.gnome.org for shell $VER)"; continue; }
  curl -fsSL "https://extensions.gnome.org$url" -o /tmp/ext.zip
  gnome-extensions install /tmp/ext.zip && echo "installed $uuid"
  rm -f /tmp/ext.zip
done < "$DOT/gnome/extensions.list"

#* settings
dconf load /org/gnome/shell/extensions/ < "$DOT/gnome/extensions.dconf"

#* enable everything in the list (set directly; gnome-extensions enable needs the shell to have loaded them)
mapfile -t uuids < "$DOT/gnome/extensions.list"
printf -v joined "'%s'," "${uuids[@]}"
gsettings set org.gnome.shell enabled-extensions "[${joined%,}]"

echo "Done. Log out/in to load them."
