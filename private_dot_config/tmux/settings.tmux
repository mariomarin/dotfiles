# Settings

# replace C-b by C-a instead of using both prefixes
set -gu prefix2
unbind C-a
set -g prefix C-a

# Start with non-login shell.
set-option -g default-command "$SHELL"

# Enable true colours
set-option -g -a terminal-overrides ",xterm-256color:Tc"

# Enable vi style key bindings in command mode.
set-option -g mode-keys vi
# set-option -g status-keys vi
# tmux-sensible already sets status-keys to emacs

# Mouse support.
set-option -g mouse on

# Keep commands history and set its limit.
set-option -g history-file ~/.tmux/cache/history

# Start window numbers at 1 to match keyboard order with tmux window order.
set-option -g base-index 1
set-option -g pane-base-index 1
