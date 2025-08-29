-- Fix for bufferline.nvim colorscheme compatibility
return {
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      -- Use the catppuccin integration directly
      opts = opts or {}
      opts.options = opts.options or {}
      opts.options.themable = true

      -- Let catppuccin handle the highlights
      local catppuccin_exists, _ = pcall(require, "catppuccin.groups.integrations.bufferline")
      if catppuccin_exists then
        opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
      end

      return opts
    end,
  },
}
