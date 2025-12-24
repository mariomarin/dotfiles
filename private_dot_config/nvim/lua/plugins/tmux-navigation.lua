-- Seamless navigation between Neovim and terminal multiplexers (tmux/zellij)
-- Uses Ctrl+Alt (C-M) via Kanata = layer for tilish compatibility
return {
  -- Zellij navigation (when running inside zellij)
  {
    "swaits/zellij-nav.nvim",
    lazy = true,
    event = "VeryLazy",
    keys = {
      { "<C-M-h>", "<cmd>ZellijNavigateLeftTab<cr>", desc = "Zellij left", silent = true },
      { "<C-M-j>", "<cmd>ZellijNavigateDown<cr>", desc = "Zellij down", silent = true },
      { "<C-M-k>", "<cmd>ZellijNavigateUp<cr>", desc = "Zellij up", silent = true },
      { "<C-M-l>", "<cmd>ZellijNavigateRightTab<cr>", desc = "Zellij right", silent = true },
    },
    cond = function()
      return vim.env.ZELLIJ ~= nil
    end,
  },

  -- Tmux navigation (when running inside tmux)
  {
    "aserowy/tmux.nvim",
    cond = function()
      return vim.env.TMUX ~= nil
    end,
    event = "VeryLazy",
    config = function()
      -- Over SSH, use OSC 52 for clipboard (configured in options.lua)
      -- Locally, let tmux.nvim sync clipboard via tmux buffers
      local is_ssh = vim.env.SSH_TTY ~= nil

      require("tmux").setup({
        copy_sync = {
          -- Sync registers between neovim instances via tmux buffers
          -- dd in nvim1, p in nvim2 - works over SSH without OSC52
          enable = true,
          -- Don't override clipboard over SSH (use OSC 52 instead)
          sync_clipboard = not is_ssh,
          sync_registers = true,
        },
        navigation = {
          -- Use = layer (C-M) for tilish-style navigation
          enable_default_keybindings = false,
          cycle_navigation = true,
          keybindings = {
            left = "<C-M-h>",
            down = "<C-M-j>",
            up = "<C-M-k>",
            right = "<C-M-l>",
            last_active = "<C-M-\\>",
            next = "<C-M-Space>",
          },
        },
        resize = {
          -- Resize via = layer (matches tilish smart-splits)
          enable_default_keybindings = false,
          resize_step_x = 1,
          resize_step_y = 1,
          keybindings = {
            left = "<C-M-=>",
            right = "<C-M-->",
            down = "<C-M-+>",
            up = "<C-M-_>",
          },
        },
      })
    end,
  },
}
