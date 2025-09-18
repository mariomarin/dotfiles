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
          -- Use Alt+Arrow keys for resizing
          enable_default_keybindings = false,
          resize_step_x = 5,
          resize_step_y = 2,
          keybindings = {
            left = "M-Left",
            down = "M-Down",
            up = "M-Up",
            right = "M-Right",
          },
        },
      })
    end,
  },
}
