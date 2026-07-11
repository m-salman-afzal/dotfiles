# Modular config: files in ~/dotfiles/zsh/ load in numeric order.
# 10-env  20-plugins  30-options  40-aliases  50-git  60-functions  70-nvm
for f in ~/dotfiles/zsh/*.zsh; do
  source "$f"
done
