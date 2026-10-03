#!/usr/bin/env nu
# ADT-based error handling.
# - Result: railway-oriented — flat-map/map/bimap short-circuit on err.
# - Validation: applicative — combine/collect-issues accumulate all errors.
# - Either: bare left/right tags.

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

# Result flatMap - chain computations that may fail
export def "result flat-map" [f: closure]: record -> record {
  if ($in | is-ok) {
    do $f $in.value
  } else {
    $in
  }
}

# Result bimap - transform both success and error
export def "result bimap" [
  on_ok: closure
  on_err: closure
]: record -> record {
  if ($in | is-ok) {
    ok (do $on_ok $in.value)
  } else {
    err (do $on_err $in.error)
  }
}

# Sequence a list of Results - fails if any fail
export def "result sequence" []: list<record> -> record {
  let results = $in
  let errors = ($results | where {|r| $r | is-err})

  if ($errors | is-not-empty) {
    err ($errors | get error)
  } else {
    ok ($results | get value)
  }
}

# Try a computation, catching errors as Result
export def "result try" [f: closure]: any -> record {
  let input = $in
  try {
    ok (do $f $input)
  } catch {|e|
    err $e
  }
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

# Validation map - transform valid value
export def "validation map" [f: closure]: record -> record {
  if ($in | is-valid) {
    valid (do $f $in.value)
  } else {
    $in
  }
}

# Validation recover - provide fallback for invalid
export def "validation recover" [default: any]: record -> any {
  if ($in | is-valid) {$in.value} else {$default}
}

# Either type helpers (for more explicit left/right semantics)
export def left [value: any]: nothing -> record<tag: string, value: any> {
  {tag: "left", value: $value}
}

export def right [value: any]: nothing -> record<tag: string, value: any> {
  {tag: "right", value: $value}
}

export def is-left []: record -> bool {
  ($in.tag? == "left")
}

export def is-right []: record -> bool {
  ($in.tag? == "right")
}
