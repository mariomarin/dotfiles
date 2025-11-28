#!/usr/bin/env nu
# Reload direnv environment (loads BW_SESSION from .envrc.local)

print "🔄 Reloading direnv environment..."
direnv allow
direnv reload
print "✅ Environment reloaded"
if ($env.BW_SESSION? | default "" | is-not-empty) {
    print "✅ BW_SESSION is loaded"
} else {
    print "⚠️  BW_SESSION not found in environment"
    print "   You may need to restart your shell or run: source .envrc.local"
}
