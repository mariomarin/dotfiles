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
        -- Try to find system Python with debugpy module
        local python_path = vim.fn.exepath("python3")
        if python_path ~= "" then
          -- Check if debugpy module is available
          local has_debugpy = vim.fn.system("python3 -c 'import debugpy' 2>/dev/null; echo $?"):gsub("\n", "") == "0"
          if has_debugpy then
            require("dap-python").setup(python_path)
          else
            vim.notify("debugpy not found. Run: sudo nixos-rebuild switch", vim.log.levels.WARN)
          end
        else
          vim.notify("Python not found in PATH", vim.log.levels.WARN)
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
