return {
  -- Disable Snacks.nvim git features that override Fugitive commands
  {
    "folke/snacks.nvim",
    opts = {
      git = { enabled = false }, -- Disable git commands (like G status showing in popup)
      gitbrowse = { enabled = false }, -- Disable git browse feature
    },
  },
  -- vim-fugitive for Git integration
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status (Fugitive)" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
      { "<leader>gd", "<cmd>Gdiff<cr>", desc = "Git diff" },
    },
    -- Load immediately to ensure commands are available and override Snacks
    lazy = false,
    priority = 100,
  },
}
