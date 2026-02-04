# Jujutsu (jj) completions for Nushell
# This module provides a command to update jj completions

# Update jj completions to cache
export def "jj update-completions" [] {
    if (which jj | is-empty) {
        print "jj command not found"
        return
    }

    let cache_dir = ([$nu.default-config-dir, '..', 'cache', 'nushell'] | path join | path expand)
    mkdir $cache_dir
    let completions_file = ([$cache_dir, 'jj-completions.nu'] | path join)

    print $"Generating jj completions to ($completions_file)..."
    jj util completion nushell | save -f $completions_file
    print "Completions generated. Restart Nushell or run: source ~/.cache/nushell/jj-completions.nu"
}

# NOTE: Actual completions should be sourced in config.nu:
# source ~/.cache/nushell/jj-completions.nu
