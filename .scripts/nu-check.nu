#!/usr/bin/env nu

# Pre-commit hook: validate Nushell scripts
# - .nu files: always checked
# - extensionless files: checked only if shebang contains nu

def is-nu-shebang [shebang: string]: nothing -> bool {
  ($shebang | str starts-with "#!") and ($shebang | str contains "nu")
}

def should-check [file: string, shebang: string]: nothing -> bool {
  ($file | str ends-with ".nu") or (is-nu-shebang $shebang)
}

def main [...files: string] {
  let failures = ($files | each {|f|
    let shebang = (open $f --raw | lines | first | default "")
    if not (should-check $f $shebang) { return null }

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
