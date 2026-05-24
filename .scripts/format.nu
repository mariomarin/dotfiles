#!/usr/bin/env nu
# Formatting utilities

# Format justfiles
def "main justfile" [] {
    if (which just | is-empty) {
        print -e "⚠️  just not found"
        exit 0
    }
    glob **/justfile | each {|file| cd ($file | path dirname); just --fmt --unstable }
    | ignore
}

# Format Lua files with stylua
def "main lua" [] {
    if (which stylua | is-empty) {
        print -e "⚠️  stylua not found"
        exit 0
    }
    cd private_dot_config/nvim
    stylua .
}

def "main markdown" [] {
    if (which rumdl | is-empty) {
        print -e "⚠️  rumdl not found"
        exit 0
    }
    do { rumdl fmt . } | complete | ignore
}

# Format Nix files with nixpkgs-fmt
def "main nix" [] {
    if (which nixpkgs-fmt | is-empty) {
        print -e "⚠️  nixpkgs-fmt not found"
        exit 0
    }
    glob **/*.nix | each {|file| nixpkgs-fmt $file }
    | ignore
}

# Format JSON and TOML files with biome
def "main others" [] {
    if (which biome | is-empty) {
        print -e "⚠️  biome not found"
        exit 0
    }
    biome format --write .
}

# Format shell scripts with shfmt
def "main shell" [] {
    if (which shfmt | is-empty) {
        print -e "⚠️  shfmt not found"
        exit 0
    }

    glob **/*.sh
    | where {|f| not ($f | str contains ".git") }
    | where {|f| not ($f | str contains "node_modules") }
    | where {|f| not ($f | str ends-with ".zsh") }
    | where {|f| not ($f | str ends-with "zshrc") }
    | where {|f| not ($f | str ends-with "zshenv") }
    | where {|f| not ($f | str contains "private_dot_config/zim/") }
    | each {|file| shfmt -w -i 2 -ci -sr -kp $file }
    | ignore
}

# Format YAML files with yamlfmt
def "main yaml" [] {
    if (which yamlfmt | is-empty) {
        print -e "⚠️  yamlfmt not found"
        exit 0
    }
    glob **/*.{yml,yaml}
    | where {|f| not ($f | str contains ".git") }
    | where {|f| not ($f | str contains "node_modules") }
    | where {|f| not ($f | str contains ".pre-commit-config") }
    | each {|file| yamlfmt $file }
    | ignore
}

# Validate nushell files
def "main nushell" [] {
    if (which nu | is-empty) {
        print -e "⚠️  nu not found"
        exit 0
    }

    let failed = glob **/*.nu
    | where {|f| not ($f | str contains ".git") }
    | where {|f| not ($f | str contains "node_modules") }
    | where {|f| not ($f | str contains "wsl-") }
    | each {|file|
        let result = (nu -n -c $"source \"($file)\"" | complete)
        if $result.exit_code != 0 {
            print -e $"✗ ($file): ($result.stderr)"
            $file
        }
    }
    | compact

    if ($failed | is-not-empty) {
        exit 1
    }
}

# Format all files
def "main all" [] {
    main justfile
    main lua
    main markdown
    main nix
    main nushell
    main others
    main shell
    main yaml
}

# Show help
def "main help" [] {
    print "Usage: nu format.nu <command>"
    print ""
    print "Commands:"
    print "  justfile   Format justfiles"
    print "  lua        Format Lua files with stylua"
    print "  markdown   Format Markdown files with rumdl"
    print "  nix        Format Nix files with nixpkgs-fmt"
    print "  nushell    Validate Nushell files"
    print "  others     Format JSON and TOML files with biome"
    print "  shell      Format shell scripts with shfmt (excludes zsh)"
    print "  yaml       Format YAML files with yamlfmt"
    print "  all        Format all files"
    print "  help       Show this help message"
}

def main [] {
    main all
}
