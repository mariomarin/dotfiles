# Vi-mode copy configuration
# Native tmux clipboard integration without tmux-yank plugin

# Detect and set appropriate copy command for X11/Wayland
if-shell -b 'echo $XDG_SESSION_TYPE | grep -q wayland' \
  'set -s copy-command "wl-copy"' \
  'set -s copy-command "xclip -in -selection clipboard"'

# Visual selection
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi V send-keys -X select-line

# Rectangle selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle

# Copy bindings (replacing tmux-yank)
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
bind-key -T copy-mode-vi Y send-keys -X copy-line
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel

# Jump to other end of selection
bind-key -T copy-mode-vi o send-keys -X other-end

# Clear selection without exiting copy mode
bind-key -T copy-mode-vi C-c send-keys -X clear-selection

# Additional navigation that plugins don't provide
bind-key -T copy-mode-vi H send-keys -X start-of-line
bind-key -T copy-mode-vi L send-keys -X end-of-line
bind-key -T copy-mode-vi % send-keys -X next-matching-bracket