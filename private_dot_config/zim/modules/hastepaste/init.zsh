# Hastebin-compatible paste functions
# Requires HASTE_SERVER environment variable (e.g., "paste.example.com")

# Only proceed if HASTE_SERVER is set
if [[ -z ${HASTE_SERVER} ]]; then
  print -P "%F{yellow}Warning: HASTE_SERVER not set. Set it in .env.work to enable hastepaste functions.%f" >&2
  return 0
fi

# Check for curl
(( ${+commands[curl]} )) || {
  print -P "%F{red}Error: curl is required for hastepaste functions%f" >&2
  return 1
}

#
# Functions
#

# Paste content to Haste server
# Usage: hastepaste [extension]
hastepaste() {
  local S="https" H="${HASTE_SERVER}" P="" L="$1"
  local SHP="${S}://${H}${P}/"
  curl -X POST -s --data-binary @- "${SHP}documents" \
    | awk -F '"' 'b{ b="."b }; {print a$4b}' a="${SHP}" b="${L}"
}

# Execute command and paste output to Haste server
# Usage: capture_command 'command with args'
capture_command() {
  if (( $# != 1 )); then
    print -P "%F{red}Error: capture_command requires exactly one argument%f" >&2
    return 1
  fi
  local command="$1"
  # Execute command and output to terminal and to hastepaste with ASCII escape codes removed.
  # The `| cat` at the end enforces `hastepaste` outputs the URL before the PS1 prompt.
  # Use sed -E for portable POSIX extended regex (works on both GNU and BSD sed)
  { print "[${PWD}] ${command}"; eval "$command"; } |& tee >(sed -E "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGKHJsu]//g" | hastepaste) | cat
}

# Pipe output through tee to both terminal and Haste server
# Usage: some_command | pipe_haste
pipe_haste() {
  tee >(sed -E "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGKHJsu]//g" | hastepaste | cat)
}

# Alternative alias for convenience
alias hpaste='hastepaste'
