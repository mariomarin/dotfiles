# Tests for cloudflare-tunnel.nu
use std/assert

const SCRIPT = ".scripts/cloudflare-tunnel.nu"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test help output" [] {
    let help = nu $SCRIPT | str downcase
    ["quick" "ssh" "http" "url" "status" "stop" "export"]
    | each { |term| assert str contains $help $term }
    | ignore
}
