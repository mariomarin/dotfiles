local install_root_dir = vim.fn.stdpath "data" .. "/mason"
local extension_path = install_root_dir .. "/packages/codelldb/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
local ft = { "rust" }

return {
  {
    "williamboman/mason.nvim",
    ft = ft,
    opts = {
      ensure_installed, { "rust-analyzer" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    ft = ft,
    opts = {
      ensure_installed, { "rust" },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    ft = ft,
    opts = function()
      local M = require "configs.cmp"
      vim.list_extend(M.sources, { name = "crates" })
      return M
    end,
  },
  {
    "simrat39/rust-tools.nvim",
    ft = ft,
    dependencies = {
      "rust-lang/rust.vim",
      "neovim/nvim-lspconfig",
    },
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
    opts = {
      servers = {
        rust_analyzer = {
          filetypes = { "rust" },

          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = {
                command = "cargo clippy",
                extraArgs = { "--no-deps" },
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("rust-tools").setup {
        tools = {
          hover_actions = { border = "solid" },
          on_initialized = function()
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "CursorHold", "InsertLeave" }, {
              pattern = { "*.rs" },
              callback = function()
                vim.lsp.codelens.refresh()
              end,
            })
          end,
        },
        server = opts,
      }
    end,
  },
  {
    "saecki/crates.nvim",
    ft = { "rust", "toml" },
    config = function(_, opts)
      local crates = require "crates"
      crates.setup(opts)
      crates.show()
    end,
    keys = {
      { "<leader>rcu", function() require("crates").upgrade_all_crates() end, desc = "Update all crates", mode = "n", },
      { "<leader>rcU", function() require("crates").upgrade_crate() end, desc = "Update current crate", mode = "n", },
    },
  },
  {
    "nvim-neotest/neotest",
    ft = ft,
    dependencies = {
      "rouge8/neotest-rust",
    },
  },
}

return plugins
