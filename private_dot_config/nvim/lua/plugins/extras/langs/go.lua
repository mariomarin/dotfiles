local ft = { "go", "gomod" }

return {
  {
    "williamboman/mason.nvim",
    ft = ft,
    opts = {
      ensure_installed = {
        "delve",
        "gofumpt",
        "goimports-reviser",
        "golangci-lint",
        "golangci-lint-langserver",
        "golangci-lint-langserver",
        "golines",
        "gopls",
        "gotestsum",
        "iferr",
        "impl",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    ft = ft,
    opts = {
      ensure_installed = { "go", "gomod" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ft = ft,
    opts = {
      servers = {
        gopls = {
          filetypes = { "go", "gomod", "gowork", "gotmpl" },
          root_dir = { "go.work", "go.mod", ".git" },
          settings = {
            gopls = {
              completeUnimported = true,
              usePlaceholders = true,
              analyses = {
                fieldalignment = true,
                unusedparams = true,
                unusedvariable = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              staticcheck = true,
              semanticTokens = true,
            },
          },
        },
        golangci_lint_ls = {},
      },
    },
  },
  {
    "nvim-neotest/neotest",
    ft = ft,
    dependencies = {
      { "nvim-neotest/neotest-go" },
    },
  },
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    event = { "CmdlineEnter" },
    ft = ft,
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
}

return plugins
