# =============================================================================
# NUSHELL VI MODE CONFIGURATION
# Attempting to match zsh-vi-mode capabilities
# =============================================================================
# version = "0.104.0"

# -----------------------------------------------------------------------------
# LOAD NUPM (Nushell Package Manager)
# -----------------------------------------------------------------------------
# Note: nupm module auto-loaded if in NU_LIB_DIRS (see env.nu)

# -----------------------------------------------------------------------------
# VI MODE
# -----------------------------------------------------------------------------
$env.config.edit_mode = 'vi'

# -----------------------------------------------------------------------------
# CURSOR SHAPES PER MODE
# Options: block, underscore, line, blink_block, blink_underscore, blink_line, inherit
# -----------------------------------------------------------------------------
$env.config.cursor_shape = {
    vi_insert: line        # Beam cursor in insert mode (like default vim)
    vi_normal: block       # Block cursor in normal mode
    emacs: line            # For when temporarily in emacs mode
}

# -----------------------------------------------------------------------------
# BUFFER EDITOR - External editor fallback (Ctrl+X Ctrl+E equivalent)
# This is your escape hatch for complex edits requiring text objects/surrounds
# -----------------------------------------------------------------------------
$env.config.buffer_editor = 'nvim'

# -----------------------------------------------------------------------------
# HISTORY CONFIGURATION
# -----------------------------------------------------------------------------
$env.config.history = {
    max_size: 100_000
    sync_on_enter: true
    file_format: "sqlite"  # Enables advanced history features
    isolation: false       # Share history across sessions
}

# -----------------------------------------------------------------------------
# COMPLETIONS
# -----------------------------------------------------------------------------
$env.config.completions = {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"     # or "prefix"
    external: {
        enable: true
        max_results: 100
        completer: null    # Will be set by carapace if available
    }
}

# -----------------------------------------------------------------------------
# COLOR CONFIG
# -----------------------------------------------------------------------------
$env.config.color_config = {
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    empty: blue
    bool: light_cyan
    int: white
    filesize: cyan
    duration: white
    datetime: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cell-path: white
    row_index: green_bold
    record: white
    list: white
    closure: green_bold
    glob: cyan_bold
    block: white
    hints: dark_gray
    search_result: { bg: red fg: white }
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_external_resolved: light_yellow_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    shape_glob_interpolation: cyan_bold
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: cyan_bold
    shape_keyword: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_match_pattern: green
    shape_matching_brackets: { attr: u }
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
    shape_vardecl: purple
    shape_raw_string: light_purple
    shape_garbage: {
        fg: white
        bg: red
        attr: b
    }
}

# -----------------------------------------------------------------------------
# KEYBINDINGS - Emulating zsh-vi-mode where possible
# -----------------------------------------------------------------------------

# Note: Core vi sequences (i, a, I, A, c, d, etc.) are hardcoded in Reedline
# and cannot be remapped. Only Ctrl/Alt sequences are configurable.

