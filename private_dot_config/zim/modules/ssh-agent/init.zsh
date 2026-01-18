# SSH agent socket detection
# Priority: forwarded agent (VMs) → GNOME Keyring → systemd

_find_ssh_sock() {
  local uid=$(id -u)

  # Forwarded agent (VMs) - prefer newest socket in /tmp
  local forwarded=$(find /tmp -maxdepth 2 -type s -name "agent.*" -user "$USER" 2>/dev/null \
    | xargs -r ls -t 2>/dev/null | head -1)
  if [[ -S "$forwarded" ]]; then
    echo "$forwarded"
    return
  fi

  # Desktop: GNOME Keyring
  if [[ -S "/run/user/$uid/gcr/ssh" ]]; then
    echo "/run/user/$uid/gcr/ssh"
    return
  fi
  if [[ -S "/run/user/$uid/keyring/ssh" ]]; then
    echo "/run/user/$uid/keyring/ssh"
    return
  fi

  # Headless: systemd ssh-agent
  if [[ -S "/run/user/$uid/ssh-agent" ]]; then
    echo "/run/user/$uid/ssh-agent"
  fi
}

_update_ssh_sock() {
  local sock=$(_find_ssh_sock)
  [[ -n "$sock" ]] && export SSH_AUTH_SOCK="$sock"
}

# Initialize on load
_update_ssh_sock
