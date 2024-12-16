# Settings
#

# set C-a as prefix
set -g prefix C-a

# Mouse support.
set-option -g mouse on

# Start window numbers at 1 to match keyboard order with tmux window order.
set-option -g base-index 1
set-option -g pane-base-index 1

# Keep commands history and set its limit.
set-option -g history-file ~/.tmux/cache/history
