#!/usr/bin/env nu

# Pre-commit hook: validate Nushell scripts
# - .nu files: always checked
# - extensionless files: checked only if shebang contains nu

def main [...files: string] {
  let failures = ($files | each {|f|
    if not ($f | str ends-with ".nu") {
      let shebang = (open $f --raw | lines | first | default "")
      if not ($shebang | str starts-with "#!") or not ($shebang | str contains "nu") {
        return null
      }
    }

    let result = (do { nu -n -c $"source \"($f)\"" } | complete)
    if $result.exit_code != 0 {
      print $"FAIL: ($f)"
      print $result.stderr
      return $f
    }
    null
  } | where {|it| $it != null })

  if not ($failures | is-empty) {
    error make { msg: $"($failures | length) file\(s\) failed nushell-check" }
  }
}
