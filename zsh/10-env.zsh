
#* Paths
export PATH=$PATH:$HOME/.local/bin
export PATH="/var/lib/flatpak/exports/bin:$PATH"

#* Editor — sudo drops these, so visudo/sudoedit rely on the `editor` alternative instead (set in initApt.sh)
export EDITOR='nvim'
export VISUAL='nvim'

#* rust
#. "$HOME/.cargo/env"
export PATH=$HOME/.cargo/bin:$PATH

#* bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

#* pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

#* google cloud sdk.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi

#* Node
export NODE_COMPILE_CACHE="$HOME/.cache/node"

#* Turso
export PATH="$PATH:$HOME/.turso"

#* LM Studio CLI
export PATH="$PATH:/home/satop/.lmstudio/bin"

#* deno
. "$HOME/.deno/env"
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then export FPATH="$HOME/.zsh/completions:$FPATH"; fi
