#!/usr/bin/env nu
# Sync TPM plugins with plugins.tmux: install new ones, remove unlisted ones

use adt.nu [ok, err, run-cmd]

# TPM reports these when no tmux server/config is available to read plugins from
def is-tpm-unconfigured [stderr: string]: nothing -> bool {
    ($stderr | str contains "Tmux Plugin Manager not configured") or ($stderr | str contains "Unknown variable")
}

def run-tpm [script: string, plugin_path: string]: nothing -> record {
    match (with-env {TMUX_PLUGIN_MANAGER_PATH: $plugin_path} { run-cmd {^$script} }) {
        {ok: true} => (ok null)
        {error: $failure} if (is-tpm-unconfigured $failure.stderr) => (ok null)
        {error: $failure} => (err $failure)
    }
}

def main [] {
    let plugin_path = ($nu.home-dir | path join '.local' 'share' 'tmux' 'plugins')
    let tpm_bin = ($plugin_path | path join 'tpm' 'bin')
    if (which tmux | is-empty) or not ($tpm_bin | path exists) { return }

    for script in [install_plugins clean_plugins] {
        match (run-tpm ($tpm_bin | path join $script) $plugin_path) {
            {ok: true} => null
            {error: $failure} => {
                print -e $"($script): ($failure.stderr | str trim)"
                exit $failure.code
            }
        }
    }
}
