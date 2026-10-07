# Run nutest suites (modules/*/tests/test_*.nu) as {name, passed, error}
# records, so run.nu and run-for-files.nu can report them with the rest.

# Directory holding nutest/mod.nu: a nupm install, else the chezmoi clone
export def find-nutest []: nothing -> any {
    let nupm_home = ($env.NUPM_HOME? | default ($nu.home-dir | path join ".local" "share" "nupm"))
    [($nupm_home | path join "modules") ($nu.home-dir | path join ".cache" "nutest-src")]
    | where {|d| $d | path join "nutest" "mod.nu" | path exists }
    | get 0?
}

export def run-suites [tests_dir: string]: nothing -> list<record> {
    let lib = (find-nutest)
    if $lib == null {
        return [{name: $"nutest ($tests_dir)", passed: false, error: "nutest not installed (chezmoi apply clones it to ~/.cache/nutest-src)"}]
    }
    let result = do {
        ^$nu.current-exe -n -I $lib -c $"use nutest; nutest run-tests --path ($tests_dir | path expand) --returns table | to nuon"
    } | complete
    if $result.exit_code != 0 {
        return [{name: $"nutest ($tests_dir)", passed: false, error: ($result.stderr | str trim)}]
    }
    $result.stdout | from nuon | each {|t|
        {name: $"($t.suite): ($t.test)", passed: ($t.result != "FAIL"), error: ($t.output | to text | str trim)}
    }
}
