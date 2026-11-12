#!/usr/bin/env nu
# Register nushell plugins (Windows): official plugins ship next to nu.exe,
# third-party ones are built with nupm (requires cargo)

# What the machine offers for installing a plugin (reads filesystem/PATH)
def gather-facts [name: string, nupm: string]: nothing -> record {
    let exe = $nu.current-exe | path dirname | path join $"($name).exe"
    {
        name: $name
        bundled: (if ($exe | path exists) { $exe } else { "" })
        nupm: (if ($nupm | path exists) { $nupm } else { "" })
        has_cargo: (which cargo | is-not-empty)
    }
}

# Decide how to install a plugin (pure). detail: exe path, nupm path or skip reason
def plan [facts: record]: nothing -> record<name: string, action: string, detail: string> {
    let step = {name: $facts.name}
    if ($facts.bundled | is-not-empty) { return ($step | merge {action: "register", detail: $facts.bundled}) }
    if ($facts.nupm | is-empty) { return ($step | merge {action: "skip", detail: "nupm not found"}) }
    if not $facts.has_cargo { return ($step | merge {action: "skip", detail: "cargo not found"}) }
    $step | merge {action: "build", detail: $facts.nupm}
}

def attempt [name: string, action: closure]: nothing -> record<name: string, ok: bool, error: string> {
    try {
        do $action
        {name: $name, ok: true, error: ""}
    } catch {|e| {name: $name, ok: false, error: $e.msg} }
}

def execute [step: record]: nothing -> record<name: string, ok: bool, error: string> {
    match $step.action {
        "register" => (attempt $step.name { plugin add $step.detail })
        # Never wait on a hidden git credential prompt
        "build" => (attempt $step.name {
            with-env {GIT_TERMINAL_PROMPT: "0"} { nu -c $"use ($step.detail); nupm install ($step.name)" }
        })
        _ => {name: $step.name, ok: true, error: ""}
    }
}

def main []: nothing -> nothing {
    let home = $env.HOME? | default $env.USERPROFILE
    let nupm = $home | path join .local share nupm nupm
    let plugins_file = $home | path join .config nushell plugins.nuon
    if not ($plugins_file | path exists) { return }

    let plugins = try { open $plugins_file } catch {|e|
        print --stderr $"cannot read ($plugins_file): ($e.msg)"
        exit 1
    }

    let steps = $plugins | each {|name| plan (gather-facts $name $nupm) }
    for s in ($steps | where action == "skip") { print --stderr $"skipping ($s.name): ($s.detail)" }

    let failures = $steps | where action != "skip" | each {|s| execute $s } | where not ok
    if ($failures | is-empty) { return }
    for f in $failures { print --stderr $"($f.name): ($f.error)" }
    exit 1
}
