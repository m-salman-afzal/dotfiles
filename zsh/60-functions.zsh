killPort() {
	sudo kill -9 $(lsof -t -i :"$1")
}

# remove all files/folder from current and children dirs
rmrf() {
  rm -rf ./**/$1
}

# cycle-sink: toggle laptop speakers <-> headphones.
# On UCM cards (e.g. skl_hda_dsp) Speaker and Headphones are mutually
# exclusive card *profiles*, so we switch the profile, not just the sink.
# Card and profile names are auto-detected, so this is machine-portable.
# GNOME shortcut Shift+Super+O runs: zsh -ic cycle-sink
cycle-sink() {
  emulate -L zsh
  local want label icon card profile sink i
  if pactl list short sinks | grep -q Headphones; then
    want=Speaker  label="Speakers"   icon=audio-speakers-symbolic
  else
    want=Headphones label="Headphones" icon=audio-headphones-symbolic
  fi

  card=$(pactl list cards | awk -v w="$want" '
    /^\tName: / { name = $2 }
    /^\t\t/ && index($0, w) { print name; exit }')
  profile=$(pactl list cards | sed -n "s/^\t\t\(HiFi ([^)]*${want}[^)]*)\): .*/\1/p" | head -1)
  if [[ -z $card || -z $profile ]]; then
    notify-send -t 2500 "Audio Output" "no card with a $want profile found"
    return 1
  fi

  pactl set-card-profile "$card" "$profile" || return 1

  # profile switch recreates the sink asynchronously — wait for it
  for i in {1..20}; do
    sink=$(pactl list short sinks | awk -v w="$want" 'index($2, w) { print $2; exit }')
    [[ -n $sink ]] && break
    sleep 0.1
  done
  if [[ -z $sink ]]; then
    notify-send -t 2500 "Audio Output" "$want sink never appeared"
    return 1
  fi

  pactl set-default-sink "$sink"
  pactl list short sink-inputs | awk '{print $1}' | while read -r si; do
    pactl move-sink-input "$si" "$sink"
  done

  notify-send -a "Audio Output" -i "$icon" -t 2000 "Audio Output" "$label"
}
