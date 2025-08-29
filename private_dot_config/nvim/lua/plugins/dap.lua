return {
  -- Disable Mason for DAP on NixOS - use system packages instead
  {
    "jay-babu/mason-nvim-dap.nvim",
    enabled = false,
  },
  
  -- Configure nvim-dap-python to use system debugpy
  {
    "mfussenegger/nvim-dap-python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- Use debugpy from the system or a known path
      local debugpy_path = vim.fn.exepath("debugpy")
      if debugpy_path ~= "" then
        require("dap-python").setup(debugpy_path)
      else
        -- Fallback to python -m debugpy
        require("dap-python").setup("python")
      end
    end,
    keys = {
      {
        "<leader>dPt",
        function()
          require("dap-python").test_method()
        end,
        desc = "Debug Method",
      },
      {
        "<leader>dPc",
        function()
          require("dap-python").test_class()
        end,
        desc = "Debug Class",
      },
    },
  },
}