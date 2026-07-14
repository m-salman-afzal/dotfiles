#!/usr/bin/env bash
#* Demote every "manual" apt package that some installed package still depends
#* on to "auto", so apt/ignore.list stays small and honest. Keepers in
#* apt/packages.list are never touched. Removes nothing: anything
#* `apt autoremove` would take afterwards gets promoted back to manual.
#* Run whenever the daily sync diff shows dependency noise in packages.list.
set -euo pipefail

DOT=$(cd "$(dirname "$0")/.." && pwd)
demote=$(mktemp)

#* candidates: manual, not a keeper, and >=1 installed reverse dependency
apt-mark showmanual | LC_ALL=C sort | LC_ALL=C comm -23 - "$DOT/apt/packages.list" \
  | xargs apt-cache rdepends --installed --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances 2>/dev/null \
  | awk '/^[^ ]/ && $0 != "Reverse Depends:" { pkg=$0; next }
         /^ /   && pkg != ""                { print pkg; pkg="" }' \
  | LC_ALL=C sort -u > "$demote"

if [[ ! -s $demote ]]; then
  echo "nothing to demote"; rm -f "$demote"; exit 0
fi

xargs sudo apt-mark auto < "$demote" > /dev/null
echo "demoted $(wc -l < "$demote") packages to auto"
rm -f "$demote"

#* safety net: re-promote anything the demotion made removable
for _ in 1 2 3; do
  mapfile -t doomed < <(apt-get autoremove --simulate 2>/dev/null | awk '/^Remv/ {print $2}')
  ((${#doomed[@]})) || break
  echo "re-promoting ${#doomed[@]} packages autoremove would take: ${doomed[*]}"
  sudo apt-mark manual "${doomed[@]}" > /dev/null
done

#* regenerate ignore.list from the clean manual set (packages.list is untouched)
apt-mark showmanual | LC_ALL=C sort | LC_ALL=C comm -23 - "$DOT/apt/packages.list" > "$DOT/apt/ignore.list"
echo "manual: $(apt-mark showmanual | wc -l) packages, ignore.list: $(wc -l < "$DOT/apt/ignore.list") lines"
