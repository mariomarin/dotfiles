# Jump search mode with prefix.
bind / copy-mode \; send-keys '/'
# bind ? copy-mode \; send-keys '?'  # Disabled - using tmux-fuzzback instead

# Launch command prompt.
bind : command-prompt

# Show clock.
bind t clock-mode

# Launch tree mode.
bind w choose-tree -Zw

# -- buffers -------------------------------------------------------------------
bind B list-buffers  # list paste buffers (moved to uppercase B)
bind p paste-buffer  # paste from the top paste buffer
bind P choose-buffer 
# choose which buffer to paste from
bind P choose-buffer "paste-buffer -b '%%' -s ''" 

# create session
bind C-c new-session

# find session
bind C-f command-prompt -p find-session 'switch-client -t %%'

# window navigation
bind -n M-Tab last-window   # move to last active window

# toggle status bar
bind-key b set-option status
