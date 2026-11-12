# Tests for the pure planning step of windows-nushell-plugins.nu
use std/assert
use ../windows-nushell-plugins.nu plan

def run-plan [facts: record]: nothing -> record {
    plan ({name: nu_plugin_x, bundled: "", has_cargo: false} | merge $facts)
}

def "test bundled plugin is registered even without cargo" []: nothing -> nothing {
    let step = run-plan {bundled: /nu/nu_plugin_x.exe}
    assert equal $step {name: nu_plugin_x, action: register, detail: /nu/nu_plugin_x.exe}
}

def "test missing cargo skips" []: nothing -> nothing {
    let step = run-plan {}
    assert equal $step {name: nu_plugin_x, action: skip, detail: "cargo not found"}
}

def "test cargo builds unbundled plugin" []: nothing -> nothing {
    let step = run-plan {has_cargo: true}
    assert equal $step {name: nu_plugin_x, action: build, detail: ""}
}
