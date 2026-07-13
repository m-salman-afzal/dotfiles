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
  then stages everything, shows the diff, and asks before committing ("updated config") and pushing. Consequences:
  (1) any uncommitted change in this repo lands in the next sync prompt — never leave experiments lying around;
  (2) never run a full interactive zsh (`zsh -i -c ...`) for testing unless you want the sync to fire.
- `zsh/81-sync-dircolors.zsh` — monthly background refresh of the dracula dircolors file.
- `apt/packages.list` is GENERATED: `apt-mark showmanual` minus `apt/ignore.list` (both LC_ALL=C sorted — comm breaks
  otherwise). `apt/ignore.list` is HAND-maintained: packages that are manual on this machine but unwanted on a fresh
  one. To drop a package from `packages.list`, add it to `ignore.list` (keep it sorted) — deleting the line directly
  gets undone by the next sync. If the package is really a dependency (e.g. libs named in some build instructions),
  `sudo apt-mark auto <pkg>` is better: it leaves both lists and becomes autoremovable.
- `(#q...)` glob qualifiers in the sync require EXTENDED_GLOB, which is off globally; the code wraps in
  `() { emulate -L zsh -o extendedglob; ... }`. With the option off the pattern is a literal string and `[[ -n ]]` is
  always true — it degrades silently, not loudly. Keep new glob-qualifier code inside such a wrapper.
- `gnome/` and `flatpak/` contain GENERATED files (overwritten by the daily sync) — hand-edits there are lost within a
  day.
- `initSystem/` — fresh-PC bootstrap chain, run via the curl one-liner in README.md: `initTerminal.sh` (SSH keys → wait
  for GitHub → clone → stow → zsh default shell), then `initApt.sh` (third-party repos with keys fetched from the
  vendors, then `apt/packages.list`), then `initGnomeExtension.sh` / `initFlatpak.sh`, which install from the
  generated lists. `initTerminal.sh` must stay `curl | bash`-safe (interactive `read`s need `</dev/tty`).
- Aliases: `ls` is aliased — scripts/subshells that parse `ls` output must use `command ls`.

## Conventions

- Commit signing is SSH-based; `.gitconfig` hardcodes `~/.ssh/gitCommitSigningKey.pub` — the bootstrap generates keys
  with exactly those names.
- Section comments use `#*` prefix.
- Force-pushing rewritten history is acceptable here (single-user repo).
