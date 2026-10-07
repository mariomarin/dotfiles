# Tests for tmux-plugins.nu against a fake TPM in a temp HOME
use std/assert

const SCRIPT = ".scripts/tmux-plugins.nu"

# Fake TPM scripts log their name; install_plugins fails with $install_stderr
def run-plugins [install_exit: int, install_stderr: string]: nothing -> record {
    let home = (mktemp -d | path expand)
    let bin = $"($home)/bin"
    let tpm = $"($home)/.local/share/tmux/plugins/tpm/bin"
    mkdir $bin $tpm
    "#!/bin/sh\nexit 0\n" | save $"($bin)/tmux"
    $"#!/bin/sh\necho install \"$TMUX_PLUGIN_MANAGER_PATH\" >> ($home)/tpm.log\necho '($install_stderr)' >&2\nexit ($install_exit)\n" | save $"($tpm)/install_plugins"
    $"#!/bin/sh\necho clean >> ($home)/tpm.log\n" | save $"($tpm)/clean_plugins"
    ^chmod +x $"($bin)/tmux" $"($tpm)/install_plugins" $"($tpm)/clean_plugins"
    let result = with-env {HOME: $home, PATH: ($env.PATH | prepend $bin)} { do { ^$nu.current-exe -n $SCRIPT } | complete }
    let log = if ($"($home)/tpm.log" | path exists) { open --raw $"($home)/tpm.log" | lines } else { [] }
    rm -rf $home
    $result | insert calls $log | insert home $home
}

def "test installs then cleans unlisted plugins" [] {
    let r = run-plugins 0 ""
    assert equal $r.exit_code 0 $r.stderr
    assert equal $r.calls [$"install ($r.home)/.local/share/tmux/plugins" "clean"]
}

def "test unconfigured tpm is not an error" [] {
    let r = run-plugins 1 "Tmux Plugin Manager not configured in tmux.conf"
    assert equal $r.exit_code 0 $r.stderr
}

def "test install failure stops before clean" [] {
    let r = run-plugins 3 "git clone failed"
    assert equal $r.exit_code 3
    assert ($r.stderr | str contains "install_plugins: git clone failed") $r.stderr
    assert equal ($r.calls | length) 1
}
