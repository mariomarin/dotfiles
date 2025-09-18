#!/usr/bin/env zsh
# zsh-vi-mode configuration
# This file should be sourced after zsh-vi-mode is loaded

# Function to be executed after zsh-vi-mode is initialized
function zvm_after_init() {
  # Re-enable fzf key bindings that might be overridden
  [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
  
  # Restore any custom key bindings
  bindkey '^P' history-substring-search-up
  bindkey '^N' history-substring-search-down
  bindkey '^y' autosuggest-accept
}

# Ensure surround is enabled
zvm_after_init_commands+=(zvm_after_init)