-- LSP configuration overrides
return {
  -- Disable grammarly LSP (not installed on NixOS)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        grammarly = {
          -- Disable grammarly language server
          mason = false,
          enabled = false,
        },
      },
    },
  },
}
