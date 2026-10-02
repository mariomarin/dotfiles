#!/usr/bin/env nu
# Reload tmux config if server is running

use adt.nu [run-cmd, is-ok, is-err]

def main [] {
    if (which tmux | is-empty) {exit 0}

    let server = (run-cmd {^tmux list-sessions})
    if ($server | is-err) {exit 0}

    let result = (run-cmd {^tmux source-file ~/.config/tmux/tmux.conf})
    if ($result | is-err) {
        print -e $"tmux reload failed: ($result.error.stderr)"
        exit 1
    }
}
