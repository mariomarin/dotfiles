-- Configure marksman as the Markdown LSP
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          -- Marksman doesn't require any special configuration
          -- It automatically detects markdown files and provides
          -- completion, hover, definitions, and references
        },
      },
    },
  },
}
