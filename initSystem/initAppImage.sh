#!/usr/bin/env bash
#* Install AppManager, then every AppImage in appimage/apps.list through it.
#* Each line is "Name<TAB>source", the source as AppManager records it: a direct URL, `zsync|<url>.zsync`,
#* or `gh-releases-zsync|owner|repo|tag|<glob>.zsync` (the AppImage's embedded update info).
set -euo pipefail

DOT=$HOME/dotfiles
AM=$HOME/.local/bin/app-manager
DATA=$HOME/.local/share/app-manager
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

command -v jq > /dev/null || sudo apt install -y jq # fresh ubuntu has no jq

#* source → download URL (empty when it can't be resolved)
url_for() {
	case $1 in
	gh-releases-zsync\|*)
		local _ owner repo tag glob api u
		IFS='|' read -r _ owner repo tag glob <<< "$1"
		[[ $tag == latest ]] && api=latest || api=tags/$tag
		for u in $(curl -fsSL "https://api.github.com/repos/$owner/$repo/releases/$api" | jq -r '.assets[].browser_download_url'); do
			# shellcheck disable=SC2053 # unquoted on purpose: the update info's file name is a glob
			[[ ${u##*/} == ${glob%.zsync} ]] && echo "$u" && return
		done
		;;
	zsync\|*)
		local u=${1#zsync|}
		echo "${u%.zsync}"
		;;
	*) echo "$1" ;;
	esac
}

#* custom.json (per-app update links, prerelease toggles) goes in before AppManager's first run:
#* it reapplies those overrides, matched by app name, to each app it installs
mkdir -p "$DATA"
[[ -e $DATA/custom.json ]] || cp "$DOT/appimage/custom.json" "$DATA/custom.json"

#* AppManager installs itself: run from the download, it copies itself to ~/Applications and links ~/.local/bin/app-manager
if [[ ! -x $AM ]]; then
	curl -fL "$(url_for 'gh-releases-zsync|kem-a|AppManager|latest|*anylinux*x86_64.AppImage.zsync')" -o "$TMP/AppManager"
	chmod +x "$TMP/AppManager"
	"$TMP/AppManager" install "$TMP/AppManager"
fi

while IFS=$'\t' read -r name src; do
	[[ -z $name ]] && continue
	jq -e --arg n "$name" 'any(.installations[]; .name == $n)' "$DATA/installations.json" > /dev/null && continue # already installed
	url=$(url_for "$src")
	[[ -z $url ]] && {
		echo "SKIP $name (no download source; install it by hand)"
		continue
	}
	curl -fL "$url" -o "$TMP/$name"
	chmod +x "$TMP/$name"
	"$AM" install "$TMP/$name"
	rm -f "$TMP/$name"
done < "$DOT/appimage/apps.list"

echo "Done."
