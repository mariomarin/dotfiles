# =============================================================================
# POWERSHELL PROFILE
# Cross-shell configuration matching nushell/zsh setup
# =============================================================================

# -----------------------------------------------------------------------------
# MODULE IMPORTS
# -----------------------------------------------------------------------------

# Import PSReadLine for enhanced editing
Import-Module PSReadLine

# Import posh-git for git integration
Import-Module posh-git

# Import Terminal-Icons for file icons
Import-Module Terminal-Icons

# Import PSFzf for fuzzy finding
Import-Module PSFzf

# -----------------------------------------------------------------------------
# OH-MY-POSH PROMPT
# -----------------------------------------------------------------------------

# Initialize oh-my-posh with spaceship theme
$env:POSH_THEME = "$env:USERPROFILE\.config\nushell\oh-my-posh\themes\spaceship.omp.json"
oh-my-posh init pwsh --config $env:POSH_THEME | Invoke-Expression

# -----------------------------------------------------------------------------
# PSREADLINE CONFIGURATION - VI MODE
# -----------------------------------------------------------------------------

# Set vi mode to match nushell/zsh
Set-PSReadLineOption -EditMode Vi

# Set cursor shapes for different modes
Set-PSReadLineOption -ViModeIndicator Cursor
Set-PSReadLineOption -ViModeChangeHandler {
    param($mode)
    switch ($mode) {
        'Command' { [Console]::CursorSize = 100 }  # Block cursor
        'Insert'  { [Console]::CursorSize = 25 }   # Line cursor
    }
}

# Enable predictions
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# Colors
Set-PSReadLineOption -Colors @{
    Command            = 'Cyan'
    Parameter          = 'Green'
    Operator           = 'Yellow'
    Variable           = 'Magenta'
    String             = 'White'
    Number             = 'White'
    Type               = 'Blue'
    Comment            = 'DarkGray'
    InlinePrediction   = 'DarkGray'
}

# Keybindings matching nushell/zsh
Set-PSReadLineKeyHandler -Chord 'Ctrl+a' -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord 'Ctrl+e' -Function EndOfLine
Set-PSReadLineKeyHandler -Chord 'Ctrl+k' -Function KillLine
Set-PSReadLineKeyHandler -Chord 'Ctrl+u' -Function BackwardKillLine
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+l' -Function ClearScreen
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function AcceptSuggestion

# History search with Ctrl+N/P
Set-PSReadLineKeyHandler -Chord 'Ctrl+n' -Function NextHistory
Set-PSReadLineKeyHandler -Chord 'Ctrl+p' -Function PreviousHistory

# Tab completion menu
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Shift+Tab' -Function MenuComplete -Direction Backward

# -----------------------------------------------------------------------------
# PSFZF CONFIGURATION
# -----------------------------------------------------------------------------

# Enable PSFzf aliases and keybindings
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'

# -----------------------------------------------------------------------------
# ZOXIDE INTEGRATION
# -----------------------------------------------------------------------------

# Initialize zoxide for smart directory navigation
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# -----------------------------------------------------------------------------
# EZA ALIASES (matching nushell/zsh exa module)
# -----------------------------------------------------------------------------

if (Get-Command eza -ErrorAction SilentlyContinue) {
    $env:EZA_COLORS = 'da=1;34:gm=1;34:Su=1;34'

    function ls { eza --group-directories-first @args }
    function ll { eza -l --git --group-directories-first @args }
    function l { eza -la --git --group-directories-first @args }
    function lr { eza -l --git --tree --group-directories-first @args }
    function lx { eza -l --git --sort=extension --group-directories-first @args }
    function lk { eza -l --git --sort=size --group-directories-first @args }
    function lt { eza -l --git --sort=modified --group-directories-first @args }
    function lc { eza -l --git --sort=changed --group-directories-first @args }
}

# -----------------------------------------------------------------------------
# GIT ALIASES (using git-aliases module)
# -----------------------------------------------------------------------------

# Import git-aliases module (Oh My Zsh style git aliases)
if (Get-Module -ListAvailable -Name git-aliases) {
    Import-Module git-aliases -DisableNameChecking
}

# -----------------------------------------------------------------------------
# UTILITY FUNCTIONS
# -----------------------------------------------------------------------------

# Environment variables
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'

# Better defaults for common commands
function df { Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free, @{Name="Size";Expression={$_.Used+$_.Free}} | Format-Table -AutoSize }
function grep { rg @args }

# -----------------------------------------------------------------------------
# WAKATIME INTEGRATION (if available)
# -----------------------------------------------------------------------------

# WakaTime heartbeat function
function Send-WakaTimeHeartbeat {
    $wakatimeBin = "$env:USERPROFILE\.wakatime\wakatime-cli.exe"
    if (Test-Path $wakatimeBin) {
        $cmd = (Get-History -Count 1).CommandLine
        $project = if (Test-Path .wakatime-project) {
            Get-Content .wakatime-project -First 1
        } elseif (git rev-parse --show-toplevel 2>$null) {
            Split-Path -Leaf (git rev-parse --show-toplevel)
        } else {
            'Terminal'
        }

        Start-Job -ScriptBlock {
            param($bin, $cmd, $proj)
            & $bin --write --plugin "powershell-wakatime/0.1.0" --entity-type app --entity $cmd --project $proj --language powershell
        } -ArgumentList $wakatimeBin, $cmd, $project | Out-Null
    }
}

# Hook wakatime into prompt (runs before each command)
$ExecutionContext.InvokeCommand.PreCommandLookupAction = {
    param($CommandName, $CommandLookupEventArgs)
    Send-WakaTimeHeartbeat
}
