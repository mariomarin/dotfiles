-- https://github.com/LazyVim/lazyvim.github.io/blob/2e3876/docs/extras/util/chezmoi.md
local chezmoi_enabled = vim.fn.executable "chezmoi" == 1

---@type LazySpec
return {
  {
    -- highlighting for chezmoi files template files
    "alker0/chezmoi.vim",
    init = function()
      vim.g["chezmoi#use_tmp_buffer"] = 1
      vim.g["chezmoi#source_dir_path"] = os.getenv("HOME") .. "/.local/share/chezmoi"
    end,
  }, {
    "xvzc/chezmoi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function(_, opts)
      require("chezmoi").setup(opts)
      require("util.plugins").on_load("telescope.nvim", function()
        require("telescope").load_extension("chezmoi")
        vim.keymap.set(
          "n",
          "<leader>oc",
          require("telescope").extensions.chezmoi.find_files,
          { desc = "Edit chezmoi files" }
        )
      end)
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
        callback = function(ev)
          local bufnr = ev.buf
          local edit_watch = function()
            require("chezmoi.commands.__edit").watch(bufnr)
          end
          vim.schedule(edit_watch)
        end,
      })
    end,
    opts = {},
    keys = { { "<leader>oc", desc = "Edit chezmoi files" } },
  }
}
