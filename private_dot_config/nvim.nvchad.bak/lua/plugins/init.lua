local get_mini_view_row_value = function()
  local cmdheight = vim.o.cmdheight * -1 -- set cmdheight as negative value
  return cmdheight - 1
end

return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      local cmp = require "cmp"
      local cmp_conf = require "nvchad.configs.cmp"

      cmp_conf.mapping = {
        ["<C-j>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif require("luasnip").expand_or_jumpable() then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
        ["<C-k>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif require("luasnip").jumpable(-1) then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
          else
            fallback()
          end
        end, {
          "i",
          "s",
        }),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        },
        ["<C-space>"] = cmp.mapping.complete(),
      }

      return cmp_conf
    end,
  },
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    -- Overwrite nvchad defaults
    opts = {
      ensure_installed = {
        "jsdoc",
        "json",
        "jsonc",
        "json5",
        "make",
        "regex",
        "sql",
        "terraform",
        "toml",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },
  {
    "andymass/vim-matchup",
    event = "VeryLazy",
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  {
    "folke/neoconf.nvim",
    opts = {},
  },
  {
    "vim-test/vim-test",
    opts = {
      setup = {},
    },
    config = function(plugin, opts)
      vim.g["test#strategy"] = "neovim"
      vim.g["test#neovim#term_position"] = "belowright"
      vim.g["test#neovim#preserve_screen"] = 1
      vim.g["test#python#runner"] = "pytest"

      -- Set up vim-test
      for k, _ in pairs(opts.setup) do
        opts.setup[k](plugin, opts)
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter"
    },
    keys = {
      { "<leader>ttF", function() require("neotest").run.run { vim.fn.expand "%", strategy = "dap" } end, desc = "Debug Test File", mode = "n" },
      { "<leader>ttL", function() require("neotest").run.run_last { strategy = "dap" } end, desc = "Debug Last Test", mode = "n" },
      { "<leader>ttN", function() require("neotest").run.run { strategy = "dap" } end, desc = "Debug Nearest Test", mode = "n" },
      { "<leader>tts", function() require("neotest").run.stop() end, desc = "Stop", mode = "n" },
      { "<leader>ttS", function() require("neotest").summary.toggle() end, desc = "Summary", mode = "n" },
      { "<leader>tta", function() require("neotest").summary.attach() end, desc = "Attach", mode = "n" },
      { "<leader>ttf", function() require("neotest").run.run(vim.fn.expand "%") end, desc = "Test File", mode = "n" },
      { "<leader>ttl", function() require("neotest").run.run_last() end, desc = "Test Last", mode = "n" },
      { "<leader>ttn", function() require("neotest").run.run() end, desc = "Test Nearest", mode = "n" },
      { "<leader>tto", function() require("neotest").output.open { enter = true } end, desc = "Output", mode = "n" },
      { "<leader>ttz", function() require("neotest").run.run { vim.fn.getcwd() } end, desc = "Suite", mode = "n" },
    }
  },
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood",
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = "<leader>m",
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      -- Key Mappings
      vim.keymap.set("n", "<leader>ma", function() harpoon:list():add() end, { desc = "Add File to Harpoon" })
      vim.keymap.set("n", "<leader>mm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Toggle Harpoon Menu" })

      vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end, { desc = "Navigate to Harpoon File 1" })
      vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end, { desc = "Navigate to Harpoon File 2" })
      vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end, { desc = "Navigate to Harpoon File 3" })
      vim.keymap.set("n", "<C-;>", function() harpoon:list():select(4) end, { desc = "Navigate to Harpoon File 4" })

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "Previous Harpoon File" })
      vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = "Next Harpoon File" })
      -- Basic Telescope Configuration
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
          local finder = function()
          local paths = {}
          for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
          end
          return require("telescope.finders").new_table({
            results = paths,
          })
        end

        require("telescope.pickers").new({}, {
          prompt_title = "Harpoon",
          finder = finder(),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            map("n", "dd", function()
              local state = require("telescope.actions.state")
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_bufnr)
              table.remove(harpoon_files.items, selected_entry.index)
              current_picker:refresh(finder())
            end)
            return true
          end,
        }):find()
      end
    vim.keymap.set("n", "<leader>mt", function() toggle_telescope(harpoon:list()) end, { desc = "Open harpoon window" })
    end,
  },
  {
    "folke/which-key.nvim",
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      wk.add({
        -- Coding Group
        { "<leader>c", group = "Coding" },

        -- Search Diagnostic
        { "<leader>s", desc = "Search Diagnostic" },

        -- DAP Group
        { "<leader>d", group = "DAP" },
        { "<leader>dp", desc = "Python" },
        { "<leader>dg", desc = "Go" },

        -- Files Group
        { "<leader>f", desc = "Telescope (Files)" },

        -- Tasks Group
        { "<leader>t", group = "Tasks" },
        { "<leader>tr", desc = "Overseer (Task Runner)" },
        { "<leader>tt", desc = "Neotest" },

        -- Claude Code Group
        { "<leader>c", group = "Claude Code" },

        -- Harpoon Group
        { "<leader>m", group = "Harpoon" },

      })
    end,
  },
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    event = "VeryLazy",
    version = "*",
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      theme = "catppuccin",
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-symbols.nvim",
      "nvim-telescope/telescope-project.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-dap.nvim",
      "tsakirist/telescope-lazy.nvim",
    },
    keys = {
      { "<leader>fd", function() require("telescope.builtin").git_files { prompt_title = "<Dotfiles>", cwd = "~/.local/share/chezmoi/", } end, desc = "Open dotfiles", mode = "n", },
      { "<leader>fs", function() require("telescope.builtin").symbols { sources = { "emoji", "kaomoji", "gitmoji" }, } end, desc = "Open emojis", mode = "n", },
      { "<leader>fp", function() require("telescope").extensions.project.project {} end, desc = "Open projects", mode = "n", },
      { "<leader>fl", "<cmd>Telescope lazy<CR>", desc = "Open Lazy Plugins in Telescope", mode = "n", }
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui" },
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "Toggle Breakpoint", mode = "n" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI", mode = "n" },
      { "<leader>dsb", function() require("dap").step_back() end, desc = "Step Back", mode = "n" },
      { "<leader>ds", function() require("dap").continue() end, desc = "Start/Continue Debugging", mode = "n" },
      { "<leader>dsi", function() require("dap").step_into() end, desc = "Step Into", mode = "n" },
      { "<leader>dso", function() require("dap").step_over() end, desc = "Step Over", mode = "n" },
      { "<leader>dsx", function() require("dap").step_out() end, desc = "Step Out", mode = "n" },
    },
    keys = {
      { "<leader>dgt", function() require("dap-go").debug_test() end, desc = "Debug Go Test", mode = "n" },
      { "<leader>dpt", function() require("dap-python").test_method() end, desc = "Debug Python Test", mode = "n" },
    }
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"}
  },
  'theHamsta/nvim-dap-virtual-text',
  {
    "lewis6991/gitsigns.nvim",
  },
  {
    "wakatime/vim-wakatime",
    event = "VeryLazy",
  },
  {
    "andythigpen/nvim-coverage",
    branch = "main",
    cmd = { "Coverage", "CoverageToggle", "CoverageSummary" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      commands = true,
      auto_reload = true,
      load_coverage_cb = function(ftype)
        vim.notify("Loaded " .. ftype .. " coverage")
      end,
      lang = {
        python = {
          coverage_file = "project/.coverage",
        },
      },
    },
    config = function(_, opts)
      require("coverage").setup(opts)
    end,
  },
  {
    "ThePrimeagen/refactoring.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    opts = {},
    config = function(_, opts)
      require("refactoring").setup(opts)
      require("telescope").load_extension("refactoring")
    end,
    keys = {
      { "<leader>rr", function() require("telescope").extensions.refactoring.refactors() end, desc = "Refactoring", mode = "n", },
    },
  },
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = "BufReadPost",
    opts = {
      search = {
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
      },
    },
    config = function(_, opts)
      require("todo-comments").setup(opts)
    end,
    keys = {
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO", mode = "n" },
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO", mode = "n" },
      { "<leader>ct", "<cmd>TodoTelescope<cr>", desc = "Open TODO in Telescope", mode = "n" },
      { "<leader>cT", "<cmd>TodoTrouble<cr>", desc = "Open TODO in Trouble", mode = "n" },
    }
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "BufReadPost",
    opts = {},
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      plugins = {
        alacritty = {
          enabled = true,
          font = "24",
        },
      },
    },
  },
  -- using <leader> z to get available mappings
  {
    "kevinhwang91/nvim-ufo",
    event = "BufReadPost",
    opts = {},
    init = function(_)
      vim.o.foldlevel = 999
    end,
    dependencies = {
      "kevinhwang91/promise-async",
      "neovim/nvim-lspconfig",
    },
  },
  { "IndianBoy42/tree-sitter-just" },
  {
    "Exafunction/codeium.vim",
    event = "BufReadPost",
    enabled = false,
    build = ":Codeium Auth",
    config = function()
      vim.g.codeium_disable_bindings = 1
      vim.keymap.set("i", "<A-CR>", function() return vim.fn["codeium#Accept"]() end, { expr = true, desc = "Codeium Accept Suggestion" })
      vim.keymap.set("i", "<C-[>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true, desc = "Codeium Next Suggestion" })
      vim.keymap.set("i", "<C-]>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true, desc = "Codeium Previous Suggestion" })
      vim.keymap.set("i", "<Esc>", function() return vim.fn["codeium#Clear"]() end, { expr = true, desc = "Codeium Clear Suggestion" })
    end,
  },
  {
    "piersolenski/wtf.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {},
    config = function(_, opts)
      require("wtf").setup(opts)
    end,
    keys = {
      { "<leader>sd", function() require("wtf").ai() end, desc = "Search Diagnostic with AI", mode = "n", },
      { "<leader>sD", function() require("wtf").search() end, desc = "Search Diagnostic with Google", mode = "n", },
    },
  },
  {
    'chipsenkbeil/distant.nvim',
    branch = 'v0.3',
    config = function()
        require('distant'):setup()
    end
  }
}
