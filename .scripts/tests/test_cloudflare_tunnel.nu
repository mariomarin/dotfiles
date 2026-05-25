# Tests for cloudflare-tunnel.nu
use std/assert

const SCRIPT = ".scripts/cloudflare-tunnel.nu"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test help output" [] {
    let help = nu $SCRIPT | str downcase
    ["quick" "ssh" "http" "url" "status" "stop"] | each {|term| assert str contains $help $term } | ignore
}

def "test parse-tunnel-url extracts url" [] {
    let result = do {
        nu -n -c 'source .scripts/cloudflare-tunnel.nu; parse-tunnel-url "INFO: https://some-tunnel-abc.trycloudflare.com connected" | to nuon'
    } | complete
    assert equal $result.exit_code 0
    assert equal ($result.stdout | str trim | from nuon) "https://some-tunnel-abc.trycloudflare.com"
}

def "test parse-tunnel-url returns null on no match" [] {
    let result = do {
        nu -n -c 'source .scripts/cloudflare-tunnel.nu; parse-tunnel-url "no url here" | to nuon'
    } | complete
    assert equal $result.exit_code 0
    assert equal ($result.stdout | str trim | from nuon) null
}
