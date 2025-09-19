# list of plugins and settings
set-environment -g TMUX_PLUGIN_MANAGER_PATH "~/.local/share/tmux/plugins"

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'

# minimal theme
set -g @plugin 'niksingh710/minimal-tmux-status'
# Make the status line pretty and add some modules
set -g status-right-length 100
set -g status-left-length 100
set -g status-left ""
#set -g @minimal-tmux-bg "#DF8E1D" # catpuccine orange
set -g @minimal-tmux-bg "#E65050" # ayu dark red

# restore vim and nvim sessions as well
set -g @plugin 'tmux-plugins/tmux-resurrect'
# for vim
set -g @resurrect-strategy-vim 'session'
set -g @resurrect-processes '"vim->vim +SLoad"'
# for neovim
set -g @resurrect-strategy-nvim 'session'
set -g @resurrect-processes '"nvim->nvim +SLoad"'

set -g @resurrect-capture-pane-contents 'on'

# Automatic restore
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'
set -g @continuum-boot 'on'

# copy/pasting tmux like vimium/vimperator
set -g @plugin 'Morantron/tmux-fingers'
# Configuration for tmux-fingers
# Start tmux fingers by pressing Alt+F
bind -n M-f run -b "#{@fingers-cli} start #{pane_id}"
# Start tmux fingers in jump mode by pressing Alt+J
bind -n M-j run -b "#{@fingers-cli} start #{pane_id} --mode jump"

# i3wm like navigation with TAB key
set -g @plugin 'farzadmf/tmux-tilish'
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

# Quick session and pane navigation with harpoon
# Note: M-h conflicts with tmux-tilish navigation, so we use custom bindings
set -g @plugin 'Chaitanyabsprip/tmux-harpoon'
# Keep default jump binding
# C-h: Fuzzy-jump to saved session/pane
# Override conflicting bindings:
set -g @harpoon_key_append1 'C-S-a'  # Add current session (was C-S-h)
set -g @harpoon_key_append2 'M-a'    # Add current session + pane (was M-h)
# C-e: Edit saved list (no conflict)

# Search your tmux scrollback buffer using fzf
# To use tmux-fuzzback, start it in a tmux session by typing prefix + ?
set -g @plugin 'roosta/tmux-fuzzback'

# quickly select, copy/insert text without a mouse
set -g @plugin 'laktak/extrakto'

# don't exit from tmux when closing a session
set -g detach-on-destroy off
# skip "kill-pane 1? (y/n)" prompt
bind-key x kill-pane
