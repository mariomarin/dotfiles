#!/usr/bin/env bun
import { $ } from "bun";
import { readFile, writeFile } from "fs/promises";
import { join } from "path";
import { tmpdir } from "os";
import { config } from "./hooks.config.ts";

// Types
interface PreToolUsePayload {
  tool_name: string;
  tool_input: Record<string, any>;
  timestamp: string;
  session_id?: string;
}

interface PostToolUsePayload {
  tool_name: string;
  tool_input: Record<string, any>;
  tool_output: any;
  success: boolean;
  error?: string;
  timestamp: string;
}

interface HookResponse {
  action: "continue" | "skip";
  message?: string;
  modified_input?: Record<string, any>;
}

interface CommitPlan {
  files: string[];
  message: string;
  body?: string;
}

// State management for gitblade
const GITBLADE_STATE_FILE = join(tmpdir(), ".gitblade-state.json");
let gitbladeActive = false;

// Git helpers using Bun's $ shell
async function getGitStatus() {
  try {
    const [status, diff, files, staged] = await Promise.all([
      $`git status --porcelain`.text(),
      $`git diff HEAD`.text().catch(() => ""),
      $`git diff --name-only HEAD`.text(),
      $`git diff --cached --name-only`.text()
    ]);
    
    return {
      hasChanges: status.trim().length > 0,
      changedFiles: files.trim().split('\n').filter(f => f),
      stagedFiles: staged.trim().split('\n').filter(f => f),
      diffSize: diff.length,
      diff: diff
    };
  } catch (error) {
    return null;
  }
}

// Smart diff truncation
function truncateDiff(diff: string, maxTokens: number = 2000): string {
  if (diff.length < maxTokens * 4) return diff; // Rough token estimate
  
  const lines = diff.split('\n');
  const important = [];
  const summary = { files: new Map<string, { added: number, removed: number }>() };
  let currentFile = '';
  
  for (const line of lines) {
    if (line.startsWith('diff --git')) {
      currentFile = line.match(/b\/(.*?)$/)?.[1] || '';
      summary.files.set(currentFile, { added: 0, removed: 0 });
      important.push(line);
    } else if (line.startsWith('@@')) {
      important.push(line);
    } else if (line.startsWith('+') && !line.startsWith('+++')) {
      const stats = summary.files.get(currentFile);
      if (stats) stats.added++;
      if (important.length < 100) important.push(line);
    } else if (line.startsWith('-') && !line.startsWith('---')) {
      const stats = summary.files.get(currentFile);
      if (stats) stats.removed++;
      if (important.length < 100) important.push(line);
    }
  }
  
  let result = "DIFF SUMMARY:\n";
  for (const [file, stats] of summary.files) {
    result += `${file}: +${stats.added} -${stats.removed}\n`;
  }
  result += "\nKEY CHANGES:\n" + important.join('\n');
  
  return result;
}

// Gitblade logic
async function handleGitblade(command: string): Promise<HookResponse> {
  const gitStatus = await getGitStatus();
  
  if (!gitStatus || !gitStatus.hasChanges) {
    return {
      action: "skip",
      message: "❌ No changes to commit"
    };
  }
  
  // Check if it's a response to our gitblade prompt
  if (command.includes("GITBLADE_RESPONSE")) {
    return { action: "continue" };
  }
  
  // Save state
  gitbladeActive = true;
  await writeFile(GITBLADE_STATE_FILE, JSON.stringify({ 
    active: true, 
    timestamp: Date.now() 
  }));
  
  const diff = truncateDiff(gitStatus.diff);
  
  const gitbladePrompt = `You are gitblade 🗡️, an elite git commit assistant.

CURRENT STATUS:
- Changed files: ${gitStatus.changedFiles.length}
- Files: ${gitStatus.changedFiles.join(', ')}

YOUR MISSION:
1. Analyze the changes below
2. Create logical, atomic commits
3. Group related changes together
4. Use conventional commit format

RULES:
- Commit message: type(scope): description (MAX 52 chars)
- Types: feat, fix, refactor, style, test, docs, chore
- Body: Wrap at 70 chars per line
- Be decisive, not shy!

OUTPUT FORMAT:
For each commit group, use EXACTLY this format:

COMMIT_START
FILES: file1.ts file2.ts
MESSAGE: feat(hooks): add gitblade TypeScript implementation
BODY:
- Implemented smart diff truncation
- Added state management
- Integrated with Claude hooks system
COMMIT_END

Now analyze these changes:

${diff}

IMPORTANT: Respond with GITBLADE_RESPONSE tag and your commit plan.`;

  return {
    action: "skip",
    message: `🗡️ Gitblade analyzing your changes...\n\n${gitbladePrompt}\n\nPlease provide your commit plan following the format above.`
  };
}

// Execute gitblade commits
async function executeGitbladeCommits(output: string): Promise<void> {
  const commitRegex = /COMMIT_START\s*\nFILES:\s*(.+)\s*\nMESSAGE:\s*(.+)\s*\n(?:BODY:\s*\n([\s\S]*?))?COMMIT_END/g;
  const commits: CommitPlan[] = [];
  
  let match;
  while ((match = commitRegex.exec(output)) !== null) {
    commits.push({
      files: match[1].split(/\s+/),
      message: match[2],
      body: match[3]?.trim()
    });
  }
  
  if (commits.length === 0) return;
  
  console.log(`\n🗡️ Gitblade executing ${commits.length} commits...`);
  
  for (let i = 0; i < commits.length; i++) {
    const commit = commits[i];
    console.log(`\n📝 Commit ${i + 1}/${commits.length}: ${commit.message}`);
    
    try {
      // Stage files
      for (const file of commit.files) {
        await $`git add ${file}`;
        console.log(`  ✓ Staged: ${file}`);
      }
      
      // Create commit
      if (commit.body) {
        await $`git commit -m ${commit.message} -m ${commit.body}`;
      } else {
        await $`git commit -m ${commit.message}`;
      }
      console.log(`  ✅ Committed!`);
    } catch (error: any) {
      console.error(`  ❌ Failed: ${error.message}`);
    }
  }
  
  console.log("\n🎉 Gitblade mission complete!");
}

// Hook implementations
export async function preToolUse(payload: PreToolUsePayload): Promise<HookResponse> {
  // Only intercept Bash commands
  if (payload.tool_name !== "Bash") {
    return { action: "continue" };
  }
  
  const command = payload.tool_input.command?.trim() || "";
  
  // Check for git commit commands
  if (command.match(/^(git\s+commit|gc\s+|gitblade)/)) {
    return handleGitblade(command);
  }
  
  return { action: "continue" };
}

export async function postToolUse(payload: PostToolUsePayload): Promise<void> {
  // Check if gitblade is active and this might be a response
  if (gitbladeActive && payload.success && payload.tool_output) {
    const output = String(payload.tool_output);
    
    if (output.includes("GITBLADE_RESPONSE") || output.includes("COMMIT_START")) {
      gitbladeActive = false;
      await executeGitbladeCommits(output);
    }
  }
}

export async function stop(): Promise<void> {
  // Cleanup gitblade state
  try {
    await writeFile(GITBLADE_STATE_FILE, JSON.stringify({ active: false }));
  } catch {}
}

// Export for Claude hooks
export default { preToolUse, postToolUse, stop };