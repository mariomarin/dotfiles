# Nushell Environment Config File
#
# version = "0.104.0"

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# -----------------------------------------------------------------------------
# NUPM (Nushell Package Manager) CONFIGURATION
# -----------------------------------------------------------------------------
$env.NUPM_HOME = ($nu.home-path | path join '.local' 'share' 'nupm')

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
    ($nu.default-config-dir | path join 'modules')
    ($nu.data-dir | path join 'completions')
    ($env.NUPM_HOME | path join 'nupm')  # Fixed: nupm module is at nupm/nupm/ not nupm/modules/
    ($env.NUPM_HOME | path join 'modules')
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# -----------------------------------------------------------------------------
# PATH CONFIGURATION
# -----------------------------------------------------------------------------
# Cross-platform PATH setup
let path_var = if ($nu.os-info.name == "windows") { "Path" } else { "PATH" }
let path_additions = [
    ($nu.home-path | path join '.local' 'bin')
    ($nu.home-path | path join 'go' 'bin')
    ($env.NUPM_HOME | path join 'scripts')
]

if ($nu.os-info.name == "windows") {
    $env.Path = ($env.Path | split row (char esep) | append $path_additions | uniq)
} else if ($nu.os-info.name == "macos") {
    $env.PATH = ($env.PATH | split row (char esep) | prepend $path_additions | prepend ['/opt/homebrew/bin' '/usr/local/bin'] | uniq)
} else {
    $env.PATH = ($env.PATH | split row (char esep) | prepend $path_additions | uniq)
}

# -----------------------------------------------------------------------------
# OH-MY-POSH PROMPT
# -----------------------------------------------------------------------------
# Oh-my-posh integration (cross-platform)
if (which oh-my-posh | is-not-empty) {
    $env.POSH_THEME = ($nu.default-config-dir | path join 'oh-my-posh' 'themes' 'spaceship.omp.json')
    oh-my-posh init nu --config $env.POSH_THEME | save --force ($nu.default-config-dir | path join 'oh-my-posh.nu')
}

# -----------------------------------------------------------------------------
# ADDITIONAL ENVIRONMENT VARIABLES
# -----------------------------------------------------------------------------
$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'

# OS-specific environment
if ($nu.os-info.name == "linux") {
    $env.BROWSER = 'firefox'
} else if ($nu.os-info.name == "macos") {
    $env.BROWSER = 'open'
}
