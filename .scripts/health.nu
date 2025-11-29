#!/usr/bin/env nu
# Health check utilities

# System health summary
def "main summary" [] {
    print "🏥 System Health Summary"
    print "========================"
    print ""
    print "🔍 Quick Status:"
    let nixos_result = (do { nixos-version } | complete)
    let nixos = if $nixos_result.exit_code == 0 { $nixos_result.stdout | lines | first | split row ' ' | first 2 | str join ' ' } else { '❌ not available' }
    let chezmoi_result = (do { chezmoi --version } | complete)
    let chezmoi = if $chezmoi_result.exit_code == 0 { $chezmoi_result.stdout | lines | first | split row ',' | first } else { '❌ not installed' }
    let nvim_result = (do { nvim --version } | complete)
    let nvim = if $nvim_result.exit_code == 0 { $nvim_result.stdout | lines | first } else { '❌ not installed' }
    let tmux_result = (do { tmux -V } | complete)
    let tmux = if $tmux_result.exit_code == 0 { $tmux_result.stdout | str trim } else { '❌ not installed' }
    let zsh_result = (do { zsh --version } | complete)
    let zsh = if $zsh_result.exit_code == 0 { $zsh_result.stdout | lines | first } else { '❌ not installed' }
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
