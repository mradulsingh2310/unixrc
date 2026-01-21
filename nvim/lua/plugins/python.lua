-- Python Development Configuration
-- Ruff (linting/formatting) + ty (type checking) + venv detection

-- Find project venv
local function find_venv()
  local cwd = vim.fn.getcwd()
  local venv_names = { ".venv", "venv", ".env", "env" }

  for _, name in ipairs(venv_names) do
    local python = cwd .. "/" .. name .. "/bin/python"
    if vim.fn.filereadable(python) == 1 then
      return { path = cwd .. "/" .. name, python = python }
    end
  end

  -- Check VIRTUAL_ENV env var
  local env_venv = vim.env.VIRTUAL_ENV
  if env_venv and vim.fn.isdirectory(env_venv) == 1 then
    return { path = env_venv, python = env_venv .. "/bin/python" }
  end

  return nil
end

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

      -- Add ty to servers with venv detection
      local venv = find_venv()
      opts.servers = opts.servers or {}
      opts.servers.ty = {
        settings = {
          ty = venv and { pythonEnvironment = venv.path } or {},
        },
      }

      -- Update ruff with venv interpreter
      if venv and opts.servers.ruff then
        opts.servers.ruff.init_options = opts.servers.ruff.init_options or {}
        opts.servers.ruff.init_options.settings = opts.servers.ruff.init_options.settings or {}
        opts.servers.ruff.init_options.settings.interpreter = { venv.python }
      end

      return opts
    end,
  },

  -- Disable Ruff hover (ty handles it)
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        end,
      })
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
