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

#* solaar's modules live in /usr/share/solaar/lib, off the default sys.path. /usr/bin/solaar prepends that
#* dir itself (init_paths()), so this is a no-op on a healthy install — it only fires if that ever stops working.
#* Not dpkg-owned and not stowable (/usr, not $HOME); this machine has carried the .pth by hand since Jun 2026.
solaar --version >/dev/null 2>&1 \
	|| echo /usr/share/solaar/lib | sudo tee /usr/lib/python3/dist-packages/solaar.pth >/dev/null

#* vim as the system editor (visudo, sudoedit, git without core.editor). --set = the non-interactive
#* `update-alternatives --config editor`. vim is an auto dep here, so it's absent from packages.list — install it.
sudo apt install -y vim
sudo update-alternatives --set editor /usr/bin/vim.basic

#* ydotool /dev/uinput access — Handy (voice dictation, apt/ignore.list: hand-installed .deb, not part of this
#* bootstrap) types its transcript by faking keystrokes. Left on its own it uses enigo → the XDG RemoteDesktop
#* portal, and GNOME re-prompts "Allow remote interaction" on EVERY paste with no way to persist the grant.
#* ydotool injects through /dev/uinput instead and never touches the portal. The udev rule is the part Handy's
#* README omits: the node is root:root by default, so ydotoold can't open it as you. Not stowable (/etc).
#* Once Handy is installed, set its `typing_tool` to "ydotool" (~/.local/share/com.pais.handy/settings_store.json).
echo 'KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"' \
	| sudo tee /etc/udev/rules.d/80-uinput.rules >/dev/null
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -aG input "$USER" #* group membership needs a re-login to take effect
#* package-shipped user unit (/usr/lib/systemd/user/ydotool.service) — runs ydotoold at login.
#* `|| true`: no session bus when this is driven headlessly, and set -e would abort the whole bootstrap.
systemctl --user enable --now ydotool.service || true

#* inotify limits — distro defaults run out under VS Code / bundlers / file watchers
#* ("ENOSPC: System limit for number of file watchers reached"). Not stowable: /etc, not $HOME.
printf 'fs.inotify.max_user_watches=524288\nfs.inotify.max_user_instances=1024\n' | sudo tee /etc/sysctl.d/99-inotify.conf >/dev/null
sudo sysctl --system >/dev/null

echo "Done. Installed manually when needed (not part of this bootstrap):"
echo "  nvidia driver (ubuntu-drivers install), docker, vscode,  lm-studio"
