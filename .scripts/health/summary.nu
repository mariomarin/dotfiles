#!/usr/bin/env nu
# System health summary

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
