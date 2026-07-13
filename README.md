# dotfiles
Personal dotfiles management

## New PC bootstrap

```sh
curl -fsSL https://raw.githubusercontent.com/m-salman-afzal/dotfiles/main/initSystem/initTerminal.sh | bash \
  && bash ~/dotfiles/initSystem/initApt.sh \
  && bash ~/dotfiles/initSystem/initGnomeExtension.sh \
  && bash ~/dotfiles/initSystem/initFlatpak.sh
```

What it does, in order:

1. **initTerminal.sh** — generates the two SSH keys (auth + commit signing), prints them and waits until they're added to GitHub, clones this repo, stows the symlinks (wiping the distro `.bashrc`/`.profile` first), installs zsh and makes it the default shell.
2. **initApt.sh** — sets up the third-party apt repos (github-cli, solaar PPA — keys fetched fresh from the vendors), then installs every package in `apt/packages.list`. Installed manually when needed: nvidia driver, docker, vscode, steam, cursor, protonvpn, lm-studio.
3. **initGnomeExtension.sh** — installs every extension in `gnome/extensions.list` from extensions.gnome.org, restores their settings from `gnome/extensions.dconf`, enables them all. Log out/in to load them.
4. **initFlatpak.sh** — installs flatpak + flathub and every app in `flatpak/apps.list` (runtimes come along as dependencies).

The lists and settings dumps are refreshed automatically by the daily sync in `zsh/80-sync.zsh`, so they always reflect the current machine.
