#!/usr/bin/env nu

# Pre-commit hook: syntax-validate Nushell scripts
# - .nu files: always checked
# - extensionless files: checked only if shebang invokes nu

def is-nu-shebang [shebang: string]: nothing -> bool {
  if not ($shebang | str starts-with "#!") {
    return false
  }

  let line = ($shebang | str trim)

  (
    ($line | str contains "/env nu") or
    ($line | str ends-with "/nu") or
    ($line | str contains "/nu ") or
    ($line | str contains " nu ") or
    ($line | str ends-with " nu")
  )
}

def should-check [file: string, shebang: string]: nothing -> bool {
  ($file | str ends-with ".nu") or (is-nu-shebang $shebang)
}

def main [...files: string] {
  let failures = (
    $files
    | each {|f|
        let shebang = (
          try {
            open $f --raw | lines | first | default ""
          } catch {
            ""
          }
        )

        if not (should-check $f $shebang) {
          return null
        }

        let result = (do { nu-check --debug $f } | complete)

        if $result.exit_code != 0 {
          print $"FAIL: ($f)"
          if not ($result.stderr | is-empty) {
            print $result.stderr
          }
          return $f
        }

        null
      }
    | where {|it| $it != null }
  )

  if not ($failures | is-empty) {
    error make {
      msg: $"($failures | length) file\(s\) failed nushell-check"
    }
  }
}
