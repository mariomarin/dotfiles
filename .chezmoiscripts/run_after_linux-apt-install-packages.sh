#!/usr/bin/env bash
# Install apt packages from ~/.config/apt/packages.conf
set -euo pipefail

CONFIG="$HOME/.config/apt/packages.conf"
[[ -f "$CONFIG" ]] || exit 0

parse_section() {
    sed -n "/^\[$1\]/,/^\[/p" "$CONFIG" | grep -v '^\[' | grep -v '^#' | grep -v '^$'
}

add_ppas() {
    parse_section ppas | while IFS= read -r ppa; do
        [[ -z "$ppa" ]] && continue
        grep -qR "${ppa#ppa:}" /etc/apt/sources.list.d/ 2> /dev/null && continue
        sudo add-apt-repository -y "$ppa"
  done
}

add_debs() {
    parse_section debs | while IFS='|' read -r name key_url key_file repo; do
        [[ -z "$name" ]] && continue
        [[ -f "$key_file" ]] && continue
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- "$key_url" | sudo gpg --dearmor -o "$key_file"
        echo "$repo" | sudo tee "/etc/apt/sources.list.d/${name}.list" > /dev/null
  done
}

install_packages() {
    mapfile -t packages < <(parse_section packages)
    [[ ${#packages[@]} -eq 0 ]] && return 0
    sudo apt-get update -qq
    sudo apt-get install -y -qq "${packages[@]}"
}

create_symlinks() {
    mkdir -p ~/.local/bin
    [[ -x /usr/bin/batcat ]] && ln -sf /usr/bin/batcat ~/.local/bin/bat
    [[ -x /usr/bin/fdfind ]] && ln -sf /usr/bin/fdfind ~/.local/bin/fd
}

add_ppas
add_debs
install_packages
create_symlinks
