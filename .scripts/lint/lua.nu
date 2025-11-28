#!/usr/bin/env nu
# Check Lua files with stylua

print "🔍 Checking Lua files with stylua..."
if (which stylua | is-empty) {
    print "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"
    exit 0
}
cd private_dot_config/nvim
let result = (do { stylua --check . } | complete)
if $result.exit_code != 0 {
    print "❌ Lua files need formatting. Run 'just format-lua' to fix."
    exit 1
}
