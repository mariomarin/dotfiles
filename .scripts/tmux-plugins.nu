#!/usr/bin/env nu
# Install TPM plugins

def main [] {
  let home = ($env.HOME? | default $env.USERPROFILE?)
  let plugin_path = ($home | path join '.local' 'share' 'tmux' 'plugins')
  let tpm_dir = ($plugin_path | path join 'tpm')
  let install_script = ($tpm_dir | path join 'bin' 'install_plugins')

  if (which tmux | is-empty) { exit 0 }
  if not ($install_script | path exists) { exit 0 }

  let result = with-env { TMUX_PLUGIN_MANAGER_PATH: $plugin_path } {
    do { ^$install_script } | complete
  }

  if $result.exit_code == 0 { return }

  let expected = ($result.stderr | str contains "Tmux Plugin Manager not configured") or ($result.stderr | str contains "Unknown variable")
  if $expected { exit 0 }

  print -e $result.stderr
  exit $result.exit_code
}
