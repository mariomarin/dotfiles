# ~/.zim/modules/ai-cli/init.zsh

_ai_cli_log() {
  [[ -z "${AI_CLI_LOG:-}" ]] && return 0
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2
}

_ai_has_tunnel() {
  local pattern="ai-sandbox-services"

  if (( $+commands[rg] )); then
    pgrep -fl ghostunnel | rg -q "$pattern" || { _ai_cli_log "tunnel: absent (rg)"; return 1 }
    _ai_cli_log "tunnel: present (rg)"
    return 0
  fi

  pgrep -fl ghostunnel | grep -q "$pattern" || { _ai_cli_log "tunnel: absent (grep)"; return 1 }
  _ai_cli_log "tunnel: present (grep)"
  return 0
}

_ai_run() {
  _ai_cli_log "run: $*"

  if ! _ai_has_tunnel; then
    _ai_cli_log "run: via ai-sandbox"
    ai-sandbox "$@"
    return
  fi

  _ai_cli_log "run: direct"
  "$@"
}

ai-claude() {
  local default_claude_model="global.anthropic.claude-opus-4-5-20251101-v1:0"
  export CLAUDE_CODE_SUBAGENT_MODEL="$default_claude_model"
  export ANTHROPIC_MODEL="$default_claude_model"

  _ai_run claude --model "$default_claude_model" "$@"
}

ai-codex() {
  _ai_cli_log "tool: codex"
  _ai_run codex
}
