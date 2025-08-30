#!/usr/bin/env bash
# Claude Helper Functions Module for Zimfw
# Based on John Lindquist's zshrc helpers from the Claude workshop

# Directory for module functions
CLAUDE_HELPERS_DIR="${0:h}/functions"

# Create functions directory if it doesn't exist
[[ -d "$CLAUDE_HELPERS_DIR" ]] || mkdir -p "$CLAUDE_HELPERS_DIR"

# Add to fpath for autoloading
fpath=("$CLAUDE_HELPERS_DIR" "${fpath[@]}")

# MCP-based Claude with container-use enforcement
cl() {
    local mcp_env="--mcp-env"

    # Build allowed tools list for containeruse
    local allowed_tools="containeruse__create_environment"
    allowed_tools+=",containeruse__run_command"
    allowed_tools+=",containeruse__checkpoint_environment"
    allowed_tools+=",containeruse__write_file"
    allowed_tools+=",containeruse__read_file"
    allowed_tools+=",containeruse__search_files"
    allowed_tools+=",containeruse__grep"
    allowed_tools+=",containeruse__list_files"
    allowed_tools+=",containeruse__delete_file"
    allowed_tools+=",containeruse__stop_environment"
    allowed_tools+=",containeruse__clear_checkpoints"
    allowed_tools+=",containeruse__rename_checkpoint"

    # System prompt for container-based development
    local system_prompt="You are operating in an MCP environment. "
    system_prompt+="Always use container-use for ALL operations. "
    system_prompt+="Create and manage isolated environments for different tasks. "
    system_prompt+="Use checkpoints to save state between operations."

    claude "$mcp_env" \
        --allowed-tools "$allowed_tools" \
        --append-system-prompt "$system_prompt" \
        "$@"
}

# Improve prompt engineering
improve() {
    local user_prompt="$*"

    local improve_prompt="Please improve the following prompt to make it more precise, actionable, and effective for an AI assistant like yourself:\n\n"
    improve_prompt+="Original prompt: \"$user_prompt\"\n\n"
    improve_prompt+="Provide an improved version that:\n"
    improve_prompt+="1. Clarifies any ambiguous language\n"
    improve_prompt+="2. Adds specific context or constraints if helpful\n"
    improve_prompt+="3. Structures the request for optimal AI understanding\n"
    improve_prompt+="4. Maintains the original intent\n\n"
    improve_prompt+="Return ONLY the improved prompt, no explanation."

    claude --model sonnet "$improve_prompt"
}

# Opus with clipboard content
popus() {
    # Check if pbpaste exists (macOS) or use xclip/xsel on Linux
    local clipboard_cmd
    if command -v pbpaste &> /dev/null; then
        clipboard_cmd="pbpaste"
  elif   command -v xclip &> /dev/null; then
        clipboard_cmd="xclip -selection clipboard -o"
  elif   command -v xsel &> /dev/null; then
        clipboard_cmd="xsel --clipboard --output"
  else
        echo "No clipboard tool found. Install xclip or xsel on Linux." >&2
        return 1
  fi

    local clipboard_content
    clipboard_content=$(eval "$clipboard_cmd")

    if [[ -z "$clipboard_content" ]]; then
        echo "Clipboard is empty" >&2
        return 1
  fi

    claude --model opus "$clipboard_content" "$@"
}

# Opus with dangerous permissions skipped
dopus() {
    claude --model opus --dangerously-skip-permissions "$@"
}

# Opus with specific MCP tools and skip permissions
copus() {
    local allowed_tools="TodoWrite,Task,WebSearch,WebFetch,Read,Write,Edit"

    claude --model opus \
        --allowed-tools "$allowed_tools" \
        --dangerously-skip-permissions \
        "$@"
}

# Claude with git commit assistance
claude_chain() {
    # Check if there are changes to commit
    if ! git diff --quiet || ! git diff --cached --quiet; then
        # Get list of changed files
        local changed_files
        changed_files=$(
                        git diff --name-only
                                              git diff --cached --name-only
    )

        # Build commit message prompt
        local prompt="Generate a git commit message for these changes:\n\n"
        prompt+="Changed files:\n$changed_files\n\n"
        prompt+="Diff:\n$(
                          git diff
                                    git diff --cached
    )\n\n"
        prompt+="Follow conventional commit format (feat:, fix:, docs:, etc.) with:\n"
        prompt+="1. A concise title\n"
        prompt+="2. A blank line\n"
        prompt+="3. A single paragraph (2-4 sentences) explaining what changed and why"

        # Get commit message from Claude
        local commit_msg
        commit_msg=$(claude --model sonnet "$prompt")

        if [[ -n "$commit_msg" ]]; then
            git add -A
            git commit -m "$commit_msg"
            echo "Committed with message:"
            echo "$commit_msg"
    else
            echo "Failed to generate commit message" >&2
            return 1
    fi
  else
        echo "No changes to commit" >&2
        return 1
  fi
}

# Fun Deadpool-style Claude
claudepool() {
    local deadpool_prompt="Talk like a caffeinated Deadpool with sadistic commentary "
    deadpool_prompt+="and comically PG-13 rated todo lists. Break the fourth wall often. "
    deadpool_prompt+="Be helpful but sarcastic. Reference chimichangas when appropriate."

    claude --append-system-prompt "$deadpool_prompt" "$@"
}

# Claude usage statistics
ccusage() {
    # This would integrate with Claude Powerline or similar tools
    # For now, provide a helpful message
    echo "Claude usage tracking:"
    echo "- Install claude-powerline: npm install -g claude-powerline"
    echo "- Or check ~/.config/claude/usage.json if available"
    echo "- Consider setting up cost alerts in your Claude settings"
}

# Quick Claude help
claude_help() {
    echo "Claude Helper Functions:"
    echo "  cl         - Claude with MCP container-use enforcement"
    echo "  improve    - Improve a prompt for better AI understanding"
    echo "  popus      - Run opus model with clipboard content"
    echo "  dopus      - Run opus with dangerous permissions skipped"
    echo "  copus      - Run opus with specific MCP tools"
    echo "  claude_chain - Git commit with semver format and paragraph"
    echo "  claudepool - Fun Deadpool-style Claude personality"
    echo "  ccusage    - Show Claude usage statistics"
}

# Alias for help
alias clhelp='claude_help'

# Export functions for use in subshells
export -f cl improve popus dopus copus claude_chain claudepool ccusage claude_help

# Set up completion for claude command if not already done
if ! command -v _claude &> /dev/null; then
    # Basic completion for claude command
    _claude() {
        # shellcheck disable=SC2034
        local -a claude_opts=(
            '--help:Show help'
            '--model:Specify model (opus, sonnet, haiku)'
            '--mcp-env:Use MCP environment'
            '--allowed-tools:Specify allowed tools'
            '--append-system-prompt:Append to system prompt'
            '--dangerously-skip-permissions:Skip permission checks'
            '--output-format:Output format (text, json, stream-json)'
            '--print:Print output'
            '--verbose:Verbose output'
    )

        _describe 'claude options' claude_opts
  }

    compdef _claude claude
fi

# Source local customizations if they exist
# shellcheck disable=SC1091
[[ -f "${0:h}/local.zsh" ]] && source "${0:h}/local.zsh"
