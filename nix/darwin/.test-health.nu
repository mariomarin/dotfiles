#!/usr/bin/env nu
# Test script for darwin health check

print "🔍 nix-darwin Health Check"
print "=========================="
let hostname_result = (do { scutil --get LocalHostName } | complete)
let hostname = if $hostname_result.exit_code == 0 { $hostname_result.stdout | str trim } else { "unknown" }
print $"✓ Hostname: ($hostname)"
let macos_result = (do { sw_vers -productVersion } | complete)
let macos = if $macos_result.exit_code == 0 { $macos_result.stdout | str trim } else { "unknown" }
print $"✓ macOS version: ($macos)"
let arch_result = (do { uname -m } | complete)
let arch = if $arch_result.exit_code == 0 { $arch_result.stdout | str trim } else { "unknown" }
print $"✓ Architecture: ($arch)"
let nix_result = (do { nix --version } | complete)
let nix_version = if $nix_result.exit_code == 0 { $nix_result.stdout | str trim } else { "not installed" }
print $"✓ Nix version: ($nix_version)"
let darwin_rebuild_exists = (which darwin-rebuild | is-not-empty)
print $"✓ darwin-rebuild: (if $darwin_rebuild_exists { 'installed' } else { '❌ not installed' })"
let flake_path = "../nixos/flake.nix"
let flake_exists = ($flake_path | path exists)
print $"✓ Flake exists: (if $flake_exists { 'yes' } else { '❌ no' })"
let config_dir = ("/etc/nix-darwin" | path exists)
print $"✓ nix-darwin config: (if $config_dir { 'installed' } else { 'not installed (run: just first-time)' })"
print ""
