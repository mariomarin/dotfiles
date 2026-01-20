# Bitwarden utilities module for Nushell

# Check if bw is available (used by commands that need it)
def bw-available [] {
    which bw | is-not-empty
}

# Store session in .env.local file
def store_session [session: string] {
    $"BW_SESSION=($session)" | save -f .env.local

    # Set permissions on Unix-like systems
    if $nu.os-info.name != "windows" {
        chmod 600 .env.local
    }
}

# Retrieve session from .env.local file (returns null if not found)
def get_stored_session [] {
    if not (".env.local" | path exists) { return null }
    let content = open .env.local | str trim
    if ($content | is-empty) { return null }
    $content | str replace "BW_SESSION=" "" | str trim
}

# Clear session from .env.local file
def clear_stored_session [] {
    if (".env.local" | path exists) { rm .env.local }
}

# Get bw status safely (returns null on failure or if bw not available)
def get-bw-status [session?: string] {
    if not (bw-available) { return null }
    let result = if ($session | is-not-empty) {
        do { BW_SESSION=$session bw status } | complete
    } else {
        do { bw status } | complete
    }
    if $result.exit_code != 0 { return null }
    $result.stdout | from json
}

# Unlock Bitwarden vault and save session token
export def unlock [] {
    if not (bw-available) {
        print "❌ Bitwarden CLI (bw) not found. Skipping."
        return
    }

    # Check for existing session in .env.local
    let stored_session = get_stored_session

    if ($stored_session | is-not-empty) {
        let status = get-bw-status $stored_session
        if ($status | is-not-empty) and $status.status == "unlocked" {
            print "✅ Valid session found in .env.local"
            $env.BW_SESSION = $stored_session
            return
        }
        print "ℹ️  Stored session expired, getting fresh session..."
        clear_stored_session
    }

    let status = get-bw-status
    let bw_status = $status | get status? | default "unauthenticated"

    let bw_session = if $bw_status == "unlocked" {
        let current_session = $env.BW_SESSION? | default ""
        if ($current_session | is-not-empty) {
            print "✅ Vault is already unlocked, using existing session"
            $current_session
        } else {
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

    store_session $bw_session
    $env.BW_SESSION = $bw_session

    print "✅ Session saved to .env.local"
    print "💡 Run 'bitwarden reload' to load in new shells"
}

# Lock vault and clear session
export def lock [] {
    if not (bw-available) {
        print "❌ Bitwarden CLI (bw) not found. Skipping."
        return
    }
    bw lock
    clear_stored_session
    $env.BW_SESSION = null
    print "🔒 Vault locked and session cleared"
}

# Load session from .env.local into environment
export def reload [] {
    if not (bw-available) {
        print "❌ Bitwarden CLI (bw) not found. Skipping."
        return
    }

    let stored_session = get_stored_session

    if ($stored_session | is-empty) {
        print "❌ No session found in .env.local"
        print "   Run 'bitwarden unlock' first"
        exit 1
    }

    let status = get-bw-status $stored_session

    if ($status | is-not-empty) and $status.status == "unlocked" {
        $env.BW_SESSION = $stored_session
        print "✅ Session loaded from .env.local"
        print "✅ Vault is unlocked"
    } else {
        print "⚠️  Stored session is invalid"
        print "   Run 'bitwarden unlock' to get a fresh session"
        clear_stored_session
        exit 1
    }
}

# Get an item from Bitwarden (returns null if not found)
export def "get item" [name: string] {
    if not (bw-available) { return null }
    if ($env.BW_SESSION? | default "" | is-empty) {
        print "❌ BW_SESSION not set. Run 'bitwarden unlock' first"
        exit 1
    }

    let result = do { bw get item $name } | complete
    if $result.exit_code != 0 { return null }
    $result.stdout | from json
}

# Get a field from a Bitwarden item (returns null if not found)
export def "get field" [item: string, field: string] {
    let item_data = get item $item
    if ($item_data | is-empty) { return null }

    # Try custom fields first
    let custom_field = $item_data.fields? | default [] | where name == $field | get 0?.value?
    if ($custom_field | is-not-empty) { return $custom_field }

    # Fall back to standard fields
    $item_data | get --ignore-errors $field
}

# Check Bitwarden status (returns null on failure or if bw not available)
export def status [] {
    if not (bw-available) {
        print "❌ Bitwarden CLI (bw) not found"
        return null
    }
    get-bw-status
}

# Show help
export def help [] {
    print "Bitwarden Utilities Module"
    print "==========================="
    print ""
    print "Commands:"
    print "  bitwarden unlock         Unlock Bitwarden vault and save session token"
    print "  bitwarden reload         Reload direnv environment (loads BW_SESSION)"
    print "  bitwarden get item       Get an item from Bitwarden"
    print "  bitwarden get field      Get a specific field from an item"
    print "  bitwarden status         Check Bitwarden status"
    print "  bitwarden help           Show this help message"
}
