local ft = { "markdown" }

return {
  {
    "williamboman/mason.nvim",
    ft = ft,
    opts = {
      ensure_installed = { "marksman" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    ft = ft,
    opts = {
      ensure_installed = { "markdown", "markdown_inline", "mermaid" },
    },
  },
  {
    ft = ft,
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Because the official marksman has dynamic lib issues on NixOS
        -- Remember to install marksman manually
        marksman = {
          cmd = {
            "sh",
            "-c",
            "test -x /run/current-system/sw/bin/marksman && { /run/current-system/sw/bin/marksman server; } || { marksman server; }",
          },
        },
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    ft = ft,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
}

return plugins
