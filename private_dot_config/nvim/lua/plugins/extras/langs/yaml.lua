local ft = { "yaml", "yaml.docker-compose" }

return {
  {
    "williamboman/mason.nvim",
    ft = ft,
    opts = {
      ensure_installed = {
        "prettierd",
        "yaml-language-server",
        "yamlfmt",
        "yamllint",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    ft = ft,
    opts = {
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "yaml" },
        highlight = { enable = true },
        indent = { enable = true },
      }
    },
  },
}
