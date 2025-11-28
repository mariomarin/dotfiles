#!/usr/bin/env nu
# Format Lua files with stylua

print "📝 Formatting Lua files with stylua..."
if (which stylua | is-empty) {
    print "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"
    exit 0
}
cd private_dot_config/nvim
stylua .
print "✅ Lua files formatted"
