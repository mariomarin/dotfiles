-- Configure LSP servers for dotfiles development
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Nix LSP
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = {
                command = { "nixpkgs-fmt" },
              },
            },
          },
        },
        -- Lua LSP (already configured by LazyVim)
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        -- Bash LSP
        bashls = {
          filetypes = { "sh", "bash", "zsh" },
        },
        -- JSON LSP
        jsonls = {
          -- Use biome for formatting instead of built-in formatter
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
        -- YAML LSP
        yamlls = {
          settings = {
            yaml = {
              format = {
                enable = false, -- Use yamlfmt instead
              },
            },
          },
        },
      },
    },
  },
}
