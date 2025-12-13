# Tmux plugins - loaded from nix (/run/current-system/sw/share/tmux-plugins/)
# Plugin packages defined in nix/common/modules/cli-tools.nix

# ── Plugin settings (must be set before loading plugins) ───────────────

# minimal-tmux-status theme
set -g status-right-length 100
set -g status-left-length 100
set -g status-left ""
#set -g @minimal-tmux-bg "#DF8E1D" # catpuccin orange
set -g @minimal-tmux-bg "#E65050" # ayu dark red

# tmux-resurrect: restore vim/nvim sessions
# for vim
set -g @resurrect-strategy-vim 'session'
# for neovim - using LazyVim's persistence.nvim
set -g @resurrect-strategy-nvim 'session'
# Combined processes configuration (single line to avoid overwriting)
set -g @resurrect-processes '"vim->vim +SLoad" "nvim->nvim"'
set -g @resurrect-capture-pane-contents 'on'

# tmux-continuum: automatic save/restore
set -g @continuum-restore 'on'
set -g @continuum-boot 'on'
# Start tmux server without creating a session (let sesh manage sessions)
set -g @continuum-systemd-start-cmd 'start-server'

# tmux-fingers: vimium-like copy/paste
# Use system clipboard (respects tmux's copy-command setting)
set -g @fingers-use-system-clipboard 1
# Custom patterns for upterm SSH strings (with base64 tokens)
set -g @fingers-pattern-0 'ssh [a-zA-Z0-9]+:[a-zA-Z0-9+/=]+@[a-zA-Z0-9.-]+'

# tmux-tilish: i3-like navigation
set -g @tilish-dmenu 'on'
set -g @tilish-new_pane '"'
# Enable smart splits for resize with vim awareness
set -g @tilish-smart-splits 'on'
# Configure resize keys to match Omarchy keybindings:
# Alt+Equal = grow left, Alt+Minus = grow right
# Alt+Shift+Equal = grow down, Alt+Shift+Minus = grow up
# Format: left/down/up/right (single step resize)
set -g @tilish-smart-splits-dirs '= + _ -'
# Disable large resize steps (not needed)
set -g @tilish-smart-splits-dirs-large ''

# Seamless tmux/vim navigation with clipboard sync
# Using aserowy/tmux.nvim on the Neovim side
# Navigation keybindings are handled by Neovim
# Note: tmux-tilish navigation (M-hjkl) still works for non-Neovim panes

# tmux-harpoon: quick session/pane navigation
# Note: M-h conflicts with tmux-tilish navigation, so we use custom bindings
# C-h: Fuzzy-jump to saved session/pane (default, no conflict)
# C-e: Edit saved list (no conflict)
# Override conflicting bindings:
set -g @harpoon_key_append1 'C-S-a'  # Add current session (was C-S-h)
set -g @harpoon_key_append2 'M-a'    # Add current session + pane (was M-h)

# tmux-fuzzback: search scrollback buffer using fzf
# Start with: prefix + ?

# tmux-extrakto: quickly select, copy/insert text without a mouse

# ── Load plugins from nix ──────────────────────────────────────────────

run-shell /run/current-system/sw/share/tmux-plugins/sensible/sensible.tmux
run-shell /run/current-system/sw/share/tmux-plugins/yank/yank.tmux
run-shell /run/current-system/sw/share/tmux-plugins/resurrect/resurrect.tmux
run-shell /run/current-system/sw/share/tmux-plugins/continuum/continuum.tmux
run-shell /run/current-system/sw/share/tmux-plugins/tmux-fingers/tmux-fingers.tmux
run-shell /run/current-system/sw/share/tmux-plugins/tilish/tilish.tmux
run-shell /run/current-system/sw/share/tmux-plugins/tmux-harpoon/harpoon.tmux
run-shell /run/current-system/sw/share/tmux-plugins/fuzzback/fuzzback.tmux
run-shell /run/current-system/sw/share/tmux-plugins/extrakto/extrakto.tmux
run-shell /run/current-system/sw/share/tmux-plugins/minimal-tmux-status/minimal.tmux

# ── Custom keybindings ─────────────────────────────────────────────────

# tmux-fingers: Alt+F to start, Alt+J for jump mode
bind -n M-f run -b "#{@fingers-cli} start #{pane_id}"
bind -n M-j run -b "#{@fingers-cli} start #{pane_id} --mode jump"

# ── General settings ───────────────────────────────────────────────────

# don't exit from tmux when closing a session
set -g detach-on-destroy off
# skip "kill-pane 1? (y/n)" prompt
bind-key x kill-pane
