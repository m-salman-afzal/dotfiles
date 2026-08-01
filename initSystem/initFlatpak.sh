#!/usr/bin/env bash
#* Install flatpak + flathub, then every app in flatpak/apps.list
#* (runtimes like org.freedesktop.Platform install automatically as dependencies)
set -euo pipefail

sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
xargs -r flatpak install --system --noninteractive flathub < "$HOME/dotfiles/flatpak/apps.list"

#* Neovim: needs host files to edit anything, and --talk-name lets plugins shell out
#* to host commands via flatpak-spawn.
flatpak override --user --filesystem=host --talk-name=org.freedesktop.Flatpak io.neovim.nvim

#* The flatpak only exports `io.neovim.nvim`, but everything that spawns an editor
#* (git, vscode-neovim, EDITOR) looks for `nvim` on PATH — hence this wrapper. It also
#* points the XDG dirs at the host ones, so nvim reads the stowed ~/.config/nvim and
#* keeps plugins/state/cache in ~/.local, not ~/.var/app. `flatpak override --env=XDG_*`
#* does NOT work for this: flatpak re-sets those to the per-app dirs after applying
#* overrides (still true in 1.16), so they have to be set inside the sandbox via `env`.
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/nvim" <<'EOF'
#!/bin/sh
exec flatpak run --command=/usr/bin/env io.neovim.nvim \
  XDG_CONFIG_HOME="$HOME/.config" \
  XDG_DATA_HOME="$HOME/.local/share" \
  XDG_STATE_HOME="$HOME/.local/state" \
  XDG_CACHE_HOME="$HOME/.cache" \
  nvim-wrapper "$@"
EOF
chmod +x "$HOME/.local/bin/nvim"

echo "Done. Some apps may need a session restart to show up in the launcher."
