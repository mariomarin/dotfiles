##############################
# Setup addition keybindings #
##############################

# prefix the table that the bind command uses by default, so:
# `bind` and `bind`

# Move panes.
bind -r < swap-pane -U # swap current pane with the previous one
bind -r > swap-pane -D # swap current pane with the next one

# Kill windows without prompt.
bind x kill-window

# Kill panes without prompt.
bind X kill-pane

# Jump search mode with prefix.
bind / copy-mode \; send-keys '/'
bind ? copy-mode \; send-keys '?'

# Launch command prompt.
bind : command-prompt

# Show clock.
bind t clock-mode

# Launch tree mode.
bind w choose-tree -Zw

# Prefix alternates for root bindings.

# easier and faster switching between next/prev window
bind p select-window -t :- # Previous window.
bind n select-window -t :+ # Next window.

# -- buffers -------------------------------------------------------------------
bind b list-buffers  # list paste buffers
bind p paste-buffer  # paste from the top paste buffer
bind P choose-buffer 
# choose which buffer to paste from
bind P choose-buffer "paste-buffer -b '%%' -s ''" 

# create session
bind C-c new-session

# find session
bind C-f command-prompt -p find-session 'switch-client -t %%'

# split current window horizontally
bind - split-window -v
# split current window vertically
bind _ split-window -h

# window navigation
unbind n
unbind p
bind -r C-h previous-window # select previous window
bind -r C-l next-window     # select next window
bind -n M-Tab last-window   # move to last active window

# Switch panes.
# Use Alt to switch panes
bind M-h select-pane -L
bind M-j select-pane -D
bind M-k select-pane -U
bind M-l select-pane -R

# pane navigation
# Old settings
bind -r h select-pane -L  # move left
bind -r j select-pane -D  # move down
bind -r k select-pane -U  # move up
bind -r l select-pane -R  # move right
bind > swap-pane -D       # swap current pane with the next one
bind < swap-pane -U       # swap current pane with the previous one

# Switch windows.
bind M-p select-window -t :- # Previous window.
bind M-n select-window -t :+ # Next window.

# Toggle zoom.
bind M-z resize-pane -Z

# Resize panes.
bind M-H resize-pane -L 2
bind M-J resize-pane -D 1
bind M-K resize-pane -U 1
bind M-L resize-pane -R 2

bind -r H resize-pane -L 2
bind -r J resize-pane -D 2
bind -r K resize-pane -U 2
bind -r L resize-pane -R 2
