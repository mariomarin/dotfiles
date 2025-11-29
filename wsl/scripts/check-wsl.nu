#!/usr/bin/env nu
# Check if WSL2 is installed

print "🔍 Checking WSL2 installation..."
let result = (do { wsl --version } | complete)
if $result.exit_code != 0 {
    print "❌ WSL is not installed"
    print "   Run: just install-wsl"
    exit 1
}
print $result.stdout
print "✅ WSL2 is installed"
