
#* Paths
export PATH=$PATH:$HOME/.local/bin

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
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
export PATH="$HOME/.local/bin:$PATH"

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
