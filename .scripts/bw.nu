#!/usr/bin/env nu
# Bitwarden utilities

# Unlock Bitwarden vault and save session token
def "main unlock" [] {
    # Check if .env.local exists and has a valid session
    if (".env.local" | path exists) {
        let env_content = (open .env.local | str trim)
        let session_token = ($env_content | str replace "BW_SESSION=" "" | str trim)

        if ($session_token | is-not-empty) {
            # Test if session is valid
            let status = try {
                do -i { BW_SESSION=$session_token bw status } | from json | get status
            } catch {
                "invalid"
            }

            if $status == "unlocked" {
                print "⚠️  You already have a valid session in .env.local"
                print "   The vault is currently unlocked with this session."
                print "   Run 'just bw-reload' to load it into your environment (Unix only)"
                return
            } else if $status == "locked" {
                print "ℹ️  Existing session in .env.local is expired (vault locked)"
                print "   Getting a fresh session..."
            }
        }
    }

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
    print "💡 Run 'nu bw.nu reload' or 'just bw-reload' to reload direnv (Unix only)"
    print "💡 Just targets automatically load BW_SESSION from .env.local"
}

# Reload direnv environment (loads BW_SESSION from .env.local)
def "main reload" [] {
    # Check if we're on a Unix-like system
    if $nu.os-info.name == "windows" {
        print "❌ direnv reload is only available on Unix-like systems (Linux, macOS, WSL)"
        print "   On Windows, BW_SESSION is automatically loaded by just targets from .env.local"
        print "   No manual reload needed - just run your just commands"
        exit 1
    }

    # Check if direnv is available
    let has_direnv = (which direnv | is-not-empty)
    if not $has_direnv {
        print "❌ direnv is not installed or not in PATH"
        print "   On Unix systems, BW_SESSION can be loaded via direnv"
        print "   However, just targets automatically load from .env.local"
        exit 1
    }

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
