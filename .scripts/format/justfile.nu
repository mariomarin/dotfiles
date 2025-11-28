#!/usr/bin/env nu
# Format justfiles

print "📝 Formatting justfiles..."
if (which just | is-empty) {
    print "⚠️  just not found"
    exit 0
}
glob **/justfile | each {|file| cd ($file | path dirname); just --fmt --unstable }
print "✅ Justfiles formatted"
