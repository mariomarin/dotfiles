#!/usr/bin/env nu
# Format YAML files with yamlfmt

print "📝 Formatting YAML files with yamlfmt..."
if (which yamlfmt | is-empty) {
    print "⚠️  yamlfmt not found. Run 'direnv allow' to load development environment"
    exit 0
}
glob **/*.{yml,yaml} | where {|f| $f !~ "/.git/" and $f !~ "/node_modules/" } | each {|file| yamlfmt $file }
print "✅ YAML files formatted"
