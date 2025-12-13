#!/usr/bin/env nu
# Health check utilities

# Get version from command (returns null on failure)
def get-version [cmd: string, parser: closure] {
    let result = do { nu -c $cmd } | complete
    if $result.exit_code != 0 { return null }
    do $parser $result.stdout
}

# System health summary
def "main summary" [] {
    print "🏥 System Health Summary"
    print "========================"
    print ""
    print "🔍 Quick Status:"

    let nixos = get-version "nixos-version" { $in | lines | first | split row ' ' | first 2 | str join ' ' } | default "❌ not available"
    let chezmoi = get-version "chezmoi --version" { $in | lines | first | split row ',' | first } | default "❌ not installed"
    let nvim = get-version "nvim --version" { $in | lines | first } | default "❌ not installed"
    let tmux = get-version "tmux -V" { $in | str trim } | default "❌ not installed"
    let zsh = get-version "zsh --version" { $in | lines | first } | default "❌ not installed"

    print $"  NixOS:   ($nixos)"
    print $"  Chezmoi: ($chezmoi)"
    print $"  Neovim:  ($nvim)"
    print $"  Tmux:    ($tmux)"
    print $"  Zsh:     ($zsh)"
}

# Full system health check
def "main all" [] {
    print "🏥 Full System Health Check"
    print "==========================="
    print ""
    do { just nixos-health } | complete | ignore
    print ""
    do { just chezmoi-health } | complete | ignore
    print ""
    do { just nvim-health } | complete | ignore
    print ""
    do { just tmux-health } | complete | ignore
    print ""
    do { just zim-health } | complete | ignore
}

# Show help
def "main help" [] {
    print "Health Check Utilities"
    print "======================"
    print ""
    print "Usage: nu health.nu <command>"
    print ""
    print "Commands:"
    print "  summary   Show quick system health summary"
    print "  all       Run full system health check"
    print "  help      Show this help message"
}

def main [] {
    main summary
}
