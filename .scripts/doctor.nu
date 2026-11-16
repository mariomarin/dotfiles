#!/usr/bin/env nu
# Doctor: report only problems with actionable fixes

use adt.nu [run-cmd, collect-issues, report-issues, "result map", "result unwrap-or"]

# Missing command as {name, fix}, or null when it is on PATH
def check-cmd [cmd: string]: nothing -> oneof<record, nothing> {
    match (which $cmd | where type == external) {
        [] => {name: $cmd, fix: "install it or check PATH"}
        _ => null
    }
}

# The issue when the command is not on PATH, else null
def check-installed [cmd: string, issue: string]: nothing -> oneof<string, nothing> {
    if (which $cmd | is-empty) { $issue } else { null }
}

# The issue when the path does not exist, else null
def check-path [path: string, issue: string]: nothing -> oneof<string, nothing> {
    if ($path | path expand | path exists) { null } else { $issue }
}

def "main chezmoi" [] {
    null | collect-issues [
        {|| check-installed chezmoi "chezmoi not found — install chezmoi" }
    ] | report-issues chezmoi

    null | collect-issues [
        {|| check-path "~/.config/chezmoi/chezmoi.toml" "config missing — run: chezmoi init" }
        {||
            let pending = run-cmd { chezmoi status }
            | result map {|out| $out.stdout | str trim | lines | length }
            | result unwrap-or 0
            if $pending > 0 { $"($pending) files out of sync — run: chezmoi apply" }
        }
    ] | report-issues chezmoi
}

def "main nvim" [] {
    null | collect-issues [
        {|| check-installed nvim "nvim not found — install neovim" }
        {|| check-path "~/.config/nvim/init.lua" "config missing — run: chezmoi apply" }
        {|| check-path "~/.local/share/nvim/lazy" "no plugins — run: just nvim-sync" }
    ] | report-issues nvim
}

def "main tmux" [] {
    null | collect-issues [
        {|| check-installed tmux "tmux not found — install tmux" }
        {|| check-path "~/.config/tmux/tmux.conf" "config missing — run: chezmoi apply" }
        {|| check-path "~/.local/share/tmux/plugins" "plugins missing — run: chezmoi apply" }
    ] | report-issues tmux
}

# ZIM_HOME as dot_zshenv sets it; chezmoi deploys zimfw.zsh and zimrc there
def zim-home []: nothing -> string {
    $env.ZIM_HOME?
    | default ($env.XDG_CONFIG_HOME? | default "~/.config" | path join zim)
    | path expand
}

def zim-issues [zim_dir: path]: nothing -> list<string> {
    let modules_dir = $zim_dir | path join modules
    let installed = $zim_dir | path join zimfw.zsh | path exists
    null | collect-issues [
        {||
            if not $installed { "zimfw.zsh missing — run: chezmoi apply" }
        }
        {|| check-path ($zim_dir | path join zimrc) "zimrc missing — run: chezmoi apply" }
        {||
            let has_modules = ($modules_dir | path exists) and (ls $modules_dir | is-not-empty)
            if $installed and not $has_modules { "no modules — run: zsh -ic 'zimfw install'" }
        }
    ]
}

def "main zim" [] {
    zim-issues (zim-home) | report-issues zim
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

# Doctors that only make sense on the current OS
def platform-components []: nothing -> list<string> {
    match $nu.os-info.name {
        linux => ["nixos"]
        macos => ["darwin"]
        windows => ["wsl"]
        _ => []
    }
}

def "main all" [] {
    let components = (platform-components) ++ [
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

def main []: nothing -> nothing {
    main summary
}
