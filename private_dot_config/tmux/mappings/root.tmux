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

# Resize panes.
bind M-H resize-pane -L 2
bind M-J resize-pane -D 1
bind M-K resize-pane -U 1
bind M-L resize-pane -R 2

bind -r H resize-pane -L 2
bind -r J resize-pane -D 2
bind -r K resize-pane -U 2
bind -r L resize-pane -R 2

bind-key -T prefix C-g split-window \
  "$SHELL --login -i -c 'navi --print | head -n 1 | tmux load-buffer -b tmp - ; tmux paste-buffer -p -t {last} -b tmp -d'"
