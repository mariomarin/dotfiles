-- Mason configuration for NixOS compatibility
local is_nixos = vim.fn.filereadable("/etc/NIXOS") == 1

return {
  -- Configure mason to work better with NixOS
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      if is_nixos then
        opts.PATH = "append" -- Use system binaries first
      end
      return opts
    end,
  },

  -- Disable automatic DAP setup on NixOS
  {
    "jay-babu/mason-nvim-dap.nvim",
    enabled = not is_nixos,
  },

  -- Configure mason-lspconfig to handle NixOS
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      if is_nixos then
        opts.automatic_installation = false
      end
      return opts
    end,
  },
}
