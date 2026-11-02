#* refresh appimage list from AppManager's registry: name + download source (custom update link, else the
#  AppImage's embedded zsync info, else its update link). custom.json = per-app overrides (update links,
#  prerelease) AppManager reapplies by name on reinstall; sorted because it saves a hash table in random order
local am=$HOME/.local/share/app-manager
jq -S '.entries |= sort_by(.name)' $am/custom.json > $HOME/dotfiles/appimage/custom.json
jq -r --slurpfile c $am/custom.json '
  ($c[0].entries | map({key: (.name | ascii_downcase), value: .custom_update_link}) | from_entries) as $link
  | .installations[]
  | [.name, ([$link[.name | ascii_downcase], .zsync_update_info, .original_update_link]
      | map(select(. != null and . != "" and . != "__CLEARED__")) | first // "")]
  | @tsv
' $am/installations.json | LC_ALL=C sort > $HOME/dotfiles/appimage/apps.list
