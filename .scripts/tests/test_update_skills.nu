# Tests for update-skills.nu against a local bare repo (no network)
use std/assert

const SCRIPT = ".scripts/update-skills.nu"

def --wrapped git-q [dir: string, ...args: string] {
    ^git -C $dir -c user.name=test -c user.email=test@example.com ...$args | complete | ignore
}

def commit-all [dir: string] {
    git-q $dir add -A
    git-q $dir commit -q -m update
    ^git -C $dir rev-parse HEAD | str trim
}

# Upstream bare repo at <tmp>/remote/acme/skills, vendored dir at <tmp>/skills
def with-fixture [body: closure]: nothing -> record {
    let tmp = (mktemp -d)
    let work = $"($tmp)/work"
    mkdir $"($work)/skills/demo"
    git-q $work init -q -b main
    "MIT\n" | save $"($work)/LICENSE"
    "v1\n" | save $"($work)/skills/demo/SKILL.md"
    "other\n" | save $"($work)/README.md"
    let old = (commit-all $work)
    "v2\n" | save --force $"($work)/skills/demo/SKILL.md"
    "ref\n" | save $"($work)/skills/demo/extra.md"
    let new = (commit-all $work)
    mkdir $"($tmp)/remote/acme"
    ^git clone -q --bare $work $"($tmp)/remote/acme/skills" | complete | ignore

    let skills = $"($tmp)/skills"
    mkdir $"($skills)/demo"
    "v1\n" | save $"($skills)/demo/SKILL.md"
    "stale\n" | save $"($skills)/demo/stale.md"
    let ctx = {
        tmp: $tmp
        skills: $skills
        lock: $"($skills)/skills-lock.json"
        old: $old
        new: $new
    }
    let result = (do $body $ctx)
    rm -rf $tmp
    $result
}

def write-lock [ctx: record, rev: string, path: string = "skills/demo"] {
    {
        demo: {repo: "acme/skills", path: $path, rev: $rev}
    } | to json | save --force $ctx.lock
}

def run-update [ctx: record]: nothing -> record {
    do { nu -n $SCRIPT --lock $ctx.lock --base $"file://($ctx.tmp)/remote" } | complete
}

def "test up to date is silent no-op" [] {
    with-fixture {|ctx|
        write-lock $ctx $ctx.new
        let r = (run-update $ctx)
        assert equal $r.exit_code 0 $r.stderr
        assert equal $r.stdout ""
        assert ($"($ctx.skills)/demo/stale.md" | path exists)
        assert equal (open $ctx.lock | get demo.rev) $ctx.new
    }
}

def "test outdated replaces skill and bumps lock" [] {
    with-fixture {|ctx|
        write-lock $ctx $ctx.old
        let r = (run-update $ctx)
        assert equal $r.exit_code 0 $r.stderr
        assert equal ($r.stdout | str trim) $"- demo: https://github.com/acme/skills/compare/($ctx.old)...($ctx.new)"
        let files = (
            ls $"($ctx.skills)/demo"
            | get name
            | path basename
            | sort
        )
        assert equal $files [LICENSE SKILL.md extra.md]
        assert equal (open --raw $"($ctx.skills)/demo/SKILL.md") "v2\n"
        assert equal (open $ctx.lock | get demo.rev) $ctx.new
    }
}

def "test missing upstream path fails and keeps skill" [] {
    with-fixture {|ctx|
        write-lock $ctx $ctx.old "skills/missing"
        let r = (run-update $ctx)
        assert equal $r.exit_code 1
        assert ($r.stderr =~ "✗ demo: skills/missing not found upstream") $r.stderr
        assert ($"($ctx.skills)/demo/stale.md" | path exists)
        assert equal (open $ctx.lock | get demo.rev) $ctx.old
    }
}
