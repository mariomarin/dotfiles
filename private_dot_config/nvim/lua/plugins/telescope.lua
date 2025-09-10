-- Telescope configuration to ensure find files keybinding works
return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- Ensure <leader><space> works for finding files
    { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
    -- Also add <leader>ff as an alternative
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
  },
}
