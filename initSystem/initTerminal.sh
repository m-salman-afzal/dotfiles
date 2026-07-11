#!/usr/bin/env bash
#* Bootstrap a fresh Linux PC: ssh keys -> github -> dotfiles -> stow -> zsh
set -euo pipefail

EMAIL="m.salmanafzal@proton.me"

#* 1. two ssh keys: auth + commit signing (names match .gitconfig's signingkey path)
mkdir -p ~/.ssh && chmod 700 ~/.ssh
[[ -f ~/.ssh/id_ed25519 ]] || ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519 -N ""
[[ -f ~/.ssh/gitCommitSigningKey ]] || ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/gitCommitSigningKey -N ""

echo
echo "Paste these at https://github.com/settings/keys"
echo
echo "== Authentication key =="
cat ~/.ssh/id_ed25519.pub
echo
echo "== Signing key (pick type: Signing Key) =="
cat ~/.ssh/gitCommitSigningKey.pub
echo

#* 2. wait until github accepts the auth key
until ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | grep -q "successfully authenticated"; do
  read -rp "GitHub hasn't accepted the key yet — add it, then press Enter to retry... " </dev/tty   # works under curl|bash too
done
echo "GitHub auth OK."

#* 3. dotfiles (ssh remote so pushes work later)
[[ -d ~/dotfiles ]] || git clone git@github.com:m-salman-afzal/dotfiles.git ~/dotfiles

#* 4. stow — nuke the distro defaults that block the symlinks, then link
sudo apt update && sudo apt install -y stow zsh
rm -f ~/.bashrc ~/.profile
stow -d "$HOME/dotfiles" -t "$HOME" .   # ignores per .stow-local-ignore

#* 5. zsh as default shell (asks for your password)
chsh -s "$(command -v zsh)"

echo "Done. Log out/in (or open a new terminal) to land in zsh."
