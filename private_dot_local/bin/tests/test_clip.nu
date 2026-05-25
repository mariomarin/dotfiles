# Tests for clip (clipboard helper)
use std/assert

const SCRIPT = "private_dot_local/bin/executable_clip"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test select-backend ssh takes priority" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_clip; select-backend {ssh: true, macos: true, wsl: false, has_xclip: false, has_wl_copy: false}'
    } | complete
    assert equal ($result.stdout | str trim) "ssh"
}

def "test select-backend macos" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_clip; select-backend {ssh: false, macos: true, wsl: false, has_xclip: false, has_wl_copy: false}'
    } | complete
    assert equal ($result.stdout | str trim) "pbcopy"
}

def "test select-backend wsl" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_clip; select-backend {ssh: false, macos: false, wsl: true, has_xclip: true, has_wl_copy: false}'
    } | complete
    assert equal ($result.stdout | str trim) "clip.exe"
}

def "test select-backend xclip" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_clip; select-backend {ssh: false, macos: false, wsl: false, has_xclip: true, has_wl_copy: true}'
    } | complete
    assert equal ($result.stdout | str trim) "xclip"
}

def "test select-backend wl-copy" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_clip; select-backend {ssh: false, macos: false, wsl: false, has_xclip: false, has_wl_copy: true}'
    } | complete
    assert equal ($result.stdout | str trim) "wl-copy"
}

def "test select-backend none" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_clip; select-backend {ssh: false, macos: false, wsl: false, has_xclip: false, has_wl_copy: false}'
    } | complete
    assert equal ($result.stdout | str trim) "none"
}
