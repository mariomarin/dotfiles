#!/usr/bin/env nu
# Setup LaunchDaemons and LaunchAgents for darwin-brew

let config_file = $"($env.HOME)/.config/launchd/services.yaml"
if not ($config_file | path exists) {
    print "No services config found, skipping"
    exit 0
}

let config = open $config_file
let launchd_dir = $"($env.HOME)/.config/launchd"
let user_agents = $"($env.HOME)/Library/LaunchAgents"
let system_daemons = "/Library/LaunchDaemons"

mkdir $user_agents

def setup-daemon [daemon: record] {
    let name = $daemon.name
    let src = $"($launchd_dir)/org.local.($name).plist"
    let dest = $"($system_daemons)/org.local.($name).plist"

    if not ($src | path exists) {
        print $"Skipping ($name): plist not found"
        return
    }

    # Copy binary if configured
    if ($daemon.copy_binary? | default false) {
        let binary_name = $daemon.binary_name
        let binary_dest = $daemon.binary_dest
        let binary_path = (which $binary_name).0?.path?
        if ($binary_path | is-not-empty) and ($binary_path != $binary_dest) {
            print $"Copying ($binary_name) to ($binary_dest)..."
            sudo cp -f $binary_path $binary_dest
            sudo chmod 755 $binary_dest
        }
    }

    # Create setup directories if configured
    if ($daemon.setup_dirs? | is-not-empty) {
        $daemon.setup_dirs | each { |dir|
            sudo mkdir -p $dir.path
            sudo chmod $dir.mode $dir.path
        }
    }

    # Install plist if changed
    let needs_update = if ($dest | path exists) {
        (open $src) != (open $dest)
    } else {
        true
    }

    if $needs_update {
        print $"Installing ($name) LaunchDaemon..."
        sudo cp $src $dest
        sudo chown root:wheel $dest
        sudo chmod 644 $dest
        do { sudo launchctl bootout system $dest } | complete | ignore
        sudo launchctl bootstrap system $dest
    }
}

def setup-agent [name: string] {
    let src = $"($launchd_dir)/org.local.($name).plist"
    let dest = $"($user_agents)/org.local.($name).plist"

    if not ($src | path exists) {
        return
    }

    let needs_update = if ($dest | path exists) {
        (open $src) != (open $dest)
    } else {
        true
    }

    if $needs_update {
        print $"Installing ($name) LaunchAgent..."
        cp $src $dest
        let uid = (id -u)
        do { launchctl bootout $"gui/($uid)" $dest } | complete | ignore
        launchctl bootstrap $"gui/($uid)" $dest
    }
}

def main [] {
    # Setup daemons
    if ($config.daemons? | is-not-empty) {
        $config.daemons | each { |daemon| setup-daemon $daemon }
    }

    # Setup agents
    if ($config.agents? | is-not-empty) {
        $config.agents | each { |agent| setup-agent $agent.name }
    }

    print "Services setup complete."
}
