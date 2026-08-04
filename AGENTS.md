# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for an Ubuntu/GNOME machine, symlinked into `$HOME` with GNU Stow. There is no build, lint, or test
suite — verification is `zsh -n <file>` / `bash -n <file>` for syntax, then opening a new shell.

## Critical: symlinks

`~/.zshrc`, `~/.gitconfig`, `~/.bashrc`, `~/.profile`, `~/.icons`, `~/.poshthemes`, `~/.config/*` are symlinks into this
repo. The Edit tool refuses symlink targets — always edit the real file under `~/dotfiles/`.

Stow invocation: `stow -d "$HOME/dotfiles" -t "$HOME" .` (package `.`). Do NOT use `stow -d "$HOME" -t "$HOME" dotfiles`
— stow ≥2.4 silently plans nothing when target == stow dir. `.stow-local-ignore` REPLACES stow's default ignore list, so
`.git`/`README` entries must stay listed there; any new top-level file/dir that shouldn't be linked into `$HOME` needs
an entry.

## Architecture

- `.zshrc` only sources `zsh/*.zsh` in glob (numeric) order. Order matters: aliases (40) must load before functions
  (50/60) that use them — zsh expands aliases at parse time. In `20-plugins.zsh`, fpath-extending plugins load before
  `compinit`, fzf-tab right after it, autosuggestions/syntax-highlighting last.
- `zsh/80-sync-dotfiles.zsh` — self-updating repo: on the first interactive shell of a day (stamp file
  `~/.cache/dotfiles-last-sync`) it regenerates `gnome/extensions.list`, `gnome/extensions.dconf`, the keyboard-shortcut
  dumps (`gnome/{media-keys,wm-keybindings,shell-keybindings}.dconf`), `flatpak/apps.list`, and `apt/packages.list`,
  then stages everything, shows the diff, and asks before committing ("updated config") and pushing. The stamp is
  touched by `.githooks/pre-push` (repo-local `core.hooksPath`, set by `initTerminal.sh`; on a clone made another way,
  run `git config core.hooksPath .githooks`) — so any manual commit+push (e.g. from VS Code) counts as that day's
  sync. Consequences:
  (1) any uncommitted change in this repo lands in the next sync prompt — never leave experiments lying around;
  (2) never run a full interactive zsh (`zsh -i -c ...`) for testing unless you want the sync to fire.
- `zsh/81-sync-dircolors.zsh` — monthly background refresh of the dracula dircolors file.
- `apt/packages.list` is GENERATED: `apt-mark showmanual` minus `apt/ignore.list` (both LC_ALL=C sorted — comm breaks
  otherwise). `apt/ignore.list` is HAND-maintained: packages that are manual on this machine but unwanted on a fresh
  one. To drop a package from `packages.list`, add it to `ignore.list` (keep it sorted) — deleting the line directly
  gets undone by the next sync. If the package is really a dependency (e.g. libs named in some build instructions),
  `sudo apt-mark auto <pkg>` is better: it leaves both lists and becomes autoremovable. `apt/markAuto.sh` does this in
  bulk: it demotes every non-keeper manual package that something installed depends on, re-promotes anything
  `apt autoremove` would then remove (so it never uninstalls), and regenerates `ignore.list`.
- `(#q...)` glob qualifiers in the sync require EXTENDED_GLOB, which is off globally; the code wraps in
  `() { emulate -L zsh -o extendedglob; ... }`. With the option off the pattern is a literal string and `[[ -n ]]` is
  always true — it degrades silently, not loudly. Keep new glob-qualifier code inside such a wrapper.
- `gnome/` and `flatpak/` contain GENERATED files (overwritten by the daily sync) — hand-edits there are lost within a
  day.
- `initSystem/` — fresh-PC bootstrap chain, run via the curl one-liner in README.md: `initTerminal.sh` (SSH keys → wait
  for GitHub → clone → stow → zsh default shell), then `initApt.sh` (third-party repos with keys fetched from the
  vendors, then `apt/packages.list`), then `initGnomeExtension.sh` / `initFlatpak.sh` / `initSnap.sh`, which install from the
  generated lists. `initTerminal.sh` must stay `curl | bash`-safe (interactive `read`s need `</dev/tty`).
- System-level (`/etc`) config can't be stowed — stow only targets `$HOME` — so it lives inline in
  `initSystem/initApt.sh`. Currently that's `/etc/sysctl.d/99-inotify.conf`:
  `fs.inotify.max_user_watches=524288` + `max_user_instances=1024`, applied with `sudo sysctl --system`. The distro
  defaults (8192 watches / 128 instances) are exhausted by VS Code, bundlers and other file watchers, which then die
  with `ENOSPC: System limit for number of file watchers reached`. Already applied on this machine; a fresh PC gets it
  from the bootstrap. Add future `/etc` config the same way, not as a stow package.
