#!/usr/bin/env nu

# Pre-commit hook: validate/lint Nushell scripts
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

def check-file [file: string]: nothing -> record<file: string, ok: bool, stage: string, stderr: string> {
  let parse_result = (do {
    nu-check --debug $file
  } | complete)

  if $parse_result.exit_code != 0 {
    return {
      file: $file
      ok: false
      stage: "nu-check"
      stderr: $parse_result.stderr
    }
  }

  let lint_result = (do {
    nu-lint $file
  } | complete)

  if $lint_result.exit_code != 0 {
    return {
      file: $file
      ok: false
      stage: "nu-lint"
      stderr: $lint_result.stderr
    }
  }

  {
    file: $file
    ok: true
    stage: ""
    stderr: ""
  }
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

        let result = (check-file $f)

        if not $result.ok {
          print $"FAIL: ($result.file) [($result.stage)]"
          if not ($result.stderr | is-empty) {
            print $result.stderr
          }
          return $result
        }

        null
      }
    | where {|it| $it != null }
  )

  if not ($failures | is-empty) {
    error make {
      msg: $"($failures | length) file\(s\) failed Nushell validation/linting"
    }
  }
}
