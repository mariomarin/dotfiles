-- Mason configuration for NixOS compatibility
return {
  -- Configure mason to work better with NixOS
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- On NixOS, prefer system-installed tools
      if vim.fn.has("unix") == 1 and vim.fn.executable("nix") == 1 then
        opts.PATH = "append" -- Use system binaries first
      end
      return opts
    end,
  },
  
  -- Disable automatic DAP setup on NixOS
  {
    "jay-babu/mason-nvim-dap.nvim",
    enabled = not (vim.fn.has("unix") == 1 and vim.fn.executable("nix") == 1),
  },
  
  -- Configure mason-lspconfig to handle NixOS
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      -- Don't auto-install on NixOS, use system packages
      if vim.fn.has("unix") == 1 and vim.fn.executable("nix") == 1 then
        opts.automatic_installation = false
      end
      return opts
    end,
  },
}