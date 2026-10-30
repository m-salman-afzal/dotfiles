# What this is

Personal dotfiles for one Ubuntu 26.04 / GNOME laptop, linked into `$HOME` with GNU Stow, plus the scripts that rebuild
the machine from scratch. No build or test suite: verify with `zsh -n <file>` / `bash -n <file>`
(+ `shellcheck` and `shfmt -l` for the bash scripts; shfmt takes its style from `.editorconfig`), then a new shell.

## Stow

- Invocation: `stow -d "$HOME/dotfiles" -t "$HOME" .` — NOT `stow -d "$HOME" -t "$HOME" dotfiles`, which stow 2.4
  accepts and silently does nothing with.
- `.stow-local-ignore` REPLACES stow's default ignore list, so `.git`, `README`, and every top-level entry that must not
  land in `$HOME` (`initSystem`, `zsh`, `apt`, `gnome`, …, this file) has to be listed. New top-level dir → add it.
- `~/.zshrc`, `~/.gitconfig`, `~/.icons`, `~/.poshthemes`, `~/.vscode/settings.json` and most of
  `~/.config/*` are symlinks into this repo. The Edit tool refuses symlinks — edit the file under `~/dotfiles/`.
- `.config/autostart/` is one folded symlink, so login entries that apps write themselves land in the repo too.

## Generated vs hand-maintained

`zsh/80-sync-dotfiles.zsh` runs on the first interactive shell of the day (stdin must be a tty; stamp
`~/.cache/dotfiles-last-sync`), regenerates the files below, stages EVERYTHING in the repo, and asks before committing
"updated config" and pushing. `.githooks/pre-push` touches the stamp, so any push counts as that day's sync, and
`.githooks/pre-commit` runs `betterleaks` on the staged diff, so a staged secret fails the commit and the sync asks again next shell
(`initTerminal.sh` sets `core.hooksPath`; on a clone made another way run `git config core.hooksPath .githooks`). So:
uncommitted changes always end up in the next sync prompt — don't leave experiments in the repo.

| Generated (hand-edits are overwritten daily) | Source | Hand-maintained input |
|---|---|---|
| `apt/packages.list` | `apt-mark showmanual` − ignore list | `apt/ignore.list` |
| `snap/apps.list` | `snap list` − bases/snapd − ignore list | `snap/ignore.list` |
| `flatpak/apps.list` | `flatpak list --app` | — |
| `gnome/extensions.list` | `ls ~/.local/share/gnome-shell/extensions` | — |
| `gnome/extensions.dconf` | `dconf dump /org/gnome/shell/extensions/`, private keys stripped by an awk filter | — |
| `gnome/{input-sources,media-keys,wm-keybindings,shell-keybindings}.dconf` | `dconf dump` | — |

- All lists are `LC_ALL=C` sorted; `comm` breaks otherwise. Keep hand-edited lists sorted the same way.
- To drop an apt package or snap from the generated list, add it to the ignore list — deleting the line is undone by
  the next sync. A package that is really a dependency is better `sudo apt-mark auto <pkg>`: it leaves both lists and
  becomes autoremovable. `apt/markAuto.sh` does that in bulk and never uninstalls anything.
- `apt/blocked.list` (hand, sorted): debs a Flatpak replaces. `initTrim.sh` pins them to -1 and purges them;
  `initApt.sh` filters them out of `packages.list`. Only Recommends belong there — pinning a hard Depends blocks
  `ubuntu-desktop`. Check: `apt-cache rdepends --installed --no-recommends --no-suggests <pkg>`.
- `extensions.dconf` holds every key under `/org/gnome/shell/extensions/`, including uninstalled extensions'. To drop
  one: `dconf reset -f /org/gnome/shell/extensions/<dir>/`. A new extension that stores private data (devices, window
  titles, history) needs a line in the sync's awk filter.
- snapd records no install reason, so `snap/ignore.list` (Canonical preinstalls, content snaps) can't be derived;
  deriving it from `seed.yaml`/`snap connections` was tried and misclassifies a third of the list.

## Shell

- `.zshrc` sources `zsh/*.zsh` in numeric order: 10 env/PATH, 20 zinit plugins + oh-my-posh, 30 options, 40 aliases,
  45 cleanup (space-reclaim aliases), 50 git, 60 functions, 70 `mise activate`, 80 daily sync, 81 monthly dircolors refresh.
- Aliases (40) must load before functions that use them (50/60): zsh expands aliases at parse time.
- In 20: plugins that extend `fpath` before `compinit`, fzf-tab right after it, autosuggestions/syntax-highlighting
  last. fzf comes from zinit (`gh-r`).
