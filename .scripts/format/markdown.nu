#!/usr/bin/env nu
# Format Markdown files with markdownlint

print "📝 Formatting Markdown files with markdownlint..."
if (which markdownlint | is-empty) {
    print "⚠️  markdownlint not found. Run 'direnv allow' to load development environment"
    exit 0
}
do { markdownlint --fix "**/*.md" --ignore node_modules --ignore .git } | complete | ignore
print "✅ Markdown files formatted"
