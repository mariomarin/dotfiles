-- Fix toggle keymaps to use proper LazyVim format
return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Configure toggle options without the 'real' field
      opts.toggle = opts.toggle or {}
      return opts
    end,
    keys = function()
      local Snacks = require("snacks")
      -- Return proper keymaps without the 'real' field
      return {
        {
          "<leader>uf",
          function()
            Snacks.toggle.format()
          end,
          desc = "Toggle Format",
        },
        {
          "<leader>uF",
          function()
            Snacks.toggle.format(true)
          end,
          desc = "Toggle Format (Buffer)",
        },
        {
          "<leader>us",
          function()
            Snacks.toggle.option("spell", { name = "Spelling" })
          end,
          desc = "Toggle Spelling",
        },
        {
          "<leader>uw",
          function()
            Snacks.toggle.option("wrap", { name = "Wrap" })
          end,
          desc = "Toggle Wrap",
        },
        {
          "<leader>uL",
          function()
            Snacks.toggle.option("relativenumber", { name = "Relative Number" })
          end,
          desc = "Toggle Relative Number",
        },
        {
          "<leader>ud",
          function()
            Snacks.toggle.diagnostics()
          end,
          desc = "Toggle Diagnostics",
        },
        {
          "<leader>ul",
          function()
            Snacks.toggle.line_number()
          end,
          desc = "Toggle Line Numbers",
        },
        {
          "<leader>uc",
          function()
            Snacks.toggle.option("conceallevel", {
              off = 0,
              on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
              name = "Conceal Level",
            })
          end,
          desc = "Toggle Conceal Level",
        },
        {
          "<leader>uA",
          function()
            Snacks.toggle.option("showtabline", {
              off = 0,
              on = vim.o.showtabline > 0 and vim.o.showtabline or 2,
              name = "Tabline",
            })
          end,
          desc = "Toggle Tabline",
        },
        {
          "<leader>uT",
          function()
            Snacks.toggle.treesitter()
          end,
          desc = "Toggle Treesitter",
        },
        {
          "<leader>ub",
          function()
            Snacks.toggle.option("background", {
              off = "light",
              on = "dark",
              name = "Dark Background",
            })
          end,
          desc = "Toggle Dark Background",
        },
        {
          "<leader>uD",
          function()
            Snacks.toggle.dim()
          end,
          desc = "Toggle Dim",
        },
        {
          "<leader>ua",
          function()
            Snacks.toggle.animate()
          end,
          desc = "Toggle Animations",
        },
        {
          "<leader>ug",
          function()
            Snacks.toggle.indent()
          end,
          desc = "Toggle Indent Guides",
        },
        {
          "<leader>uG",
          function()
            Snacks.toggle.indent({ enabled = true, animate = { enabled = false } })
          end,
          desc = "Toggle Indent Guides (Animated)",
        },
        {
          "<leader>up",
          function()
            Snacks.toggle.option("paste", { name = "Paste Mode" })
          end,
          desc = "Toggle Paste Mode",
        },
        {
          "<leader>uS",
          function()
            Snacks.toggle.scroll()
          end,
          desc = "Toggle Smooth Scrolling",
        },
        {
          "<leader>uh",
          function()
            Snacks.toggle.inlay_hints()
          end,
          desc = "Toggle Inlay Hints",
        },
        {
          "<leader>uZ",
          function()
            Snacks.toggle.zen()
          end,
          desc = "Toggle Zen Mode",
        },
        {
          "<leader>uz",
          function()
            Snacks.toggle.zoom()
          end,
          desc = "Toggle Zoom",
        },
        {
          "<leader>dpp",
          function()
            Snacks.toggle.profiler()
          end,
          desc = "Toggle Profiler",
        },
        {
          "<leader>dph",
          function()
            Snacks.toggle.profiler_highlights()
          end,
          desc = "Toggle Profiler Highlights",
        },
        {
          "<leader>wm",
          function()
            Snacks.toggle.maximize()
          end,
          desc = "Toggle Maximize Window",
        },
      }
    end,
  },
}
