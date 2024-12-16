return {
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- bash
    { import = "plugins.extras.lang.bash" },
    -- c/cpp
    { import = "plugins.extras.lang.cpp" },
    -- go
    { import = "plugins.extras.lang.go" },
    -- lua
    { import = "plugins.extras.lang.lua" },
    -- python
    { import = "plugins.extras.lang.python" },
    -- typescript
    { import = "plugins.extras.lang.typescript" },
    -- yaml
    { import = "plugins.extras.lang.yaml" },
    -- treesitter
    { import = "plugins.extras.treesitter" },
    -- chezmoi
    { import = "plugins.extras.chezmoi" },
  },
  defaults = { lazy = true },
  install = { colorscheme = { "nvchad" } },

  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}
