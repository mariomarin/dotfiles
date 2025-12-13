# Claude Helpers Zsh Module

A collection of helpful Claude Code functions based on John Lindquist's workshop demonstrations.

## Installation

Add to your `.zimrc`:

```zsh
# Add before the completion module
zmodule ${ZIM_CONFIG_FILE:h}/modules/claude-helpers
```

Then run:

```bash
zimfw install
```

## Functions

### Core Claude Functions

- **`cl`** - Claude with MCP container-use enforcement
  - Forces all operations through containerized environments
  - Includes checkpointing and isolated execution
  
- **`improve`** - Improve prompts for better AI understanding

  ```bash
  improve "help me fix this bug"
  # Returns: "Debug and resolve the error by analyzing stack trace and implementing a fix"
  ```

- **`popus`** - Run Opus model with clipboard content

  ```bash
  # Copy code to clipboard, then:
  popus "explain this code"
  ```

- **`dopus`** - Run Opus with dangerous permissions skipped

  ```bash
  dopus "analyze this entire codebase"
  ```

- **`copus`** - Run Opus with specific MCP tools enabled
  - Pre-configured with TodoWrite, Task, WebSearch, etc.

### Workflow Functions

- **`claude_chain`** - Generate git commits with Claude

  ```bash
  # Make changes, then:
  claude_chain
  # Automatically stages and commits with conventional format:
  # feat: add user authentication
  # 
  # Implemented JWT-based authentication system with login, logout, and token
  # refresh endpoints. This enables secure API access and session management
  # for the application.
  ```

- **`claudepool`** - Fun Deadpool personality mode

  ```bash
  claudepool "help me organize my tasks"
  # Get help with sarcastic commentary and chimichanga references
  ```

### Utility Functions

- **`ccusage`** - Show Claude usage statistics
- **`clhelp`** - Display help for all Claude functions

## Examples

### Container-based development

```bash
cl "create a FastAPI server with user authentication"
```

### Improve your prompts

```bash
improve "make a website"
# Returns: "Create a responsive website with specific requirements and tech stack"
```

### Quick code analysis

```bash
# Copy problematic code to clipboard
popus "find the bug and suggest a fix"
```

### Workflow automation

```bash
# After making changes
claude_chain  # Auto-generates and commits with appropriate message
```

## Configuration

Create `~/.config/zim/modules/claude-helpers/local.zsh` for personal customizations:

```zsh
# Example: Add your own Claude helper
my_claude() {
    claude --model sonnet --custom-flag "$@"
}
```

## Requirements

- Claude Code CLI installed and configured
- For clipboard functions: `pbpaste` (macOS) or `xclip`/`xsel` (Linux)
- Git (for `claude_chain`)

## Credits

Based on helper functions from John Lindquist's Claude workshop.
