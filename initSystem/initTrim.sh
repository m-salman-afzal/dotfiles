#!/usr/bin/env bash
#* Trim the stock Ubuntu desktop. Everything here is post-mortem tooling or a daemon for hardware this laptop
#* doesn't have — none of it changes how the system runs, only who gets a report after something already died.
#* Idempotent, re-run any time. Measured on the Victus / Ubuntu 26.04, 2026-09-20; numbers in README.md.
#* Deliberately NOT here: snap, GRUB_TIMEOUT, GNOME extensions, journald cap.
set -euo pipefail

#* apport + whoopsie — crash catcher and its uploader. Never prevents a crash; its retracer has OOM-stormed the whole
#* desktop by unpacking a core dump into tmpfs /tmp, and apport-autoreport sat failed for 30 s at every boot.
#* gdb / coredumpctl cover the rare real debugging need. whoopsie is static, so mask, not disable.
sudo sed -i 's/^enabled=1/enabled=0/' /etc/default/apport
sudo systemctl disable --now apport.service apport-autoreport.timer apport-autoreport.path apport-forward.socket
sudo systemctl mask --now whoopsie.service whoopsie.path
sudo rm -f /var/crash/*

#* kdump — a spare kernel kept resident to dump RAM after a kernel panic: reserves 512 MB (crashkernel=) for a file
#* nobody reads on a laptop. Purging removes /etc/default/grub.d/kdump-tools.cfg; update-grub drops the param.
if dpkg -s kdump-tools &>/dev/null; then
	sudo apt purge -y kdump-tools
	sudo apt autoremove --purge -y
	sudo update-grub
fi

#* docker — hand-installed (apt/ignore.list), so only if present. docker.socket stays: the daemon starts on the first
#* `docker` command instead of at boot (0.8 s boot, ~240 MB idle for docker + containerd).
if command -v dockerd &>/dev/null; then
	sudo systemctl disable docker.service
	sudo systemctl enable docker.socket
fi

#* daemons for hardware that isn't here: ModemManager (no WWAN modem), cups + cups-browsed (no printer).
#* Printer one day: `sudo systemctl enable --now cups.socket cups-browsed`.
sudo systemctl disable --now ModemManager.service cups.service cups.socket cups.path cups-browsed.service

#* motd-news + ua-timer — phone home to Canonical for the ssh/tty login banner and Ubuntu Pro nags (apt news, ESM
#* upsell). No ssh logins here and Pro isn't attached, so nothing reads either. Attach Pro one day: re-enable ua-timer.
sudo systemctl disable --now motd-news.timer ua-timer.timer

#* gnome-software — App Center's background half: ~270 MB resident + packagekitd, only to poll flatpak updates.
#* The stowed .config/autostart/org.gnome.Software.desktop (Hidden=true) kills the login autostart; this stops the
#* overview search from D-Bus-activating it straight back. Updates: open it, or `flatpak update`.
if command -v gnome-software &>/dev/null; then
	cur=$(gsettings get org.gnome.desktop.search-providers disabled)
	case $cur in
		*org.gnome.Software.desktop*) ;;
		'@as []') gsettings set org.gnome.desktop.search-providers disabled "['org.gnome.Software.desktop']" ;;
		*) gsettings set org.gnome.desktop.search-providers disabled "${cur%]}, 'org.gnome.Software.desktop']" ;;
	esac
fi

#* debs a Flatpak replaces (apt/blocked.list) — mostly ubuntu-desktop Recommends that a fresh install ships. Pin them
#* to -1 so neither a release upgrade (26.04 pulled showtime/gnome-calendar/gnome-snapshot in as new Recommends) nor a
#* stray `apt install` brings them back, then purge any that are here. Recommends only: pinning a hard Depends
#* (nautilus, yelp) would block ubuntu-desktop itself. The Flatpaks themselves come from flatpak/apps.list.
printf 'Package: %s\nPin: release a=*\nPin-Priority: -1\n' "$(tr '\n' ' ' < "$HOME/dotfiles/apt/blocked.list")" \
	| sudo tee /etc/apt/preferences.d/blocked-debs >/dev/null
#* `|| true`: dpkg-query exits 1 for names it has never seen (purged = forgotten), and pipefail would abort on that
installed=$(dpkg-query -W -f='${db:Status-Abbrev}${Package}\n' $(<"$HOME/dotfiles/apt/blocked.list") 2>/dev/null | sed -n 's/^ii //p' || true)
if [[ -n $installed ]]; then
	sudo apt purge -y $installed
	sudo apt autoremove --purge -y
fi

echo "Done. Reboot to see the kdump RAM back and the apport boot delay gone."
