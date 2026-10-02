#!/usr/bin/env nu
# Install TPM plugins

use adt.nu [run-cmd, is-ok, is-err]

def main [] {
    let home = $env.HOME? | default $env.USERPROFILE?
    let plugin_path = $home | path join '.local' 'share' 'tmux' 'plugins'
    let tpm_dir = $plugin_path | path join 'tpm'
    let install_script = $tpm_dir | path join 'bin' 'install_plugins'

    if (which tmux | is-empty) {exit 0}
    if not ($install_script | path exists) {exit 0}

    let result = with-env {TMUX_PLUGIN_MANAGER_PATH: $plugin_path} {
        run-cmd {^$install_script}
    }

    if ($result | is-ok) {return}

    let expected = ($result.error.stderr | str contains "Tmux Plugin Manager not configured") or ($result.error.stderr | str contains "Unknown variable")
    if $expected {exit 0}

    print -e $result.error.stderr
    exit $result.error.code
}
