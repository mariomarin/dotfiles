# Claude Helper Functions for Nushell
# Based on John Lindquist's helpers from the Claude workshop
# Ported from zsh to nushell

# MCP-based Claude with container-use enforcement
export def cl [...args] {
    let allowed_tools = [
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
    ] | str join ","

    let system_prompt = "You are operating in an MCP environment. Always use container-use for ALL operations. Create and manage isolated environments for different tasks. Use checkpoints to save state between operations."

    claude --mcp-env --allowed-tools $allowed_tools --append-system-prompt $system_prompt ...$args
}

# Improve prompt engineering
export def improve [...args] {
    let user_prompt = ($args | str join " ")

    let improve_prompt = $"Please improve the following prompt to make it more precise, actionable, and effective for an AI assistant like yourself:

Original prompt: \"($user_prompt)\"

Provide an improved version that:
1. Clarifies any ambiguous language
2. Adds specific context or constraints if helpful
3. Structures the request for optimal AI understanding
4. Maintains the original intent

Return ONLY the improved prompt, no explanation."

    claude --model sonnet $improve_prompt
}

# Opus with clipboard content
export def popus [...args] {
    # Check clipboard command based on OS
    let clipboard_cmd = if (sys host | get name) == "Windows" {
        "powershell.exe -command Get-Clipboard"
    } else if (which pbpaste | is-not-empty) {
        "pbpaste"
    } else if (which xclip | is-not-empty) {
        "xclip -selection clipboard -o"
    } else if (which xsel | is-not-empty) {
        "xsel --clipboard --output"
    } else {
        error make {msg: "No clipboard tool found. Install xclip or xsel on Linux."}
    }

    let clipboard_content = (bash -c $clipboard_cmd | str trim)

    if ($clipboard_content | is-empty) {
        error make {msg: "Clipboard is empty"}
    }

    claude --model opus $clipboard_content ...$args
}

# Opus with dangerous permissions skipped
export def dopus [...args] {
    claude --model opus --dangerously-skip-permissions ...$args
}

# Opus with specific MCP tools and skip permissions
export def copus [...args] {
    let allowed_tools = "TodoWrite,Task,WebSearch,WebFetch,Read,Write,Edit"

    claude --model opus --allowed-tools $allowed_tools --dangerously-skip-permissions ...$args
}

# Fun Deadpool-style Claude
export def claudepool [...args] {
    let deadpool_prompt = "Talk like a caffeinated Deadpool with sadistic commentary and comically PG-13 rated todo lists. Break the fourth wall often. Be helpful but sarcastic. Reference chimichangas when appropriate."

    claude --append-system-prompt $deadpool_prompt ...$args
}

# Claude usage statistics
export def ccusage [] {
    print "Claude usage tracking:"
    print "- Install claude-powerline: npm install -g claude-powerline"
    print "- Or check ~/.config/claude/usage.json if available"
    print "- Consider setting up cost alerts in your Claude settings"
}

# Quick Claude help
export def claude-help [] {
    print "Claude Helper Functions:"
    print "  cl         - Claude with MCP container-use enforcement"
    print "  improve    - Improve a prompt for better AI understanding"
    print "  popus      - Run opus model with clipboard content"
    print "  dopus      - Run opus with dangerous permissions skipped"
    print "  copus      - Run opus with specific MCP tools"
    print "  claudepool - Fun Deadpool-style Claude personality"
    print "  ccusage    - Show Claude usage statistics"
}

# Aliases
export alias clhelp = claude-help
