local ft = { "typescript", "javascript" }

---@type NvPluginSpec[]
local plugins = {
  {
    "williamboman/mason.nvim",
    ft = ft,
    opts = function(_, opts)
      vim.list_extend(
        opts.ensure_installed,
        { "typescript-language-server", "prettierd", "deno", "js-debug-adapter", "eslint-lsp" }
      )
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    ft = ft,
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "typescript", "javascript" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    ft = ft,
    opts = {
      servers = {
        eslint = {
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectory = { mode = "auto" },
          },
        },
      },
    },
  },
  {
    "pmizio/typescript-tools.nvim",
    ft = ft,
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = function()
      local on_attach = require("plugins.configs.lspconfig").on_attach
      return {
        on_attach = on_attach,
        settings = {
          expose_as_code_action = "all",
        },
      }
    end,
  },
  {
    "nvim-neotest/neotest",
    ft = ft,
    dependencies = {
      "nvim-neotest/neotest-jest",
    },
  },
}

return plugins
