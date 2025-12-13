# Tests for cloudflare-tunnel.nu
use std/assert

const SCRIPT = ".scripts/cloudflare-tunnel.nu"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test help output" [] {
    let help = nu $SCRIPT | str downcase
    ["quick tunnels" "ssh" "http" "status" "stop" "list"]
    | each { |term| assert str contains $help $term }
    | ignore
}

def "test help mentions env vars" [] {
    let help = nu $SCRIPT
    ["CF_ACCOUNT_ID" "CF_API_TOKEN"]
    | each { |var| assert str contains $help $var }
    | ignore
}
