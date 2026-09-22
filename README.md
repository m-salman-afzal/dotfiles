# dotfiles

Personal dotfiles management

## New PC bootstrap

```sh
curl -fsSL https://raw.githubusercontent.com/m-salman-afzal/dotfiles/main/initSystem/initTerminal.sh -o /tmp/initTerminal.sh \
  && bash /tmp/initTerminal.sh \
  && bash ~/dotfiles/initSystem/initApt.sh \
  && bash ~/dotfiles/initSystem/initGnomeExtension.sh \
  && bash ~/dotfiles/initSystem/initFlatpak.sh \
  && bash ~/dotfiles/initSystem/initSnap.sh \
  && bash ~/dotfiles/initSystem/initTrim.sh
```

What it does, in order:

1. **initTerminal.sh** — generates the two SSH keys (auth + commit signing), prints them and waits until they're added
   to GitHub, clones this repo, stows the symlinks (wiping the distro `.bashrc`/`.profile` first), installs zsh and
   makes it the default shell.
2. **initApt.sh** — sets up the third-party apt repos (github-cli, solaar PPA, mise via `extrepo` — keys fetched fresh
   from the vendors), then installs every package in `apt/packages.list`, raises the inotify watch/instance limits in
   `/etc/sysctl.d/99-inotify.conf` (file watchers hit `ENOSPC` on the defaults), makes vim the system `editor`
   alternative, and installs mise plus every tool pinned in `.config/mise/config.toml` (node, deno, bun, pnpm, rust) along
   with its zsh completions. Installed manually when needed: nvidia driver, docker, vscode, steam, cursor, protonvpn,
   lm-studio.
3. **initGnomeExtension.sh** — installs every extension in `gnome/extensions.list` from extensions.gnome.org, restores
   their settings from `gnome/extensions.dconf`, enables them all. Log out/in to load them.
4. **initFlatpak.sh** — installs flatpak + flathub and every app in `flatpak/apps.list` (runtimes come along as
   dependencies).
5. **initSnap.sh** — installs every snap in `snap/apps.list` (bases and content snaps come along as dependencies).
   Includes ghostty, the default terminal — `.config/xdg-terminals.list` points Ctrl+Alt+T at it.
6. **initTrim.sh** — turns off stock Ubuntu pieces that only cost resources on a laptop (measured on the Victus,
   2026-09-20). apport + whoopsie: crash reporter, never prevents a crash, autoreport sat failed 30 s at boot, whoopsie
   held 100 MB, and its retracer has OOM-stormed the desktop. kdump-tools: 512 MB of RAM reserved for a kernel-panic
   dump nobody reads. docker.service at boot: socket activation stays, the daemon starts on first use (0.8 s boot,
   240 MB idle). ModemManager + cups/cups-browsed: no modem, no printer. gnome-software's background half: 270 MB +
   packagekitd just to poll flatpak updates — the stowed `.config/autostart/org.gnome.Software.desktop` hides the
   autostart, the script drops its overview search provider. Idempotent. Deliberately not in here: snap, GRUB_TIMEOUT,
   GNOME extensions.

The lists and settings dumps are refreshed automatically by the daily sync in `zsh/80-sync.zsh`, so they always reflect
the current machine.
