#!/usr/bin/env nu
# Install apt packages from ~/.config/apt/packages.conf

let config = $"($env.HOME)/.config/apt/packages.conf"
if not ($config | path exists) { exit 0 }

def parse-section [name: string]: nothing -> list<string> {
    open $config
    | lines
    | skip until { $in == $"[($name)]" }
    | skip 1
    | take until { $in starts-with "[" }
    | where { $in != "" and not ($in starts-with "#") }
}

def add-ppas [] {
    parse-section ppas | each { |ppa|
        let ppa_name = $ppa | str replace "ppa:" ""
        let exists = (ls /etc/apt/sources.list.d/ | get name | any { open $in | str contains $ppa_name })
        if not $exists {
            sudo add-apt-repository -y $ppa
        }
    }
}

def add-debs [] {
    parse-section debs | each { |line|
        let parts = $line | split column "|" name key_url key_file repo | first
        if not ($parts.key_file | path exists) {
            sudo mkdir -p /etc/apt/keyrings
            http get $parts.key_url | sudo gpg --dearmor -o $parts.key_file
            $parts.repo | sudo tee $"/etc/apt/sources.list.d/($parts.name).list" | ignore
        }
    }
}

def install-packages [] {
    let packages = parse-section packages
    if ($packages | is-empty) { return }
    sudo apt-get update -qq
    sudo apt-get install -y -qq ...$packages
}

def create-symlinks [] {
    mkdir ($env.HOME | path join ".local/bin")
    if ("/usr/bin/batcat" | path exists) {
        ln -sf /usr/bin/batcat ($env.HOME | path join ".local/bin/bat")
    }
    if ("/usr/bin/fdfind" | path exists) {
        ln -sf /usr/bin/fdfind ($env.HOME | path join ".local/bin/fd")
    }
}

add-ppas
add-debs
install-packages
create-symlinks
