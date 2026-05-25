#!/usr/bin/env nu
# Reload tmux config if server is running

def main [] {
  if (which tmux | is-empty) { exit 0 }

  let server = (do { ^tmux list-sessions } | complete)
  if $server.exit_code != 0 { exit 0 }

  let result = (do { ^tmux source-file ~/.config/tmux/tmux.conf } | complete)
  if $result.exit_code != 0 {
    print -e $"tmux reload failed: ($result.stderr)"
    exit 1
  }
}
