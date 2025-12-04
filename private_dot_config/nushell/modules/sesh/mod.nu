# Sesh - Smart session manager with tmux integration
# Ported from zsh to nushell

# Sesh session selector with fzf (or skim if available)
export def "sesh sessions" [] {
    # Get session list from sesh
    let sessions = (sesh list -t -c | lines)

    if ($sessions | is-empty) {
        print "No sessions available"
        return
    }

    # Use skim plugin if available, otherwise fall back to fzf
    let session = if (which skim | is-not-empty) {
        # Try using nu_plugin_skim if registered
        try {
            $sessions | skim
        } catch {
            # Fall back to external fzf
            $sessions | str join "\n" | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  '
        }
    } else {
        # Use external fzf
        $sessions | str join "\n" | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  '
    }

    if ($session | is-empty) {
        return
    }

    # Connect to selected session
    sesh connect $session
}

# Quick alias for session selection
export alias ss = sesh sessions
