#!/usr/bin/env bash
#* Install every snap in snap/apps.list (bases and content snaps come along as dependencies).
#* Classic snaps refuse a plain install and say so, so retry those with --classic.
set -euo pipefail

while read -r app; do
	[[ -z $app ]] && continue
	snap list "$app" &>/dev/null && continue   # already installed
	sudo snap install "$app" || sudo snap install --classic "$app"
done < "$HOME/dotfiles/snap/apps.list"

echo "Done."
