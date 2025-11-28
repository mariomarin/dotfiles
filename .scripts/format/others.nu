#!/usr/bin/env nu
# Format JSON and TOML files with biome

print "📝 Formatting JSON and TOML files with biome..."
if (which biome | is-empty) {
    print "⚠️  biome not found. Run 'direnv allow' to load development environment"
    exit 0
}
biome format --write .
print "✅ JSON and TOML files formatted"
