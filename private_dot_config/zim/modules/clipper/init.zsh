# Clipper integration for Zsh
# Provides clipboard access over SSH via Clipper daemon
# See: https://github.com/wincent/clipper

# Clipper configuration
typeset -g CLIPPER_HOST="${CLIPPER_HOST:-localhost}"
typeset -gi CLIPPER_PORT="${CLIPPER_PORT:-8377}"

# Detect nc flags once at module load time
typeset -ga _CLIPPER_NC_CMD=(nc)

# Check if nc command exists
if (( ${+commands[nc]} )); then
  # Detect if nc supports -N flag (required on Ubuntu/Debian)
  # Check help output to avoid connecting to Clipper during detection
  if nc -h 2>&1 | grep -qF -- '-N'; then
    _CLIPPER_NC_CMD+=(-N)
  fi
fi

#
# Functions
#

# Copy stdin to clipboard via Clipper
# Works locally and remotely over SSH (via RemoteForward)
clip() {
  # Check if nc command exists
  (( ${+commands[nc]} )) || {
    print -P "%F{red}Error: nc (netcat) command not found%f" >&2
    return 1
  }

  # Send input to Clipper using pre-detected nc flags
  "${_CLIPPER_NC_CMD[@]}" "$CLIPPER_HOST" "$CLIPPER_PORT" || {
    print -P "%F{red}Error: Could not connect to Clipper at ${CLIPPER_HOST}:${CLIPPER_PORT}%f" >&2
    print -P "%F{yellow}Is Clipper running? Check: lsof -i :${CLIPPER_PORT}%f" >&2
    return 1
  }
}

# Copy file contents to clipboard via Clipper
# Usage: clipfile <filename>
clipfile() {
  # Validate arguments
  (( $# == 1 )) || {
    print -P "%F{red}Error: clipfile requires exactly one argument%f" >&2
    return 1
  }

  # Check file exists and is regular file
  [[ -f $1 ]] || {
    print -P "%F{red}Error: File not found: $1%f" >&2
    return 1
  }

  # Send file to clipboard
  < "$1" clip && print -P "%F{green}✓ Copied $1 to clipboard%f"
}

# Copy command output to clipboard and display it
# Usage: clipped <command>
clipped() {
  (( $# >= 1 )) || {
    print -P "%F{red}Error: clipped requires at least one argument%f" >&2
    return 1
  }

  # Execute command with output to both terminal and clipboard
  # Use direct execution to avoid eval injection risks
  "$@" | tee >(clip)
}

#
# Aliases
#

alias pclip='clip'  # Copy to clipboard (matches pbcopy naming)

# Source local customizations if they exist
[[ -f ${0:h}/local.zsh ]] && source "${0:h}/local.zsh"
