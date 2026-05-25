#!/usr/bin/env nu
# Install packages from winget DSC configuration (Windows)

def main [] {
  if (which winget | is-empty) {
    error make { msg: "winget not found" }
  }

  let config_file = ($env.USERPROFILE | path join ".config" "winget" "configuration.dsc.yaml")
  if not ($config_file | path exists) {
    error make { msg: $"config not found: ($config_file)" }
  }

  let result = do { winget configure --file $config_file --accept-configuration-agreements --disable-interactivity } | complete
  if $result.exit_code != 0 {
    if ($result.stdout | is-not-empty) { print -e $result.stdout }
    if ($result.stderr | is-not-empty) { print -e $result.stderr }
    exit $result.exit_code
  }
}
