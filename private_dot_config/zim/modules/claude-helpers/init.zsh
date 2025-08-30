# Claude Helper Functions Module for Zimfw
# Based on John Lindquist's zshrc helpers from the Claude workshop
# This is a Zsh module - no shebang needed as it's sourced, not executed

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
    # Early return if no changes
    if git diff --quiet && git diff --cached --quiet; then
        echo "No changes to commit" >&2
        return 1
    fi

    # Get list of changed files
    local changed_files
    changed_files=$(git diff --name-only; git diff --cached --name-only)

    # Build commit message prompt
    local prompt="You are a git commit assistant. Analyze these changes and suggest how to group them into logical, atomic commits.\n\n"
    prompt+="Changed files:\n$changed_files\n\n"
    prompt+="Instructions:\n"
    prompt+="1. Group related changes together (e.g., all changes to a specific feature/component)\n"
    prompt+="2. Never use 'git add -A' or stage unrelated changes together\n"
    prompt+="3. For each group, provide the files to stage and a conventional commit message\n\n"
    prompt+="Format your response EXACTLY like this for EACH commit group:\n"
    prompt+="COMMIT 1:\n"
    prompt+="FILES: file1.txt file2.txt file3.txt\n"
    prompt+="MESSAGE: type(scope): short description\n\n"
    prompt+="Detailed explanation (2-3 sentences).\n"
    prompt+="---\n\n"
    prompt+="Current changes:\n$(git diff 2>/dev/null; git diff --cached 2>/dev/null)"

    # Get commit plan from Claude
    local commit_plan
    commit_plan=$(claude --model sonnet "$prompt")

    if [[ -z "$commit_plan" ]]; then
        echo "Failed to generate commit plan" >&2
        return 1
    fi

    echo "📋 Commit plan generated:"
    echo "$commit_plan"
    echo ""
    
    # Parse and execute commits
    local in_commit=false
    local files=""
    local message=""
    local body=""
    local commit_count=0
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^COMMIT[[:space:]]+[0-9]+: ]]; then
            in_commit=true
            files=""
            message=""
            body=""
        elif [[ "$line" =~ ^FILES:[[:space:]]+(.*) ]] && [[ -n "${BASH_REMATCH[1]}" ]]; then
            files="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^MESSAGE:[[:space:]]+(.*) ]] && [[ -n "${BASH_REMATCH[1]}" ]]; then
            message="${BASH_REMATCH[1]}"
        elif [[ "$line" == "---" ]] && [[ $in_commit == true ]]; then
            # Execute the commit
            if [[ -n "$files" ]] && [[ -n "$message" ]]; then
                echo "🔄 Staging files: $files"
                # Split files and add them
                for file in $files; do
                    git add "$file" || {
                        echo "❌ Failed to stage $file" >&2
                        return 1
                    }
                done
                
                # Commit with message and body
                if [[ -n "$body" ]]; then
                    git commit -m "$message" -m "$body" || {
                        echo "❌ Failed to commit" >&2
                        return 1
                    }
                else
                    git commit -m "$message" || {
                        echo "❌ Failed to commit" >&2
                        return 1
                    }
                fi
                ((commit_count++))
                echo "✅ Committed: $message"
                echo ""
            fi
            in_commit=false
        elif [[ $in_commit == true ]] && [[ -n "$message" ]] && [[ "$line" != "FILES:"* ]] && [[ "$line" != "MESSAGE:"* ]]; then
            # Build commit body
            if [[ -n "$body" ]]; then
                body="$body\n$line"
            else
                body="$line"
            fi
        fi
    done <<< "$commit_plan"
    
    echo "🎉 Created $commit_count commits!"
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
    echo "  claude_chain - Analyze changes and create grouped commits automatically"
    echo "  claudepool - Fun Deadpool-style Claude personality"
    echo "  ccusage    - Show Claude usage statistics"
}

# Alias for help
alias clhelp='claude_help'

# In zsh, functions are automatically available in subshells
# No need to export them like in bash

# Set up completion for claude command if not already done
# Note: compdef is only available after compinit is called
# So we define the completion function but don't call compdef here
if ! command -v _claude &> /dev/null; then
    # Basic completion for claude command
    _claude() {
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

    # Store in fpath for autoloading
    local completion_file="${0:h}/functions/_claude"
    if [[ ! -f "$completion_file" ]]; then
        mkdir -p "${0:h}/functions"
        echo "#compdef claude" > "$completion_file"
        declare -f _claude >> "$completion_file"
  fi
    fpath=("${0:h}/functions" $fpath)
fi

# Source local customizations if they exist
# shellcheck disable=SC1091
[[ -f "${0:h}/local.zsh" ]] && source "${0:h}/local.zsh"
