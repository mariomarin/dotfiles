#!/usr/bin/env nu
# Format shell scripts with shfmt

print "📝 Formatting shell scripts with shfmt..."
if (which shfmt | is-empty) {
    print "⚠️  shfmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"
    exit 0
}
shfmt -w -i 2 -ci -sr -kp .
print "✅ Shell scripts formatted"
