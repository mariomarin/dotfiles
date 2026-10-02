#!/usr/bin/env nu
# Light ADT helpers - functional core for error handling

# Result type constructors
export def ok [value: any]: nothing -> record<ok: bool, value: any> {
  {ok: true, value: $value}
}

export def err [error: any]: nothing -> record<ok: bool, error: any> {
  {ok: false, error: $error}
}

# Result type predicates
export def is-ok []: record -> bool {
  $in.ok? == true
}

export def is-err []: record -> bool {
  not ($in | is-ok)
}

# Run command and return Result
export def run-cmd [cmd: closure]: nothing -> record<ok: bool> {
  let result = (do $cmd | complete)
  if $result.exit_code == 0 {
    ok {stdout: $result.stdout, stderr: $result.stderr}
  } else {
    err {stdout: $result.stdout, stderr: $result.stderr, code: $result.exit_code}
  }
}

# Result map - apply function to success value
export def "result map" [f: closure]: record -> record {
  if ($in | is-ok) {
    ok (do $f $in.value)
  } else {
    $in
  }
}

# Result unwrap with default
export def "result unwrap-or" [default: any]: record -> any {
  if ($in | is-ok) {$in.value} else {$default}
}

# --- Validation ADT - accumulates errors (unlike Result which short-circuits) ---

export def valid [value: any]: nothing -> record<valid: bool, value: any> {
  {valid: true, value: $value}
}

export def invalid [errors: list]: nothing -> record<valid: bool, errors: list> {
  {valid: false, errors: $errors}
}

export def is-valid []: record -> bool {
  $in.valid? == true
}

export def is-invalid []: record -> bool {
  not ($in | is-valid)
}

# Combine multiple validations - accumulates ALL errors
export def "validation combine" [validators: list<closure>]: any -> record {
  let val = $in
  let results = ($validators | each {|f| do $f $val})
  let all_errors = ($results
    | where {|r| $r | is-invalid}
    | get errors
    | flatten
  )

  if ($all_errors | is-empty) {
    valid $val
  } else {
    invalid $all_errors
  }
}

# Collect issues from multiple checks (returns list of issues)
export def collect-issues [checks: list<closure>]: any -> list {
  let val = $in
  $checks
  | each {|check| do $check $val}
  | flatten
  | where {|issue| $issue != null and ($issue | is-not-empty)}
}
