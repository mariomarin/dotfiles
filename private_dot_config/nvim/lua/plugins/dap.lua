return {
  -- Override LazyVim's Python DAP configuration for NixOS compatibility
  {
    "mfussenegger/nvim-dap-python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    -- Only load when Python files are opened
    ft = "python",
    config = function()
      -- Check if we're on NixOS
      local is_nixos = vim.fn.executable("nix") == 1

      if is_nixos then
        -- Try to find system debugpy
        local debugpy_path = vim.fn.exepath("debugpy-adapter")
        if debugpy_path == "" then
          debugpy_path = vim.fn.exepath("debugpy")
        end

        if debugpy_path ~= "" then
          require("dap-python").setup(debugpy_path)
        else
          -- Use Python module fallback
          require("dap-python").setup()
          vim.notify("debugpy not found in PATH. Install it with your package manager.", vim.log.levels.WARN)
        end
      else
        -- Use default Mason installation path
        local mason_path = vim.fn.stdpath("data") .. "/mason"
        require("dap-python").setup(mason_path .. "/packages/debugpy/venv/bin/python")
      end
    end,
    keys = {
      {
        "<leader>dPt",
        function()
          require("dap-python").test_method()
        end,
        desc = "Debug Method (Python)",
      },
      {
        "<leader>dPc",
        function()
          require("dap-python").test_class()
        end,
        desc = "Debug Class (Python)",
      },
    },
  },
}
