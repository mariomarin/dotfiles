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
          -- Enable default keybindings (C-hjkl) for navigation
          enable_default_keybindings = true,
          cycle_navigation = true, -- Cycle to opposite pane when at edge
        },
        resize = {
          -- Enable resizing with Alt + hjkl
          enable_default_keybindings = true,
          resize_step_x = 1,
          resize_step_y = 1,
        },
      })
    end,
  },
}
