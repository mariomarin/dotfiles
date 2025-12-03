-- Clipboard configuration for cross-platform compatibility
-- Handles WSL, X11, Wayland, and macOS clipboard providers

return {
  {
    "LazyVim/LazyVim",
    opts = function()
      -- Detect WSL environment
      local is_wsl = vim.fn.has("wsl") == 1 or vim.fn.getenv("WSL_DISTRO_NAME") ~= nil

      if is_wsl then
        -- Use Windows clipboard on WSL
        vim.g.clipboard = {
          name = "WslClipboard",
          copy = {
            ["+"] = { "clip.exe" },
            ["*"] = { "clip.exe" },
          },
          paste = {
            ["+"] = {
              "powershell.exe",
              "-c",
              '[Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            },
            ["*"] = {
              "powershell.exe",
              "-c",
              '[Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            },
          },
          cache_enabled = 0,
        }
      end

      -- Enable system clipboard by default
      vim.opt.clipboard = "unnamedplus"
    end,
  },
}
