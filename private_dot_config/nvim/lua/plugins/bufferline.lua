-- Disable bufferline to avoid conflicts with catppuccin colorscheme
-- LazyVim's lualine already shows buffers in the statusline
return {
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
}
