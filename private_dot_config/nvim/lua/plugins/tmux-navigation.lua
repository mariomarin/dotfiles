-- Seamless navigation between Neovim and tmux
-- Direct M-hjkl bindings (matches tmux-tilish without prefix)
return {
  {
    "aserowy/tmux.nvim",
    cond = function()
      return vim.env.TMUX ~= nil
    end,
    event = "VeryLazy",
    config = function()
      local is_ssh = vim.env.SSH_TTY ~= nil

      require("tmux").setup({
        copy_sync = {
          enable = true,
          sync_clipboard = not is_ssh,
          sync_registers = true,
        },
        navigation = {
          enable_default_keybindings = false,
          cycle_navigation = true,
          keybindings = {
            left = "<M-h>",
            down = "<M-j>",
            up = "<M-k>",
            right = "<M-l>",
          },
        },
        resize = {
          enable_default_keybindings = false,
          resize_step_x = 1,
          resize_step_y = 1,
          keybindings = {
            left = "<M-=>",
            right = "<M-->",
            down = "<M-+>",
            up = "<M-_>",
          },
        },
      })
    end,
  },
}
