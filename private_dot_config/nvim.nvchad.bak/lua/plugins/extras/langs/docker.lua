local ft = { "dockerfile" }
---@type NvPluginSpec[]
return {
  {
    "williamboman/mason.nvim",
    ft = ft,
    opts = {
       ensure_installed = { "dockerfile-language-server", "docker-compose-language-service", "hadolint" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    ft = ft,
    opts = {
      ensure_installed = { "dockerfile" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ft = ft,
    opts = {
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },
}
