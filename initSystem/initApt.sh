#!/usr/bin/env bash
#* Set up third-party apt repos — keys fetched fresh from each vendor over HTTPS,
#* nothing stored in this repo — then install everything in apt/packages.list.
set -euo pipefail

DOT=$HOME/dotfiles

#* github cli (gh) — official steps from https://github.com/cli/cli/blob/trunk/docs/install_linux.md
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

#* solaar PPA (launchpad delivers the key automatically)
sudo add-apt-repository -y ppa:solaar-unifying/stable

sudo apt update
xargs -r sudo apt install -y < "$DOT/apt/packages.list"

echo "Done. Installed manually when needed (not part of this bootstrap):"
echo "  nvidia driver (ubuntu-drivers install), docker, vscode,  lm-studio"
