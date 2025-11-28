#!/usr/bin/env nu
# Unlock Bitwarden vault and save session token

let bw_status = try {
    bw status | from json | get status
} catch {
    "unauthenticated"
}

let bw_session = if $bw_status == "unlocked" {
    print "✅ Vault is already unlocked"
    let result = (bw unlock --raw --passwordenv BW_PASSWORD | complete)
    let session = $result.stdout | str trim
    if ($session | is-empty) {
        print "⚠️  Could not get session token. You may need to run 'bw lock' and try again."
        exit 1
    }
    $session
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
