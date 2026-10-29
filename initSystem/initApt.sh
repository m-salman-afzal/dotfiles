#!/usr/bin/env bash
#* Set up third-party apt repos — keys fetched fresh from each vendor over HTTPS,
#* nothing stored in this repo — then install everything in apt/packages.list.
set -euo pipefail

DOT=$HOME/dotfiles

#* mise (runtime/tool version manager) — debian's extrepo ships the vendor repo + key, so nothing to fetch by hand
sudo apt install -y extrepo
sudo extrepo enable mise

#* Every third-party deb in packages.list needs its source in place before the list install below: one package with
#* no installation candidate fails the whole `apt install`. A new third-party deb in packages.list needs a step here.
#* ghostty (default terminal) — not in Ubuntu's archive; mkasberg's PPA builds it for each release
sudo add-apt-repository -y --no-update ppa:mkasberg/ghostty-ubuntu

sudo apt update
#* openlogi (Logitech mouse/keyboard settings) — GitHub release .deb only, no apt repo, so apt never upgrades it;
#* re-run these two lines for a newer release. After `apt update`: apt resolves the .deb's dependencies from the lists.
curl -fsSL "$(curl -fsSL https://api.github.com/repos/AprilNEA/OpenLogi/releases/latest | grep -oE 'https://[^"]+linux-amd64\.deb' | head -1)" -o /tmp/openlogi.deb
sudo apt install -y /tmp/openlogi.deb && rm -f /tmp/openlogi.deb
#* skip debs a Flatpak replaces (apt/blocked.list): initTrim.sh pins them to -1, and one stale packages.list entry
#* would then fail this whole install with "has no installation candidate"
grep -vxFf "$DOT/apt/blocked.list" "$DOT/apt/packages.list" | xargs -r sudo apt install -y

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
	| sudo tee /etc/udev/rules.d/80-uinput.rules > /dev/null
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -aG input "$USER" #* group membership needs a re-login to take effect
#* package-shipped user unit (/usr/lib/systemd/user/ydotool.service) — runs ydotoold at login.
#* `|| true`: no session bus when this is driven headlessly, and set -e would abort the whole bootstrap.
systemctl --user enable --now ydotool.service || true

#* inotify limits — distro defaults run out under VS Code / bundlers / file watchers
#* ("ENOSPC: System limit for number of file watchers reached"). Not stowable: /etc, not $HOME.
printf 'fs.inotify.max_user_watches=524288\nfs.inotify.max_user_instances=1024\n' | sudo tee /etc/sysctl.d/99-inotify.conf > /dev/null
sudo sysctl --system > /dev/null

#* mise — installed explicitly (like vim above) so a fresh bootstrap works even before the daily sync has added
#* it to packages.list; the apt line is a no-op once it's in there. `mise install` pulls every tool pinned in the
#* stowed .config/mise/config.toml. Last in the file and `|| true`-guarded because it's the slow, network-bound,
#* least critical step — a failed tool download must not skip the /etc config above. Completions are GENERATED,
#* so not stowed: ~/.zsh/completions is already on FPATH (zsh/10-env.zsh), before 20-plugins.zsh's compinit.
#* Re-run the completion line after a mise upgrade to refresh it.
sudo apt install -y mise
mkdir -p "$HOME/.zsh/completions"
mise completion zsh > "$HOME/.zsh/completions/_mise"
mise install || true
mise exec -- gh completion -s zsh > "$HOME/.zsh/completions/_gh" || true #* the gh deb shipped this; mise's doesn't

echo "Done. Installed manually when needed (not part of this bootstrap):"
echo "  nvidia driver (ubuntu-drivers install), docker, vscode, handy"
