-- Disable plugins that are causing conflicts
return {
  -- Disable copilot plugins
  { "zbirenbaum/copilot.lua", enabled = false },
  { "zbirenbaum/copilot-cmp", enabled = false },

  -- Fix bufferline configuration
  {
    "akinsho/bufferline.nvim",
    opts = function()
      local Snacks = require("snacks")
      local colors = Snacks.util and Snacks.util.color
        or {
          get = function(_, _)
            return "#000000"
          end,
        }
      return {
        options = {
          -- Use a simple separator instead of trying to use Snacks.util.color
          separator_style = "thin",
        },
      }
    end,
  },
}
