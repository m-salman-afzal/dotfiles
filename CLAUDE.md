# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for an Ubuntu/GNOME machine, symlinked into `$HOME` with GNU Stow. There is no build, lint, or test suite — verification is `zsh -n <file>` / `bash -n <file>` for syntax, then opening a new shell.

## Critical: symlinks

`~/.zshrc`, `~/.gitconfig`, `~/.bashrc`, `~/.profile`, `~/.icons`, `~/.poshthemes`, `~/.config/*` are symlinks into this repo. The Edit tool refuses symlink targets — always edit the real file under `~/dotfiles/`.

Stow invocation: `stow -d "$HOME/dotfiles" -t "$HOME" .` (package `.`). Do NOT use `stow -d "$HOME" -t "$HOME" dotfiles` — stow ≥2.4 silently plans nothing when target == stow dir. `.stow-local-ignore` REPLACES stow's default ignore list, so `.git`/`README` entries must stay listed there; any new top-level file/dir that shouldn't be linked into `$HOME` needs an entry.

## Architecture

- `.zshrc` only sources `zsh/*.zsh` in glob (numeric) order. Order matters: aliases (40) must load before functions (50/60) that use them — zsh expands aliases at parse time. In `20-plugins.zsh`, fpath-extending plugins load before `compinit`, fzf-tab right after it, autosuggestions/syntax-highlighting last.
- `zsh/80-sync.zsh` — self-updating repo: on the first shell of a day (stamp file `~/.cache/dotfiles-last-sync`) it regenerates `gnome/extensions.list`, `gnome/extensions.dconf`, `flatpak/apps.list`, then auto-commits everything as "updated config" and pushes, all backgrounded with `&!`. Consequences: (1) any uncommitted change in this repo gets committed within a day — never leave experiments lying around; (2) never run a full interactive zsh (`zsh -i -c ...`) for testing unless you want the sync to fire.
- `(#q...)` glob qualifiers in the sync require EXTENDED_GLOB, which is off globally; the code wraps in `() { emulate -L zsh -o extendedglob; ... }`. With the option off the pattern is a literal string and `[[ -n ]]` is always true — it degrades silently, not loudly. Keep new glob-qualifier code inside such a wrapper.
- `gnome/` and `flatpak/` contain GENERATED files (overwritten by the daily sync) — hand-edits there are lost within a day.
- `initSystem/` — fresh-PC bootstrap chain, run via the curl one-liner in README.md: `initTerminal.sh` (SSH keys → wait for GitHub → clone → stow → zsh default shell) then `initGnomeExtension.sh` / `initFlatpak.sh`, which install from the generated lists. `initTerminal.sh` must stay `curl | bash`-safe (interactive `read`s need `</dev/tty`).
- Aliases: `ls` is aliased — scripts/subshells that parse `ls` output must use `command ls`.

## Conventions

- Commit signing is SSH-based; `.gitconfig` hardcodes `~/.ssh/gitCommitSigningKey.pub` — the bootstrap generates keys with exactly those names.
- Section comments use `#*` prefix.
- Force-pushing rewritten history is acceptable here (single-user repo).
