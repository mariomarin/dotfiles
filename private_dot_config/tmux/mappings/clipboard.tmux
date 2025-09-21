# Normal mode clipboard bindings (replacing tmux-yank)

# Copy current command line to clipboard (prefix-y)
# Works with shells and REPLs by capturing the current line
bind-key y run-shell "tmux capture-pane -p -S -1 | tail -1 | tr -d '\n' | \
  $(tmux show-option -gvs copy-command)"

# Copy current pane's working directory to clipboard (prefix-Y)
bind-key Y run-shell "tmux display-message -p '#{pane_current_path}' | \
  $(tmux show-option -gvs copy-command)"