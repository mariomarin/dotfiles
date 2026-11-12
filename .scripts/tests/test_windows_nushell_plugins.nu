# Tests for the pure planning step of windows-nushell-plugins.nu
use std/assert
source ../windows-nushell-plugins.nu

def run-plan [facts: record]: nothing -> record {
    plan ({name: nu_plugin_x, bundled: "", nupm: "", has_cargo: false} | merge $facts)
}

def "test bundled plugin is registered even without nupm or cargo" []: nothing -> nothing {
    let step = run-plan {bundled: 'C:\nu\nu_plugin_x.exe'}
    assert equal $step {name: nu_plugin_x, action: register, detail: 'C:\nu\nu_plugin_x.exe'}
}

def "test missing nupm skips" []: nothing -> nothing {
    let step = run-plan {has_cargo: true}
    assert equal $step {name: nu_plugin_x, action: skip, detail: "nupm not found"}
}

def "test missing cargo skips" []: nothing -> nothing {
    let step = run-plan {nupm: /nupm}
    assert equal $step {name: nu_plugin_x, action: skip, detail: "cargo not found"}
}

def "test nupm and cargo build with nupm path" []: nothing -> nothing {
    let step = run-plan {nupm: /nupm, has_cargo: true}
    assert equal $step {name: nu_plugin_x, action: build, detail: /nupm}
}
