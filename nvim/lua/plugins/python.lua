-- Python Development Configuration
-- Ruff (native LSP) + ty (type checker) + venv detection

return {
  -- Configure LSP servers for Python
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Ruff native language server (replaces ruff-lsp)
        -- Handles linting and formatting
        ruff = {
          init_options = {
            settings = {
              lineLength = 100,
              -- Use project's pyproject.toml/ruff.toml if present
            },
          },
        },

        -- ty - Astral's fast type checker
        ty = {
          settings = {
            ty = {
              -- ty settings go here
            },
          },
        },

        -- Disable basedpyright/pyright hover in favor of ty
        -- Keep pyright for now as ty is still maturing
        basedpyright = {
          settings = {
            basedpyright = {
              disableOrganizeImports = true, -- Let Ruff handle imports
            },
            python = {
              analysis = {
                -- Let Ruff handle linting
                typeCheckingMode = "off",
              },
            },
          },
        },
      },

      -- Custom setup for servers
      setup = {
        -- Detect and use project virtual environment
        ruff = function(_, opts)
          local lspconfig = require("lspconfig")
          local venv_path = vim.fn.getcwd() .. "/.venv/bin/python"
          local uv_venv = vim.fn.getcwd() .. "/.venv/bin/python"

          -- Check for common venv locations
          if vim.fn.filereadable(venv_path) == 1 then
            opts.init_options = opts.init_options or {}
            opts.init_options.settings = opts.init_options.settings or {}
            opts.init_options.settings.interpreter = { venv_path }
          elseif vim.fn.filereadable(uv_venv) == 1 then
            opts.init_options = opts.init_options or {}
            opts.init_options.settings = opts.init_options.settings or {}
            opts.init_options.settings.interpreter = { uv_venv }
          end

          lspconfig.ruff.setup(opts)
          return true
        end,

        -- Configure ty with venv detection
        ty = function(_, opts)
          local lspconfig = require("lspconfig")
          local venv_path = vim.fn.getcwd() .. "/.venv"

          if vim.fn.isdirectory(venv_path) == 1 then
            opts.settings = opts.settings or {}
            opts.settings.ty = opts.settings.ty or {}
            opts.settings.ty.pythonEnvironment = venv_path
          end

          lspconfig.ty.setup(opts)
          return true
        end,

        -- Configure basedpyright with venv
        basedpyright = function(_, opts)
          local lspconfig = require("lspconfig")
          local venv_path = vim.fn.getcwd() .. "/.venv"

          if vim.fn.isdirectory(venv_path) == 1 then
            opts.settings = opts.settings or {}
            opts.settings.python = opts.settings.python or {}
            opts.settings.python.venvPath = vim.fn.getcwd()
            opts.settings.python.pythonPath = venv_path .. "/bin/python"
          end

          lspconfig.basedpyright.setup(opts)
          return true
        end,
      },
    },
  },

  -- Disable Ruff's hover in favor of ty/pyright
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local on_attach = opts.on_attach
      opts.on_attach = function(client, bufnr)
        if client.name == "ruff" then
          -- Disable hover - let ty or pyright handle it
          client.server_capabilities.hoverProvider = false
        end
        if on_attach then
          on_attach(client, bufnr)
        end
      end
    end,
  },

  -- Mason - ensure tools are installed
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "ruff",
      },
    },
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

  -- Treesitter for Python
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "python",
      })
    end,
  },
}
