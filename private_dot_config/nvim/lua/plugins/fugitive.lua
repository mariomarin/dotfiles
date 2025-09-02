return {
  -- vim-fugitive for Git integration
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gstatus", "Gblame", "Gpush", "Gpull", "Gcommit", "Glog" },
    -- Load before gitsigns to ensure G command is defined by fugitive
    priority = 100,
  },
}
