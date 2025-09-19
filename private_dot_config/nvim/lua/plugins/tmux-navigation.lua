-- Seamless navigation and clipboard sync between Neovim and tmux
return {
  {
    "aserowy/tmux.nvim",
    event = "VeryLazy",
    config = function()
      require("tmux").setup({
        copy_sync = {
          -- Sync clipboard between neovim and tmux
          enable = true,
          sync_clipboard = true,
          sync_registers = true,
        },
        navigation = {
          -- Use tilish-style navigation (M-hjkl)
          enable_default_keybindings = false,
          cycle_navigation = true, -- Cycle to opposite pane when at edge
          keybindings = {
            left = "M-h",
            down = "M-j",
            up = "M-k",
            right = "M-l",
            last_active = "M-\\",
            next = "M-Space",
          },
        },
        resize = {
          -- Use Omarchy-style keybindings to match tmux-tilish config
          enable_default_keybindings = false,
          resize_step_x = 1,
          resize_step_y = 1,
          keybindings = {
            left = "M-=", -- Alt+Equal: grow left
            right = "M--", -- Alt+Minus: grow right
            down = "M-+", -- Alt+Shift+Equal: grow down
            up = "M-_", -- Alt+Shift+Minus: grow up
          },
        },
      })
    end,
  },
}