- Neovim is a flatpak (`io.neovim.nvim`). `initFlatpak.sh` writes `~/.local/bin/nvim` as a wrapper (not a symlink) that
  launches it via `flatpak run --command=/usr/bin/env … nvim-wrapper`, setting `XDG_{CONFIG,DATA,STATE,CACHE}_HOME` to
  the host dirs so it uses the stowed `.config/nvim` and keeps plugins/state in `~/.local`. `flatpak override
  --env=XDG_*` can NOT do this — flatpak re-sets those to the per-app `~/.var/app` dirs after applying overrides (1.16,
  verified) and silently ignores the override; don't "simplify" the wrapper back into one.
- Default editor / terminal live in three places, one per mechanism: `EDITOR`/`VISUAL=nvim` in `zsh/10-env.zsh` (sudo
  strips them, hence the next one); `update-alternatives --set editor /usr/bin/vim.basic` in `initApt.sh` for
  visudo/sudoedit; `.config/xdg-terminals.list` (stowed) naming `ghostty_ghostty.desktop` for the terminal.
  GNOME's Ctrl+Alt+T on 26.04 runs `xdg-terminal-exec`, which reads that list — do NOT add the old custom-keybinding
  or `xdg-mime application/x-terminal` workarounds; both are stale and neither is applied here. Ghostty comes from
  `snap/apps.list`, and its snap registers the winning `x-terminal-emulator` alternative on its own. Desktop id is the snap's
  `ghostty_ghostty.desktop`, not `com.mitchellh.ghostty.desktop`.
- `snap/apps.list` is GENERATED, same shape as apt's: `snap list` minus the base/snapd-noted snaps (those arrive as
  deps) minus the HAND-maintained `snap/ignore.list` (both LC_ALL=C sorted — comm breaks otherwise). `ignore.list`
  holds the Canonical preinstalls and content snaps (gnome-*, mesa, gtk-common-themes, snap-store…) that a fresh
  Ubuntu already has. To drop a snap, add it to `ignore.list`, don't delete the `apps.list` line — the next sync puts
  it back. `initSnap.sh` installs plain, then retries `--classic` on failure, so classic-only snaps (ghostty) need no
  metadata in the list. The hand-maintained ignore list is unavoidable, unlike flatpak's `--app`: snapd records no
  install reason (checked on 2.76.1 — no `snap list` flag, no `/v2/snaps` field, `snap changes` is pruned) and
  `snap autoremove` has been an open request for years. Deriving it from `seed.yaml` + content-slot providers in
  `snap connections` was tried and misclassifies ~a third of the list (drops `bibata-all-cursor`, keeps
  `desktop-security-center`/`prompting-client`/`gnome-3-28-1804`). Don't re-attempt it.
- `/dev/uinput` is shared infrastructure — two unrelated things now write to it, so don't "clean up"
  `/etc/udev/rules.d/80-uinput.rules` (written by `initApt.sh`, not dpkg-owned): Handy's dictation typing and
  Solaar's `KeyPress` rules both break without it. Logitech hidraw `uaccess` is a separate concern and comes from
  solaar's own dpkg-owned `60-solaar.rules` — nothing in the bootstrap needs to grant it.
- Solaar (MX Master 3S button remapping) replaces input-remapper. Only `.config/solaar/rules.yaml` is stowed —
  `config.yaml` sits next to it unstowed on purpose: it's device state (pairing, per-device settings) the daemon
  rewrites constantly. Rules alone aren't enough; the buttons must also be `Diverted` in `Key/Button Diversion`, and
  that lives in `config.yaml`, so a fresh PC needs `solaar config "MX Master 3S" divert-keys "<Back|Forward|Mouse
  Gesture> Button" Diverted` (with Solaar not running — a live daemon owns the file and overwrites CLI edits on exit).
  Solaar's rule editor greys out entirely when `rules.yaml` is missing: with no file it loads only `built_in_rules`,
  and built-in rules carry `source=None`, which is the flag the UI uses for editability. The file existing is what
  creates the editable "User-defined rules" node.
- Aliases: `ls` is aliased — scripts/subshells that parse `ls` output must use `command ls`.

## Conventions

- Commit signing is SSH-based; `.gitconfig` hardcodes `~/.ssh/gitCommitSigningKey.pub` — the bootstrap generates keys
  with exactly those names.
- Section comments use `#*` prefix.
- Force-pushing rewritten history is acceptable here (single-user repo).
