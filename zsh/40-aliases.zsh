alias ls='ls -la --color'

alias uuac="sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove --purge -y && sudo apt clean all -y && sudo snap refresh && sudo flatpak update && sudo flatpak uninstall --unused"

alias Python="/usr/bin/python3"

alias python="/usr/bin/python3"

alias srs="sudo systemctl start redis-server"

alias disableKernelIpv6="sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1"

alias enableKernelIpv6="sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0 && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0"

#* claude
alias claude="$HOME/.local/bin/claude"

#* rclone
alias mountChatlyCdn="rclone mount r2CloudflareStorageChatly:chatly ~/r2mount --daemon"
alias mountProtonDrive="rclone mount protonDrive: ~/protonDriveMount --daemon"

#* node
alias n="npm"
alias p="pnpm"

alias nr="npm run"
alias pr="pnpm run"

alias nrd="npm run dev"
alias prd="pnpm run dev"

alias nrdh="npm run dev:https"
alias prdh="pnpm run dev:https"

alias nrb="npm run build"
alias prb="pnpm run build"

alias nrs="npm run start"
alias prs="pnpm run start"

alias nrt="npm run test"
alias prt="pnpm run test"

alias nrtd="npm run test:dev"
alias prtd="pnpm run test:dev"

alias nrtp="npm run test:prod"
alias prtp="pnpm run test:prod"
