# Bitwarden utilities module for Nushell

# Store session in .env.local file
def store_session [session: string] {
    $"BW_SESSION=($session)" | save -f .env.local

    # Set permissions on Unix-like systems
    if $nu.os-info.name != "windows" {
        chmod 600 .env.local
    }
}

# Retrieve session from .env.local file
def get_stored_session [] {
    try {
        if (".env.local" | path exists) {
            open .env.local | str replace "BW_SESSION=" "" | str trim
        } else {
            ""
        }
    } catch {
        ""
    }
}

# Clear session from .env.local file
def clear_stored_session [] {
    try {
        if (".env.local" | path exists) {
            rm .env.local
        }
    } catch {
        # Session already cleared
    }
}

# Unlock Bitwarden vault and save session token
export def unlock [] {
    # Check for existing session in .env.local
    let stored_session = (get_stored_session)

    if ($stored_session | is-not-empty) {
        # Test if session is valid
        let status = try {
            do -i { BW_SESSION=$stored_session bw status } | from json | get status
        } catch {
            "invalid"
        }

        if $status == "unlocked" {
            print "✅ Valid session found in .env.local"
            $env.BW_SESSION = $stored_session
            return
        } else {
            print "ℹ️  Stored session expired, getting fresh session..."
            clear_stored_session
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

    # Store in .env.local
    store_session $bw_session

    # Also set in current environment
    $env.BW_SESSION = $bw_session

    print "✅ Session saved to .env.local"
    print "💡 Run 'bitwarden reload' to load in new shells"
}

# Lock vault and clear session
export def lock [] {
    bw lock
    clear_stored_session
    $env.BW_SESSION = null
    print "🔒 Vault locked and session cleared"
}

# Load session from .env.local into environment
export def reload [] {
    let stored_session = (get_stored_session)

    if ($stored_session | is-empty) {
        print "❌ No session found in .env.local"
        print "   Run 'bitwarden unlock' first"
        exit 1
    }

    # Verify session is still valid
    let status = try {
        do -i { BW_SESSION=$stored_session bw status } | from json | get status
    } catch {
        "invalid"
    }

    if $status == "unlocked" {
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

# Get an item from Bitwarden
export def "get item" [name: string] {
    if ($env.BW_SESSION? | default "" | is-empty) {
        print "❌ BW_SESSION not set. Run 'bitwarden unlock' first"
        exit 1
    }

    try {
        bw get item $name | from json
    } catch {
        error make {msg: $"Item '($name)' not found in Bitwarden"}
    }
}

# Get a field from a Bitwarden item
export def "get field" [
    item: string
    field: string
] {
    let item_data = (get item $item)

    # Try custom fields first
    let custom_field = try {
        $item_data.fields? | default [] | where name == $field | first | get value
    } catch {
        null
    }

    if ($custom_field | is-not-empty) {
        return $custom_field
    }

    # Fall back to standard fields
    try {
        $item_data | get $field
    } catch {
        error make {msg: $"Field '($field)' not found in item '($item)'"}
    }
}

# Check Bitwarden status
export def status [] {
    try {
        bw status | from json
    } catch {
        error make {msg: "Failed to get Bitwarden status"}
    }
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
