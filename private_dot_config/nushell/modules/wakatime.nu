# WakaTime integration for nushell
# Tracks terminal activity similar to wakatime-zsh-plugin

export def wakatime-heartbeat [] {
    # Skip if tracking disabled
    if ($env | get -i WAKATIME_DO_NOT_TRACK | default 0) == 1 {
        return
    }

    # Locate wakatime-cli binary
    let wakatime_bin = ($env | get -i ZSH_WAKATIME_BIN | default ($nu.home-path | path join '.wakatime' 'wakatime-cli'))

    if not ($wakatime_bin | path exists) {
        return
    }

    # Get the command being executed
    let cmd = (commandline | split row ' ' | first)

    if ($cmd | is-empty) {
        return
    }

    # Determine project name
    let project = if ('.wakatime-project' | path exists) {
        open .wakatime-project | lines | first
    } else {
        try {
            git rev-parse --show-toplevel | path basename
        } catch {
            'Terminal'
        }
    }

    # Build offline flag
    let offline_flag = if ($env | get -i WAKATIME_DISABLE_OFFLINE | default 0) == 1 {
        '--disable-offline'
    } else {
        ''
    }

    let timeout = ($env | get -i WAKATIME_TIMEOUT | default '5')

    # Send heartbeat in background
    try {
        ^$wakatime_bin --write `
            --plugin 'nushell-wakatime/0.1.0' `
            --entity-type app `
            --entity $cmd `
            --project $project `
            --language sh `
            --timeout $timeout `
            $offline_flag o> /dev/null e> /dev/null &
    }
}
