#* apt / snap
alias rmPkgLeftovers='dpkg -l | grep "^rc" && sudo apt purge $(dpkg -l | awk "/^rc/{print \$2}")'

alias rmSnapLeftovers='snap list --all | awk "/disabled/{print \$1, \$3}" | while read n r; do sudo snap remove "$n" --revision="$r"; done'

#* docker
# one y/N per category; containers first so their images/volumes become unused
alias dockerPrune="docker system df && docker container prune && docker image prune -a && docker builder prune -a && docker network prune && docker volume prune -a && docker system df"
