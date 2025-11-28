#!/usr/bin/env nu
# Check Nix files syntax

print "🔍 Checking Nix files syntax..."
let nix_files = (glob **/*.nix)
let result = ($nix_files | each {|file| do { nix-instantiate --parse $file } | complete } | all {|r| $r.exit_code == 0 })
if $result {
    print "✅ Nix syntax valid"
} else {
    print "❌ Nix syntax errors found"
    exit 1
}
