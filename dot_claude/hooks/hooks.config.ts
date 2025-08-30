// Claude Hooks Configuration
export const config = {
  // Enable specific hooks
  enableGitblade: true,
  enableAuditLogging: false,
  enableSecurityChecks: false,
  
  // Gitblade settings
  gitblade: {
    // Maximum diff size to include in prompt (characters)
    maxDiffSize: 10000,
    // Maximum number of files to show in detail
    maxFilesToShow: 20,
    // Conventional commit types to use
    commitTypes: ["feat", "fix", "docs", "style", "refactor", "test", "chore", "perf"],
    // Auto-execute commits after plan
    autoExecute: false,
    // Show emoji in output
    useEmoji: true
  },
  
  // Logging settings
  logging: {
    // Log file location
    logFile: "/tmp/claude-hooks.log",
    // Log level
    level: "info" as "debug" | "info" | "warn" | "error"
  }
};

export type HooksConfig = typeof config;