- `ls` is aliased to `ls -la --color` — code that parses `ls` output uses `command ls`.
- `(#q…)` glob qualifiers need EXTENDED_GLOB, which is off. Wrap them in `() { emulate -L zsh -o extendedglob; … }`
  like 80/81 do — with the option off the pattern is a literal string and `[[ -n … ]]` is silently always true.
- `zsh -i` sources the whole config; the sync fires only with a tty on stdin. Test syntax with `zsh -n` instead.

## Tools: mise

- mise (apt package, vendor repo via `extrepo enable mise`) owns node, bun, pnpm, rust, neovim and the CLIs (`npm:`
  tools, `cargo:du-dust`, oh-my-posh, gh, rclone, fastfetch, mprocs, betterleaks, shellcheck, shfmt), pinned in the stowed `.config/mise/config.toml`.
  New CLI → `mise use -g <tool>`, never a PATH line in `zsh/10-env.zsh`.
- Neovim is `aqua:neovim/neovim` (the official release tarball), named explicitly: plain `neovim` resolves to a vfox
  plugin.
- PATH order: 10 puts the mise shims on PATH (`mise activate --shims`) because 20 runs `oh-my-posh init` before 70's
  full `mise activate`. oh-my-posh's init bakes its versioned install path into the shell, so after `mise up` prunes the
  old version, open shells lose the prompt — `exec zsh`.
- mise's `rust` drives rustup: toolchains in `~/.rustup`, `cargo install`ed bins in `~/.cargo/bin`, which
  `mise activate` already puts on PATH. Components are listed in `config.toml`.
- `PNPM_HOME` (in 10) is only where `pnpm add -g` puts bins; pnpm itself is mise's.
- `mise self-update` is refused on the apt build — upgrade mise with apt, tools with `mise up`. Zsh completions
  (`~/.zsh/completions/_mise`, `_gh`) are generated by `initApt.sh`, not stowed; that dir is on FPATH from 10.

## Bootstrap (`initSystem/`, order in README.md)

`initTerminal.sh` (SSH keys → wait for GitHub → clone → `core.hooksPath` → stow → zsh) → `initApt.sh` →
`initGnomeExtension.sh` → `initFlatpak.sh` → `initSnap.sh` → `initTrim.sh`. All idempotent.

- `initTerminal.sh` runs under `curl | bash`: interactive `read`s need `</dev/tty`, and `ssh` needs `-n`.
- One package with no installation candidate fails the whole `apt install` of `packages.list`, so `initApt.sh` puts
  every third-party deb's source in place first: mise (`extrepo`), ghostty (PPA), openlogi (GitHub-release .deb, no
  repo — apt never upgrades it). A new third-party deb in `packages.list` needs a step there too.
- `/etc` config can't be stowed, so it lives inline in `initApt.sh`: `/etc/sysctl.d/99-inotify.conf` (raised inotify
  limits; defaults run out under VS Code/bundlers) and `/etc/udev/rules.d/80-uinput.rules`, which Handy's dictation
  needs (it types via ydotool → `/dev/uinput`). Neither file is dpkg-owned; don't "clean up" either. New `/etc` config
  goes in that script too.
- `initTrim.sh` disables stock services this laptop doesn't need (apport/whoopsie, kdump, docker at boot → socket
  activation, ModemManager, cups, motd-news, ua-timer, GNOME Software's search provider) and applies
  `apt/blocked.list`. It deliberately leaves snap,
  GRUB_TIMEOUT and GNOME extensions alone.
- `.profile`/`.bashrc` are not in the repo: zsh is the login shell, so the distro defaults stay.
- Hand-installed, outside the bootstrap: nvidia driver, docker, VS Code, Handy, claude-desktop, plus AppImages in
  `~/Applications` (managed by AppManager).

## Defaults

- Editor: `EDITOR`/`VISUAL=nvim` in `zsh/10-env.zsh`, `core.editor = nvim` in `.gitconfig`; sudo strips env, so
  `initApt.sh` sets the system `editor` alternative to vim for visudo/sudoedit.
- Terminal: Ghostty (deb, desktop id `com.mitchellh.ghostty.desktop`). GNOME's Ctrl+Alt+T runs `xdg-terminal-exec`,
  which reads the stowed `.config/xdg-terminals.list` — no custom keybinding or `xdg-mime` workaround needed.

## Removing software

A package with no apt reverse deps is not necessarily unused: GNOME extensions call host binaries apt can't see (e.g.
`cava` ← dynamic-music-pill, soundbar). Before removing a "leaf" package, grep `~/.local/share/gnome-shell/extensions`
for it.

## Conventions

- Section comments use a `#*` prefix.
- Commits are SSH-signed with `~/.ssh/gitCommitSigningKey.pub` (path hardcoded in `.gitconfig`; `initTerminal.sh`
  generates exactly that key).
- Single-user repo: force-pushing rewritten history is fine.
