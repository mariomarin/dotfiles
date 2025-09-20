# Vi-mode copy configuration
# Most bindings are handled by tmux-sensible and tmux-yank plugins
# Only custom bindings that aren't provided by plugins are defined here

# Visual selection (tmux-yank only provides copy, not selection)
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi V send-keys -X select-line

# Rectangle selection (not provided by plugins)
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle

# Jump to other end of selection
bind-key -T copy-mode-vi o send-keys -X other-end

# Clear selection without exiting copy mode
bind-key -T copy-mode-vi C-c send-keys -X clear-selection

# Additional navigation that plugins don't provide
bind-key -T copy-mode-vi H send-keys -X start-of-line
bind-key -T copy-mode-vi L send-keys -X end-of-line
bind-key -T copy-mode-vi % send-keys -X next-matching-bracket