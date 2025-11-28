#!/usr/bin/env nu
# Full system health check

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
