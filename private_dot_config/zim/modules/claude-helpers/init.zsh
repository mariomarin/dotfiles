# Claude Helper Functions Module for Zimfw
# Based on John Lindquist's zshrc helpers from the Claude workshop
# This is a Zsh module - no shebang needed as it's sourced, not executed

# Directory for module functions
CLAUDE_HELPERS_DIR="${0:h}/functions"

# Create functions directory if it doesn't exist
[[ -d "$CLAUDE_HELPERS_DIR" ]] || mkdir -p "$CLAUDE_HELPERS_DIR"

# Add to fpath for autoloading
fpath=("$CLAUDE_HELPERS_DIR" "${fpath[@]}")

# Only proceed if claude command exists
if (( ! ${+commands[claude]} )); then
    return 0
fi

#
# Helper Functions
#

# Get clipboard content across platforms
_claude_get_clipboard() {
    local clipboard_cmd

    if (( $+commands[pbpaste] )); then
        clipboard_cmd="pbpaste"
    elif (( $+commands[xclip] )); then
        clipboard_cmd="xclip -selection clipboard -o"
    elif (( $+commands[xsel] )); then
        clipboard_cmd="xsel --clipboard --output"
    else
        echo "Error: No clipboard tool found. Install xclip or xsel." >&2
        return 1
    fi

    eval "$clipboard_cmd"
}

#
# Functions
#

# MCP-based Claude with container-use enforcement
cl() {
    local allowed_tools=(
        "containeruse__create_environment"
        "containeruse__run_command"
        "containeruse__checkpoint_environment"
        "containeruse__write_file"
        "containeruse__read_file"
        "containeruse__search_files"
        "containeruse__grep"
        "containeruse__list_files"
        "containeruse__delete_file"
        "containeruse__stop_environment"
        "containeruse__clear_checkpoints"
        "containeruse__rename_checkpoint"
    )

    local system_prompt="You are operating in an MCP environment. \
Always use container-use for ALL operations. \
Create and manage isolated environments for different tasks. \
Use checkpoints to save state between operations."

    claude --mcp-env \
        --allowed-tools "${(j:,:)allowed_tools}" \
        --append-system-prompt "$system_prompt" \
        "$@"
}

# Improve prompt engineering
improve() {
    [[ -z "$*" ]] && {
        echo "Error: No prompt provided" >&2
        return 1
    }

    local improve_prompt="Please improve the following prompt to make it more precise, actionable, and effective for an AI assistant like yourself:

Original prompt: \"$*\"

Provide an improved version that:
1. Clarifies any ambiguous language
2. Adds specific context or constraints if helpful
3. Structures the request for optimal AI understanding
4. Maintains the original intent

Return ONLY the improved prompt, no explanation."

    claude --model sonnet "$improve_prompt"
}

# Opus with clipboard content
popus() {
    local clipboard_content
    clipboard_content=$(_claude_get_clipboard) || return

    if [[ -z "$clipboard_content" ]]; then
        echo "Error: Clipboard is empty" >&2
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
    claude --model opus \
        --allowed-tools "TodoWrite,Task,WebSearch,WebFetch,Read,Write,Edit" \
        --dangerously-skip-permissions \
        "$@"
}

# Fun Deadpool-style Claude
claudepool() {
    local deadpool_prompt="Talk like a caffeinated Deadpool with sadistic commentary \
and comically PG-13 rated todo lists. Break the fourth wall often. \
Be helpful but sarcastic. Reference chimichangas when appropriate."

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
    echo "  claudepool - Fun Deadpool-style Claude personality"
    echo "  ccusage    - Show Claude usage statistics"
}

# Alias for help
alias clhelp='claude_help'

# Source local customizations if they exist
# shellcheck disable=SC1091
[[ -f "${0:h}/local.zsh" ]] && source "${0:h}/local.zsh"