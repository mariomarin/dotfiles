#!/usr/bin/env bun
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

// Types for Claude hooks
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

// Git commit patterns
const COMMIT_PATTERNS = [
  /^git\s+commit/,
  /^gc\s+/,
  /^git\s+c\s+/
];

// Check if command is a git commit
function isGitCommit(command: string): boolean {
  return COMMIT_PATTERNS.some(pattern => pattern.test(command));
}

// Get git status and changes
async function getGitStatus() {
  try {
    const { stdout: status } = await execAsync("git status --porcelain");
    const { stdout: diff } = await execAsync("git diff HEAD");
    const { stdout: files } = await execAsync("git diff --name-only HEAD");
    
    return {
      hasChanges: status.trim().length > 0,
      changedFiles: files.trim().split('\n').filter(f => f),
      diffSize: diff.length,
      diff: diff
    };
  } catch (error) {
    return {
      hasChanges: false,
      changedFiles: [],
      diffSize: 0,
      diff: ""
    };
  }
}

// Create smart diff summary for large diffs
function createDiffSummary(diff: string, maxLength: number = 3000): string {
  if (diff.length <= maxLength) return diff;
  
  // Extract key parts: file headers and changed lines
  const lines = diff.split('\n');
  const summary = [];
  let currentFile = '';
  let addedCount = 0;
  let removedCount = 0;
  
  for (const line of lines) {
    if (line.startsWith('diff --git')) {
      if (currentFile) {
        summary.push(`${currentFile}: +${addedCount} -${removedCount}`);
      }
      currentFile = line.match(/b\/(.*?)$/)?.[1] || '';
      addedCount = 0;
      removedCount = 0;
    } else if (line.startsWith('+') && !line.startsWith('+++')) {
      addedCount++;
    } else if (line.startsWith('-') && !line.startsWith('---')) {
      removedCount++;
    }
  }
  
  if (currentFile) {
    summary.push(`${currentFile}: +${addedCount} -${removedCount}`);
  }
  
  return `DIFF SUMMARY (${diff.length} chars total):\n${summary.join('\n')}\n\n[Diff truncated for token limit]`;
}

// Generate commit plan
async function generateCommitPlan(gitStatus: any) {
  const diffContent = gitStatus.diffSize > 10000 
    ? createDiffSummary(gitStatus.diff)
    : gitStatus.diff;
    
  const prompt = `You are gitblade, a git commit assistant. Analyze these changes and create atomic commits.

Changed files:
${gitStatus.changedFiles.join('\n')}

Instructions:
1. Group related changes together
2. Create logical, atomic commits
3. Use conventional commit format: type(scope): description
4. Keep commit messages under 52 characters
5. Return a simple JSON array of commit objects

Format:
[
  {
    "files": ["file1.ts", "file2.ts"],
    "message": "feat(hooks): add gitblade commit assistant",
    "body": "Optional detailed description"
  }
]

Changes to analyze:
${diffContent}`;

  // Here we would call Claude API directly or return the plan
  // For now, return the prompt as the plan
  return {
    prompt,
    needsUserInput: true
  };
}

// Main hook function
export async function preToolUse(payload: PreToolUsePayload): Promise<HookResponse> {
  // Only intercept Bash commands
  if (payload.tool_name !== "Bash") {
    return { action: "continue" };
  }
  
  const command = payload.tool_input.command?.trim() || "";
  
  // Check if it's a git commit command
  if (!isGitCommit(command)) {
    return { action: "continue" };
  }
  
  console.log("🗡️  Gitblade activated! Analyzing your changes...");
  
  // Get git status
  const gitStatus = await getGitStatus();
  
  if (!gitStatus.hasChanges) {
    return {
      action: "skip",
      message: "❌ No changes to commit"
    };
  }
  
  // Generate commit plan
  const plan = await generateCommitPlan(gitStatus);
  
  if (plan.needsUserInput) {
    // Return modified command that will ask Claude to create commits
    return {
      action: "continue",
      modified_input: {
        ...payload.tool_input,
        command: `echo '${plan.prompt.replace(/'/g, "'\"'\"'")}' | claude --model sonnet`,
        description: "Generate commit plan with gitblade"
      }
    };
  }
  
  return { action: "continue" };
}

// Export for Claude hooks
export default { preToolUse };

// If running directly for testing
if (import.meta.main) {
  const testPayload: PreToolUsePayload = {
    tool_name: "Bash",
    tool_input: { command: "git commit -m 'test'" },
    timestamp: new Date().toISOString()
  };
  
  const result = await preToolUse(testPayload);
  console.log("Test result:", result);
}