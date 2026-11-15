#!/usr/bin/env nu
# Doctor: report only problems with actionable fixes

use adt.nu [run-cmd, collect-issues, "result map", "result unwrap-or"]

# Missing command as {name, fix}, or null when it is on PATH
def check-cmd [cmd: string]: nothing -> any {
    match (which $cmd | where type == external) {
        [] => {name: $cmd, fix: "install it or check PATH"}
        _ => null
    }
}

# Print the component's issues and fail; silent when there are none
def report [name: string]: list<any> -> nothing {
    let issues = $in
    if ($issues | is-empty) { return }
    print $"($name):"
    $issues | each {|i| print $"  ($i)" } | ignore
    exit 1
}

# The issue when the command is not on PATH, else null
def check-installed [cmd: string, issue: string]: nothing -> any {
    if (which $cmd | is-empty) { $issue } else { null }
}

# The issue when the path does not exist, else null
def check-path [path: string, issue: string]: nothing -> any {
    if ($path | path expand | path exists) { null } else { $issue }
}

def "main chezmoi" [] {
    null | collect-issues [
        {|| check-installed chezmoi "chezmoi not found — install chezmoi" }
    ] | report chezmoi

    null | collect-issues [
        {|| check-path "~/.config/chezmoi/chezmoi.toml" "config missing — run: chezmoi init" }
        {||
            let pending = run-cmd { chezmoi status }
            | result map {|out| $out.stdout | str trim | lines | length }
            | result unwrap-or 0
            if $pending > 0 { $"($pending) files out of sync — run: chezmoi apply" }
        }
    ] | report chezmoi
}

def "main nvim" [] {
    null | collect-issues [
        {|| check-installed nvim "nvim not found — install neovim" }
        {|| check-path "~/.config/nvim/init.lua" "config missing — run: chezmoi apply" }
        {|| check-path "~/.local/share/nvim/lazy" "no plugins — run: just nvim-sync" }
    ] | report nvim
}

def "main tmux" [] {
    null | collect-issues [
        {|| check-installed tmux "tmux not found — install tmux" }
        {|| check-path "~/.config/tmux/tmux.conf" "config missing — run: chezmoi apply" }
        {|| check-path "~/.local/share/tmux/plugins" "plugins missing — run: chezmoi apply" }
    ] | report tmux
}

def "main zim" [] {
    let zim_dir = "~/.zim" | path expand
    let modules_dir = $zim_dir | path join modules
    let installed = $zim_dir | path exists
    null | collect-issues [
        {|| if not $installed { "zim not installed — run: curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh" } }
        {|| check-path "~/.config/zim/zimrc" "zimrc missing — run: chezmoi apply" }
        {||
            let has_modules = ($modules_dir | path exists) and (ls $modules_dir | is-not-empty)
            if $installed and not $has_modules { "no modules — run: zsh -c 'source ~/.zim/zimfw.zsh && zimfw install'" }
        }
    ] | report zim
}

def "main summary" [] {
    let issues = (
        ["chezmoi" "nvim" "tmux" "zsh" "nu"]
        | each {|cmd| check-cmd $cmd }
        | where {|r| $r != null }
    )

    if ($issues | is-empty) { return }

    $issues | each {|i| print $"  missing: ($i.name) — ($i.fix)" } | ignore
    exit 1
}

def "main all" [] {
    let components = [
        "nixos"
        "chezmoi"
        "nvim"
        "tmux"
        "zim"
        "kanata"
        "atuin"
    ]
    let failures = ($components | par-each {|c|
        match (run-cmd { ^just $"($c)-doctor" }) {
            {ok: true} => null
            {error: $failure} => {
                let out = $failure.stdout | str trim
                if ($out | is-not-empty) { print $out }
                $c
            }
        }
    } | compact)

    if ($failures | is-empty) {
        print "All good."
        return
    }

    exit 1
}

def main [] {
    main summary
}
