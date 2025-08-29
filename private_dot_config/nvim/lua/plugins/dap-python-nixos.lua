-- Override Python DAP to use system debugpy on NixOS
return {
  {
    "mfussenegger/nvim-dap-python",
    optional = true,
    opts = function()
      -- On NixOS, use system Python with debugpy
      if vim.fn.executable("nix") == 1 then
        return {
          adapter = "python3",
        }
      end
      return {}
    end,
  },
}
