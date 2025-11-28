#!/usr/bin/env nu
# Check shell scripts with shellcheck

print "🔍 Checking shell scripts with shellcheck..."
if (which shellcheck | is-empty) {
    print "⚠️  shellcheck not found. Run 'devenv shell' or 'direnv allow' to load development environment"
    exit 0
}
let sh_files = (glob **/*.sh)
$sh_files | each {|file| shellcheck $file }
print "✅ Shell scripts valid"
