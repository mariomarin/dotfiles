#!/usr/bin/env nu

# Read-only disk report: free space, snapshots, redundant files (rmlint),
# caches, Docker and backup copies. Never deletes: rmlint only removes files
# through the rmlint.sh it writes by default, and we request JSON only.
#
# Functional core, imperative shell (data / calculations / actions):
#   gather    action       machine -> Facts (raw command output, as data)
#   diagnose  calculation  Facts -> list<Finding>
#   render    calculation  list<Finding> -> string
#   main      action       prints
#
#   Finding = {kind: volume,       mount, size, free, pct}
#           | {kind: stray-script, path}
#           | {kind: snapshot,     name}
#           | {kind: redundant,    type, path, size}
#           | {kind: duplicates,   keep, copies, wasted}
#           | {kind: cache,        name, size}
#           | {kind: docker,       item, size, reclaimable}
#           | {kind: backup,       path, size}

# --- data ---

const KINDS = [volume stray-script snapshot redundant duplicates cache docker backup]

const DOCKER_RAW = "Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw"

const ADVICE = {
    duplicate_file: "keeps the original (ranked by -S, default: shallowest path, then oldest); review before acting"
    duplicate_dir: "whole directory duplicates; compare with diff -r before touching"
    emptyfile: "often markers (.keep, __init__.py, lockfiles) — never bulk-delete"
    emptydir: "often expected by apps or tooling — remove only ones you recognize"
    badlink: "dangling symlinks; may point to an unmounted volume — check with ls -l"
    baduid: "owned by a deleted user — fix with chown, don't delete"
    badgid: "group no longer exists — fix with chgrp, don't delete"
    badugid: "user and group gone — fix with chown, don't delete"
    nonstripped: "binaries with debug symbols — strip only if space matters"
}

def main [
    path: path = "."  # directory to scan for redundant files
    --top: int = 10   # rows per table
    --list            # print every path rmlint would remove
]: nothing -> nothing {
    if (which rmlint | is-empty) { print --stderr "rmlint not installed"; exit 1 }
    let root = ($path | path expand)
    if not ($root | path exists) { print --stderr $"no such path: ($root)"; exit 1 }

    let facts = (gather $root)
    print ($facts | diagnose | render {root: $root, top: $top, list: $list, caches: $facts.cache_dir})
}

# --- actions: the only code that reads the machine ---

def gather [root: string]: nothing -> record {
    let home = $env.HOME
    let darwin = ((sys host).name == Darwin)
    let cache_dir = if $darwin {
        $home | path join Library/Caches
    } else {
        $env.XDG_CACHE_HOME? | default ($home | path join .cache)
    }
    let backup_dirs = (ls $home | where type == dir | get name | where {|p| $p | is-backup-dir })
    let has_docker = (which docker | is-not-empty)

    {
        home: $home
        cache_dir: $cache_dir
        disks: (sys disks | select mount total free)
        stray_scripts: (glob --depth 4 $"($root)/**/rmlint.sh")
        snapshots: (if $darwin { run-text tmutil listlocalsnapshots / } else { "" })
        rmlint: (run-rmlint $root)
        caches: (du-paths (if ($cache_dir | path exists) { ls --all $cache_dir | get name } else { [] }))
        docker_raw: (du-paths [($home | path join $DOCKER_RAW)])
        docker_df: (if $has_docker { run-text docker system df --format "{{json .}}" } else { "" })
        backups: (du-paths $backup_dirs)
    }
}

# stdout of a command, or "" if it fails.
def --wrapped run-text [cmd: string, ...args: string]: nothing -> string {
    let res = (do { run-external $cmd ...$args } | complete)
    if $res.exit_code == 0 { $res.stdout } else { "" }
}

# `du -sk` output for the paths that exist; unreadable entries are skipped.
def du-paths [paths: list<string>]: nothing -> string {
    let existing = ($paths | where ($it | path exists))
    if ($existing | is-empty) { return "" }
    do { ^du -sk ...$existing } | complete | get stdout
}

def run-rmlint [root: string]: nothing -> string {
    let out = (mktemp --tmpdir disk-doctor.XXXXXX)
    let res = (do { rmlint $root -o $"json:($out)" } | complete)
    let json = (open --raw $out)
    rm --force $out
    if $res.exit_code != 0 { error make {msg: $"rmlint failed: ($res.stderr | str trim)"} }
    $json
}

