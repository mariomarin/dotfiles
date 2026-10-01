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

def "test into-utf8 decodes binary multibyte" [] {
    let result = do {
        nu -n -c "source private_dot_local/bin/executable_clip; ('café ☕ 中文 🎉' | into binary) | into-utf8"
    } | complete
    assert equal ($result.stdout | str trim) "café ☕ 中文 🎉"
}

def "test into-utf8 passes strings through" [] {
    let result = do {
        nu -n -c "source private_dot_local/bin/executable_clip; ('résumé' | into-utf8)"
    } | complete
    assert equal ($result.stdout | str trim) "résumé"
}

def "test into-utf8 handles empty input" [] {
    let result = do {
        nu -n -c "source private_dot_local/bin/executable_clip; (null | into-utf8)"
    } | complete
    assert equal $result.exit_code 0
    assert equal ($result.stdout | str trim) ""
}

def "test read-file preserves utf-8" [] {
    let tmp = (mktemp -t "clip-utf8-XXXXXX")
    "naïve — 你好 🚀" | save --force --raw $tmp
    let result = do {
        nu -n -c $"source private_dot_local/bin/executable_clip; read-file '($tmp)'"
    } | complete
    rm --force $tmp
    assert equal ($result.stdout | str trim) "naïve — 你好 🚀"
}
