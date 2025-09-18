# Resize panes with Alt+Arrow keys
# This integrates with tmux.nvim for seamless resizing between tmux and Neovim

# Check if we're in vim
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?\.?(view|n?vim?x?)(-wrapped)?(diff)?'"

# Resize bindings that work with tmux.nvim
# These use Alt+Arrow keys to avoid conflicts with tmux-tilish navigation
bind-key -n 'M-Left'  if-shell "$is_vim" 'send-keys M-Left'  'resize-pane -L 5'
bind-key -n 'M-Down'  if-shell "$is_vim" 'send-keys M-Down'  'resize-pane -D 2'
bind-key -n 'M-Up'    if-shell "$is_vim" 'send-keys M-Up'    'resize-pane -U 2'
bind-key -n 'M-Right' if-shell "$is_vim" 'send-keys M-Right' 'resize-pane -R 5'

# Also handle resize in copy mode
bind-key -T copy-mode-vi M-Left  resize-pane -L 5
bind-key -T copy-mode-vi M-Down  resize-pane -D 2
bind-key -T copy-mode-vi M-Up    resize-pane -U 2
bind-key -T copy-mode-vi M-Right resize-pane -R 5