$env.config.keybindings = [
    # -------------------------------------------------------------------------
    # INSERT MODE BINDINGS
    # -------------------------------------------------------------------------

    # Ctrl+A - Move to beginning of line (like Emacs/zsh)
    {
        name: move_to_line_start
        modifier: control
        keycode: char_a
        mode: vi_insert
        event: { edit: MoveToLineStart }
    }

    # Ctrl+E - Move to end of line
    {
        name: move_to_line_end
        modifier: control
        keycode: char_e
        mode: vi_insert
        event: { edit: MoveToLineEnd }
    }

    # Ctrl+K - Kill to end of line
    {
        name: kill_line
        modifier: control
        keycode: char_k
        mode: vi_insert
        event: { edit: CutToLineEnd }
    }

    # Ctrl+U - Kill to beginning of line
    {
        name: unix_line_discard
        modifier: control
        keycode: char_u
        mode: vi_insert
        event: { edit: CutFromLineStart }
    }

    # Ctrl+W - Delete word backward
    {
        name: backward_kill_word
        modifier: control
        keycode: char_w
        mode: vi_insert
        event: { edit: BackspaceWord }
    }

    # Ctrl+H - Backspace (explicit)
    {
        name: backspace
        modifier: control
        keycode: char_h
        mode: vi_insert
        event: { edit: Backspace }
    }

    # Ctrl+L - Clear screen
    {
        name: clear_screen
        modifier: control
        keycode: char_l
        mode: [vi_insert, vi_normal]
        event: { send: ClearScreen }
    }

    # -------------------------------------------------------------------------
    # NORMAL MODE BINDINGS
    # -------------------------------------------------------------------------

    # Note: Ctrl+R is handled by atuin if available (see atuin.nu)
    # Falls back to built-in history menu if atuin is not installed
    # Ctrl+N/P for menu/history navigation defined below in MENU NAVIGATION section

    # -------------------------------------------------------------------------
    # MENU NAVIGATION
    # -------------------------------------------------------------------------

    # Tab - Completion menu
    {
        name: completion_menu
        modifier: none
        keycode: tab
        mode: [vi_insert, vi_normal]
        event: {
            until: [
                { send: menu name: completion_menu }
                { send: menunext }
                { edit: complete }
            ]
        }
    }

    # Shift+Tab - Previous completion
    {
        name: completion_previous
        modifier: shift
        keycode: backtab
        mode: [vi_insert, vi_normal]
        event: { send: menuprevious }
    }

    # Ctrl+N / Ctrl+P - Next/Previous in menus (emacs style)
    {
        name: menu_next
        modifier: control
        keycode: char_n
        mode: [vi_insert, vi_normal]
        event: {
            until: [
                { send: menudown }
                { send: down }
            ]
        }
    }
    {
        name: menu_prev
        modifier: control
        keycode: char_p
        mode: [vi_insert, vi_normal]
        event: {
            until: [
                { send: menuup }
                { send: up }
            ]
        }
    }
]

# -----------------------------------------------------------------------------
# MENUS CONFIGURATION
# -----------------------------------------------------------------------------
$env.config.menus = [
    {
        name: completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: {
            text: green
            selected_text: { attr: r }
            description_text: yellow
        }
    }
    {
        name: history_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 20
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
    }
    {
        name: ide_completion_menu
        only_buffer_difference: false
        marker: "❯ "
        type: {
            layout: ide
            min_completion_width: 0
            max_completion_width: 50
            max_completion_height: 10
            padding: 0
            border: true
            cursor_offset: 0
            description_mode: "prefer_right"
            min_description_width: 0
            max_description_width: 50
            max_description_height: 10
            description_offset: 1
        }
        style: {
            text: green
            selected_text: { attr: r }
            description_text: yellow
        }
    }
]

# -----------------------------------------------------------------------------
# HOOKS - Matching zsh-vi-mode hook system
# -----------------------------------------------------------------------------
use ($nu.default-config-dir | path join 'modules' 'wakatime.nu')

$env.config.hooks = {
    pre_prompt: [{ ||
        null
    }]
    pre_execution: [{ ||
        wakatime wakatime-heartbeat
    }]
    env_change: {
        PWD: [{ |before, after|
            null
        }]
    }
    display_output: "if (term size).columns >= 100 { table -e } else { table }"
    command_not_found: { ||
        null
    }
}

# -----------------------------------------------------------------------------
# SHELL INTEGRATION (OSC Codes)
# -----------------------------------------------------------------------------
# OSC codes for terminal integration with Alacritty and Windows Terminal
$env.config.shell_integration = {
    osc2: true    # Window/tab title with abbreviated path
    osc7: true    # Communicate working directory to terminal
    osc8: true    # Clickable hyperlinks in terminal output
    osc9_9: false # ConEmu path communication (conflicts with osc7)
    osc133: true  # Shell integration markers (prompt/command/output)
    osc633: true  # VS Code shell integration
    reset_application_mode: true # Reset mode for better SSH compatibility
}

# -----------------------------------------------------------------------------
# DISPLAY & UI SETTINGS
# -----------------------------------------------------------------------------
$env.config.show_banner = false
$env.config.use_ansi_coloring = true
$env.config.bracketed_paste = true
$env.config.float_precision = 2
$env.config.error_style = "fancy"

# LS configuration
$env.config.ls = {
    use_ls_colors: true
    clickable_links: true  # Enable clickable file paths (requires OSC 8)
}

