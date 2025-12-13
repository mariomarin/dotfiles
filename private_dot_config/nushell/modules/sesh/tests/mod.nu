# Sesh module tests
use std/assert

const MOD = "private_dot_config/nushell/modules/sesh/mod.nu"

def "test module parses" [] {
    do { nu -n -c $"source ($MOD)" } | complete | get exit_code | assert equal $in 0
}
