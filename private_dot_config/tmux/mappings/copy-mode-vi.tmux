# Vi-mode copy configuration
# Selection bindings (not provided by tmux-yank)
# Copy bindings handled by tmux-yank plugin

# Visual selection
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi V send-keys -X select-line

# Rectangle selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle

# Jump to other end of selection
bind-key -T copy-mode-vi o send-keys -X other-end

# Clear selection without exiting copy mode
bind-key -T copy-mode-vi C-c send-keys -X clear-selection

# Additional navigation
bind-key -T copy-mode-vi H send-keys -X start-of-line
bind-key -T copy-mode-vi L send-keys -X end-of-line
bind-key -T copy-mode-vi % send-keys -X next-matching-bracket