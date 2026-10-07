# nutest suite for the bitwarden module (run by .scripts/tests/run-nutest.nu)
use std/assert
use std/testing *

const MOD = path self ../mod.nu

# Evaluate a snippet with the module sourced (private helpers included)
def bw-eval [snippet: string, --cwd: string]: nothing -> any {
    let dir = ($cwd | default $env.PWD)
    let result = do { cd $dir; ^$nu.current-exe -n -c $"source ($MOD); ($snippet) | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

@test
def "stored session round-trips through .env.local" [] {
    let dir = (mktemp -d)
    assert equal (bw-eval --cwd $dir "get_stored_session") null
    assert equal (bw-eval --cwd $dir "store_session tok-123; get_stored_session") "tok-123"
    assert equal (bw-eval --cwd $dir "clear_stored_session; get_stored_session") null
    rm -rf $dir
}
