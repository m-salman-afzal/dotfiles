# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/satop/.lmstudio/bin"
# End of LM Studio CLI section

# Toolchains (node/deno/bun/pnpm/rust) come from mise in zsh/70-mise.zsh — no PATH lines here.
# volta (~/.volta), rustup's .cargo/env and deno's env used to be sourced from this file; all three
# are gone or mise-managed, and the deno one was already erroring on every login shell.
