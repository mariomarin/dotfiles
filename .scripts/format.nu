#!/usr/bin/env nu
# Formatting utilities

# Format justfiles
def "main justfile" [] {
    print "📝 Formatting justfiles..."
    if (which just | is-empty) {
        print "⚠️  just not found"
        exit 0
    }
    glob **/justfile | each {|file| cd ($file | path dirname); just --fmt --unstable }
    print "✅ Justfiles formatted"
}

# Format Lua files with stylua
def "main lua" [] {
    print "📝 Formatting Lua files with stylua..."
    if (which stylua | is-empty) {
        print "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    }
    cd private_dot_config/nvim
    stylua .
    print "✅ Lua files formatted"
}

# Format Markdown files with markdownlint
def "main markdown" [] {
    print "📝 Formatting Markdown files with markdownlint..."
    if (which markdownlint | is-empty) {
        print "⚠️  markdownlint not found. Run 'direnv allow' to load development environment"
        exit 0
    }
    do { markdownlint --fix "**/*.md" --ignore node_modules --ignore .git } | complete | ignore
    print "✅ Markdown files formatted"
}

# Format Nix files with nixpkgs-fmt
def "main nix" [] {
    print "📝 Formatting Nix files with nixpkgs-fmt..."
    if (which nixpkgs-fmt | is-empty) {
        print "⚠️  nixpkgs-fmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    }
    glob **/*.nix | each {|file| nixpkgs-fmt $file }
    print "✅ Nix files formatted"
}

# Format JSON and TOML files with biome
def "main others" [] {
    print "📝 Formatting JSON and TOML files with biome..."
    if (which biome | is-empty) {
        print "⚠️  biome not found. Run 'direnv allow' to load development environment"
        exit 0
    }
    biome format --write .
    print "✅ JSON and TOML files formatted"
}

# Format shell scripts with shfmt
def "main shell" [] {
    print "📝 Formatting shell scripts with shfmt..."
    if (which shfmt | is-empty) {
        print "⚠️  shfmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    }
    shfmt -w -i 2 -ci -sr -kp .
    print "✅ Shell scripts formatted"
}

# Format YAML files with yamlfmt
def "main yaml" [] {
    print "📝 Formatting YAML files with yamlfmt..."
    if (which yamlfmt | is-empty) {
        print "⚠️  yamlfmt not found. Run 'direnv allow' to load development environment"
        exit 0
    }
    glob **/*.{yml,yaml} | where {|f| $f !~ "/.git/" and $f !~ "/node_modules/" } | each {|file| yamlfmt $file }
    print "✅ YAML files formatted"
}

# Format all files
def "main all" [] {
    print "📝 Formatting all files..."
    print ""
    main justfile
    print ""
    main lua
    print ""
    main markdown
    print ""
    main nix
    print ""
    main others
    print ""
    main shell
    print ""
    main yaml
    print ""
    print "✅ All files formatted"
}

# Show help
def "main help" [] {
    print "Formatting Utilities"
    print "===================="
    print ""
    print "Usage: nu format.nu <command>"
    print ""
    print "Commands:"
    print "  justfile   Format justfiles"
    print "  lua        Format Lua files with stylua"
    print "  markdown   Format Markdown files with markdownlint"
    print "  nix        Format Nix files with nixpkgs-fmt"
    print "  others     Format JSON and TOML files with biome"
    print "  shell      Format shell scripts with shfmt"
    print "  yaml       Format YAML files with yamlfmt"
    print "  all        Format all files"
    print "  help       Show this help message"
}

def main [] {
    main all
}
