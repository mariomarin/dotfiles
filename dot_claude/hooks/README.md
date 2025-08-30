# Claude Hooks - TypeScript

This directory contains TypeScript hooks for Claude Code, implementing the gitblade commit assistant and other workflow enhancements.

## Setup

1. Install dependencies:
   ```bash
   cd ~/.claude/hooks
   bun install
   ```

2. The hooks will be automatically loaded by Claude Code when present in `~/.claude/hooks/hooks.ts`

## Features

### Gitblade 🗡️

An intelligent git commit assistant that:
- Analyzes your changes and creates atomic, well-structured commits
- Uses conventional commit format
- Groups related changes together
- Provides smart diff truncation for large changes

**Usage:**
- Type `gitblade`, `blade`, or `gb` in Claude
- Or just try `git commit` and gitblade will offer to help

### Configuration

Edit `hooks.config.ts` to customize behavior:
- Enable/disable specific hooks
- Configure gitblade settings
- Set logging preferences

## Development

- `bun run dev` - Run with watch mode
- `bun test` - Test the hooks
- Hooks are written in TypeScript and run with Bun for fast execution

## Hook Types

- **preToolUse**: Intercept and modify tool calls before execution
- **postToolUse**: React to tool execution results
- **stop**: Cleanup when Claude session ends

## Based on

This implementation follows the patterns from John Lindquist's Claude Workshop, using Bun for package management and TypeScript for type safety.