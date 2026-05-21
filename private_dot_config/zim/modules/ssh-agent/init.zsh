autoload -Uz add-zsh-hook

# Reachable agent socket?
# ssh-add -l exit codes: 0=has keys, 1=no keys, 2=can't contact agent
_ssh_sock_ok() {
  [[ -n $1 && -S $1 ]] || return 1
  SSH_AUTH_SOCK=$1 ssh-add -l </dev/null >/dev/null 2>&1
  (( $? == 0 || $? == 1 ))
}

# Best socket: forwarded (newest, ours) → current → desktop/systemd fallbacks
_ssh_best_sock() {
  local sock
  local -a forwarded fallbacks

  setopt localoptions extended_glob

  forwarded=(/tmp/(agent.*|*/agent.*)(#qN=Uom))
  for sock in $forwarded; do
    _ssh_sock_ok "$sock" || continue
    REPLY=$sock
    return 0
  done

  if _ssh_sock_ok "$SSH_AUTH_SOCK"; then
    REPLY=$SSH_AUTH_SOCK
    return 0
  fi

  fallbacks=(
    /run/user/$EUID/gcr/ssh
    /run/user/$EUID/keyring/ssh
    /run/user/$EUID/ssh-agent
  )

  for sock in $fallbacks; do
    _ssh_sock_ok "$sock" || continue
    REPLY=$sock
    return 0
  done

  return 1
}

_update_ssh_auth_sock() {
  _ssh_best_sock || return 0
  [[ $REPLY == $SSH_AUTH_SOCK ]] || export SSH_AUTH_SOCK=$REPLY
}

_ssh_auth_sock_preexec() {
  case $1 in
    (aws*|kubectl*|helm*|k9s*|terraform*|ssh*|scp*|sftp*|git*)
      _update_ssh_auth_sock
      ;;
  esac
}

add-zsh-hook -d preexec _ssh_auth_sock_preexec 2>/dev/null
add-zsh-hook    preexec _ssh_auth_sock_preexec

_update_ssh_auth_sock
