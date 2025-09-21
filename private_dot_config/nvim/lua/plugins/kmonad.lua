return {
  -- KMonad syntax highlighting
  {
    "kmonad/kmonad-vim",
    ft = { "kbd", "kmonad" },
    init = function()
      -- Associate .kbd files with kmonad filetype
      vim.filetype.add({
        extension = {
          kbd = "kmonad",
        },
      })
    end,
  },
}
