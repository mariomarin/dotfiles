#!/usr/bin/env bun
// Simplified gitblade hook that enhances git commit commands

interface PreToolUsePayload {
  tool_name: string;
  tool_input: Record<string, any>;
  timestamp: string;
}

interface HookResponse {
  action: "continue" | "skip";
  message?: string;
  modified_input?: Record<string, any>;
}

export async function preToolUse(payload: PreToolUsePayload): Promise<HookResponse> {
  if (payload.tool_name !== "Bash") {
    return { action: "continue" };
  }
  
  const command = payload.tool_input.command?.trim() || "";
  
  // Intercept gitblade command
  if (command === "gitblade" || command === "blade" || command === "gb") {
    console.log("🗡️ Gitblade activated!");
    
    // Replace with our enhanced command
    return {
      action: "continue",
      modified_input: {
        ...payload.tool_input,
        command: `
# Check for changes
if git diff --quiet && git diff --cached --quiet; then
  echo "❌ No changes to commit"
  exit 1
fi

# Get changed files
CHANGED_FILES=$(git diff --name-only HEAD | head -20)
echo "📋 Changed files:"
echo "$CHANGED_FILES"
echo ""

# Create a focused diff summary
echo "📊 Creating diff summary..."
DIFF_SUMMARY=$(git diff HEAD --stat)
echo "$DIFF_SUMMARY"
echo ""

# Use Claude to analyze and create commits
echo "🤖 Asking Claude to analyze changes and create atomic commits..."
claude --model sonnet << 'EOF'
You are gitblade, a git commit assistant. Based on the git status and changes shown above, create atomic commits.

Rules:
1. Group related changes together
2. Use conventional commit format: type(scope): description (max 52 chars)
3. Create multiple small commits rather than one large commit
4. Be decisive and confident

For each commit, output exactly:
git add <files>
git commit -m "type(scope): description"

Now create the commits for the changes shown above.
EOF
`,
        description: "Run gitblade commit assistant"
      }
    };
  }
  
  // Intercept git commit to suggest using gitblade
  if (command.startsWith("git commit") && !command.includes("--amend")) {
    return {
      action: "skip",
      message: "💡 Tip: Use 'gitblade' or 'gb' for intelligent commit creation!\n\nGitblade will analyze your changes and create atomic, well-formatted commits.\n\nRun: gitblade"
    };
  }
  
  return { action: "continue" };
}

export default { preToolUse };