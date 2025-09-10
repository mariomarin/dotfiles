-- Window maximization plugin
return {
  "declancm/maximize.nvim",
  keys = {
    {
      "<leader>wm",
      function()
        require("maximize").toggle()
      end,
      desc = "Maximize/restore window",
    },
    {
      "<C-w>o",
      function()
        require("maximize").toggle()
      end,
      desc = "Maximize/restore window",
    },
  },
  config = true,
}
