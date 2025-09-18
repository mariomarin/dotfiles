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

# Seamless tmux/vim navigation (over SSH too!)
set -g @plugin 'sunaku/tmux-navigate'
# enable tilish bind keys for tmux-navigate
# <M-[hjkl]>
set -g @tilish-navigate 'on'

# Use fzf to manage your tmux work environment!
# To launch tmux-fzf, press prefix + F (Shift+F).
set -g @plugin 'sainnhe/tmux-fzf'

# Search your tmux scrollback buffer using fzf
# To use tmux-fuzzback, start it in a tmux session by typing prefix + ?
set -g @plugin 'roosta/tmux-fuzzback'

# quickly select, copy/insert text without a mouse
set -g @plugin 'laktak/extrakto'

# don't exit from tmux when closing a session
set -g detach-on-destroy off
# skip "kill-pane 1? (y/n)" prompt
bind-key x kill-pane
