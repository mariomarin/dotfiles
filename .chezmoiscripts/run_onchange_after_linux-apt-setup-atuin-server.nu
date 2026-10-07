#!/usr/bin/env nu
# Enable and start the atuin sync server (linux-apt only, see .chezmoiignore).
# Restarts on unit or drop-in changes are reload-services' job
# (.chezmoidata/services.yaml), so this only has to succeed once.

if (which atuin | is-empty) or (which systemctl | is-empty) { exit 0 }

let result = (do { ^systemctl --user enable --now atuin-server.service } | complete)
match $result {
    {exit_code: 0} => null
    {stderr: $stderr} => {
        print -e $"⚠️  atuin-server not started: ($stderr | str trim)"
        print -e "   After login run: systemctl --user enable --now atuin-server.service"
    }
}
