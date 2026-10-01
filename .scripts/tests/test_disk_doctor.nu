# Tests for disk-doctor.nu
use std/assert

const SCRIPT = ".scripts/disk-doctor.nu"

const RMLINT_JSON = r#'[
  {"description": "rmlint json-dump", "cwd": "/r"},
  {"type": "duplicate_file", "checksum": "aa", "path": "/r/a/big", "size": 100, "is_original": true},
  {"type": "duplicate_file", "checksum": "aa", "path": "/r/b/big", "size": 100, "is_original": false},
  {"type": "duplicate_file", "checksum": "aa", "path": "/r/b/big2", "size": 100, "is_original": false},
  {"type": "emptyfile", "path": "/r/a/empty", "size": 0, "is_original": false},
  {"aborted": false, "total_files": 5}
]'#

def eval [expr: string]: nothing -> any {
    let result = do { nu -n -c $"source ($SCRIPT); ($expr) | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

def facts [overrides: record = {}]: nothing -> string {
    {
        home: "/Users/u"
        cache_dir: "/Users/u/Library/Caches"
        disks: [[mount, total, free]; ["/", 1000b, 500b]]
        stray_scripts: []
        snapshots: ""
        rmlint: ""
        caches: ""
        docker_raw: ""
        docker_df: ""
        backups: ""
    } | merge $overrides | to nuon
}

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test parse-du converts KiB to bytes" [] {
    let input = "4\t/a\n2\t/b c" | to nuon
    assert equal (eval $"($input) | parse-du") [
        [path size]
    ]
}

def "test parse-du empty input" [] {
    assert equal (eval "'' | parse-du") []
}

def "test parse-rmlint drops header and footer" [] {
    let lint = eval $"($RMLINT_JSON | to nuon) | parse-rmlint"
    assert equal ($lint | length) 4
}

def "test parse-rmlint empty input" [] {
    assert equal (eval "'' | parse-rmlint") []
}

def "test parse-snapshots skips header" [] {
    let input = (
        "Snapshots for disk /:\ncom.apple.os.update-AB\ncom.apple.TimeMachine.2026-09-27-101500.local"
        | to nuon
    )
    let names = eval $"($input) | parse-snapshots | get name"
    assert equal $names ["com.apple.os.update-AB" "com.apple.TimeMachine.2026-09-27-101500.local"]
}

def "test parse-docker-df reads json lines" [] {
    let input = '{"Type":"Images","Size":"3.2GB","Reclaimable":"1.1GB (34%)"}' | to nuon
    let row = eval $"($input) | parse-docker-df | first"
    assert equal $row {kind: docker, item: Images, size: 3200000000b, reclaimable: "1.1GB (34%)"}
}

def "test is-backup-dir matches basename only" [] {
    let result = (
        eval "['/h/backup-dendrite' '/h/Old Backups' '/h/docs' '/backup/docs'] | each { is-backup-dir }"
    )
    assert equal $result [true true false false]
}

def "test volume-of picks longest mount prefix" [] {
    let disks = [[mount, total, free]; ["/", 1000b, 900b], ["/Users", 1000b, 50b]] | to nuon
    let volume = eval $"($disks) | volume-of /Users/u | first"
    assert equal $volume.mount "/Users"
    assert equal $volume.pct 95
}

def "test volume-of no matching mount" [] {
    assert equal (eval "[[mount total free]; ['/data' 1b 1b]] | volume-of /Users/u") []
}

def "test redundant-files excludes originals" [] {
    let paths = eval $"($RMLINT_JSON | to nuon) | parse-rmlint | redundant-files | get path"
    assert equal $paths ["/r/b/big" "/r/b/big2" "/r/a/empty"]
}

def "test duplicate-groups sums wasted copies" [] {
    let groups = eval $"($RMLINT_JSON | to nuon) | parse-rmlint | duplicate-groups"
    assert equal $groups [
        {
            kind: duplicates
            keep: "/r/a/big"
            copies: 2
            wasted: 200b
        }
    ]
}

const HARDLINK_JSON = r#'[
  {"type": "duplicate_file", "path": "/r/a", "size": 100, "disk_id": 1, "inode": 7, "is_original": true},
  {"type": "duplicate_file", "path": "/r/b", "size": 100, "disk_id": 1, "inode": 7, "is_original": false}
]'#

def "test duplicate-groups hardlinks have no checksum and waste nothing" [] {
    let groups = eval $"($HARDLINK_JSON | to nuon) | parse-rmlint | duplicate-groups"
    assert equal $groups [
        {
            kind: duplicates
            keep: "/r/a"
            copies: 1
            wasted: 0b
        }
    ]
}

def "test redundant-files hardlink frees nothing" [] {
    let sizes = (
        eval $"($HARDLINK_JSON | to nuon) | parse-rmlint | redundant-files | get size"
    )
    assert equal $sizes [
        0b
    ]
}

def "test diagnose with nothing found yields only volume" [] {
    assert equal (eval $"(facts) | diagnose | get kind") [volume]
}

def "test diagnose covers every source" [] {
    let full = (facts {
        stray_scripts: ["/r/rmlint.sh"]
        snapshots: "com.apple.os.update-AB", 
        rmlint: $RMLINT_JSON
        caches: "8\t/Users/u/Library/Caches/Firefox"
        docker_raw: "16\t/Users/u/Docker.raw"
        backups: "32\t/Users/u/backup-dendrite"
    })
    let kinds = eval $"($full) | diagnose | get kind | uniq"
    assert equal $kinds [
        volume
        stray-script
        snapshot
        redundant
        duplicates
        cache
        docker
        backup
    ]
}

def "test render clean report" [] {
    let text = (
        eval $"(facts) | diagnose | render {root: /r, top: 5, list: false, caches: /c} | ansi strip"
    )
    assert ($text | str contains "redundant files: none in /r")
    assert not ($text | str contains "next steps")
}

def "test render flags nearly full disk" [] {
    let text = (
        eval $"(facts {disks: [[mount total free]; ['/' 100b 5b]]}) | diagnose | render {root: /r, top: 5, list: false, caches: /c}"
    )
    assert ($text | str contains "95% used")
    assert ($text | str contains "nearly full")
}

def "test render --list shows relative paths" [] {
    let text = (
        eval $"(facts {rmlint: $RMLINT_JSON}) | diagnose | render {root: /r, top: 5, list: true, caches: /c} | ansi strip"
    )
    assert ($text | str contains "[duplicate_file] b/big2")
    assert ($text | str contains "next steps")
}

def "test render warns about stray rmlint.sh" [] {
    let text = (
        eval $"(facts {stray_scripts: ['/r/rmlint.sh']}) | diagnose | render {root: /r, top: 5, list: false, caches: /c}"
    )
    assert ($text | str contains "DELETES files")
}

def "test main never modifies scanned files" [] {
    let dir = (mktemp --directory --tmpdir disk-doctor-test.XXXXXX)
    "same" | save ($dir | path join a.txt)
    "same" | save ($dir | path join b.txt)
    touch ($dir | path join empty.txt)
    let before = ls --all $dir | select name size

    let result = do { nu -n $SCRIPT $dir --list } | complete
    let after = ls --all $dir | select name size
    rm --recursive --force $dir

    assert equal $result.exit_code 0 $result.stderr
    assert ($result.stdout | ansi strip | str contains "[duplicate_file] b.txt")
    assert equal $after $before
}
