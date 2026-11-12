# Tests for the pure planning step of windows-nushell-plugins.nu
use std/assert

const SCRIPT = ".scripts/windows-nushell-plugins.nu"

def run-plan [facts: record]: nothing -> record {
    let base = {name: "nu_plugin_x", bundled: "", nupm: "", has_cargo: false}
    nu -n -c $"source ($SCRIPT); plan ($base | merge $facts | to nuon) | to nuon" | from nuon
}

def "test bundled plugin is registered even without nupm or cargo" [] {
    let step = run-plan {bundled: 'C:\nu\nu_plugin_x.exe'}
    assert equal $step {name: "nu_plugin_x", action: "register", detail: 'C:\nu\nu_plugin_x.exe'}
}

def "test missing nupm skips" [] {
    let step = run-plan {has_cargo: true}
    assert equal $step.action "skip"
    assert equal $step.detail "nupm not found"
}

def "test missing cargo skips" [] {
    let step = run-plan {nupm: "/nupm"}
    assert equal $step.action "skip"
    assert equal $step.detail "cargo not found"
}

def "test nupm and cargo build with nupm path" [] {
    let step = run-plan {nupm: "/nupm", has_cargo: true}
    assert equal $step {name: "nu_plugin_x", action: "build", detail: "/nupm"}
}
