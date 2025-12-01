#!/usr/bin/env nu
# Bitwarden utilities

# Unlock Bitwarden vault and save session token
def "main unlock" [] {
    let bw_status = try {
        bw status | from json | get status
    } catch {
        "unauthenticated"
    }

    let bw_session = if $bw_status == "unlocked" {
        # Vault is already unlocked, check if we have a session token
        let current_session = ($env.BW_SESSION? | default "")
        if ($current_session | is-not-empty) {
            print "✅ Vault is already unlocked, using existing session"
            $current_session
        } else {
            # No session in environment, lock and unlock to get a fresh one
            print "🔒 Vault is unlocked but no session found, getting fresh session..."
            bw lock | ignore
            bw unlock --raw | str trim
        }
    } else if $bw_status == "locked" {
        print "🔓 Unlocking Bitwarden vault..."
        bw unlock --raw | str trim
    } else {
        print "❌ Bitwarden is not logged in. Please run 'bw login' first"
        exit 1
    }

    $"BW_SESSION=($bw_session)" | save -f .env.local
    print "✅ Session saved to .env.local"
    print "💡 Run 'nu bw.nu reload' or 'just bw-reload' to reload direnv"
    print "💡 Just targets automatically load BW_SESSION from .env.local"
}

# Reload direnv environment (loads BW_SESSION from .env.local)
def "main reload" [] {
    print "🔄 Reloading direnv environment..."
    direnv allow
    direnv reload
    print "✅ Environment reloaded"
    if ($env.BW_SESSION? | default "" | is-not-empty) {
        print "✅ BW_SESSION is loaded"

        # Verify session is still valid
        let status = try {
            bw status | from json | get status
        } catch {
            "error"
        }

        if $status == "unlocked" {
            print "✅ Session is valid and vault is unlocked"
        } else if $status == "locked" {
            print "⚠️  Session expired or vault is locked - run 'just bw-unlock'"
        } else {
            print "⚠️  Session invalid - run 'just bw-unlock' to get a fresh session"
        }
    } else {
        print "⚠️  BW_SESSION not found in environment"
        print "   Run 'just bw-unlock' to unlock vault and save session"
    }
}

# Show help
def "main help" [] {
    print "Bitwarden Utilities"
    print "==================="
    print ""
    print "Usage: nu bw.nu <command>"
    print ""
    print "Commands:"
    print "  unlock   Unlock Bitwarden vault and save session token"
    print "  reload   Reload direnv environment (loads BW_SESSION)"
    print "  help     Show this help message"
}

def main [] {
    main help
}
