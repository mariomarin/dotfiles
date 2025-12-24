#!/usr/bin/env zsh
# zsh-vi-mode configuration
# This file should be sourced after zsh-vi-mode is loaded

# ── System clipboard integration ─────────────────────────────────────────────
ZVM_SYSTEM_CLIPBOARD_ENABLED=true

# Platform-specific clipboard commands
if [[ "$OSTYPE" == darwin* ]]; then
  # macOS: auto-detection works (pbcopy/pbpaste)
  :
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
  # WSL: use Windows clipboard
  ZVM_CLIPBOARD_COPY_CMD='clip.exe'
  ZVM_CLIPBOARD_PASTE_CMD='powershell.exe -NoProfile -Command Get-Clipboard'
elif [[ -n "$WAYLAND_DISPLAY" ]]; then
  # Wayland: auto-detection works (wl-copy/wl-paste)
  :
elif [[ -n "$DISPLAY" ]]; then
  # X11: auto-detection works (xclip/xsel)
  :
fi

# Function to be executed after zsh-vi-mode is initialized
function zvm_after_init() {
  # Re-enable fzf key bindings that might be overridden by zsh-vi-mode
  # Note: fzf is loaded via zimfw module, but we need to restore bindings
  if (( ${+functions[fzf-file-widget]} )); then
    bindkey '^T' fzf-file-widget
  fi
  # Skip fzf-history-widget if atuin is available (atuin replaces it)
  if (( ${+functions[fzf-history-widget]} )) && ! (( ${+commands[atuin]} )); then
    bindkey '^R' fzf-history-widget
  fi
  if (( ${+functions[fzf-cd-widget]} )); then
    bindkey '\ec' fzf-cd-widget
  fi
  
  # Set up atuin bindings if available
  if (( ${+functions[setup_atuin_bindings]} )); then
    setup_atuin_bindings
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