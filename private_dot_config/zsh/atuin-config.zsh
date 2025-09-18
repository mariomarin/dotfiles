#!/usr/bin/env zsh
# Atuin configuration for zsh-vi-mode compatibility
# This file configures atuin with custom bindings that work well with vi mode

# Only configure if atuin is available
if (( ${+commands[atuin]} )); then
  # Disable default bindings so we can set custom ones
  # This must be set before atuin is initialized by the zim module
  export ATUIN_NOBIND="true"
  
  # Note: Atuin automatically adds itself as a zsh-autosuggestions strategy
  # If you want to override this, configure it after the zim module loads
  
  # Function to set up atuin bindings after zsh-vi-mode is initialized
  function setup_atuin_bindings() {
    # Main search binding (replaces Ctrl+R)
    bindkey '^r' atuin-search
    
    # Up arrow bindings for terminal compatibility
    bindkey '^[[A' atuin-up-search
    bindkey '^[OA' atuin-up-search
    
    # Vi mode specific bindings
    # In insert mode
    bindkey -M viins '^r' atuin-search-viins
    bindkey -M viins '^[[A' atuin-up-search-viins
    bindkey -M viins '^[OA' atuin-up-search-viins
    
    # In command mode
    bindkey -M vicmd '/' atuin-search-vicmd
    bindkey -M vicmd 'k' atuin-up-search-vicmd
  }
  
  # Export the function so it can be called from zsh-vi-mode-config.zsh
  export -f setup_atuin_bindings 2>/dev/null || true
fi