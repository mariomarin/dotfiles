-- NixOS-specific LSP configurations
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- On NixOS, use system-installed nil instead of Mason
      if vim.fn.executable("nix") == 1 and vim.fn.executable("nil") == 1 then
        opts.servers.nil_ls = {
          mason = false, -- Don't install via Mason
          settings = {
            ["nil"] = {
              formatting = {
                command = { "nixpkgs-fmt" }, -- Use nixpkgs-fmt as the formatter
              },
            },
          },
        }
      end
      return opts
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Skip nil_ls installation on NixOS
      if vim.fn.executable("nix") == 1 then
        opts.ensure_installed = vim.tbl_filter(function(pkg)
          return pkg ~= "nil"
        end, opts.ensure_installed or {})
      end
      return opts
    end,
  },
}
