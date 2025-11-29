#!/usr/bin/env nu
# Install WSL2 (requires Administrator privileges)

# Check if WSL is already installed
let wsl_installed = (do { wsl --version } | complete | get exit_code) == 0
if $wsl_installed {
    print "✅ WSL2 is already installed"
    wsl --version
    exit 0
}

print "📦 Installing WSL2..."
print "⚠️  This requires Administrator privileges"
print "   You may be prompted for elevation"
print ""
wsl --install
print ""
print "✅ WSL2 installation started"
print "💡 You may need to restart your computer"
print "   After restart, run: just check-wsl"
