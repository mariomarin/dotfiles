#!/usr/bin/env nu
use std assert

# Test has-dyld-error function by creating mock log files

def setup_test_log [content: string]: string -> string {
    let test_log = $"/tmp/test-kanata-($env.PWD | path basename)-($content | hash md5).log"
    $content | save -f $test_log
    $test_log
}

export def "test dyld error detection with library not loaded" [] {
    let content = "dyld[562]: Library not loaded: /nix/store/fgrxz4hr8f71hkhsddbvk8nxadpg67bv-libiconv-115.100.1/lib/libiconv.2.dylib
  Referenced from: <B7E5688F-B5A1-3F1B-8C09-994D803F116C> /usr/local/bin/kanata
  Reason: tried: '/nix/store/fgrxz4hr8f71hkhsddbvk8nxadpg67bv-libiconv-115.100.1/lib/libiconv.2.dylib' (no such file)"

    let log = (setup_test_log $content)

    # Test the has-dyld-error function inline
    let result = (nu -c $'
        source .scripts/kanata-doctor.nu
        has-dyld-error "($log)"
    ')

    assert ($result.has_error == true)
    assert ($result.lib | str contains "libiconv")

    rm -f $log
}

export def "test dyld error detection with no error" [] {
    let content = "kanata started successfully
listening on port 5829
connect_failed asio.system:61"

    let log = (setup_test_log $content)

    let result = (nu -c $'
        source .scripts/kanata-doctor.nu
        has-dyld-error "($log)"
    ')

    assert ($result.has_error == false)

    rm -f $log
}

export def "test dyld error detection with missing log" [] {
    let result = (nu -c '
        source .scripts/kanata-doctor.nu
        has-dyld-error "/tmp/nonexistent-kanata-test.log"
    ')

    assert ($result.has_error == false)
}

export def "test dyld library path parsing" [] {
    let content = "Some logs
dyld[123]: Library not loaded: /nix/store/abc123-foo/lib/libfoo.dylib
More logs"

    let log = (setup_test_log $content)

    let result = (nu -c $'
        source .scripts/kanata-doctor.nu
        has-dyld-error "($log)"
    ')

    assert ($result.has_error == true)
    assert ($result.lib == "/nix/store/abc123-foo/lib/libfoo.dylib")

    rm -f $log
}

export def "test has-no-devices detection" [] {
    let content = "kanata started
Couldn't register any device
failed to start"

    let log = (setup_test_log $content)

    let result = (nu -c $'
        source .scripts/kanata-doctor.nu
        has-no-devices "($log)"
    ')

    assert ($result == true)

    rm -f $log
}

export def "test has-no-devices with normal startup" [] {
    let content = "kanata started successfully
listening on port 5829
device registered"

    let log = (setup_test_log $content)

    let result = (nu -c $'
        source .scripts/kanata-doctor.nu
        has-no-devices "($log)"
    ')

    assert ($result == false)

    rm -f $log
}
