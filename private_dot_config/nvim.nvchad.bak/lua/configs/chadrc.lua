local map = vim.keymap.set

-- Disabled
map("n", "<C-n>", "<Nop>", { desc = "Disable nvim-tree NvChad builtin" })

-- General
map("n", "<leader>q", ":q<cr>", { desc = "Quit" })
map("n", "<leader>pm", "<cmd>Lazy<cr>", { desc = "Open Lazy Plugin Manager" })
map("n", "<esc>", ":noh<cr>", { desc = "Clear highlights" })
map("i", "i", function() if vim.fn.getline(".") == "" then return [["_cc]] end return "i" end, { desc = "Fix indentation in insert mode", expr = true })

-- Nvimtree
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Nvimtree (Explorer)" })

---@type ChadrcConfig
local M = {}

local highlights = require "custom.highlights"

M.ui = {
  theme = "catppuccin",
  theme_toggle = { "catppuccin", "one_light" },

  statusline = {
    theme = "vscode_colored",
    separator_style = "round",
    overriden_modules = function(modules)
      modules[6] = "" -- Disable LSP Progress
    end,
  },

  tabufline = {
    lazyload = false,
  },

  hl_override = highlights.override,
  hl_add = highlights.add,

  nvdash = {
    load_on_startup = true,
  },

  cmp = {
    style = "atom",
  },
}

M.plugins = "custom.plugins"

return M
