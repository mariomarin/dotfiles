# Settings
#

# set C-a as prefix
set -g prefix C-a

# Escape time for Alt/Meta key sequences (10ms allows ESC+key to be recognized as M-key)
# Override tmux-sensible's escape-time 0 which breaks Alt bindings:
# - At 0ms, tmux interprets ESC immediately, so "ESC j" becomes "Escape, j" not "M-j"
# - 10ms is imperceptible to humans but enough for the two-byte sequence to arrive
# - Recommended by Neovim's :checkhealth
set -sg escape-time 10

# Vi-style key bindings in copy mode (enables j/k navigation)
set-option -g mode-keys vi

# Mouse support
set-option -g mouse on

# Start window numbers at 1 to match keyboard order with tmux window order.
set-option -g base-index 1
set-option -g pane-base-index 1

# Keep commands history and set its limit.
set-option -g history-file ~/.tmux/cache/history

# Terminal settings for true color support
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",alacritty:RGB"

# OSC 52 clipboard support (copy to local clipboard over SSH)
set -g set-clipboard on
set -g allow-passthrough on
