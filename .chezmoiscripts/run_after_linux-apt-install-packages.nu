#!/usr/bin/env nu
# Install apt packages from ~/.config/apt/packages.yaml

let config_file = $"($env.HOME)/.config/apt/packages.yaml"
if not ($config_file | path exists) { exit 0 }

let config = open $config_file

def add-repos [] {
    $config.repos | each { |repo|
        if $repo.type == "ppa" {
            let ppa_name = $repo.ppa | str replace "ppa:" ""
            let exists = (ls /etc/apt/sources.list.d/ | get name | any { open $in | str contains $ppa_name })
            if not $exists {
                sudo add-apt-repository -y $repo.ppa
            }
        } else if $repo.type == "deb" {
            let list_file = $"/etc/apt/sources.list.d/($repo.name).list"
            if not ($list_file | path exists) {
                # Only setup GPG key if key_url is provided
                if ($repo.key_url? | is-not-empty) {
                    sudo mkdir -p /etc/apt/keyrings
                    http get $repo.key_url | sudo gpg --dearmor -o $repo.key_file
                }
                $repo.repo | sudo tee $list_file | ignore
            }
        }
    }
}

def install-packages [] {
    let packages = $config.packages
    if ($packages | is-empty) { return }
    sudo apt-get update -qq
    sudo apt-get install -y -qq ...$packages
}

def create-symlinks [] {
    let bin_dir = $env.HOME | path join ".local/bin"
    mkdir $bin_dir

    let symlinks = [
        [src, dest];
        ["/usr/bin/batcat", "bat"]
        ["/usr/bin/fdfind", "fd"]
    ]

    $symlinks | where { $in.src | path exists } | each { |link|
        ln -sf $link.src ($bin_dir | path join $link.dest)
    }
}

add-repos
install-packages
create-symlinks
