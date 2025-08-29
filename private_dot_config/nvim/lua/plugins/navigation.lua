return {
  -- Leap for better navigation
  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    config = function()
      require("leap").add_default_mappings()
    end,
  },
  
  -- Tmux navigation
  {
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
  },
  
  -- Session management
  {
    "tpope/vim-obsession",
    event = "VeryLazy",
  },
}