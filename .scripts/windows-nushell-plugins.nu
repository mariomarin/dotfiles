#!/usr/bin/env nu
# Register nushell plugins (Windows): official plugins ship next to nu.exe,
# third-party ones are built with nupm (requires cargo)

def find-bundled [name: string] {
    let exe = $nu.current-exe | path dirname | path join $"($name).exe"
    if ($exe | path exists) { $exe } else { null }
}

def build-with-nupm [nupm: string, name: string] {
    if (which cargo | is-empty) {
        print -e $"skipping ($name): cargo not found"
        return
    }
    # Never wait on a hidden git credential prompt
    with-env {GIT_TERMINAL_PROMPT: "0"} {
        ^nu -c $"use ($nupm); nupm install ($name)"
    }
}

def main [] {
    let home = $env.HOME? | default $env.USERPROFILE?
    let nupm = $home | path join '.local' 'share' 'nupm' 'nupm'
    let plugins_file = $home | path join '.config' 'nushell' 'plugins.nuon'
    if not ($plugins_file | path exists) { return }

    let failures = open $plugins_file | each {|name|
        try {
            let bundled = find-bundled $name
            if ($bundled | is-not-empty) {
                plugin add $bundled
            } else if ($nupm | path exists) {
                build-with-nupm $nupm $name
            }
            null
        } catch { $name }
    } | compact

    if ($failures | is-not-empty) {
        error make {msg: $"plugins failed: ($failures | str join ', ')"}
    }
}
