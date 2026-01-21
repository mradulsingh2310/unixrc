-- Python Development Configuration
-- Ruff (native LSP) + ty (type checker) + venv detection

-- Utility: Find Python virtual environment
local function find_venv()
  local cwd = vim.fn.getcwd()

  -- Common venv directory names to check
  local venv_names = { ".venv", "venv", ".env", "env" }

  for _, name in ipairs(venv_names) do
    local venv_path = cwd .. "/" .. name
    if vim.fn.isdirectory(venv_path) == 1 then
      local python_path = venv_path .. "/bin/python"
      if vim.fn.filereadable(python_path) == 1 then
        return {
          path = venv_path,
          python = python_path,
        }
      end
    end
  end

  -- Check for Poetry virtualenv
  local poetry_venv = vim.fn.trim(vim.fn.system("cd " .. cwd .. " && poetry env info -p 2>/dev/null"))
  if vim.v.shell_error == 0 and poetry_venv ~= "" then
    return {
      path = poetry_venv,
      python = poetry_venv .. "/bin/python",
    }
  end

  -- Check VIRTUAL_ENV environment variable
  local env_venv = vim.env.VIRTUAL_ENV
  if env_venv and vim.fn.isdirectory(env_venv) == 1 then
    return {
      path = env_venv,
      python = env_venv .. "/bin/python",
    }
  end

  return nil
end

-- Make find_venv available globally for other plugins
_G.find_python_venv = find_venv

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

        -- ty - Astral's fast type checker (from Astral, makers of Ruff)
        ty = {
          -- ty is installed via: uv tool install ty OR pipx install ty
          cmd = { "ty", "server" },
          filetypes = { "python" },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              ".git"
            )(fname) or vim.fn.getcwd()
          end,
          settings = {
            ty = {},
          },
        },

        -- Disable basedpyright type checking - let ty handle it
        basedpyright = {
          settings = {
            basedpyright = {
              disableOrganizeImports = true, -- Let Ruff handle imports
            },
            python = {
              analysis = {
                -- Disable type checking - ty handles it
                typeCheckingMode = "off",
                -- Still useful for go-to-definition, hover docs
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
      },

      -- Custom setup for servers
      setup = {
        -- Detect and use project virtual environment for Ruff
        ruff = function(_, opts)
          local lspconfig = require("lspconfig")
          local venv = find_venv()

          if venv then
            opts.init_options = opts.init_options or {}
            opts.init_options.settings = opts.init_options.settings or {}
            opts.init_options.settings.interpreter = { venv.python }
          end

          lspconfig.ruff.setup(opts)
          return true
        end,

        -- Configure ty with venv detection
        ty = function(_, opts)
          local lspconfig = require("lspconfig")
          local venv = find_venv()

          if venv then
            opts.settings = opts.settings or {}
            opts.settings.ty = opts.settings.ty or {}
            opts.settings.ty.pythonEnvironment = venv.path
          end

          lspconfig.ty.setup(opts)
          return true
        end,

        -- Configure basedpyright with venv
        basedpyright = function(_, opts)
          local lspconfig = require("lspconfig")
          local venv = find_venv()

          if venv then
            opts.settings = opts.settings or {}
            opts.settings.python = opts.settings.python or {}
            opts.settings.python.venvPath = vim.fn.fnamemodify(venv.path, ":h")
            opts.settings.python.pythonPath = venv.python
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
