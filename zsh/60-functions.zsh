killPort() {
	sudo kill -9 $(lsof -t -i :"$1")
}

# Run a command in a memory-capped cgroup. next dev peaks ~8G warm / >11G on a
# cold .next; without a cap the pressure lands on systemd-oomd, which kills the
# swap-heaviest cgroup in the session — whichever browser has been open longest,
# not the process that caused it. Usage: devcap pnpm dev
devcap() {
  systemd-run --user --scope -p MemoryMax=11G -p MemorySwapMax=0 --collect -- "$@"
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

#* System update: apt, snap and flatpak side by side; quits itself once all three finish.
#  ti@:te@ suppresses screen's alternate-screen swap, so the final frame is left behind in the
#  terminal instead of being wiped on exit. Everything inside runs as root already: one password
#  prompt, and no re-prompt when a long upgrade outlives the sudo ticket.
#  =() not <() because sudo closes inherited fds. Each job parks on a marker-file barrier so all
#  three regions stay on screen until the slowest one is done, then window 0 quits the session.
function uuac {
  sudo mkdir -p /run/uuac && sudo rm -f /run/uuac/apt /run/uuac/snap /run/uuac/flatpak || return
  # screen draws at absolute row 1, so scroll the visible screen into scrollback first: without this it
  # overwrites whatever was on screen, and a second run lands on top of the first one's leftovers
  local n=$(tput lines)
  printf "\e[${n}H"; repeat $n print
  sudo screen -c =(cat <<'RC'
startup_message off
termcapinfo * ti@:te@
caption always "%t"
screen -t apt sh -c 'apt update -y && apt upgrade --with-new-pkgs -y && apt autoremove --purge -y && apt clean all -y; echo "[apt finished, exit $?]"; touch /run/uuac/apt; while [ $(ls /run/uuac | wc -l) -lt 3 ]; do sleep 1; done; sleep 1; screen -X quit'
split -v
focus
screen -t snap sh -c 'snap refresh; echo "[snap finished, exit $?]"; touch /run/uuac/snap; sleep 3600'
split -v
focus
screen -t flatpak sh -c 'flatpak update -y && flatpak uninstall --unused -y; echo "[flatpak finished, exit $?]"; touch /run/uuac/flatpak; sleep 3600'
resize -h =
RC
)
}
