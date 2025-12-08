return {
  -- Kanata syntax highlighting (uses kmonad-vim as syntax is similar)
  {
    "kmonad/kmonad-vim",
    ft = { "kbd", "kanata" },
    init = function()
      -- Associate .kbd files with kanata filetype
      vim.filetype.add({
        extension = {
          kbd = "kanata",
        },
      })
    end,
  },
}