# RM configuration
$env.config.rm = {
    always_trash: false  # Don't always use trash, allow permanent deletion
}

# Table configuration
$env.config.table = {
    mode: rounded  # Rounded table borders
    index_mode: always  # Always show row indices
    show_empty: true
    padding: { left: 1, right: 1 }
    trim: {
        methodology: wrapping
        wrapping_try_keep_words: true
        truncating_suffix: "..."
    }
    header_on_separator: false
}

# -----------------------------------------------------------------------------
# EXTERNAL TOOL INTEGRATIONS
# -----------------------------------------------------------------------------

# Atuin history (if available)
let atuin_init = ($nu.default-config-dir | path join 'atuin.nu')
if (which atuin | is-not-empty) and ($atuin_init | path exists) {
    source ~/.config/nushell/atuin.nu
}

# Zoxide directory navigation (if available)
let zoxide_init = ($nu.default-config-dir | path join 'zoxide.nu')
if (which zoxide | is-not-empty) and ($zoxide_init | path exists) {
    source ~/.config/nushell/zoxide.nu
}

# Carapace completer (if available)
if (which carapace | is-not-empty) {
    let carapace_completer = {|spans: list<string>|
        carapace $spans.0 nushell ...$spans
        | from json
        | if ($in | default [] | where value =~ '^-.*ERR' | is-empty) { $in } else { null }
    }
    $env.config.completions.external.completer = $carapace_completer
}

# -----------------------------------------------------------------------------
# NUPM MODULES
# -----------------------------------------------------------------------------

# Claude helpers (if claude command exists)
if (which claude | is-not-empty) {
    use ($nu.default-config-dir | path join 'modules' 'claude-helpers') *
}

# Sesh session manager (if sesh command exists)
if (which sesh | is-not-empty) {
    use ($nu.default-config-dir | path join 'modules' 'sesh') *
}

# Container-use completions (if container-use exists)
if (which container-use | is-not-empty) {
    use ($nu.default-config-dir | path join 'modules' 'container-use-completions') *
}

# AWS SSO CLI completions (if aws-sso exists)
if (which aws-sso | is-not-empty) {
    use ($nu.default-config-dir | path join 'modules' 'aws-sso-cli-completions') *
}

# Git branchless completions (if git-branchless exists)
if (which git-branchless | is-not-empty) {
    use ($nu.default-config-dir | path join 'modules' 'git-branchless-completions') *
}

# -----------------------------------------------------------------------------
# PLUGIN REGISTRATION
# -----------------------------------------------------------------------------
# Plugins installed via NixOS packages or nupm need to be registered

# Register clipboard plugin if installed via nupm
let clipboard_plugin = ($nu.home-path | path join '.local' 'share' 'nupm' 'modules' 'nu_plugin_clipboard' 'target' 'release' 'nu_plugin_clipboard')
if ($clipboard_plugin | path exists) {
    try {
        plugin add $clipboard_plugin
    } catch {
        # Plugin already registered or error - silently continue
    }
}

# NixOS plugins are automatically registered via system PATH

# -----------------------------------------------------------------------------
# COMMUNITY SCRIPTS
# -----------------------------------------------------------------------------

# Community scripts loaded via nu-scripts (installed by nupm)
# Individual scripts can be used with: use nu-scripts/git *

# -----------------------------------------------------------------------------
# EZA ALIASES (eza/exa replacement for ls)
# -----------------------------------------------------------------------------
if (which eza | is-not-empty) {
    $env.EZA_COLORS = 'da=1;34:gm=1;34:Su=1;34'

    alias ls = eza --group-directories-first
    alias ll = ls -l --git  # Long format with git status
    alias l = ll -a         # Long format, all files
    alias lr = ll -T        # Long format, recursive tree
    alias lx = ll --sort=extension  # Long format, sort by extension
    alias lk = ll --sort=size       # Long format, largest file size last
    alias lt = ll --sort=modified   # Long format, newest modification time last
    alias lc = ll --sort=changed    # Long format, newest status change last
}

# -----------------------------------------------------------------------------
# GIT ALIASES (git module with 'g' prefix)
# -----------------------------------------------------------------------------
if (which git | is-not-empty) {
    use ($nu.default-config-dir | path join 'modules' 'git.nu') *
}
