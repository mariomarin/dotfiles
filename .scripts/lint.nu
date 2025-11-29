#!/usr/bin/env nu
# Linting utilities

# Check Lua files with stylua
def "main lua" [] {
    print "🔍 Checking Lua files with stylua..."
    if (which stylua | is-empty) {
        print "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    }
    cd private_dot_config/nvim
    let result = (do { stylua --check . } | complete)
    if $result.exit_code != 0 {
        print "❌ Lua files need formatting. Run 'nu format.nu lua' or 'just format-lua' to fix."
        exit 1
    }
    print "✅ Lua files valid"
}

# Check Nix files syntax
def "main nix" [] {
    print "🔍 Checking Nix files syntax..."
    let nix_files = (glob **/*.nix)
    let result = ($nix_files | each {|file| do { nix-instantiate --parse $file } | complete } | all {|r| $r.exit_code == 0 })
    if $result {
        print "✅ Nix syntax valid"
    } else {
        print "❌ Nix syntax errors found"
        exit 1
    }
}

# Check Nushell scripts syntax
def "main nu" [] {
    print "🔍 Checking Nushell scripts syntax..."
    let nu_files = (glob .scripts/**/*.nu)
    if ($nu_files | is-empty) {
        print "✅ No Nushell scripts to check"
        exit 0
    }
    let results = ($nu_files | each {|file|
        let check = (nu --ide-check 0 $file | complete)
        {file: $file, exit_code: $check.exit_code}
    })
    let failed = ($results | where exit_code != 0)
    if ($failed | is-empty) {
        print $"✅ All ($nu_files | length) Nushell scripts are valid"
    } else {
        print $"❌ ($failed | length) Nushell script\(s\) have syntax errors:"
        $failed | each {|f| print $"   ($f.file)" }
        exit 1
    }
}

# Check shell scripts with shellcheck
def "main shell" [] {
    print "🔍 Checking shell scripts with shellcheck..."
    if (which shellcheck | is-empty) {
        print "⚠️  shellcheck not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    }
    let sh_files = (glob **/*.sh)
    $sh_files | each {|file| shellcheck $file }
    print "✅ Shell scripts valid"
}

# Check all files
def "main all" [] {
    print "🔍 Linting all files..."
    print ""

    let lua_result = (do { main lua } | complete)
    print ""

    let nix_result = (do { main nix } | complete)
    print ""

    let nu_result = (do { main nu } | complete)
    print ""

    let shell_result = (do { main shell } | complete)
    print ""

    let failed = [$lua_result $nix_result $nu_result $shell_result] | where exit_code != 0
    if ($failed | is-empty) {
        print "✅ All checks passed"
    } else {
        print $"❌ ($failed | length) check\(s\) failed"
        exit 1
    }
}

# Show help
def "main help" [] {
    print "Linting Utilities"
    print "================="
    print ""
    print "Usage: nu lint.nu <command>"
    print ""
    print "Commands:"
    print "  lua      Check Lua files with stylua"
    print "  nix      Check Nix files syntax"
    print "  nu       Check Nushell scripts syntax"
    print "  shell    Check shell scripts with shellcheck"
    print "  all      Check all files"
    print "  help     Show this help message"
}

def main [] {
    main all
}
