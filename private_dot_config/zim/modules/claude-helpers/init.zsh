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
    elif command -v xclip &> /dev/null; then
        clipboard_cmd="xclip -selection clipboard -o"
    elif command -v xsel &> /dev/null; then
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
    echo "  claudepool - Fun Deadpool-style Claude personality"
    echo "  ccusage    - Show Claude usage statistics"
}

# Alias for help
alias clhelp='claude_help'

# Source local customizations if they exist
# shellcheck disable=SC1091
[[ -f "${0:h}/local.zsh" ]] && source "${0:h}/local.zsh"