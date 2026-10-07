#!/usr/bin/env nu
# Reload tmux config if server is running

use adt.nu [run-cmd]

def main [] {
    if (which tmux | is-empty) { return }
    if not (run-cmd {^tmux list-sessions}).ok { return }

    match (run-cmd {^tmux source-file ($nu.home-dir | path join '.config' 'tmux' 'tmux.conf')}) {
        {ok: true} => null
        {error: $failure} => {
            print -e $"tmux reload failed: ($failure.stderr | str trim)"
            exit 1
        }
    }
}
