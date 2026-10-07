# Tests that all .scripts/*.nu files parse without errors
use std/assert

const SKIP = ["dev.nu"] # Scripts that can't be sourced in isolation

def "test all scripts parse" [] {
    glob ".scripts/*.nu"
    | where { |f|
        let name = $f | path basename
        not ($f | str contains "/tests/") and not ($name in $SKIP)
    }
    | each { |script|
        let result = do { nu -n -c $"source ($script)" } | complete
        assert equal $result.exit_code 0 $"($script): ($result.stderr)"
    }
    | ignore
}

def "test all nushell modules parse" [] {
    glob "private_dot_config/nushell/modules/{*/mod.nu,*.nu}"
    | each { |module|
        let result = do { nu -n -c $"source ($module)" } | complete
        assert equal $result.exit_code 0 $"($module): ($result.stderr)"
    }
    | ignore
}
