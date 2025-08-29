-- Override Python DAP to use system debugpy on NixOS
return {
  {
    "mfussenegger/nvim-dap-python",
    optional = true,
    config = function()
      local path = require("mason-registry").get_package("debugpy"):get_install_path()
      if vim.fn.executable("nix") == 1 and vim.fn.executable("python3") == 1 then
        -- On NixOS, use system Python with debugpy
        require("dap-python").setup("python3")
      else
        -- Use Mason's debugpy
        require("dap-python").setup(path .. "/venv/bin/python")
      end
    end,
  },
}
