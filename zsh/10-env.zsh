#* Paths
export PATH=$PATH:$HOME/.local/bin
export PATH="/var/lib/flatpak/exports/bin:$PATH"
#* mise shims here, not in 70-mise.zsh: 20-plugins.zsh runs oh-my-posh (a mise tool) before the full
#* `mise activate`, which then puts the real install dirs ahead of these.
eval "$(mise activate zsh --shims)"

#* Editor — sudo drops these, so visudo/sudoedit rely on the `editor` alternative instead (set in initApt.sh)
export EDITOR='nvim'
export VISUAL='nvim'

#* pnpm — the pnpm binary itself comes from mise (.config/mise/config.toml). PNPM_HOME stays because
#* `pnpm add -g` puts its bins there (ncu); mise activates at 70 and so wins the PATH order for pnpm itself.
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

#* Node
export NODE_COMPILE_CACHE="$HOME/.cache/node"

#* LM Studio CLI
export PATH="$PATH:/home/satop/.lmstudio/bin"

#* Hand-generated zsh completions (_mise, written by initSystem/initApt.sh) — must stay ahead of the compinit
#* in zsh/20-plugins.zsh.
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then export FPATH="$HOME/.zsh/completions:$FPATH"; fi
