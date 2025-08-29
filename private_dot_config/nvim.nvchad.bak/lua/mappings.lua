require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Disabled
map("n", "<C-n>", "<Nop>", { desc = "Disable nvim-tree NvChad builtin" })

-- General
map("n", "<leader>q", ":q<cr>", { desc = "Quit" })
map("n", "<leader>pm", "<cmd>Lazy<cr>", { desc = "Open Lazy Plugin Manager" })
map("n", "<esc>", ":noh<cr>", { desc = "Clear highlights" })
map("i", "i", function() if vim.fn.getline(".") == "" then return [["_cc]] end return "i" end, { desc = "Fix indentation in insert mode", expr = true })
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Nvimtree
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Nvimtree (Explorer)" })


