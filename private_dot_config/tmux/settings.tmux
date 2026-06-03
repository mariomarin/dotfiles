# Settings
#

# set C-a as prefix
set -g prefix C-a

# Force zsh as default shell for new windows/panes
# Works even if login shell is bash (corporate environments)
set -g default-shell /run/current-system/sw/bin/zsh

# Kanata + macOS adds >10ms jitter between ESC and char bytes
set -sg escape-time 50

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
set -ag terminal-overrides ",alacritty:RGB,ghostty:RGB"

# OSC 52 clipboard support (copy to actual client terminal, not host)
set -s set-clipboard external
set -as terminal-features ',ghostty:clipboard,alacritty:clipboard,xterm-256color:clipboard'
set -g allow-passthrough on
