local get_poetry_venv_path = function()
  local fn = vim.fn
  if fn.executable "poetry" == 1 then
    return fn.trim(fn.system "poetry config virtualenvs.path")
  end

  return ""
end

local ft = { "python" }

return {
  {
    "williamboman/mason.nvim",
    ft = ft,
    opts = {
      ensure_installed = { "pyright", "ruff", "black", "debugpy" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    ft = ft,
    opts = {
      ensure_installed = { "python" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ft = ft,
    opts = {
      servers = {
        pyright = {
          filetypes = { "python" },
          root_dir = { "requirements.txt", "pyproject.toml", "poetry.lock", ".git" },

          settings = {
            pyright = {
              venvPath = get_poetry_venv_path(),
            },
            analysis = {
              typeCheckingMode = "off",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
        ruff = {
          on_attach = function(client, bufnr)
            local lspconfig_on_attach = require("plugins.configs.lspconfig").on_attach

            lspconfig_on_attach(client, bufnr)
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end,
          filetypes = { "python" },
          root_dir = { "requirements.txt", "pyproject.toml", "poetry.lock", ".git" },
        },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    ft = ft,
    dependencies = {
      "nvim-neotest/neotest-python",
    },
  },
}
