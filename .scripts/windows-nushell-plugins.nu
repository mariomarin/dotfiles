#!/usr/bin/env nu
# Register nushell plugins (Windows): official plugins ship next to nu.exe,
# third-party ones are built with cargo install

# What the machine offers for installing a plugin (reads filesystem/PATH)
def gather-facts [name: string]: nothing -> record<name: string, bundled: string, has_cargo: bool> {
    let exe = $nu.current-exe | path dirname | path join $"($name).exe"
    {
        name: $name
        bundled: (if ($exe | path exists) { $exe } else { "" })
        has_cargo: (which cargo | is-not-empty)
    }
}

# Decide how to install a plugin (pure). detail: exe path or skip reason
export def plan [facts: record]: nothing -> record<name: string, action: string, detail: string> {
    if ($facts.bundled | is-not-empty) {
        return {name: $facts.name, action: register, detail: $facts.bundled}
    }
    if not $facts.has_cargo {
        return {name: $facts.name, action: skip, detail: "cargo not found"}
    }
    {name: $facts.name, action: build, detail: ""}
}

def attempt [name: string, action: closure]: nothing -> record<name: string, ok: bool, error: string> {
    try {
        do $action
        {name: $name, ok: true, error: ""}
    } catch {|e| {name: $name, ok: false, error: $e.msg} }
}

def cargo-install [name: string]: nothing -> nothing {
    cargo install --locked $name
    plugin add ($env.CARGO_HOME? | default ($nu.home-dir | path join .cargo) | path join bin $"($name).exe")
}

def execute [step: record]: nothing -> record<name: string, ok: bool, error: string> {
    match $step.action {
        register => (attempt $step.name { plugin add $step.detail })
        build => (attempt $step.name { cargo-install $step.name })
        _ => {name: $step.name, ok: true, error: ""}
    }
}

def main []: nothing -> nothing {
    let plugins_file = $nu.home-dir | path join .config nushell plugins.nuon
    if not ($plugins_file | path exists) { return }

    let plugins = try { open $plugins_file } catch {|e|
        print --stderr $"cannot read ($plugins_file): ($e.msg)"
        exit 1
    }

    let steps = $plugins | each {|name| plan (gather-facts $name) }
    for s in ($steps | where action == skip) { print --stderr $"skipping ($s.name): ($s.detail)" }

    let failures = $steps | where action != skip | each {|s| execute $s } | where not ok
    if ($failures | is-empty) { return }
    for f in $failures { print --stderr $"($f.name): ($f.error)" }
    exit 1
}
