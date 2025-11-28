#!/usr/bin/env nu
# Unlock Bitwarden vault and save session token

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

$"export BW_SESSION=\"($bw_session)\"" | save -f .envrc.local
$"BW_SESSION=\"($bw_session)\"" | save -f .env
print "✅ Session saved to .env and .envrc.local"
print "💡 Run 'just bw-reload' to reload direnv and load the session"
