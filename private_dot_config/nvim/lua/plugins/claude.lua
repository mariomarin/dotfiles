return {
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("claude-code").setup({
        window = {
          position = "float", -- "vertical", "horizontal", "tab", or "float"
          float = {
            width = "90%",
            height = "90%",
            border = "rounded", -- "single", "double", "rounded", "solid", "shadow"
          },
        },
        file_refresh = {
          enabled = true,
          delay = 500, -- milliseconds
        },
        log_level = "info", -- "debug", "info", "warn", "error"
      })
    end,
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
      { "<leader>cr", "<cmd>ClaudeCodeReload<cr>", desc = "Reload Claude Code modified files" },
      { "<leader>c.", "<cmd>ClaudeCode --continue<cr>", desc = "Continue with Claude Code" },
    },
  },
}