local ft = "lua"

return {
  {
    "williamboman/mason.nvim",
    ft = ft,
    opts = {
      ensure_installed = { "lua-language-server", "stylua" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    ft = ft,
    opts = {
      ensure_installed = { "lua", "luadoc", "luap", "vim", "vimdoc" },
    },
  },
  {
    ft = ft,
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          filetypes = { "lua" },

          settings = {
            Lua = {
              codeLens = {
                enable = true,
              },
              completion = {
                autoRequire = true,
                enable = true,
                callSnippet = "Both",
                displayContext = true,
                showParams = true,
              },
              diagnostics = {
                enable = true,
                globals = { "vim" },
                workspaceDelay = 100,
              },
              hint = {
                enable = true,
                paramName = "all",
              },
              workspace = {
                library = {
                  vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
                  vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
                  vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
                },
                checkThirdParty = false,
                maxPreload = 100000,
                preloadFileSize = 10000,
              },
            },
          },
        },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    ft = ft,
    dependencies = {
      "nvim-neotest/neotest-plenary",
    },
  },
}
