#* refresh gnome extension list + settings so new installs get committed too
command ls $HOME/.local/share/gnome-shell/extensions > $HOME/dotfiles/gnome/extensions.list # command: dodge the ls alias
#  awk drops only the private bits: window titles, bt MACs, phone pairing state.
#  everything else in those extensions still syncs
dconf dump /org/gnome/shell/extensions/ | awk '
  /^\[/ { sec=$0; if (sec ~ /^\[gsconnect\/device/) next }   # pairing state: certs, caps
  sec ~ /^\[gsconnect\/device/ { next }
  sec == "[SmartAutoMoveNG]" && /^saved-windows=/ { next }
  sec == "[Bluetooth-Battery-Meter]" && /^(device-list|galaxy-buds-list|gattbas-list|upower-device-list)=/ { next }
  sec == "[gsconnect]" && /^devices=/ { next }
  sec == "[dynamic-music-pill]" && /^playback-history=/ { next }   # what was watched/played
  { print }
' > $HOME/dotfiles/gnome/extensions.dconf

#* refresh keyboard layout + xkb options (caps:escape lives here)
dconf dump /org/gnome/desktop/input-sources/ > $HOME/dotfiles/gnome/input-sources.dconf

#* refresh custom keyboard shortcuts (app launchers, wm, shell)
dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > $HOME/dotfiles/gnome/media-keys.dconf
dconf dump /org/gnome/desktop/wm/keybindings/ > $HOME/dotfiles/gnome/wm-keybindings.dconf
dconf dump /org/gnome/shell/keybindings/ > $HOME/dotfiles/gnome/shell-keybindings.dconf
