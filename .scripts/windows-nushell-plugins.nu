#!/usr/bin/env nu
# Register nushell plugins (Windows): official plugins ship next to nu.exe,
# third-party ones are built with nupm (requires cargo)

# Path of a plugin bundled with nu, or empty string if not bundled
def find-bundled [name: string]: nothing -> string {
    let exe = $nu.current-exe | path dirname | path join $"($name).exe"
    if ($exe | path exists) { $exe } else { "" }
}

def build-with-nupm [nupm: string, name: string]: nothing -> record<ok: bool, error: string> {
    if not ($nupm | path exists) { return {ok: false, error: "nupm not found"} }
    if (which cargo | is-empty) { return {ok: false, error: "cargo not found"} }
    # Never wait on a hidden git credential prompt
    try {
        with-env {GIT_TERMINAL_PROMPT: "0"} { ^nu -c $"use ($nupm); nupm install ($name)" }
        {ok: true, error: ""}
    } catch {|e| {ok: false, error: $e.msg} }
}

def install-plugin [nupm: string, name: string]: nothing -> record<ok: bool, error: string> {
    let bundled = find-bundled $name
    if ($bundled | is-empty) { return (build-with-nupm $nupm $name) }
    try {
        plugin add $bundled
        {ok: true, error: ""}
    } catch {|e| {ok: false, error: $e.msg} }
}

def main []: nothing -> nothing {
    let home = $env.HOME? | default $env.USERPROFILE
    let nupm = $home | path join .local share nupm nupm
    let plugins_file = $home | path join .config nushell plugins.nuon
    if not ($plugins_file | path exists) { return }

    let plugins = try { open $plugins_file } catch {|e|
        print -e $"cannot read ($plugins_file): ($e.msg)"
        exit 1
    }

    let failures = $plugins
        | each {|name| install-plugin $nupm $name | insert name $name }
        | where not ok

    if ($failures | is-empty) { return }
    $failures | each {|f| print -e $"($f.name): ($f.error)" } | ignore
    exit 1
}
