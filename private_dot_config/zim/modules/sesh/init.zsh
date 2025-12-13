# sesh - Smart session manager with tmux integration
# This module provides keybindings and functions for sesh

# Disable flow control (Ctrl+s/Ctrl+q) to free up Ctrl+s for sesh
stty -ixon 2>/dev/null

# Sesh session selector function
# Uses functional middle ground approach with early returns
sesh-sessions() {
  # Ensure we have terminal access
  exec </dev/tty
  exec <&1
  
  # Get session selection from user
  local session
  session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ') || return 0
  
  # Reset prompt
  zle reset-prompt > /dev/null 2>&1 || true
  
  # Early return if no session selected
  [[ -z "$session" ]] && return 0
  
  # Connect to selected session
  sesh connect "$session"
}

# Register the widget
zle -N sesh-sessions

# Bind Ctrl+g in all modes (g = go to session)
bindkey -M emacs '^g' sesh-sessions
bindkey -M vicmd '^g' sesh-sessions
bindkey -M viins '^g' sesh-sessions