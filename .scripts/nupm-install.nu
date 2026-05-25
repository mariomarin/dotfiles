#!/usr/bin/env nu
# Install nupm modules

def install-module [nupm_path: string, module_path: string, name: string] {
  let result = do { ^nu -c $"use ($nupm_path); nupm install --path ($module_path) --force" } | complete
  if $result.exit_code != 0 { print -e $"failed: ($name)" }
  $result.exit_code == 0
}

def main [] {
  let home = ($env.HOME? | default $env.USERPROFILE?)
  let modules_dir = ($home | path join '.config' 'nushell' 'modules')
  let nupm_path = ($home | path join '.local' 'share' 'nupm' 'nupm')

  if not ($nupm_path | path exists) { exit 0 }

  # Registry packages
  do { ^nu -c $"use ($nupm_path); nupm install nu-scripts" } | complete | ignore

  # Local modules
  let local_modules = ["bitwarden" "claude-helpers" "sesh"]

  let failures = ($local_modules | each {|module|
    let path = ($modules_dir | path join $module)
    if not ($path | path exists) { return null }
    if (install-module $nupm_path $path $module) { null } else { $module }
  } | where {|r| $r != null })

  if ($failures | is-not-empty) {
    error make { msg: $"modules failed: ($failures | str join ', ')" }
  }
}