# --- calculations: facts in, findings out ---

def diagnose []: record -> list<record> {
    let facts = $in
    let lint = ($facts.rmlint | parse-rmlint)
    [
        ...($facts.disks | volume-of $facts.home)
        ...($facts.stray_scripts | each {|p| {kind: stray-script, path: $p} })
        ...($facts.snapshots | parse-snapshots)
        ...($lint | redundant-files)
        ...($lint | duplicate-groups)
        ...($facts.caches | parse-du | each {|r| {kind: cache, name: ($r.path | path basename), size: $r.size} })
        ...($facts.docker_raw | parse-du | each {|r| {kind: docker, item: "Docker.raw (VM disk)", size: $r.size, reclaimable: ""} })
        ...($facts.docker_df | parse-docker-df)
        ...($facts.backups | parse-du | each {|r| {kind: backup, path: $r.path, size: $r.size} })
    ]
}

# Copies of other machines tend to linger long after they're needed.
def is-backup-dir []: string -> bool {
    path basename | $in =~ '(?i)backup'
}

# `du -sk` lines -> [{path, size}]
def parse-du []: string -> list<record> {
    lines
    | parse "{kb}\t{path}"
    | each {|r| {path: $r.path, size: ($r.kb | into int | $in * 1024 | into filesize)} }
}

# rmlint JSON -> lint entries (header and footer dropped).
def parse-rmlint []: string -> list<record> {
    let json = $in
    if ($json | str trim | is-empty) { return [] }
    $json | from json | where ($it.type? != null)
}

# APFS snapshots pin deleted blocks: space stays used with no visible file.
def parse-snapshots []: string -> list<record> {
    lines
    | where ($it | str starts-with com.apple)
    | each {|name| {kind: snapshot, name: $name} }
}

# `docker system df --format '{{json .}}'` lines -> findings.
def parse-docker-df []: string -> list<record> {
    lines
    | each { from json }
    | each {|r| {kind: docker, item: $r.Type, size: ($r.Size | into filesize), reclaimable: $r.Reclaimable} }
}

# The disk holding `home`: the longest mount point that prefixes it.
def volume-of [home: string]: table -> list<record> {
    where ($home | str starts-with $it.mount)
    | sort-by {|d| $d.mount | str length }
    | last 1
    | each {|d|
        {
            kind: volume
            mount: $d.mount
            size: $d.total
            free: $d.free
            pct: (($d.total - $d.free) / $d.total * 100 | math round)
        }
    }
}

# Hardlinks share an inode: rmlint skips hashing them and removing one frees nothing.
def inode-key []: record -> any {
    let entry = $in
    if $entry.inode? == null { return null }
    $"($entry.disk_id?):($entry.inode)"
}

# Space a copy would free: none when it is a hardlink of a kept file.
def reclaimable [kept: list]: record -> filesize {
    let entry = $in
    let key = ($entry | inode-key)
    if $key != null and $key in $kept { return 0b }
    $entry.size | into filesize
}

def redundant-files []: list<record> -> list<record> {
    let lint = $in
    let kept = ($lint | where ($it.is_original? | default false) | each { inode-key } | compact)
    $lint
    | where not ($it.is_original? | default false)
    | each {|e| {kind: redundant, type: $e.type, path: $e.path, size: ($e | reclaimable $kept)} }
}

def duplicate-groups []: list<record> -> list<record> {
    where type == duplicate_file
    | group-by {|e| $e.checksum? | default ($e | inode-key) | default $e.path }
    | values
    | each {|group|
        let kept = ($group | where is_original | each { inode-key } | compact)
        let copies = ($group | where not $it.is_original)
        {
            kind: duplicates
            keep: ($group | where is_original | get 0?.path | default "?")
            copies: ($copies | length)
            wasted: ($copies | each { reclaimable $kept } | math sum | into filesize)
        }
    }
}

# --- calculations: findings in, text out ---

def render [ctx: record]: list<record> -> string {
    let findings = $in
    let clean = ($findings | where kind == redundant | is-empty)
    [
        (if $clean { $"redundant files: none in ($ctx.root)" })
        ...($KINDS | each {|kind| $findings | where kind == $kind | view $kind $ctx })
        (if not $clean { next-steps $ctx.root })
    ]
    | compact
    | str join "\n"
}

