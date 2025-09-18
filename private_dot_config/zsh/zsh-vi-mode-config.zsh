#!/usr/bin/env zsh
# zsh-vi-mode configuration
# This file should be sourced after zsh-vi-mode is loaded

# Function to be executed after zsh-vi-mode is initialized
function zvm_after_init() {
  # Re-enable fzf key bindings that might be overridden by zsh-vi-mode
  # Note: fzf is loaded via zimfw module, but we need to restore bindings
  if (( ${+functions[fzf-file-widget]} )); then
    bindkey '^T' fzf-file-widget
  fi
  if (( ${+functions[fzf-history-widget]} )); then
    bindkey '^R' fzf-history-widget
  fi
  if (( ${+functions[fzf-cd-widget]} )); then
    bindkey '\ec' fzf-cd-widget
  fi
  
  # Restore any custom key bindings
  bindkey '^P' history-substring-search-up
  bindkey '^N' history-substring-search-down
  bindkey '^y' autosuggest-accept
  
  # Additional bindings for case variations
  bindkey '^p' history-substring-search-down
  bindkey '^n' history-substring-search-up
}

# Ensure surround is enabled
zvm_after_init_commands+=(zvm_after_init)