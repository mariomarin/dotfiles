-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- NixOS compatibility
if vim.fn.has("unix") == 1 and vim.fn.executable("nix") == 1 then
  -- Disable automatic LSP installation on NixOS
  vim.g.lazyvim_python_lsp = vim.fn.exepath("pylsp") ~= "" and "pylsp" or "pyright"
  vim.g.lazyvim_python_ruff = vim.fn.exepath("ruff") ~= "" and "ruff" or nil
end
