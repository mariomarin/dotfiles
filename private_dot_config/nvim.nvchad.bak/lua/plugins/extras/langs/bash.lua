local ft = { "sh", "zsh" }

return {
  {
    "williamboman/mason.nvim",
    ft = ft,
    opts = {
      ensure_installed = { "bash-language-server", "shfmt", "shellharden" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    ft = ft,
    opts = {
      ensure_installed = { "bash" }
    },
  },
  {
    "neovim/nvim-lspconfig",
    ft = ft,
    opts = {
      servers = {
        bashls = {
          settings = {
            bashIde = {
              shellcheckPath = "/run/current-system/sw/bin/shellceck",
            },
          },
        },
      },
    },
  },
}
