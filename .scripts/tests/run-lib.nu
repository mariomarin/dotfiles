# Shared by run.nu and run-for-files.nu: run `test …` commands in a file
use ../adt.nu [run-cmd "result map"]

# Result of the file's "test ..." command names; err when it fails to parse
def load-test-funcs [test_file: string]: nothing -> record {
    # Fresh interpreter per file: source needs a parse-time path
    run-cmd {
        ^$nu.current-exe -n -c $"source ($test_file); scope commands | where name =~ '^test ' | get name | to nuon"
    }
    | result map {|out| $out.stdout | str trim | from nuon }
}

def run-test [test_file: string, func: string]: nothing -> record<name: string, passed: bool, error: string> {
    let result = do { ^$nu.current-exe -n -c $"source ($test_file); ($func)" } | complete
    {
        name: $func
        passed: ($result.exit_code == 0)
        error: ($result.stderr | str trim)
    }
}

# Run each "test ..." command in a file; a parse failure is one failed result
export def run-file [test_file: string]: nothing -> list<record> {
    let loaded = load-test-funcs $test_file
    if not $loaded.ok {
        return [
            {
                name: "load file"
                passed: false
                error: ($loaded.error.stderr | str trim)
            }
        ]
    }
    $loaded.value | each {|func| run-test $test_file $func }
}
