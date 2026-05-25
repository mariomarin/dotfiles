#!/usr/bin/env nu
# Install nushell plugins via nupm registry (Windows)

def main [] {
  let home = ($env.HOME? | default $env.USERPROFILE?)
  let nupm_path = ($home | path join '.local' 'share' 'nupm' 'nupm')
  let plugins_file = ($home | path join '.config' 'nushell' 'plugins.nuon')

  if not ($nupm_path | path exists) { exit 0 }
  if not ($plugins_file | path exists) { exit 0 }

  let plugins = open $plugins_file

  let failures = ($plugins | each {|plugin|
    let result = do { ^nu -c $"use ($nupm_path); nupm install ($plugin)" } | complete
    if $result.exit_code != 0 { $plugin } else { null }
  } | where {|r| $r != null })

  if ($failures | is-not-empty) {
    error make { msg: $"plugins failed: ($failures | str join ', ')" }
  }
}
