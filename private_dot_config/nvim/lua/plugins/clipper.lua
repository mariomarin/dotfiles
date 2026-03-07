-- Clipper integration for Neovim
-- Provides clipboard access via Clipper daemon (localhost:8377)
-- Works locally and over SSH via RemoteForward
-- See: https://github.com/wincent/vim-clipper
return {
  "wincent/vim-clipper",
  lazy = false, -- Load immediately for TextYankPost autocommand
  init = function()
    -- Configuration (before plugin loads)
    vim.g.ClipperAddress = "localhost"
    vim.g.ClipperPort = 8377

    -- Enable automatic clipboard sync via TextYankPost
    vim.g.ClipperAuto = 1

    -- Enable <leader>y mapping (plugin will create it)
    vim.g.ClipperMap = 1

    -- Lock down invocation for security (prevent malicious plugins from overwriting)
    -- Empty string means use default nc invocation with auto-detection
    -- Note: To customize (e.g., force nc -N), call clipper#set_invocation() here
    vim.schedule(function()
      if vim.fn.exists("*clipper#set_invocation") == 1 then
        vim.fn["clipper#set_invocation"]("")
      end
    end)
  end,
  -- Note: No 'keys' spec needed since lazy=false
  -- Plugin's ClipperMap=1 will create <leader>y mapping automatically
  config = function()
    -- Additional configuration after plugin loads
    -- vim-clipper automatically provides:
    -- 1. <leader>y mapping to call :Clip (via ClipperMap=1)
    -- 2. TextYankPost autocommand to send yanks to Clipper (via ClipperAuto=1)
    -- 3. :Clip command to manually send text to Clipper

    -- Add user command alias for convenience
    vim.api.nvim_create_user_command("Clipper", function()
      vim.cmd("Clip")
    end, {
      desc = "Send last yank to Clipper (alias for :Clip)",
    })
  end,
}