# One view per finding kind; null when there is nothing to show.
def view [kind: string, ctx: record]: list<record> -> any {
    let items = $in
    if ($items | is-empty) { return null }
    match $kind {
        volume => ($items | first | view-volume)
        stray-script => ($items | view-stray-scripts)
        snapshot => ($items | view-snapshots)
        redundant => ($items | view-redundant $ctx)
        duplicates => ($items | view-duplicates $ctx)
        cache => ($items | view-caches $ctx)
        docker => ($items | view-docker)
        backup => ($items | view-backups)
    }
}

def view-volume []: record -> string {
    let v = $in
    let flag = if $v.pct >= 90 { "  ← nearly full" } else { "" }
    $"disk ($v.mount): ($v.pct)% used, ($v.free) free of ($v.size)($flag)\n"
}

def view-stray-scripts []: list<record> -> string {
    [
        "warning: existing rmlint.sh found — running it DELETES files:"
        ...($in | each {|i| $"  ($i.path)  \(preview: ($i.path) -n, or remove it if stale\)" })
        ""
    ] | str join "\n"
}

def view-snapshots []: list<record> -> string {
    [
        "local APFS snapshots (hold deleted files' space; size not reported):"
        ...($in | each {|i| $"  ($i.name)" })
        "  macOS drops them under pressure. delete one by date: sudo tmutil deletelocalsnapshots <YYYY-MM-DD-HHMMSS>\n"
    ] | str join "\n"
}

def view-redundant [ctx: record]: list<record> -> string {
    let items = $in
    let summary = (
        $items
        | group-by type
        | items {|type, rows|
            {
                type: $type
                count: ($rows | length)
                size: ($rows | get size | math sum)
                advice: ($ADVICE | get --optional $type | default "")
            }
        }
        | sort-by size --reverse
        | table --index false | str trim --right
    )
    let removals = if $ctx.list {
        ["\nwould remove:" ...($items | each {|i| $"  [($i.type)] ($i.path | rel $ctx.root)" })]
    } else { [] }
    ["rmlint would flag (nothing was changed):" $summary ...$removals] | str join "\n"
}

def view-duplicates [ctx: record]: list<record> -> string {
    let rows = (
        $in
        | sort-by wasted --reverse
        | first $ctx.top
        | each {|i| {keep: ($i.keep | rel $ctx.root), copies: $i.copies, wasted: $i.wasted} }
        | table --index false | str trim --right
    )
    $"\nlargest duplicate groups \(top ($ctx.top)\):\n($rows)"
}

def view-caches [ctx: record]: list<record> -> string {
    let items = $in
    let total = ($items | get size | math sum)
    let rows = ($items | sort-by size --reverse | first $ctx.top | select name size | table --index false | str trim --right)
    [
        $"\nlargest caches in ($ctx.caches) \(($total) total\):"
        $rows
        "  apps rebuild caches; clear one while its app is closed."
        $"  browse and pick interactively: dua i '($ctx.caches)'"
    ] | str join "\n"
}

def view-docker []: list<record> -> string {
    [
        "\ndocker:"
        ($in | select item size reclaimable | table --index false | str trim --right)
        "  inspect first: docker system df -v · dangling images only: docker image prune"
    ] | str join "\n"
}

def view-backups []: list<record> -> string {
    [
        "\nbackup copies:"
        ($in | select path size | table --index false | str trim --right)
        "  confirm a copy exists elsewhere (NAS, the source machine) before moving it off this disk"
    ] | str join "\n"
}

def next-steps [root: string]: nothing -> string {
    $"
next steps \(all read-only\):
  full list:         just disk-doctor ($root) --list
  big files only:    rmlint ($root) --size 10M -o json:/tmp/rmlint.json
  protect a folder:  rmlint new/ // keep/ --keep-all-tagged --must-match-tagged -o json:/tmp/rmlint.json
  preview a script:  rmlint ($root) -o sh:/tmp/rmlint.sh && /tmp/rmlint.sh -n
docs: https://rmlint.readthedocs.io/en/latest/tutorial.html"
}

def rel [root: string]: string -> string {
    str replace $"($root)/" ""
}
