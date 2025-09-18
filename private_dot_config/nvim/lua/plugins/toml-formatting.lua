-- Configure TOML formatting with taplo
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.toml = { "taplo" }
      return opts
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        taplo = {
          settings = {
            evenBetterToml = {
              schema = {
                -- Enable schema support for known TOML files
                catalogs = {
                  "https://www.schemastore.org/api/json/catalog.json",
                },
              },
            },
          },
        },
      },
    },
  },
}
