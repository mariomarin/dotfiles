#!/usr/bin/env nu
# Check Nushell scripts syntax

print "🔍 Checking Nushell scripts syntax..."
let nu_files = (glob .scripts/**/*.nu)
if ($nu_files | is-empty) {
    print "✅ No Nushell scripts to check"
    exit 0
}
let results = ($nu_files | each {|file|
    let check = (nu --ide-check 0 $file | complete)
    {file: $file, exit_code: $check.exit_code}
})
let failed = ($results | where exit_code != 0)
if ($failed | is-empty) {
    print $"✅ All ($nu_files | length) Nushell scripts are valid"
} else {
    print $"❌ ($failed | length) Nushell script\(s\) have syntax errors:"
    $failed | each {|f| print $"   ($f.file)" }
    exit 1
}
