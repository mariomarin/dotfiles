# Tests for post-commit-apply.nu
use std/assert

const SCRIPT = ".scripts/post-commit-apply.nu"

def applied [paths: list<string>]: nothing -> list<bool> {
    let result = do {
        ^$nu.current-exe -n -c $"source ($SCRIPT); ($paths | to nuon) | each {|p| is-applied $p } | to nuon"
    } | complete
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

def "test script parses" []: nothing -> nothing {
    do { ^$nu.current-exe -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test repo-only paths are not applied" []: nothing -> nothing {
    let paths = [
        "docs/keybindings.md"
        ".github/workflows/validate.yml"
        ".scripts/tests/test_doctor.nu"
        "nix/README.md"
        "private_dot_config/nvim/CLAUDE.md"
        ".chezmoiscripts_CLAUDE.md"
        "README.md"
        "devenv.nix"
    ]
    assert equal (applied $paths) ($paths | each { false })
}

def "test dotfiles, scripts and nix sources are applied" []: nothing -> nothing {
    let paths = [
        "private_dot_config/tmux/tmux.conf"
        "private_dot_config/nvim/README.md"
        ".scripts/reload-services.nu"
        ".chezmoiscripts/run_onchange_nixos-rebuild.nu.tmpl"
        "nix/nixos/flake.lock"
        "nix/common/modules/tmux.nix"
        ".chezmoidata/services.yaml"
    ]
    assert equal (applied $paths) ($paths | each { true })
}
