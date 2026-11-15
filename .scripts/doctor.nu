#!/usr/bin/env nu
# Doctor: report only problems with actionable fixes

use adt.nu [run-cmd]

# Missing command as {name, fix}, or null when it is on PATH
def check-cmd [cmd: string]: nothing -> any {
    match (which $cmd | where type == external) {
        [] => {name: $cmd, fix: "install it or check PATH"}
        _ => null
    }
}

# Print the component's issues and fail; silent when there are none
def report [name: string, issues: list<string>]: nothing -> nothing {
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
    report chezmoi ([(check-installed chezmoi "chezmoi not found — install chezmoi")] | compact)

    let status = do { chezmoi status } | complete
    let pending = if $status.exit_code == 0 { $status.stdout | str trim | lines | length } else { 0 }
    report chezmoi ([
        (check-path "~/.config/chezmoi/chezmoi.toml" "config missing — run: chezmoi init")
        (if $pending > 0 { $"($pending) files out of sync — run: chezmoi apply" })
    ] | compact)
}

def "main nvim" [] {
    report nvim ([
        (check-installed nvim "nvim not found — install neovim")
        (check-path "~/.config/nvim/init.lua" "config missing — run: chezmoi apply")
        (check-path "~/.local/share/nvim/lazy" "no plugins — run: just nvim-sync")
    ] | compact)
}

def "main tmux" [] {
    report tmux ([
        (check-installed tmux "tmux not found — install tmux")
        (check-path "~/.config/tmux/tmux.conf" "config missing — run: chezmoi apply")
        (check-path "~/.local/share/tmux/plugins" "plugins missing — run: chezmoi apply")
    ] | compact)
}

def "main zim" [] {
    let zim_dir = "~/.zim" | path expand
    let modules_dir = $zim_dir | path join modules
    let installed = $zim_dir | path exists
    let no_modules = $installed and ((not ($modules_dir | path exists)) or (ls $modules_dir | is-empty))
    report zim ([
        (if not $installed { "zim not installed — run: curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh" })
        (check-path "~/.config/zim/zimrc" "zimrc missing — run: chezmoi apply")
        (if $no_modules { "no modules — run: zsh -c 'source ~/.zim/zimfw.zsh && zimfw install'" })
    ] | compact)
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
    let failures = ($components | each {|c|
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
