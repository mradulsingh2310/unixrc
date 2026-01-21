-- Python Development Configuration
-- Ruff (linting/formatting) + ty (type checking)

return {
  -- Disable basedpyright/pyright from LazyVim's Python extra
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = { enabled = false },
        pyright = { enabled = false },
        ruff = {
          init_options = {
            settings = {
              lineLength = 100,
            },
          },
        },
      },
    },
  },

  -- Configure ty manually (not in lspconfig yet)
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")

      -- Register ty if not already registered
      if not configs.ty then
        configs.ty = {
          default_config = {
            cmd = { "ty", "server" },
            filetypes = { "python" },
            root_dir = lspconfig.util.root_pattern(
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              ".git"
            ),
            single_file_support = true,
            settings = {},
          },
        }
      end

      -- Add ty to servers
      opts.servers = opts.servers or {}
      opts.servers.ty = {}

      return opts
    end,
  },

  -- Conform for formatting (uses Ruff)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
      },
    },
  },
}
