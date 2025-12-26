# Settings
#

# set C-a as prefix
set -g prefix C-a

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

# Extended keys support for CSI u sequences (kanata =+key bindings)
set -s extended-keys on
set -s extended-keys-format csi-u
set -as terminal-features 'alacritty:extkeys'

# OSC 52 clipboard support (copy to local clipboard over SSH)
set -g set-clipboard on
set -g allow-passthrough on
